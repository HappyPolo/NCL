;======================================================================
; ESMF_all_8.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF software
;   - Interpolating swath data to a rectilinear grid read off a file
;======================================================================
; This example is identical to ESMF_regrid_8.ncl, except it does the
; regridding in separate steps.  See ESMF_wgts_8.ncl for a faster 
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
    srcFileName = "AusSnow_Source.nc"
    destFile    = "AusSnow_Dest.nc"

;---Output (and input) files
    srcGridName = "AusSnow_src_SCRIP.nc"
    dstGridName = "AusSnow_dst_SCRIP.nc"
    wgtFile_b   = "AUS_Swath_2_Rect_bilinear.nc"
    wgtFile_p   = "AUS_Swath_2_Rect_patch.nc"
    wgtFile_c   = "AUS_Swath_2_Rect_conserve.nc"

;---Set to True if you want to skip any of these steps
    SKIP_SRC_SCRIP_GEN = False
    SKIP_DST_SCRIP_GEN = False
    SKIP_WGT_GEN       = False

;----------------------------------------------------------------------
; Step 1, part 1
;     Convert swath grid to SCRIP convention file.
;----------------------------------------------------------------------
    sfile   = addfile(srcFileName,"r")
    madis   = sfile->masked_madiS
    lat2d   = sfile->lat2d
    lon2d   = sfile->lon2d

;---0 is treated as a missing value, so fix this
    madis = where(madis.eq.0, madis@_FillValue, madis)

;---Assign zoom region
    minlon = min(lon2d)
    maxlon = max(lon2d)
    minlat = min(lat2d)
    maxlat = max(lat2d)

    print("min/max madis = " + min(madis) + "/" + max(madis))
    print("min/max lat2d = " + minlat + "/" + maxlat)
    print("min/max lon2d = " + minlon + "/" + maxlon)

    if(.not.SKIP_SRC_SCRIP_GEN) then
    
;--- Convert to a SCRIP Convention file.
      Opt                = True
      Opt@ForceOverwrite = True
      Opt@PrintTimings   = True
      Opt@Mask2D         = where(ismissing(madis),0,1)
      Opt@Title          = srcFileName

      curvilinear_to_SCRIP(srcGridName,lat2d,lon2d,Opt)

;---Clean up
      delete(Opt)
   end if

;----------------------------------------------------------------------
; Step 1, part 2
;     Convert destination grid to SCRIP convention file.
;----------------------------------------------------------------------
    dfile = addfile(destFile,"r")
    lat   = dfile->lat    ; Need these for coordinate arrays
    lon   = dfile->lon    ; later.

    if(.not.SKIP_DST_SCRIP_GEN) then
      Opt                = True
      Opt@ForceOverwrite = True
      Opt@PrintTimings   = True
      Opt@Title          = "Australia Rectilinear Grid"

      rectilinear_to_SCRIP(dstGridName,lat,lon,Opt)

;---Clean up
      delete(Opt)
    end if

;----------------------------------------------------------------------
; Step 2
;     Generate the weights using different interpolation methods.
;----------------------------------------------------------------------
    if(.not.SKIP_WGT_GEN) then
      Opt                      = True
      Opt@SrcRegional          = True
      Opt@DstRegional          = True
      Opt@ForceOverwrite       = True
      Opt@PrintTimings         = True
      Opt@Debug                = True

      Opt@InterpMethod = "bilinear"    ; the default
      ESMF_regrid_gen_weights(srcGridName,dstGridName,wgtFile_b,Opt)

      Opt@InterpMethod = "patch"
      ESMF_regrid_gen_weights(srcGridName,dstGridName,wgtFile_p,Opt)

      Opt@InterpMethod = "conserve"
      ESMF_regrid_gen_weights(srcGridName,dstGridName,wgtFile_c,Opt)

;---Clean up
      delete(Opt)
    end if

;----------------------------------------------------------------------
; Step 3
;     Apply the weights to a given variable on the various weight files
;----------------------------------------------------------------------
    opt                = True
    opt@PrintTimings   = True
    opt@Debug          = True

;---bilinear
    madis_regrid_b = ESMF_regrid_with_weights(madis,wgtFile_b,opt)

;---patch
    madis_regrid_p = ESMF_regrid_with_weights(madis,wgtFile_p,opt)

