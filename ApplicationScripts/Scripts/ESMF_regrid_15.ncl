;======================================================================
; ESMF_regrid_15.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF software
;   - Interpolating swath data to a 0.25 degree grid
;======================================================================
;
; This example is identical to ESMF_15.ncl, except it does the
; regridding in one call to ESMF_regrid.
;
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
    srcFileName = "MOD06_L2.A2010031.1430.005.2010031221343.hdf.he2"
    sfile         = addfile(srcFileName,"r")      ; source grid
    cldfrac       = sfile->Cloud_Fraction_mod06
    cldfrac@lat2d = sfile->Latitude_mod06
    cldfrac@lon2d = sfile->Longitude_mod06

    minlon = min(cldfrac@lon2d)                   ; ssign map zoom region
    maxlon = max(cldfrac@lon2d)
    minlat = min(cldfrac@lat2d)
    maxlat = max(cldfrac@lat2d)

    ;;print("min/max cldfrac = " + min(cldfrac) + "/" + max(cldfrac))
    ;;print("min/max lat2d = " + minlat + "/" + maxlat)
    ;;print("min/max lon2d = " + minlon + "/" + maxlon)

    Opt                 =  True                ; Regridding options

    Opt@SrcFileName     = "SrcSCRIP.nc"        ; Output files
    Opt@DstFileName     = "DstSCRIP.nc"
    Opt@ForceOverwrite  = True

    Opt@SrcTitle        = srcFileName          ; Optional, but good idea

    Opt@DstGridType     = "0.25deg"            ; Destination grid
    Opt@DstLLCorner     = (/minlat,minlon/)
    Opt@DstURCorner     = (/maxlat,maxlon/)

    Opt@SrcRegional     = True
    Opt@DstRegional     = True

    ;;Opt@Debug        = True
    ;;Opt@PrintTimings = True

;---Regrid using bilinear
    Opt@InterpMethod  = "bilinear"
    Opt@WgtFileName   = "Swath_2_Rect_bilinear.nc"

    cldfrac_regrid_b  = ESMF_regrid(cldfrac,Opt)
    printVarSummary(cldfrac_regrid_b)

    Opt@SkipDstGrid  = True        ; Don't need to generate the source
    Opt@SkipSrcGrid  = True        ; and destination grids again.

;---Regrid using patch
    Opt@InterpMethod = "patch"
    Opt@WgtFileName  = "Swath_2_Rect_patch.nc"
    cldfrac_regrid_p = ESMF_regrid(cldfrac,Opt)
    printVarSummary(cldfrac_regrid_p)

;---Regrid using conserve
    Opt@InterpMethod = "conserve"
    Opt@WgtFileName  = "Swath_2_Rect_conserve.nc"
    cldfrac_regrid_c = ESMF_regrid(cldfrac,Opt)
    printVarSummary(cldfrac_regrid_c)

;----------------------------------------------------------------------
; Plotting
;----------------------------------------------------------------------
    wks = gsn_open_wks("png","ESMF_regrid")    ; send graphics to PNG file

    colors = (/ "white"         \        ; cloudy
              ,"azure"         \        ; uncertain
              ,"cadetblue"     \        ; probably clear
              ,"blue4"         /)       ; clear

    res                       = True

    res@gsnMaximize           = True           ; make plot large 

    res@gsnDraw               = False
    res@gsnFrame              = False

    res@mpProjection          = "Satellite"   ; choose map projection

    res@mpDataBaseVersion     = "MediumRes"
    res@mpDataSetName         = "Earth..4"
    res@mpFillOn              = False
    res@mpOutlineOn           = True
    res@mpOutlineBoundarySets = "AllBoundaries"

    res@mpLimitMode           = "LatLon"           ; required
    res@mpMinLatF             = minlat-1
    res@mpMaxLatF             = maxlat+1
    res@mpMinLonF             = minlon-1
    res@mpMaxLonF             = maxlon+1
    res@mpCenterLonF          = (minlon + maxlon)*0.5
    res@mpCenterLatF          = (minlat + maxlat)*0.5

    res@cnLinesOn             = False
    res@cnFillMode            = "RasterFill"
    res@cnLineLabelsOn        = False
    res@cnFillOn              = True
    res@cnFillPalette         = colors             ; set color map

    res@cnLevelSelectionMode  = "ManualLevels"     ; set manual contour levels
    res@cnMinLevelValF        = 10                ; min contour level
    res@cnMaxLevelValF        = 100                ; max contour level
    res@cnLevelSpacingF       =  10                ; contour spacing

    res@trGridType            = "TriangularMesh"   ; faster graphic rendering

    res@pmTickMarkDisplayMode = "Always"

    res@gsnAddCyclic          = False   ; don't add cyclic longitude point

    res@tiMainFontHeightF     = 0.02

    res@lbLabelBarOn          = False   ; turn off labelbar, we will add
                                        ; later in panel plot.
    res@gsnRightString        = ""      ; clean up plot labels

;---Create plot of original data
    dims = dimsizes(cldfrac)
    res@tiMainString = "Original data (" + \
                       str_join(tostring(dims)," x ") + ")"
    plot = gsn_csm_contour_map(wks,cldfrac,res)     

;---Create plots of regridded data
    dims = dimsizes(cldfrac_regrid_b)
    res@tiMainString = "Regridded to 0.25 degree grid (bilinear) (" + \
                       str_join(tostring(dims)," x ") + ")"
    plot_regrid_b = gsn_csm_contour_map(wks,cldfrac_regrid_b,res)     

    res@tiMainString = "Regridded to 0.25 degree grid (patch) (" + \
                       str_join(tostring(dims)," x ") + ")"
    plot_regrid_p = gsn_csm_contour_map(wks,cldfrac_regrid_p,res)     

    res@tiMainString = "Regridded to 0.25 degree grid (conserve) (" + \
                       str_join(tostring(dims)," x ") + ")"
    plot_regrid_c = gsn_csm_contour_map(wks,cldfrac_regrid_c,res)     

;---Panel three plots
    pres                     = True
    pres@gsnMaximize         = True    ; The default for PS/PDF
    pres@gsnPanelLabelBar    = True
    pres@lbTitleString       = "percent"        ; title
    pres@lbTitlePosition     = "Bottom"         ; location of title
    pres@lbLabelFontHeightF  = 0.01
    pres@lbTitleFontHeightF  = 0.01

    gsn_panel(wks,(/plot,plot_regrid_b/),(/2,1/),pres)
    gsn_panel(wks,(/plot,plot_regrid_p/),(/2,1/),pres)
    gsn_panel(wks,(/plot,plot_regrid_c/),(/2,1/),pres)
end
