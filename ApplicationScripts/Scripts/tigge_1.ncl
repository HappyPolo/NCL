load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"		; needed for dim_avg_Wrap, dim_variance_Wrap

begin
  a = addfile("z_tigge_c_ecmf_20070512120000_0012_pl_glob_prod.grib2","r")
  z500 = a->gh_P1_L100_GGA0(:,{50000.},:,:)    ; grab 50000. Pa level
  printVarSummary(z500)                        ; [ensemble0 | 51] x [lat_0 | 400] x [lon_0 | 800]

  z500 = z500/10.		; convert to decimeters
;=============================================================	
  wks = gsn_open_wks("ps","tigge_1")
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
  res@gsnLeftString = z500@initial_time
  res@gsnCenterString = z500@forecast_time+"hr forecast"
  res@gsnRightString = z500@units+" *10~S~-1~N~"
  res@tiMainString = "ECMWF 500hPa HGHT"
  res@tiMainFontHeightF = 0.012                 ; set the main title font height
;  res@gsnStringFontHeightF = 0.015
	
  plot_base = gsn_csm_map(wks,res)               ; create the blank base plot
	
  mres = True                                    ; create a resource list for contour plots
  mres@cnLevelSelectionMode = "ManualLevels"     ; manually select the levels
  mres@cnMinLevelValF  = 490.                    ; set the minimum contour level
  mres@cnMaxLevelValF  = 622.                    ; set the maximum contour level
  mres@cnLevelSpacingF = 4.                      ; set the contour interval
  mres@cnLineColor = "blue"                      ; contour the lines blue
  mres@gsnFrame = False                          ; don't advance the frame
  mres@gsnDraw  = False                          ; don't draw the plot
  mres@cnLineLabelInterval = 2                   ; label every other line
  mres@cnInfoLabelOn         = False             ; don't draw the info label
  mres@cnLineLabelPerimOn = False                ; turn the line label perimeter off
;  mres@cnLineLabelBackgroundColor = -1
  mres@cnLineLabelFontColor = "blue"             ; color the line labels blue
  mres@cnLineLabelFontHeightF = 0.01             ; set the line label font height

	
  mres@gsnCenterString = ""
  mres@gsnLeftString = ""
  mres@gsnRightString = ""
  plot_temp = new(10,"graphic")         
  do gg = 0,9                           ; only plot the first 10 ensemble members
	plot_temp(gg) = gsn_csm_contour(wks,z500(gg,:,:),mres)
	overlay(plot_base,plot_temp(gg))
  end do
  draw(plot_base)
  frame(wks)
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
  print("Creating ensemble average")
  ensavg = dim_avg_Wrap(z500(lat_0|:,lon_0|:,ensemble0|:))  ; average across the ensemble dimension
	                                                          ; to get an ensemble average
  vari = dim_variance_Wrap(z500(lat_0|:,lon_0|:,ensemble0|:))											   
		
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
  cres@cnMinLevelValF       = .5                            ; set the minimum contour level
  cres@cnMaxLevelValF       =  5.                          ; set the maximum contour level
  cres@cnLevelSpacingF      = .5                            ; set the contour interval
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
  eres@cnMinLevelValF  = 490.                    ; set the minimum contour level
  eres@cnMaxLevelValF  = 622.                    ; set the maximum contour level
  eres@cnLevelSpacingF = 4.                      ; set the contour interval 
  eres@cnLineColor = "blue"                      ; contour the lines blue
  eres@cnLineLabelInterval = 2                   ; label every other line
  eres@cnInfoLabelOn         = False             ; don't draw the info label
  eres@cnLineLabelPerimOn = False                ; turn the line label perimeter off
  eres@cnLineLabelFontColor = "blue"             ; color the line labels blue
  eres@cnLineLabelFontHeightF = 0.01             ; set the line label font height
	
  cres@gsnLeftString = ensavg@initial_time
  cres@gsnCenterString = ensavg@forecast_time+"hr forecast"
  cres@gsnRightString = ensavg@units+" *10~S~-1~N~"
  cres@tiMainString = "ECMWF Ensemble 500hPa HGHT Mean and Variance (color)"
  plot_ens = gsn_csm_contour_map_overlay(wks,vari,ensavg,cres,eres)
end
