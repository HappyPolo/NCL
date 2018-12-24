begin

	fAir 	= addfile("air.sig995.2016.nc","r")

	air 	= fAir->air(16:21,:,:)
	air		= (/air-273.15/)
	
	res 							= True
	res@gsnDraw						= False
	res@gsnFrame					= False
	res@gsnLeftString 				= ""
	res@gsnRightString 				= ""
	
	; turn off shading over continents
	res@mpFillOn					= False
	
	; set the thickness of coastal lines
	res@mpGeophysicalLineColor 		= "Gray40"
	
	; =========> Your Task <====================
	; ******************************************
	; Set the range of 
	; 1) minimum latitude (mpMinLatF)
	; 2) maximum latitude (mpMaxLatF)
	; 3) minimum longitude (mpMinLonF)
	; 4) maximum longitude (mpMaxLonF)
	
	
	
	; ******************************************
	; ******************************************
	; Change the font size of 
	; 1) main title (tiMainFontHeightF)
	; 2) label on x-axis (tmXBLabelFontHeightF)
	; 3) label on y-axis (tmYLLabelFontHeightF)
	
	
	; ******************************************
	; ******************************************
	; Turn on shading (cnFillOn)
	
	
	; Turn off contour lines (cnLinesOn) 
	; and contour labels (cnLineLabelsOn)
	
	
	; Set contour intervals
	; interval = 5K
	
	res@cnLevelSelectionMode 		= 
	res@cnMaxLevelValF				= 
	res@cnMinLevelValF				= 
	res@cnLevelSpacingF				= 
	
	
	; Set color table (cnFillPalette)
	
	
	
	; Turn off label bar on individual plot (lbLabelBarOn)
	
	
	; ******************************************
	; ******************************************
	; Define wksName
	
	wksName = 
	
	
	wks 	= gsn_open_wks("png",wksName)
	plot 	= new(6,graphic)
	
	do i = 0, 5
	
		; Set the main title of each plot (tiMainString)
		
		
		; Draw individual plot
		
		plot(i)	= gsn_csm_contour_map_ce(wks,air(i,:,:),res)
	end do
	
	; resource of panel plot
	
	resPanel								= True
	resPanel@gsnPanelLabelBar				= True  ; set a common label bar 
	resPanel@lbLabelFontHeightF				= 0.018 ; font size of the common label bar
	resPanel@gsnPanelXWhiteSpacePercent 	= 5.	; white space on x-axis between two plots in the panel plot
	resPanel@gsnPanelYWhiteSpacePercent 	= 5.	; white space on y-axis between two plots in the panel plot
	
	; Use gsn_panel to draw a panel plot 
	
	
	; >>>>>>>>>>> End of Q2. <<<<<<<<<<<<<<<<<<<<<<<
	
end