;---conserve
    madis_regrid_c = ESMF_regrid_with_weights(madis,wgtFile_c,opt)

;---Add coordinate arrays and attributes to regridded variables
    copy_VarAtts_except(madis,madis_regrid_b,(/"coordinates","_FillValue"/))
    madis_regrid_b@description = "madiS data regridding using bilinear method"

    madis_regrid_b!0           = "lat"
    madis_regrid_b!1           = "lon"
    madis_regrid_b&lat         = lat
    madis_regrid_b&lon         = lon

;---patch variable
    copy_VarAtts_except(madis,madis_regrid_p,(/"coordinates","_FillValue"/))
    madis_regrid_p@description = "madiS data regridding using patch method"
    madis_regrid_p!0           = "lat"
    madis_regrid_p!1           = "lon"
    madis_regrid_p&lat         = lat
    madis_regrid_p&lon         = lon

;---conserve variable
    copy_VarAtts_except(madis,madis_regrid_c,(/"coordinates","_FillValue"/))
    madis_regrid_c@description = "madiS data regridding using conservative method"
    madis_regrid_c!0           = "lat"
    madis_regrid_c!1           = "lon"
    madis_regrid_c&lat         = lat
    madis_regrid_c&lon         = lon

;----------------------------------------------------------------------
; Plotting section
;----------------------------------------------------------------------

;---Delete the descriptions so they don't get used for titles. 
    delete(madis_regrid_b@description)
    delete(madis_regrid_p@description)
    delete(madis_regrid_c@description)

    wks = gsn_open_wks("png","ESMF_all")          ; send graphics to PNG file

    res                       = True              ; Plot modes desired.

    res@gsnMaximize           = True ; make plot large 

    res@gsnDraw               = False
    res@gsnFrame              = False

    res@mpDataBaseVersion     = "MediumRes"
    res@mpDataSetName         = "Earth..4"
    res@mpFillOn              = False
    res@mpOutlineOn           = True
    res@mpOutlineBoundarySets = "AllBoundaries"

    res@mpCenterLonF          = 148.5
    res@mpMinLatF             = min(lat2d)
    res@mpMaxLatF             = max(lat2d)
    res@mpMinLonF             = min(lon2d)
    res@mpMaxLonF             = max(lon2d)

    res@cnLinesOn             = False
    res@cnFillMode            = "RasterFill"
    res@cnLineLabelsOn        = False
    res@cnFillOn              = True
    res@cnFillPalette         = "BlAqGrYeOrRe"   ; set color map

    res@cnLevelSelectionMode  = "ExplicitLevels"
    res@cnLevels              = ispan(10,75,5)

    res@pmTickMarkDisplayMode = "Always"

    res@gsnAddCyclic          = False   ; don't add cyclic longitude point

    res@tiMainFontHeightF     = 0.02

    res@lbLabelBarOn = False

    res@sfYArray              = lat2d
    res@sfXArray              = lon2d

    res@tiMainString          = "Original data (" + \
                                  str_join(tostring(dimsizes(madis))," x ") + ")"
    plot = gsn_csm_contour_map_ce(wks,madis,res)     

    delete(res@sfYArray)
    delete(res@sfXArray)

    res@tiMainString = "Regridded data (bilinear) (" + \
                       str_join(tostring(dimsizes(madis_regrid_b))," x ") + ")"

    plot_b = gsn_csm_contour_map_ce(wks,madis_regrid_b,res)     

    res@tiMainString = "Regridded data (patch) (" + \
                       str_join(tostring(dimsizes(madis_regrid_p))," x ") + ")"

    plot_p = gsn_csm_contour_map_ce(wks,madis_regrid_p,res)     

    res@tiMainString = "Regridded data (conserve) (" + \
                       str_join(tostring(dimsizes(madis_regrid_c))," x ") + ")"

    plot_c = gsn_csm_contour_map_ce(wks,madis_regrid_c,res)     

;---Panel all three plots
    pres                    = True
    pres@gsnPanelLabelBar   = True
    pres@pmLabelBarWidthF   = 0.8
    pres@lbLabelFontHeightF = 0.01
    gsn_panel(wks,(/plot,plot_b,plot_p,plot_c/),(/2,2/),pres)
end
