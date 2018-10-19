;======================================================================
; ESMF_all_14.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF software
;   - Interpolating data from an ICON grid to a 5 degree grid
;======================================================================
; This example is identical to ESMF_regrid_14.ncl, except it does the
; regridding in separate steps.  See ESMF_wgts_14.ncl for a faster 
; example of regridding using an existing weights file.
;======================================================================
; This example uses the ESMF application "ESMF_RegridWeightGen" to 
; generate the weights.
;
; For more information about ESMF:
;
;        http://www.earthsystemmodeling.org/
;
; This script uses built-in functions that are only available in 
; NCL V6.1.0 and later.
;======================================================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin
;---Input files
    srcFileName = "MRWB4N5_DOM01_R2B04L31_0001.nc"

;---Output (and input) files
    srcGridName = "ICON_ESMF.nc"
    dstGridName = "5deg_SCRIP.nc"
    wgtFile     = "ICON_2_5deg.nc"

;---Set to True if you want to skip any of these steps
    SKIP_ESMF_GEN  = False
    SKIP_SCRIP_GEN = False
    SKIP_WGT_GEN   = False

;----------------------------------------------------------------------
; Step 1 part 1
;   Convert source icon grid to an ESMF File.
;----------------------------------------------------------------------
    sfile   = addfile(srcFileName,"r")
    rad2deg = get_r2d("float")                ; radians to degrees
    scale   = 1e6
    div     = sfile->DIV(1,0,:)   ; dims: (time,lev,cell)
    div     = div*scale
    lon1d   = sfile->clon *rad2deg   ; cell center, lon
    lat1d   = sfile->clat *rad2deg   ; cell center, lat
;
; Add code here to use clat_vertices/clon_vertices instead of
; calling csstri inside unstructured_to_ESMF.
;
    if(.not.SKIP_ESMF_GEN) then
      Opt                = True
      Opt@ForceOverwrite = True
      Opt@PrintTimings   = True

      unstructured_to_ESMF(srcGridName,lat1d,lon1d,Opt)

;---Clean up
      delete(Opt)
    end if
    
;----------------------------------------------------------------------
; Step 1 part 2
;   Converting destination 5 deg grid to a SCRIP File.
;----------------------------------------------------------------------
    if(.not.SKIP_SCRIP_GEN) then
      Opt                = True
      Opt@ForceOverwrite = True
      Opt@PrintTimings   = True

      latlon_to_SCRIP(dstGridName,"5deg",Opt)
;      latlon_to_SCRIP(dstGridName,"G64",Opt)

;---Clean up
      delete(Opt)
    end if

;----------------------------------------------------------------------
; Step 2
;    Generate weights
;----------------------------------------------------------------------
    method = "patch"              ; "conserve" ; "bilinear"
    if(.not.SKIP_WGT_GEN) then
      Opt                      = True
      Opt@InterpMethod         = method
      Opt@SrcESMF              = True
      Opt@ForceOverwrite       = True
      Opt@PrintTimings         = True

      ESMF_regrid_gen_weights(srcGridName, dstGridName, wgtFile, Opt)
    end if

;----------------------------------------------------------------------
; Step 3
;   Interpolate data from Tripolar to MPAS grid.
;----------------------------------------------------------------------
    Opt                = True
    Opt@PrintTimings   = True

    div_regrid = ESMF_regrid_with_weights(div,wgtFile,Opt)

;---Add attributes and coordinate arrays for plotting
    dstlat       = retrieve_SCRIP_lat(dstGridName)
    dstlon       = retrieve_SCRIP_lon(dstGridName)
    dstlat@units = "degrees_north"
    dstlon@units = "degrees_east"

    copy_VarAtts_except(div,div_regrid,"_FillValue")
    div_regrid!0   = "lat"
    div_regrid!1   = "lon"
    div_regrid&lat = dstlat (:,0)    ; This is a rectilinear grid, so
    div_regrid&lon = dstlon (0,:)    ; we only need a 1D sub-selection.

;----------------------------------------------------------------------
; Plotting section
;----------------------------------------------------------------------
    wks = gsn_open_wks("png","ESMF_all")  ; send graphics to PNG file

    res                       = True

    res@gsnMaximize           = True

    res@gsnDraw               = False
    res@gsnFrame              = False

    res@cnLevelSelectionMode  = "ManualLevels"
    res@cnMinLevelValF        = -1.0
    res@cnMaxLevelValF        =  1.8
    res@cnLevelSpacingF       =  0.2
     
    res@cnFillOn              = True
    res@cnFillPalette         = "BlAqGrYeOrReVi200"   ; set color map
    res@cnFillMode            = "RasterFill"
    res@cnLinesOn             = False
    res@cnLineLabelsOn        = False

    res@lbLabelBarOn          = False

;---Original grid
    res@sfXArray              = lon1d
    res@sfYArray              = lat1d

    res@tiMainString = "Original ICON grid (" + dimsizes(div) + " cells)"

    plot_orig = gsn_csm_contour_map(wks,div,res)  
    delete(res@sfXArray)
    delete(res@sfYArray)

;---Regridded data
    res@gsnAddCyclic = False
    dims = tostring(dimsizes(div_regrid))
    res@tiMainString = "Regridded to 5 degree grid (" + \
                       str_join(dims,",") + ") (" + method + ")"

    plot_regrid = gsn_csm_contour_map(wks,div_regrid,res)  

;---Compare the plots in a panel
    pres                   = True
    pres@gsnMaximize       = True
    pres@gsnPanelLabelBar  = True

    gsn_panel(wks,(/plot_orig,plot_regrid/),(/2,1/),pres)
end

