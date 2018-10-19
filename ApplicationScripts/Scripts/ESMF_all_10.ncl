;======================================================================
; ESMF_all_10.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF software
;   - Interpolating data from an MPAS grid to 0.25 degree grid
;======================================================================
; This example is identical to ESMF_regrid_10.ncl, except it does the
; regridding in separate steps.  See ESMF_wgts_10.ncl for a faster 
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
;---Input file
    srcFileName = "MPAS.nc"

;---Output (and input) files
    srcGridName = "MPAS_ESMF.nc"
    dstGridName = "World_0.25deg_SCRIP.nc"
    wgtFile     = "MPAS_2_World.nc"

;---Set to True if you want to skip any of these steps
    SKIP_ESMF_GEN  = False
    SKIP_SCRIP_GEN = False
    SKIP_WGT_GEN   = False
    
;----------------------------------------------------------------------
; Convert MPAS to unstructured ESMF file.
;----------------------------------------------------------------------

;---Retrieve cell centers
    sfile   = addfile(srcFileName,"r")
    lonCell = sfile->lonCell
    latCell = sfile->latCell

;---Convert to degrees from radians
    r2d     = 180.0d/(atan(1)*4.0d)  ; Radian to Degree
    lonCell = lonCell*r2d
    latCell = latCell*r2d

    if(.not.SKIP_ESMF_GEN) then
;---Set some Options
      Opt                = True
      Opt@ForceOverwrite = True
      Opt@PrintTimings   = True
      Opt@InputFileName  = srcFileName
      Opt@Debug          = True

      unstructured_to_ESMF(srcGridName,latCell,lonCell,Opt)

;---Clean up
      delete(Opt)
    end if

;----------------------------------------------------------------------
; Convert 0.25 degree world grid to SCRIP file
;----------------------------------------------------------------------
    if(.not.SKIP_SCRIP_GEN) then
      Opt                = True
      Opt@LLCorner       = (/-89.75d,   0.00d /)
      Opt@URCorner       = (/ 89.75d, 359.75d /) 
      Opt@ForceOverwrite = True
      Opt@PrintTimings   = True
      Opt@Title          = "World Grid 0.25 degree resolution"
      Opt@Debug          = True

      latlon_to_SCRIP(dstGridName,"0.25deg",Opt)

;---Clean up
      delete(Opt)
    end if

;----------------------------------------------------------------------
; Generate interpolation weights for MPAS Grid to World Grid    
;----------------------------------------------------------------------
    if(.not.SKIP_WGT_GEN) then
      Opt                = True
      Opt@InterpMethod   = "bilinear"
      Opt@SrcESMF        = True    
      Opt@ForceOverwrite = True
      Opt@PrintTimings   = True

      ESMF_regrid_gen_weights(srcGridName, dstGridName, wgtFile, Opt)

;---Clean up
      delete(Opt)
    end if

;----------------------------------------------------------------------
; Interpolate data from MPAS to World grid.
;----------------------------------------------------------------------

;---Read data from MPAS Grid
    sp = sfile->surface_pressure(0,:)
    sp = sp/1000.   ; Not sure what the pressure units are, there's
                    ; not much metadata info on this file

    Opt                = True
    Opt@Debug          = True
    Opt@PrintTimings   = True
    Opt@Debug          = True

    sp_regrid = ESMF_regrid_with_weights(sp,wgtFile,Opt)

;---Assign coordinate arrays.
    lat2d = retrieve_dstGrid_lat(wgtFile)
    lon2d = retrieve_dstGrid_lon(wgtFile)
    lat1d = lat2d(:,0)
    lon1d = lon2d(0,:)
    lat1d@units = "degrees_north"
    lon1d@units = "degrees_east"

;---Don't need these anymore
    delete(lat2d)
    delete(lon2d)

    copy_VarAtts(sp,sp_regrid)
    sp_regrid!0   = "lat"
    sp_regrid!1   = "lon"
    sp_regrid&lat = lat1d
    sp_regrid&lon = lon1d

;----------------------------------------------------------------------
; Plotting section
;----------------------------------------------------------------------
    wks = gsn_open_wks("png","ESMF_all")        ; send graphics to PNG file

;---Resources to share between both plots
    res                     = True              ; Plot modes desired.

    res@gsnDraw             = False
    res@gsnFrame            = False

    res@gsnMaximize         = True              ; Maximize plot

    res@cnFillOn            = True              ; color plot desired
    res@cnFillPalette       = "rainbow"         ; set color map
    res@cnLinesOn           = False             ; turn off contour lines
    res@cnLineLabelsOn      = False             ; turn off contour labels
    res@cnFillMode          = "RasterFill"      ; turn raster on      

    res@cnLevelSelectionMode = "ManualLevels"
    res@cnMinLevelValF       =  55
    res@cnMaxLevelValF       = 100
    res@cnLevelSpacingF      =   2.5

    res@lbLabelBarOn        = False    ; Will turn on in panel later.

    res@mpFillOn            = False

    res@trGridType         = "TriangularMesh"  ; allow missing coordinates
    res@gsnAddCyclic       = False

;---Resources for plotting regridded data
    res@gsnAddCyclic       = False

    dims = tostring(dimsizes(sp_regrid))
    res@tiMainString          = "Data regridded to 0.25 degree grid (" + \
                                str_join(dims," x ") + ")"

    plot_regrid = gsn_csm_contour_map(wks,sp_regrid,res)

    res@sfXArray           = lonCell
    res@sfYArray           = latCell
    res@gsnAddCyclic       = False

    res@tiMainString       = "Original MPAS grid (" + dimsizes(sp) + " cells)"

    plot_orig = gsn_csm_contour_map(wks,sp,res)  

;---Compare the plots in a panel
    pres                   = True
    pres@gsnMaximize       = True
    pres@gsnPanelLabelBar  = True

    gsn_panel(wks,(/plot_orig,plot_regrid/),(/2,1/),pres)
end
