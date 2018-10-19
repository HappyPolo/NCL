;----------------------------------------------------------------------
; ESMF_regrid_34.ncl
;
; Concepts illustrated:
;   - Interpolating NARR data to a WRF grid
;----------------------------------------------------------------------
; This example uses the ESMF application "ESMF_RegridWeightGen" to 
; generate the weights.
;
; For more information about ESMF:
;
;        http://www.earthsystemmodeling.org/
;
; This script uses built-in functions that are only available in 
; NCL V6.1.0 and later.
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin
    method = "bilinear"

; ESMF stuff
; ----------------
; NARR source grid

    srcDirName      = "./"
    srcFileName     = "merged_AWIP32.1979010100.3D.NARR.grb"
    srcPathName     = srcDirName+srcFileName
    sfile           = addfile(srcPathName,"r")      ; source grid

    x               = sfile->TMP_221_ISBL(10,:,:)   ; level 10 is arbitrary
    src_lat2d       = sfile->gridlat_221   
    src_lon2d       = sfile->gridlon_221

; ESMF options

    Opt                 =  True                ; Regridding options
    Opt@SrcFileName     = "SrcSCRIP_NARR.nc"   ; Output files
    Opt@ForceOverwrite  =  True
    Opt@SrcTitle        = "NARR Grid"          ; Optional, but good idea

    Opt@SrcRegional     = True   
    Opt@SrcGridLat      = src_lat2d            ; source grid
    Opt@SrcGridLon      = src_lon2d

; WRF destination grid; only want lat/lon

    dstDirName      = "./"
    dstFileName     = "wrfout_d01_000000.nc"
    dstPathName     = dstDirName+dstFileName
    dfile           = addfile(dstPathName,"r")   ; WRF grid (destination)

    dst_lat2d       = dfile->XLAT(0,:,:)
    dst_lon2d       = dfile->XLONG(0,:,:)
    Opt@DstGridLat  = dst_lat2d 
    Opt@DstGridLon  = dst_lon2d
    Opt@DstFileName = "DstSCRIP_WRF.nc"
    Opt@DstRegional = True

;---Regrid using bilinear

    Opt@InterpMethod  = method
    Opt@WgtFileName   = "NARR_2_WRF."+method+".nc"   ; use subsequently

    x_regrid          = ESMF_regrid(x,Opt)
    printVarSummary(x_regrid)

;----------------------------------------------------------------------
; Plotting
;----------------------------------------------------------------------

    dimsrc   = dimsizes(src_lat2d)
    nlat     = dimsrc(0)
    mlon     = dimsrc(1)
                                              ; src => NARR
    minlon   = min(src_lon2d)                 ; minlat=   0.897  
    maxlon   = max(src_lon2d)                 ; maxlat=  85.334
    minlat   = min(src_lat2d)                 ; minlon=-179.998
    maxlat   = max(src_lat2d)                 ; maxlon= 179.992

    x@lat2d  = src_lat2d
    x@lon2d  = src_lon2d

    mpProjection  = "LambertConformal"  ; choose map projection for plots

    wks = gsn_open_wks("png","ESMF_regrid" )   ; send graphics to PNG file

    res                       = True
    res@gsnMaximize           = True           ; make plot large 

    res@gsnDraw               = False
    res@gsnFrame              = False
    res@gsnAddCyclic          = False          ; don't add cyclic longitude point

    res@mpFillOn              = False
    res@mpOutlineOn           = True
    res@mpOutlineBoundarySets = "AllBoundaries"

    res@mpProjection           = mpProjection       
    res@pmTickMarkDisplayMode = "Always"

    res@cnLinesOn             = False
    res@cnFillMode            = "RasterFill"
    res@cnLineLabelsOn        = False
    res@cnFillOn              = True
    res@cnLevelSelectionMode  = "ManualLevels"     ; set manual contour levels
    res@cnMinLevelValF        = 220.              ; min contour level
    res@cnMaxLevelValF        = 258.               ; max contour level
    res@cnLevelSpacingF       =   2                ; contour spacing

    res@trGridType            = "TriangularMesh"   ; faster graphic rendering

    res@lbLabelBarOn          = False   ; turn off labelbar, we will add
    res@tiMainFontHeightF     = 0.02

    res@mpLimitMode            = "Corners"            ; choose range of map
    res@mpDataBaseVersion      = "LowRes"             ; simplify border lines

                               ; NARR
    res@mpLeftCornerLatF       = src_lat2d(0,0)
    res@mpLeftCornerLonF       = src_lon2d(0,0)
    res@mpRightCornerLatF      = src_lat2d(nlat-1,mlon-1)
    res@mpRightCornerLonF      = src_lon2d(nlat-1,mlon-1)
    res@mpLambertParallel1F    = src_lat2d@mpLambertParallel1F
    res@mpLambertParallel2F    = src_lat2d@mpLambertParallel2F
    res@mpLambertMeridianF     = src_lat2d@mpLambertMeridianF
                                        ; later in panel plot.
;---Create plot of original NARR data
    dims = dimsizes(x)
    res@tiMainString = "Original data (" + \
                       str_join(tostring(dims)," x ") + ")"
    plot = gsn_csm_contour_map(wks,x,res)     

;---Create plots of regridded data

    dimdst   = dimsizes(dst_lat2d)
    nlat     = dimdst(0)
    mlon     = dimdst(1)

    res@mpLeftCornerLatF       = dst_lat2d(0,0)
    res@mpLeftCornerLonF       = dst_lon2d(0,0)
    res@mpRightCornerLatF      = dst_lat2d(nlat-1,mlon-1)
    res@mpRightCornerLonF      = dst_lon2d(nlat-1,mlon-1)
    res@mpLambertParallel1F    = dfile@TRUELAT1
    res@mpLambertParallel2F    = dfile@TRUELAT2
    res@mpLambertMeridianF     = dfile@CEN_LON

    res@tiMainString = "Regridded to WRF grid ("+method+") (" + \
                       str_join(tostring(dimdst)," x ") + ")"
    plot_regrid = gsn_csm_contour_map(wks,x_regrid,res)     

;---Panel plots
    pres                     = True
    pres@gsnMaximize         = True    ; The default for PS/PDF
    pres@gsnPanelLabelBar    = True
   ;pres@lbLabelFontHeightF  = 0.01

    gsn_panel(wks,(/plot,plot_regrid/),(/2,1/),pres)
end

