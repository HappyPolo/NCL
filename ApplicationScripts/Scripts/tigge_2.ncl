load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"		; needed for dim_avg_Wrap

begin
	a = addfile("z_tigge_c_ecmf_20070512120000_0012_pl_glob_prod.grib2","r")
	z500 = a->gh_P1_L100_GGA0(:,{50000.},:,:)    ; grab 50000. Pa level
	printVarSummary(z500)                        ; [ensemble0 | 51] x [lat_0 | 400] x [lon_0 | 800]

	z500 = z500/10.		; convert to dekameters
;=============================================================	
	wks = gsn_open_wks("ps","tigge_2")
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
	
	res@tiMainFontHeightF    = 0.012              ; set the main title font height
	res@gsnLeftString = z500@initial_time
	res@gsnCenterString = z500@forecast_time+"hr forecast"
	res@gsnRightString = z500@units+" *10~S~-1~N~"
	res@tiMainString = "ECMWF 500hPa 564dm contour"	
	plot_base = gsn_csm_map(wks,res)               ; create the blank base plot
	
	mres = True                                    ; create a resource list for contour plots
	mres@cnLevelSelectionMode = "ExplicitLevels"   ; explicitly select the levels
     mres@cnLevels             = 564.               ; only draw the 564 contour
	mres@cnLineColor          = "blue"             ; contour the lines blue
	mres@gsnFrame             = False              ; don't advance the frame
	mres@gsnDraw              = False              ; don't draw the plot
	mres@cnLineLabelsOn       = False              ; turn off the line labels
	mres@cnInfoLabelOn        = False              ; don't draw the info label
	
	mres@gsnLeftString = ""
	mres@gsnCenterString = ""
	mres@gsnRightString = ""
	plot_temp = new(52,"graphic")         ; 51 members plus 1 ensemble member
	do gg = 0,50                           ; only plot the first 10 ensemble members
	   plot_temp(gg) = gsn_csm_contour(wks,z500(gg,:,:),mres)
	   overlay(plot_base,plot_temp(gg))
	end do
	
	mres@cnLineThicknessF = 2.5                     ; alter resources for ensemble average
	mres@cnLineColor = "red"
	ensavg = dim_avg_Wrap(z500(lat_0|:,lon_0|:,ensemble0|:))  ; average across the ensemble dimension
	                                                          ; to get an ensemble average	
	plot_temp(51) = gsn_csm_contour(wks,ensavg,mres)	
     overlay(plot_base,plot_temp(51))
	draw(plot_base)
	frame(wks)
end
