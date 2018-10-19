;********************************************************
; panel_21.ncl
;
; Concepts illustrated:
;   - Paneling six contour plots on the same page
;   - Adding a common labelbar to paneled plots
;   - Adding a common title to paneled plots
;   - Adding extra side and bottom labels to paneled plots
;
;********************************************************
;
; This code is an example of how to add an common title
; and x-axis and y-axis labels to a panel plot. 
;
; Setting axislabelstyle to "individual" gives individual
; titles and axis labels for each panel, while setting it
; to "panel" will turn these off and put the common labels
; instead.
;
; Author: Jonathan Vigh, Colorado State University 
; Date:   12/04/07
; 
;********************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

  msg_val = -9999d

; Set a few parameters which will control the behavior of the plotting code
  plottype = "png"
  axislabelstyle = "panel"	; "individual" will give a title, x-axis, and y-axis label for each plot (NCL's default behavior)
  				; "panel" will turn the individual labels off and put one title, x-axis, and y-axis for the entire panel plot

;***************************************************************************************************
; Set up parameters which will be used in setting up the coordinate arrays and calculating the data
;***************************************************************************************************
; choose # of points for the isoline calculations
  nhloc = 26	; number of points which comprise the heating location axis
  nvmax = 26    ; number of points which comprise the vmax axis

; define some commonly used numerical values using double precision
  half = 1d/2d
  quarter = 1d/4d

; define mathematical, geophysical, and thermodynamic constants
  pi               = 3.14159265358979d0	; pi
  gravity          = 9.80655d0   	; gravitational acceleration, etc.: units of m/s^2; this is the World Meteorological Organization value for gravity at 45 degrees latitude)
  dry_gas_constant = 287d	        ; dry gas constant (J/(K kg)

; define other parameters
  background_coriolis = 5.0d-5	                ; far-field constant Coriolis parameter (1/s)
  N                   = 1.0d-2			; Brunt-Vaisala frequency (1/s) 
  T0                  = 300d			; reference state temperature
  scale_height = dry_gas_constant*T0/gravity	; scale height

  inverse_muf = 1.0d6	        ; Rossby Radius in far-field is 1000 km
  muf = 1d/inverse_muf		; muf is the inverse Rossby Radius of the far-field

  ztop = (pi)/sqrt( (muf^2d)*(N^2d)/(background_coriolis^2d) - quarter/scale_height^2d )    ; calculate the top of the barotropic model's atmosphere


; Define the values of radius of maximum winds (rmax) - each value will correspond to a separate isoline plot
  rmax_coord     = (/ 30d, 25d, 20d, 15d, 10d, 5d/)*1000d  
  rmax_coord_km = rmax_coord/1000d
  nrmax = dimsizes(rmax_coord)
    
  rmax_coord!0		= "coresize"
  rmax_coord&coresize	= rmax_coord_km
  
  rmax_coord@long_name	= "Radius of Maximum Winds"
  rmax_coord@units	= "m"


; Define the x-axis coordinate - the location of heating
  hloc_coord = fspan(1000d,40000d,nhloc)
  hloc_coord_km = hloc_coord/1000d
    
  hloc_coord!0		     = "heatinglocation"
  hloc_coord&heatinglocation = hloc_coord_km
  
  hloc_coord@long_name	= "Location of Heating, r~B~h~N~"
  hloc_coord@units	= "m"


; Define the left y-axis coordinate - the maximum wind speed
  vmax_coord = fspan(0d,75d,nvmax)
    
  vmax_coord!0		= "intensity"
  vmax_coord&intensity	= vmax_coord
  
  vmax_coord@long_name	= "Maximum Wind Speed"
  vmax_coord@units	= "m s~S~-1~N~"
    
  
; Define a second y-axis coordinate - Rossby radius (inverse mu) - this is dependent on the vortex-specific vmax and rmax - this axis will be different for each panel 
  nimuc = nvmax
  
  imuc_coord = new((/nrmax,nimuc/),"double")
  muc_coord  = new((/nrmax,nimuc/),"double")
  fc_coord   = new((/nrmax,nimuc/),"double")

  imuc_coord!0 = "coresize"
  imuc_coord!1 = "inertial"

; compute the inverse Rossby Radius for each particular rmax and associated range of vmax's 
  do jrmax = 0, nrmax-1
     fc_coord(jrmax,:) = background_coriolis + 2d*vmax_coord/rmax_coord(jrmax)	; first compute the effective Coriolis parameter
     muc_coord(jrmax,:) = (fc_coord(jrmax,:)/N)*sqrt((pi^2d)/ztop^2d + quarter/(scale_height^2d))  ; then the inverse Rossby Radius
  end do

  imuc_coord = 1d/muc_coord
  imuc_coord_km = imuc_coord/1000d

  imuc_coord@long_name	= "Rossby Radius, ~F33~m~F21~~S~-1~N~"
  imuc_coord@units	= "m"
  

;***********************************************************************************************************************************
; Compute a 3D data variable (note that this is just a dummy field for illustrative purposes), but we'll call it temperature tendency.. 
;***********************************************************************************************************************************
  data3D = new((/nrmax,nimuc,nhloc/),"double")
  
  data3D!0 = "coresize"
  data3D!1 = "intensity"
  data3D!2 = "heatinglocation"
  
  data3D&coresize        = rmax_coord_km
  data3D&intensity       = vmax_coord
  data3D&heatinglocation = hloc_coord_km
  
  data3D@long_name = "Temperature Tendency at Vortex Center (r = 0)"
  data3D@units = "K h~S~-1~N~"
  
  do jrmax = 0, nrmax-1
     do jimuc = 0, nimuc-1
        do jhloc = 0, nhloc-1   
           data3D(jrmax,jimuc,jhloc) = (rmax_coord(jrmax)/1000d)*((jimuc+1d)/nimuc)*sin(pi*(jhloc+1d+jimuc+rmax_coord(jrmax)/1000d)/nhloc)
        end do 
     end do
  end do


;******************************************************************************************************************************************************
; Create panel plot of isolines of temperature tendency at the VORTEX CENTER holding rc constant, but varying inertial stability and heating location *
;******************************************************************************************************************************************************
     wks = gsn_open_wks(plottype,"panel")  	; Open a postscript workstation.  
     gsn_define_colormap(wks,"WhBlGrYeRe")	 ; choose colormap

     plot = new(nrmax,graphic)

     res = True

     res@gsnDraw	= False	  ; do not draw frame since we will be adding a polyline and paneling
     res@gsnFrame       = False   ; do not advance frame
     res@gsnMaximize	= True	  ; maximize the plot space on page - this will apply to each individual plot
     res@gsnPaperOrientation = "landscape"
     res@gsnSpreadColors   = True    ; use full range of colormap

; Set the size of the individual title and axis fonts
     res@tiXAxisFontHeightF = 0.03
     res@tiYAxisFontHeightF = 0.03

; Also boost the size of the axis value labels - in a panel plot the default will probably be too small
     res@tmXBLabelFontHeightF = 0.03
     res@tmYLLabelFontHeightF = 0.03
     res@tmYRLabelFontHeightF = 0.03

     if (axislabelstyle .eq. "individual") then
        res@tiXAxisString   = hloc_coord@long_name + " (km)"
        res@tiYAxisString   = vmax_coord@long_name + " (" + vmax_coord@units + ")"

        res@gsnLeftString = " " ; override the default - we don't want the variable long_name on each individual plot - we'll add a common title for the panel title 
        res@gsnCenterStringFontHeightF = 0.04
        res@gsnRightStringFontHeightF = 0.03
     else  ; if we are going to make common labels for the overall panel plot, turn off titles and x- and y-axis titles
        res@tiXAxisOn = False
        res@tiYAxisOn = False 
	res@tiMainOn  = False
   
        res@tmXBLabelFontHeightF = 0.04    ; boost the axis value labels even more
        res@tmYLLabelFontHeightF = 0.04
        res@tmYRLabelFontHeightF = 0.04	
	  
     end if

     res@lbLabelBarOn = False	; turn off label bars for the individual plots
     res@lbOrientation = "vertical"

     res@cnFillOn            = True     ; turn on color
     res@cnLinesOn           = False	; but no contour lines
     res@cnLineLabelsOn      = False	; or contour labels
     res@cnInfoLabelOn       = False

; Set the format of the x-axis and make the minor values match top and bottom
     res@tmXBFormat = "f"	
     res@tmXBMinorPerMajor = 1
     res@tmXTMinorPerMajor = 1


; Set explicit tickmarks for the left y-axis  
     res@tmYLOn        = True 
     res@tmYLLabelsOn  = True
     res@tmYLMode      = "Explicit"		; Set the tickmark mode to explicit to define our own values
     res@tmYLValues    = vmax_coord(::5) 	; Give the value that determine location of major tickmarks - use every fifth value
     res@tmYLLabels    = vmax_coord(::5) 	; Give the labels for the y-axis tickmarks

; Set explicit tickmarks for the right y-axis  
     res@tmYUseLeft    = False			; the default is true, but we want the right axis to be different from the left
     res@tmYROn        = True 
     res@tmYRLabelsOn  = True
     res@tmYRMode      = "Explicit"		; Set the tickmark mode to explicit to define our own values
     res@tmYRValues    = vmax_coord(::5) 	; Give the value that determine location of major tickmarks
     res@tmYRFormat    = "0f"			; tweak the format so that unnecessary numbers aren't displayed for the exact numbers


; Retrieve font height of left axis string.
;     getvalues plot
;        "tiYAxisFontHeightF" : font_height
;     end getvalues
     font_height = res@tiYAxisFontHeightF	; we could retrieve the dynamically-set value, but since we already set it, we just use the value of the resource

; Create some text resources for a second right y-axis text string which we will add to the plot later using gsn_add_annotation.
     txres               = True
     txres@txAngleF      = 90.          ; Rotate string clockwise 
     txres@txFontHeightF = font_height  ; Use same font height as left axis

; Set some positional resources to move the text string to center/right edge of plot.
     amres                  = True
     amres@amParallelPosF   = 0.8    ; 0.5 is the right edge of the plot, so
                                     ; 0.6 is a little further to the right. In this case, we have to really move it over.
     amres@amOrthogonalPosF = 0.0    ; This is the center of the plot.
     amres@amJust           = "CenterCenter"
; By default, the center of the string is what's placed at the position
; indicated by amParallelPosF and amOrthogonalPosF. You can use amJust
; to change this to any one of 9 positions: "CenterCenter" (default),
; "TopCenter", "TopRight", "CenterRight", "BottomRight", "BottomCenter",
; "BottomLeft", "CenterLeft", "TopLeft".

; Create another set of text resources to label the radius of maximum winds, which will be marked by a vertical polyline in the plot  
     txres2               = True             
     txres2@txAngleF      = 90.          ; Rotate string clockwise 
     if (axislabelstyle .eq. "individual") then
        txres2@txFontHeightF = font_height    
     else
        txres2@txFontHeightF = 0.04
     end if
     
; Also set some resources to control the properties of the polyline
     polyres                  = True                      ; polyline mods desired
     polyres@gsLineColor      = "red"                     ; color of lines
     polyres@gsLineThicknessF = 3.0                       ; thickness of lines

; Create arrays of graphical objects so that each annotation is assigned to a unique object   
     dumline = new(nrmax,"graphic")	; for the polyline
     toid    = new(nrmax,"graphic")	; the label for the polyline
     txid    = new(nrmax,"graphic")	; a text object to add the right y-axis (for the individual plots)
     annoid  = new(nrmax,"graphic")	; the annotation object for the right y-axis 

     do i = 0, nrmax-1
        res@tmYRLabels      = round(10d*imuc_coord_km(i,::5),0)/10d     ; do this to get nice round values

        if (axislabelstyle .eq. "individual") then
           res@gsnCenterString = "r~B~c~N~ = "+rmax_coord_km(i)+" km"	; override the default
	else ; if we want a common panel plots, then turn off all the strings at the top of the individual plot
	   res@gsnCenterString = " "	
	   res@gsnLeftString = " "
	   res@gsnRightString = " "
	end if   

	plot(i) = gsn_csm_contour(wks,data3D(i,:,:),res)   ; draw the contour plot

; Now add a polyline at the location of maximum winds (first, create the two points that define the polyline - go from the bottom x-axis to the top x-axis at the radius of maxinum winds)
        xpts = (/rmax_coord_km(i),rmax_coord_km(i)/)
	ypts = (/              0d,             75d/)

;        polyres@gsLineLabelString = "test"; "r~B~c~N~ = "+rmax_coord_km(i)+" km"    ; normally, we could add a line label string using this resource
;        polyres@gsLineLabelString = "test"; "r~B~c~N~ = "+rmax_coord_km(i)+" km"    ; normally, we could add a line label string using this resource
										     ; however, for some reason, the complicated string we are adding causes nothing to be printed (a bug?),
										     ; so we'll add the label using gsn_add_text 
; Add the polyline marking the radius of maximum winds
	dumline(i) = gsn_add_polyline(wks,plot(i),xpts,ypts,polyres)    ; draw each line separately. Each line must contain two points.

; Add the label to the polyline using gsn_add_text
        toid(i) = gsn_add_text(wks,plot(i),"r~B~c~N~ = "+rmax_coord_km(i)+" km",xpts(0)+3d,avg(ypts),txres2)

; If we want individual axis labels, we now have to add the right y-axis using gsn_create_text and gsn_add_annotation
        if (axislabelstyle .eq. "individual") then
           txid(i) = gsn_create_text(wks,imuc_coord@long_name+" (km)",txres)
           annoid(i) = gsn_add_annotation(plot(i),txid(i),amres)  ; Attach string to plot
        end if

     end do


;******************
; Draw panel plot * 
;******************
     resP = True

     resP@gsnPanelMainString = "Variation of T~B~t~N~(0) with Heating Location and Rossby Radius"	; a common title for the entire panel plot
     resP@gsnPanelMainFontHeightF = 0.025 
     
     resP@gsnPanelXWhiteSpacePercent = 5	; set a bit of extra white space between panels in the x and y directions
     resP@gsnPanelYWhiteSpacePercent = 5

     resP@gsnPanelLabelBar = True	; turn on a common labelbar for the entire panel plot
     resP@lbTitlePosition = "Bottom"	; put it below the plot
     resP@lbTitleString = "Temperature Tendency at Vortex Center (K h~S~-1~N~)" ; give the labelbar a title
     resP@lbTitleFontHeightF = 0.018	; tweak the size of the labelbar title
     resP@lbTitleOffsetF = 0.2		; positive values are up when the labelbar is under the plot
     resP@pmLabelBarOrthogonalPosF = -0.07	; move the labelbar down a bit so we have room for the overall x-axis

     if (axislabelstyle .eq. "panel") then
        resP@gsnFrame         = False           ; don't advance the frame when paneling so we can use gsn_text_ndc afterwards to add the common x- and y-axis labels

; Make room for overall axis labels on instead of individual ones
        resP@gsnPanelLeft  = 0.1	; shrink panel plot so that there is extra room for the left y-axis label
        resP@gsnPanelRight = 0.9	; shrink panel plot so that there is extra room for the right y-axis label
     end if

     gsn_panel(wks,plot,(/2,3/),resP)   ; panel the plots

     if (axislabelstyle .eq. "panel") then
 ; Create another set of text resources for overall axis labels  
        txres3               = True             
        txres3@txAngleF      = 90.          ; Rotate string clockwise 
        txres3@txFontHeightF = 0.02
        gsn_text_ndc(wks,vmax_coord@long_name + " (" + vmax_coord@units + ")",0.085,0.5,txres3)	; add the common left y-axis label
        gsn_text_ndc(wks,imuc_coord@long_name + " (km)",0.915,0.5,txres3)	                ; add the common right y-axis label

        txres3@txAngleF      = 0.                                               ; put back to normal orientation 
        gsn_text_ndc(wks,hloc_coord@long_name + " (km)",0.5,0.26,txres3)	; add the common bottom x-axis label

        frame(wks)	; now frame the plot and we're done
     end if

     delete(plot)
     delete(wks)
     delete(res)
     delete(resP)
     delete(txres)
     delete(txres2)
     if (axislabelstyle .eq. "panel") then
        delete(txres3)
     end if
     delete(amres)
     delete(polyres)
     delete(dumline)  
     delete(toid)
     delete(txid)
     delete(annoid)   

end
