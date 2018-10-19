;======================================================================
; gland_2.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF_regrid_with_weights
;   - Interpolating from one grid to another using an existing weights file
;   - Writing data to a NetCDF file using the easy but inefficient method
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


    METHOD        = "bilinear"       ; bilinear, patch, conserve
    RES           = "0.5deg"            ; 0.5deg, 1.0deg

    wgtDirName    = "./"
    wgtFileName   = "gland_to_Rect_"+METHOD+"."+RES+".nc"
    wgtPathName   = wgtDirName+wgtFileName

;----------------------------------------------------------------------
; Regridding section
;----------------------------------------------------------------------

;---Read data from input file containing source grid
    srcDirName   = "./"
    srcFileName  = "gland5.input.nc"
    srcPathName  = srcDirName+srcFileName
    sfile        = addfile(srcPathName,"r")

;---Regrid variables using existing weights file
    
    prs_gland    = sfile->presusurf
    prs_regrid   = ESMF_regrid_with_weights(prs_gland,wgtPathName,False)
    printVarSummary(prs_regrid)
    
    thk_gland    = sfile->thk
    thk_regrid   = ESMF_regrid_with_weights(thk_gland,wgtPathName,False)
    printVarSummary(thk_regrid)
    
    topg_gland   = sfile->topg
    topg_regrid  = ESMF_regrid_with_weights(topg_gland,wgtPathName,False)
    printVarSummary(topg_regrid)
    
    prcp_gland   = sfile->presprcp
    prcp_regrid  = ESMF_regrid_with_weights(prcp_gland,wgtPathName,False)
    printVarSummary(prcp_regrid)

;----------------------------------------------------------------------
; Plot the original and regridded data.
;----------------------------------------------------------------------
    lat2d = sfile->lat(0,:,:)
    lon2d = sfile->lon(0,:,:)

    dimg  = dimsizes(lat2d)
    nlat  = dimg(0)
    mlon  = dimg(1)

    wks = gsn_open_wks("png","gland")             ; send graphics to PNG file

    res                      = True               ; plot mods desired
    res@gsnDraw              = False
    res@gsnFrame             = False 
    res@gsnAddCyclic         = False 
    res@cnFillOn             = True               ; turn on color
    res@cnFillMode           = "RasterFill"
    res@cnLinesOn            = False
    res@cnLineLabelsOn       = False
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
  ;************************************************
  ; Turn on lat / lon labeling
  ;************************************************
  
    var   = (/ "presusurf", "thk", "topg", "presprcp" /)
    nvar  = dimsizes(var)
    plots = new(2,graphic)
    ntPlt = 0

    do nv=0,nvar-1
       x := sfile->$var(nv)$                        ; all time steps
       x@lat2d = lat2d
       x@lon2d = lon2d
  
       res@cnFillPalette = "WhiteBlueGreenYellowRed"
       if (var(nv).eq."topg") then
           res@cnFillPalette        = "testcmap"
           res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
           res@cnMinLevelValF       = -3000.
           res@cnMaxLevelValF       =  3000.
           res@cnLevelSpacingF      =   500. 
       end if
  
       res@gsnCenterString = "WGS84 on Sphere: (301,561)"
       plots(0) = gsn_csm_contour_map(wks,x(ntPlt,:,:),res)

       res@gsnCenterString = "ESMF: "+RES+" (53,207): "+METHOD 

       if (var(nv).eq."presusurf") then
           plots(1) = gsn_csm_contour_map(wks,prs_regrid(ntPlt,:,:),res)
       end if

       if (var(nv).eq."thk") then
           plots(1) = gsn_csm_contour_map(wks,thk_regrid(ntPlt,:,:),res)
       end if

       if (var(nv).eq."topg") then
           plots(1) = gsn_csm_contour_map(wks,topg_regrid(ntPlt,:,:),res)
       end if

       if (var(nv).eq."presprcp") then
           plots(1) = gsn_csm_contour_map(wks,prcp_regrid(ntPlt,:,:),res)
       end if
  
       resP@txString      = "gland5: "+x@long_name+" ("+x@units+")" 
       gsn_panel(wks,plots,(/1,2/),resP)
   
       if (var(nv).eq."topg") then
           delete( [/ res@cnLevelSelectionMode, res@cnMinLevelValF, res@cnMaxLevelValF, res@cnLevelSpacingF /] )
       end if
    end do
  
