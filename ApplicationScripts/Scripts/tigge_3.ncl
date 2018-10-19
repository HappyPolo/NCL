load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"		; needed for dim_avg_Wrap, dim_variance_Wrap

begin
  a = addfile("z_tigge_c_ecmf_20070512120000_0012_pl_glob_prod.grib2","r")
  ecmf_im = a->t_P1_L100_GGA0(:,{85000.},::-1,:)    ; grab T@85000. Pa level, flip lats
  ecmf = dim_avg_Wrap(ecmf_im(lat_0|:,lon_0|:,ensemble0|:))  ; average across the ensemble dimension
  delete(ecmf_im)                                            ; to get an ensemble average	

  a2 = addfile("z_tigge_c_babj_20070512120000_0012_pl_glob_test.grib2","r")
  babj_im = a2->t_P1_L100_GLL0(:,{85000.},::-1,:)    ; grab T@85000. Pa level, flip lats
  babj = dim_avg_Wrap(babj_im(lat_0|:,lon_0|:,ensemble0|:))  ; average across the ensemble dimension
  delete(babj_im)                                            ; to get an ensemble average

  a3 = addfile("z_tigge_c_egrr_20070512120000_0012_pl_glob_prod.grib2","r")
  egrr_im = a3->t_P1_L100_GLL0(:,{85000.},:,:)    ; grab T@85000. Pa level 
  egrr = dim_avg_Wrap(egrr_im(lat_0|:,lon_0|:,ensemble0|:))  ; average across the ensemble dimension
  delete(egrr_im)                                            ; to get an ensemble average	
	
  a4 = addfile("z_tigge_c_kwbc_20070512120000_0012_pl_glob_prod.grib2","r")
  kwbc_im = a4->t_P1_L100_GLL0(:,{85000.},::-1,:)    ; grab T@85000. Pa level, flip lats
  kwbc = dim_avg_Wrap(kwbc_im(lat_0|:,lon_0|:,ensemble0|:))  ; average across the ensemble dimension
  delete(kwbc_im)                                            ; to get an ensemble average

  a5 = addfile("z_tigge_c_rjtd_20070512120000_0012_pl_glob_prod.grib2","r")
  rjtd_im = a5->t_P1_L100_GLL0(:,{85000.},::-1,:)    ; grab T@85000. Pa level, flip lats
  rjtd = dim_avg_Wrap(rjtd_im(lat_0|:,lon_0|:,ensemble0|:))  ; average across the ensemble dimension
  delete(rjtd_im)                                            ; to get an ensemble average
;=============================================================	
  wks = gsn_open_wks("ps","tigge_3")
  gsn_define_colormap(wks,"rainbow")
;
; This will not be necessary in V6.1.0 and later. Named colors can
; be used without having to first add them to the color map.
;
  newcolor = NhlNewColor(wks,0.90,0.90,0.90)		; add gray90 to colormap
	
  res = True
  res@mpDataBaseVersion="MediumRes"
  res@mpProjection = "LambertEqualArea"
  res@mpLimitMode = "LatLon"
  res@mpMinLatF = 7.                                       ; set the minimum latitude
  res@mpMaxLatF = 90.                                      ; set the maximum latitude
  res@mpMinLonF = 200.                                     ; set the minimum longitude
  res@mpMaxLonF = 330.                                     ; set the maximum longitude
  res@mpCenterLonF = (res@mpMaxLonF + res@mpMinLonF)/2.    ; set the longitude at the center of the plot
  res@mpOutlineOn = True                                   ; turn the map outlines on
  res@mpOutlineBoundarySets = "National"                   ; draw national boundaries
  res@mpOutlineSpecifiers = (/"Canada : Provinces","United States : States"/)  ; draw US States, Canadian provinces
  res@mpLandFillColor = "gray90"			            ; shade land with gray90
  res@gsnFrame = False                                     ; don't advance the frame
  res@gsnDraw  = False                                     ; don't draw the plot
  res@gsnMaximize = True                                   ; maximize the plot
  res@gsnPaperOrientation = "portrait"                     ; when maximizing, keep the orientation as portrait
  res@gsnLeftString = egrr@initial_time
  res@gsnCenterString = egrr@forecast_time+"hr forecast"
  res@gsnRightString = egrr@units+" *10~S~-1~N~"
  res@tiMainString = "500hPa Temperature"	
  res@tiMainFontHeightF = 0.012                 ; set the main title font height
