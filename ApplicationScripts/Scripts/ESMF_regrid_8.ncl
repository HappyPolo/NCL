;======================================================================
; ESMF_regrid_8.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF_regrid
;   - Interpolating swath data to a rectilinear grid read off a file
;======================================================================
; This example is identical to ESMF_all_8.ncl, except it does the
; regridding in one call to "ESMF_regrid".  See ESMF_wgts_8.ncl
; for a faster example of regridding using an existing weights file.
;======================================================================
; This example uses the ESMF application "ESMF_RegridWeightGen" to 
; generate the weights.
;
; For more information about ESMF:
;
;        http://www.earthsystemmodeling.org/
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
;---Read data off source file
    srcFileName = "AusSnow_Source.nc"                  ; source grid
    sfile       = addfile(srcFileName,"r")
    madis       = sfile->masked_madiS
    madis@lat2d = sfile->lat2d
    madis@lon2d = sfile->lon2d

;---0 is treated as a missing value, so fix this
    madis = where(madis.eq.0, madis@_FillValue, madis)

;---Assign zoom region
    minlon = min(madis@lon2d)
    maxlon = max(madis@lon2d)
    minlat = min(madis@lat2d)
    maxlat = max(madis@lat2d)

    ;;print("min/max madis = " + min(madis) + "/" + max(madis))
    ;;print("min/max lat2d = " + minlat + "/" + maxlat)
    ;;print("min/max lon2d = " + minlon + "/" + maxlon)

;---Read data off destination file
    dfile = addfile("AusSnow_Dest.nc","r")
    lat   = dfile->lat    ; Need these for coordinate arrays
    lon   = dfile->lon    ; for regridding

;---Options for regridding
    Opt                 = True

    Opt@SrcFileName     = "AusSnow_src_SCRIP.nc"
    Opt@DstFileName     = "AusSnow_dst_SCRIP.nc"
    Opt@ForceOverwrite  = True

    Opt@SrcTitle        = srcFileName                  ; source grid
    Opt@SrcMask2D       = where(ismissing(madis),0,1)
    Opt@SrcRegional     = True

    Opt@DstTitle        = "Australia Rectilinear Grid" ; destination grid
    Opt@DstGridLat      = lat
    Opt@DstGridLon      = lon
    Opt@DstRegional     = True

    ;;Opt@PrintTimings  = True

    Opt@InterpMethod = "bilinear"            ; bilinear interpolation 
    Opt@WgtFileName  = "AUS_Swath_2_Rect_bilinear.nc"
    madis_regrid_b   = ESMF_regrid(madis,Opt)

    Opt@InterpMethod = "patch"               ; patch interpolation 
    Opt@WgtFileName  = "AUS_Swath_2_Rect_patch.nc"
    madis_regrid_p   = ESMF_regrid(madis,Opt)

    Opt@InterpMethod = "conserve"            ;  interpolation 
    Opt@WgtFileName  = "AUS_Swath_2_Rect_conserve.nc"
    madis_regrid_c   = ESMF_regrid(madis,Opt)

;----------------------------------------------------------------------
; Plotting section
;----------------------------------------------------------------------

    wks = gsn_open_wks("png","ESMF_regrid")        ; send graphics to PNG file

    res                       = True               ; Plot mods desired.

    res@gsnMaximize           = True

    res@gsnDraw               = False
    res@gsnFrame              = False

    res@mpDataBaseVersion     = "MediumRes"
    res@mpDataSetName         = "Earth..4"
    res@mpFillOn              = False
    res@mpOutlineOn           = True
    res@mpOutlineBoundarySets = "AllBoundaries"

    res@mpCenterLonF          = 148.5
    res@mpMinLatF             = min(madis@lat2d)
    res@mpMaxLatF             = max(madis@lat2d)
    res@mpMinLonF             = min(madis@lon2d)
    res@mpMaxLonF             = max(madis@lon2d)

    res@cnLinesOn             = False
    res@cnFillMode            = "RasterFill"
    res@cnLineLabelsOn        = False
    res@cnFillOn              = True
    res@cnFillPalette         = "BlAqGrYeOrRe"  ; set color map

    res@cnLevelSelectionMode  = "ExplicitLevels"
    res@cnLevels              = ispan(10,75,5)

    res@pmTickMarkDisplayMode = "Always"

    res@gsnAddCyclic          = False   ; don't add cyclic longitude point

    res@tiMainFontHeightF     = 0.02
 
    res@lbLabelBarOn          = False

    res@tiMainString          = "Original data (" + \
                                  str_join(tostring(dimsizes(madis))," x ") + ")"
    plot = gsn_csm_contour_map_ce(wks,madis,res)     

;---bilinear
    res@tiMainString = "Regridded data (bilinear) (" + \
                       str_join(tostring(dimsizes(madis_regrid_b))," x ") + ")"

    plot_b = gsn_csm_contour_map_ce(wks,madis_regrid_b,res)     

;---patch
    res@tiMainString = "Regridded data (patch) (" + \
                       str_join(tostring(dimsizes(madis_regrid_p))," x ") + ")"

    plot_p = gsn_csm_contour_map_ce(wks,madis_regrid_p,res)     

;---conserve
    res@tiMainString = "Regridded data (conserve) (" + \
                       str_join(tostring(dimsizes(madis_regrid_c))," x ") + ")"

    plot_c = gsn_csm_contour_map_ce(wks,madis_regrid_c,res)     

;---Panel all four plots
    pres                    = True
    pres@gsnPanelLabelBar   = True
    pres@pmLabelBarWidthF   = 0.8
    pres@lbLabelFontHeightF = 0.01

    gsn_panel(wks,(/plot,plot_b,plot_p,plot_c/),(/2,2/),pres)
end
