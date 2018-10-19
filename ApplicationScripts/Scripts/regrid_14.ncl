;*************************************************************
; regrid_14.ncl
;
; Concepts illustrated:
;   - Reverse the north-south grid ordering via NCL array indexing
;   - Using simple bilinear interpolation (linint2), perform 
;     (a) (180x360) - 1-deg x 1deg rectilinear grid to a 
;     (b) (192,288) = 0.9375x1.25 deg grid.
;     (c) Interpolate(b) back to (a)
;   - Plot the results
;     
;   - This illustrates that interpolation is *not* reversible
;*************************************************************
;;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"  
;************************************************
;;begin
;************************************************
; read in GPCP netCDF file
;************************************************
  gpcp = addfile("GPCP_1DD_v1.2_199610-201407.TEST.nc","r")
;************************************************
; read in GPCP
;************************************************
  prc = gpcp->PREC                     ; (*,lat,lon)  ==> (*,180,360)
  printVarSummary(prc)

  prc = prc(:,::-1,:)                  ; linint2 requires lat monotonically increasing
  printVarSummary(prc)
  printMinMax(prc,1)

  yyyymmdd = cd_calendar(prc&time, -2) ; use for identifying plys

;************************************************
; interpolate to new grid
;***********************************************
  mvr = addfile("mvr_cam5.globe.LAT_LON.nc","r")
  lat_mvr = mvr->lat                   ; [192]
  lon_mvr = mvr->lon                   ; [288]
  
  prc_mvr = linint2_Wrap(prc&lon,prc&lat,prc,True,lon_mvr,lat_mvr,0)
  prc_mvr@NCL_tag = "GPCP [1x1; (180,360)] bilinearly interpolated to MVR (192,288)"
  printVarSummary(prc_mvr)
  printMinMax(prc_mvr,1)

;************************************************
; interpolate prc_mvr back to original GPCP grid  
;***********************************************
  
  prc_mvr_1x1 = linint2_Wrap(prc_mvr&lon,prc_mvr&lat,prc_mvr,True,prc&lon,prc&lat,0)
  prc_mvr_1x1@NCL_tag = "GPCP [180,360] => MVR [192,288] => GPCP [180,360] "
  printVarSummary(prc_mvr_1x1)
  printMinMax(prc_mvr_1x1,1)

;************************************************
; difference grid
;***********************************************
  prc_diff = prc_mvr_1x1 - prc
  copy_VarCoords(prc, prc_diff)
  prc_diff@long_name = "prc diff: reinterpolated grid" 
  prc_diff@units     =  prc@units 
  printVarSummary(prc_diff)
  
;************************************************
; resources
;************************************************
  wks = gsn_open_wks("png","regrid")           ; open a work station

  res                     = True               ; plot mods desired
  res@cnFillOn            = True               ; turn on color   
  res@mpFillOn            = False              
  
  res@cnFillMode          = "RasterFill"         ; Raster Mode
  res@cnLinesOn           = False              ; no contour lines
  res@cnLineLabelsOn      = False              ; no line labels
  res@lbLabelBarOn        = False              ; turn off label bar

  res@gsnDraw             = False              ; don't draw yet
  res@gsnFrame            = False              ; don't advance frame yet

  res@cnLevelSelectionMode = "ExplicitLevels"              
  res@cnLevels             = (/0.1,1,2.5,5,10,15,20,25,50,75/) ; "mm/day" 
  res@cnFillPalette        = (/"Snow","PaleTurquoise","PaleGreen","SeaGreen3" ,"Yellow" \   ; contour colors
                              ,"Orange","HotPink","Red","Violet", "Purple", "Brown"/)       ; one more color than contour levels

;************************************************
; create plots
;************************************************
  nt   = 0                ; arbitrarily plot 1st time step
 
  plot = new(3,graphic)
  res@tiMainString        = "GPCP: 1x1: (180,360)"
  res@gsnCenterString     = yyyymmdd(nt)
  plot(0) = gsn_csm_contour_map_ce(wks,prc(nt,:,:),res)  ; create the plot

  res@tiMainString        = "GPCP on MVR Grid (192,288)"
  plot(1) = gsn_csm_contour_map_ce(wks,prc_mvr(nt,:,:),res)  ; create the plot

  res@tiMainString        = "GPCP on MVR Grid (192,288) to GPCP(180,360)"
  plot(2) = gsn_csm_contour_map_ce(wks,prc_mvr_1x1(nt,:,:),res)  ; create the plot
;************************************************
; create panel
;************************************************
  pres                  = True
  pres@gsnPanelLabelBar = True                   ; common label bar
  gsn_panel(wks,plot,(/3,1/),pres)

  delete([/ res@cnLevelSelectionMode, res@cnLevels, res@cnFillPalette /])

  res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res@cnMinLevelValF       = -16.               ; set min contour level
  res@cnMaxLevelValF       =  16.               ; set max contour level
  res@cnLevelSpacingF      =   1.               ; set contour spacing

  res@cnFillPalette        = "ViBlGrWhYeOrRe"

  res@tiMainString        = "Difference: Reinterpolated to Original (180,360)"
  plot(0) = gsn_csm_contour_map_ce(wks,prc_diff(nt,:,:),res)  ; create the plot
  gsn_panel(wks,plot(0),(/1,1/),pres)
;;end