;  res@gsnStringFontHeightF = 0.015
  plot_base = gsn_csm_map(wks,res)               ; create the blank base plot
	
  mres = True                                    ; create a resource list for contour plots
  mres@cnLevelSelectionMode = "ManualLevels"     ; manually select the levels
  mres@cnMinLevelValF  = 230.                    ; set the minimum contour level
  mres@cnMaxLevelValF  = 310.                    ; set the maximum contour level
  mres@cnLevelSpacingF = 2.                      ; set the contour interval
  mres@cnLineColor = "blue"                      ; contour the lines blue
  mres@gsnFrame = False                          ; don't advance the frame
  mres@gsnDraw  = False                          ; don't draw the plot
  mres@cnLineLabelInterval = 5                   ; label every other line
  mres@cnInfoLabelOn         = False             ; don't draw the info label
  mres@cnLineLabelPerimOn = False                ; turn the line label perimeter off
;  mres@cnLineLabelBackgroundColor = -1
  mres@cnLineLabelFontColor = "blue"             ; color the line labels blue
  mres@cnLineLabelFontHeightF = 0.01             ; set the line label font height
  mres@tiMainFontHeightF = 0.012                 ; set the main title font height
	
  mres@gsnLeftString = ""
  mres@gsnCenterString = ""
  mres@gsnRightString = ""
	
  plot_temp = new(5,"graphic")         
  mres@cnLineColor = "blue"                      ; contour the lines blue
  plot_temp(0) = gsn_csm_contour(wks,ecmf,mres)
  overlay(plot_base,plot_temp(0))
	
  plot_temp(1) = gsn_csm_contour(wks,babj,mres)
  overlay(plot_base,plot_temp(1))
	
  plot_temp(2) = gsn_csm_contour(wks,egrr,mres)
  overlay(plot_base,plot_temp(2))
	
  plot_temp(3) = gsn_csm_contour(wks,kwbc,mres)
  overlay(plot_base,plot_temp(3))
	
  plot_temp(4) = gsn_csm_contour(wks,rjtd,mres)
  overlay(plot_base,plot_temp(4))

  draw(plot_base)
  frame(wks)
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
  print("Regridding babj, ecmf, egrr, and kwbc to rjtd grid")
	
  babj_rg = linint2_Wrap(babj&lon_0,babj&lat_0,babj,True,rjtd&lon_0,rjtd&lat_0,0)
  delete(babj)
  ecmf_rg = linint2_Wrap(ecmf&lon_0,ecmf&lat_0,ecmf,True,rjtd&lon_0,rjtd&lat_0,0)
  delete(ecmf)
  egrr_rg = linint2_Wrap(egrr&lon_0,egrr&lat_0,egrr,True,rjtd&lon_0,rjtd&lat_0,0) ;!Problem
  delete(egrr)
  kwbc_rg = linint2_Wrap(kwbc&lon_0,kwbc&lat_0,kwbc,True,rjtd&lon_0,rjtd&lat_0,0)
  delete(kwbc)

  ens = rjtd    ; done to keep the meta-data
  ens = (/ (rjtd+babj_rg+ecmf_rg+egrr_rg+kwbc_rg)/5.0 /) ; average across the models
	                                                       ; to get an ensemble average
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 												
  tarr = new((/dimsizes(rjtd&lat_0),dimsizes(rjtd&lon_0),5/),typeof(rjtd),rjtd@_FillValue)  ; create new array to house 5 ensemble averages
  tarr(:,:,0) = (/ rjtd /)											
  tarr(:,:,1) = (/ babj_rg /)
  tarr(:,:,2) = (/ ecmf_rg /)
  tarr(:,:,3) = (/ egrr_rg /)
  tarr(:,:,4) = (/ kwbc_rg /)
  delete(rjtd)
  delete(babj_rg)
  delete(ecmf_rg)
  delete(egrr_rg)
  delete(kwbc_rg)

  vari = ens     ; done for the meta-data
  vari = (/ dim_variance(tarr) /)  ; compute the variance of the righmost dimension, in this case the "ensemble" dimension
	        ; (/ /) doesn't transfer meta-data (or the lack thereof) to the lefthand side of the =.														
												
  cres = True
  cres@mpDataBaseVersion="MediumRes"
  cres@mpProjection = "LambertEqualArea"
  cres@mpLimitMode = "LatLon"
  cres@mpMinLatF = 7.                                       ; set the minimum latitude
  cres@mpMaxLatF = 90.                                      ; set the maximum latitude
  cres@mpMinLonF = 200.                                     ; set the minimum longitude
  cres@mpMaxLonF = 330.                                     ; set the maximum longitude
  cres@mpCenterLonF = (cres@mpMaxLonF + cres@mpMinLonF)/2.    ; set the longitude at the center of the plot
  cres@mpOutlineOn = True                                   ; turn the map outlines on
  cres@mpOutlineBoundarySets = "National"                   ; draw national boundaries
  cres@mpOutlineSpecifiers = (/"Canada : Provinces","United States : States"/)  ; draw US States, Canadian provinces
  cres@mpFillOn = False                                     ; do not fill the land
  cres@gsnMaximize = True                                   ; maximize the plot
  cres@gsnPaperOrientation  = "portrait"                    ; when maximizing, keep the orientation as portrait
  cres@cnLevelSelectionMode = "ManualLevels"                ; manually select the levels
  cres@cnMinLevelValF       = 1.                            ; set the minimum contour level
  cres@cnMaxLevelValF       =  10.                          ; set the maximum contour level
  cres@cnLevelSpacingF      = 1.                            ; set the contour interval
  cres@cnFillOn = True                                      ; turn on contour shading     
  cres@cnFillColors = (/0,55,70,85,100,115,130,145,160,175,189/)    ; set the fill colors
  cres@cnLinesOn = False                         ; don't draw the contour lines
  cres@cnInfoLabelOn         = False             ; don't draw the info label
  cres@cnLineLabelsOn = False                    ; don't draw the contour line labels
  cres@tiMainFontHeightF = 0.012                 ; set the main title font height	
  cres@mpPerimOn = True
  cres@mpPerimLineThicknessF = 2.5               ; thicken perimeter border so it is more noticeable
														   	
  eres = True
  eres@cnLevelSelectionMode = "ManualLevels"     ; manually select the levels
  eres@cnMinLevelValF  = 230.                    ; set the minimum contour level
  eres@cnMaxLevelValF  = 330.                    ; set the maximum contour level
  eres@cnLevelSpacingF = 2.                      ; set the contour interval 
  eres@cnLineColor = "blue"                      ; contour the lines blue
  eres@cnLineLabelInterval = 2                   ; label every other line
  eres@cnInfoLabelOn         = False             ; don't draw the info label
  eres@cnLineLabelPerimOn = False                ; turn the line label perimeter off
  eres@cnLineLabelFontColor = "blue"             ; color the line labels blue
  eres@cnLineLabelFontHeightF = 0.01             ; set the line label font height
	
  cres@gsnLeftString = ens@initial_time
  cres@gsnCenterString = ens@forecast_time+"hr forecast"
  cres@gsnRightString = ens@units+" *10~S~-1~N~"
  cres@tiMainString = "Multi-model Ensemble 500hPa Temperature Mean and Variance (color)"
  plot_ens = gsn_csm_contour_map_overlay(wks,vari,ens,cres,eres)
end
