;======================================================================
; ESMF_all_patch_12.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF software
;   - Interpolating data from a curvilinear tripolar grid to an MPAS grid
;======================================================================
; This example is identical to ESMF_regrid_12.ncl, except it does the
; regridding in separate steps.  See ESMF_wgts_12.ncl for a faster 
; example of regridding using an existing weights file. See 
; ESMF_all_conserve_12.ncl for an example of using the "conserve"
; interpolation method.
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
    srcFileName = "Tripolar.nc" 
    dstFileName = "MPAS.nc"

;---Interpolation method to use
    interpMethod = "patch"

;---Output (and, eventually, input) files
    srcGridName = "Tripolar_SCRIP.nc"
    dstGridName = "MPAS_ESMF.nc"
    wgtFile     = "Tripolar_2_MPAS_" + interpMethod + ".nc"

;---Set to True if you want to skip any of these steps
    SKIP_TRI_SCRIP_GEN  = False
    SKIP_MPAS_ESMF_GEN  = False
    SKIP_WGT_GEN        = False

;----------------------------------------------------------------------
; Step 1 part 1
;   Convert source tripolar grid to a SCRIP File.
;----------------------------------------------------------------------
    sfile = addfile(srcFileName,"r")
    lat2d = sfile->TLAT
    lon2d = sfile->TLON
    if(.not.SKIP_TRI_SCRIP_GEN) then
      Opt                = True
      Opt@ForceOverwrite = True
      Opt@PrintTimings   = True
      Opt@Title          = "A curvilinear Tripolar grid."
      Opt@Mask2D         = tointeger( sfile->tmask )

      curvilinear_to_SCRIP(srcGridName,lat2d,lon2d,Opt)

;---Clean up
      delete(Opt)
    end if
    
;----------------------------------------------------------------------
; Step 1 part 2
;   Converting destination MPAS grid to an unstructured ESMF File.
;----------------------------------------------------------------------
    dfile = addfile(dstFileName,"r")

;---Read in lat/lon cell centers and convert to degrees from radians
    r2d     = 180.0d/(atan(1)*4.0d)
    lonCell = dfile->lonCell
    latCell = dfile->latCell
    lonCell = lonCell*r2d
    latCell = latCell*r2d

    if(.not.SKIP_MPAS_ESMF_GEN) then
      Opt                = True
      Opt@ForceOverwrite = True
      Opt@PrintTimings   = True
      Opt@InputFileName  = dstFileName

      print("Converting MPAS to Unstructured ESMF convention file ...")
      unstructured_to_ESMF(dstGridName,latCell,lonCell,Opt)

;---Clean up
      delete(Opt)
    end if

;----------------------------------------------------------------------
; Step 2
;    Generate weights
;----------------------------------------------------------------------
    if(.not.SKIP_WGT_GEN) then
      Opt                      = True
      Opt@InterpMethod         = interpMethod
      Opt@DstESMF              = True
      Opt@ForceOverwrite       = True
      Opt@PrintTimings         = True

      print("Generating interpolation weights from Tripolar to MPAS grid ...")
      ESMF_regrid_gen_weights(srcGridName, dstGridName, wgtFile, Opt)
    end if

;----------------------------------------------------------------------
; Step 3
;   Interpolate data from Tripolar to MPAS grid.
;----------------------------------------------------------------------
    sst = rm_single_dims( sfile->sst )

    Opt                = True
    Opt@PrintTimings   = True
;   Opt@Debug          = True

    sst_regrid = ESMF_regrid_with_weights(sst,wgtFile,Opt)
    
;---Fix the 0.0 values.
    sst_regrid@_FillValue = default_fillvalue(typeof(sst_regrid))
    sst_regrid = where(sst_regrid.eq.0,sst_regrid@_FillValue,sst_regrid)

;----------------------------------------------------------------------
; Plotting section
;----------------------------------------------------------------------
    sst@lat2d = lat2d
    sst@lon2d = lon2d

    wks = gsn_open_wks("png","ESMF_all_"+interpMethod)  ; send graphics to PNG file
    gsn_define_colormap(wks,"rainbow")             ; Change color map

    res                       = True

    res@gsnMaximize           = True

    res@gsnDraw               = False
    res@gsnFrame              = False

    res@cnLevelSelectionMode  = "ManualLevels"
    res@cnMinLevelValF        = 272
    res@cnMaxLevelValF        = 302
    res@cnLevelSpacingF       =   2
     
    res@cnFillOn              = True
    res@cnFillPalette         = "rainbow"        ; set color map
    res@cnFillMode            = "RasterFill"
    res@cnLinesOn             = False
    res@cnLineLabelsOn        = False

    res@lbLabelBarOn          = False

    res@mpMinLatF             = min(latCell)
    res@mpMaxLatF             = max(latCell)
    res@mpMinLonF             = min(lonCell)
    res@mpMaxLonF             = max(lonCell)
    res@mpCenterLonF          = (min(lonCell)+max(lonCell))*0.5

;---Original grid
    res@gsnAddCyclic = True

    dims = tostring(dimsizes(lat2d))
    res@tiMainString = "Original tripolar grid (" + str_join(dims," x ") + ")"

    plot_orig = gsn_csm_contour_map(wks,sst,res)  

;---Regridded data
    res@gsnAddCyclic = False
    res@sfXArray     = sst_regrid@lon1d
    res@sfYArray     = sst_regrid@lat1d
    res@tiMainString = "Regridded to MPAS grid using '" + interpMethod + \
                       "' (" + dimsizes(sst_regrid) + " cells)" 

    plot_regrid = gsn_csm_contour_map(wks,sst_regrid,res)  

;---Compare the plots in a panel
    pres                   = True
    pres@gsnMaximize       = True
    pres@gsnPanelLabelBar  = True

    gsn_panel(wks,(/plot_orig,plot_regrid/),(/2,1/),pres)
end

