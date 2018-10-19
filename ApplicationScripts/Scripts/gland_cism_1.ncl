;======================================================================
; gland_cism_1.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF_regrid_with_weights
;   - Interpolating from one grid to another using an existing weights file
;======================================================================
; This example is identical to ESMF_regrid_1.ncl, except it assumes
; the weights file already exists, and does regridding using 
; "ESMF_regrid_with_weights".  This is the best method to use if you 
; already have the weights.
;======================================================================
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


    WRITE_RESULTS = True 
    METHOD        = "conserve"    ; bilinear, patch, conserve
    RES           = "0.5deg"      ; 0.5deg, 1.0deg

    wgtDirName    = "./"
    wgtFileName   = "gland_to_Rect_"+METHOD+"."+RES+".nc"
    wgtPathName   = wgtDirName+wgtFileName

;----------------------------------------------------------------------
; Read lat2d/lon2d from gland5.input.nc
;----------------------------------------------------------------------

    glandDirName   = "./"
    glandFileName  = "gland5.input.nc"
    glandPathName  = glandDirName+glandFileName
    gfile          = addfile(glandPathName,"r")
    lat2d          = gfile->lat(0,:,:)
    lon2d          = gfile->lon(0,:,:)

    dimg  = dimsizes(lat2d)
    nlat  = dimg(0)
    mlon  = dimg(1)
;----------------------------------------------------------------------
; Regridding section: Use ESMF 33 generated weight files
;----------------------------------------------------------------------

;---Read data from input file containing source grid
    srcDirName   = "./"
    srcFileName  = "co2_1000ppm_twoway_synch.cism.h.0481-01-01-00000.nc"
    srcPathName  = srcDirName+srcFileName
    sfile        = addfile(srcPathName,"r")

;---Regrid variables using existing weights file
    
    thk_model    = sfile->thk
    thk_regrid   = ESMF_regrid_with_weights(thk_model,wgtPathName,False)
    printVarSummary(thk_regrid)
    
    topg_model   = sfile->topg
    topg_regrid  = ESMF_regrid_with_weights(topg_model,wgtPathName,False)
    printVarSummary(topg_regrid)
    
    temp_model   = sfile->temp    ; (time,level,y1,x1)
    temp_regrid  = ESMF_regrid_with_weights(temp_model,wgtPathName,False)
    printVarSummary(temp_regrid)

;----------------------------------------------------------------------
; Plot the original and regridded data.
;----------------------------------------------------------------------
    temp_model@lat2d = lat2d
    temp_model@lon2d = lon2d
    topg_model@lat2d = lat2d
    topg_model@lon2d = lon2d
    thk_model@lat2d  = lat2d
    thk_model@lon2d  = lon2d

    wks = gsn_open_wks("png","gland_cism")        ; send graphics to PNG file

    res                      = True               ; plot mods desired
    res@gsnDraw              = False
    res@gsnFrame             = False 
    res@gsnAddCyclic         = False 
    res@cnFillOn             = True               ; turn on color
    res@cnFillMode           = "RasterFill"
    res@cnLinesOn            = False
    res@cnLineLabelsOn       = False
    res@cnFillPalette        = "WhiteBlueGreenYellowRed"
    res@lbLabelBarOn         = False              ; turn off individual lb's
  
    res@trGridType           = "TriangularMesh"
  
    res@mpProjection          = "Stereographic"
    res@mpDataBaseVersion     = "mediumres"
    res@mpFillOn              = False             ; turn off default land map fill
    res@mpPerimDrawOrder      = "PostDraw"  
  
    res@mpLimitMode           = "Corners"  
    res@mpLeftCornerLatF      = lat2d(0,0)
    res@mpLeftCornerLonF      = lon2d(0,0)
    res@mpRightCornerLatF     = lat2d(nlat-1,mlon-1)
    res@mpRightCornerLonF     = lon2d(nlat-1,mlon-1)
    res@mpCenterLonF          = sfile->mapping@straight_vertical_longitude_from_pole
    res@mpCenterLatF          = sfile->mapping@standard_parallel
  
    res@gsnLeftString         = ""
    res@gsnRightString        = ""
  
    resP                      = True                ; panel resoources
    resP@gsnMaximize          = True
    resP@gsnPanelLabelBar     = True                ; add common colorbar
    resP@pmLabelBarHeightF    = 0.1                 ; wider than default
    resP@pmLabelBarWidthF     = 0.7                 ; smaller than default
    resP@lbLabelFontHeightF   = 0.0125              ; make label size
  
    plots = new(2,graphic)
    ntPlt = 0
  
    res@gsnCenterString = "Model: (301,561)"
    plots(0) = gsn_csm_contour_map(wks,thk_model(ntPlt,:,:),res)
    res@gsnCenterString = "ESMF: "+RES+" (53,207): "+METHOD 
    plots(1) = gsn_csm_contour_map(wks,thk_regrid(ntPlt,:,:),res)
    resP@txString = "Model: "+thk_model@long_name+" ("+thk_model@units+")" 
    gsn_panel(wks,plots,(/1,2/),resP)

    res@gsnCenterString = "Model: (301,561)"
    plots(0) = gsn_csm_contour_map(wks,topg_model(ntPlt,:,:),res)
    res@gsnCenterString = "ESMF: "+RES+" (53,207): "+METHOD 
    plots(1) = gsn_csm_contour_map(wks,topg_regrid(ntPlt,:,:),res)
    resP@txString = "Model: "+topg_model@long_name+" ("+topg_model@units+")" 
    gsn_panel(wks,plots,(/1,2/),resP)

    sigma = temp_model&level
    klev  = dimsizes(sigma)
    
    kl = 0   ; sigma level
    res@gsnCenterString = "Model: (301,561)"
    plots(0) = gsn_csm_contour_map(wks,temp_model(ntPlt,kl,:,:),res)
    res@gsnCenterString = "ESMF: "+RES+" (53,207): "+METHOD 
    plots(1) = gsn_csm_contour_map(wks,temp_regrid(ntPlt,kl,:,:),res)
    resP@txString = "Model: "+temp_model@long_name+" ("+temp_model@units+"): sigma="+sigma(kl) 
    gsn_panel(wks,plots,(/1,2/),resP)

    
    kl = klev-1   ; sigma level
    res@gsnCenterString = "Model: (301,561)"
    plots(0) = gsn_csm_contour_map(wks,temp_model(ntPlt,kl,:,:),res)
    res@gsnCenterString = "ESMF: "+RES+" (53,207): "+METHOD 
    plots(1) = gsn_csm_contour_map(wks,temp_regrid(ntPlt,kl,:,:),res)
    resP@txString = "Model: "+temp_model@long_name+" ("+temp_model@units+"): sigma="+sigma(kl) 
    gsn_panel(wks,plots,(/1,2/),resP)
   
