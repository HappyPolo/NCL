begin

	; Define the name of figure
	wksName 		=" hhoiuhku"
	
	wks 			= gsn_open_wks("x11",wksName)
		
	res 			= True
	res@gsnDraw 	= False
	res@gsnFrame 	= False
	
	res@mpMinLatF	= 20.
	res@mpMaxLatF	= 50.
	res@mpMinLonF	= 100.
	res@mpMaxLonF	= 140.
	
	res@tmXBLabelFontHeightF = 0.024
	res@tmYLLabelFontHeightF = 0.024
	
	res@mpFillOn	= False
	res@pmTickMarkDisplayMode = "Always"
	
	plot 			= gsn_csm_map(wks,res)
	
	; =================================================================
	
	xStation		= (/110, 115, 120, 125, 130, 120/) ; X coordinate
	yStation 		= (/25, 35, 25, 35, 25, 45/) ; Y coordinate
	lbStation		= (/"1","2","3","4","5","6"/) 
		
	; Add markers (gsn_add_polymarker)
	plot2 = gsn_add_polymarker(wks, plot, xStation, yStation, res)
	
	; Add text labels (gsn_add_text), where labels are given by lbStation
	; Text SHOULD NOT overlap with markers
	plot3 = gsn_add_text(wks, plot, lbStation, xStation, yStation, res)
	
	draw(plot)
	frame(wks)
	; Draw graph
	
	
	
end