;*************************************************
; panel_16.ncl
;
; Concepts illustrated:
;   - Paneling three plots vertically on a page
;   - Making paneled plots smaller on the page for publication purposes
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  a = addfile("80.nc","r")
  u = a->U(0,17,:,:)               ; read surface winds
  v = a->V(0,17,:,:)
  windspd = u			   ; done to keep coordinate variables
  windspd = (/ sqrt(u^2+v^2) /)	   ; compute wind speed
  windspd@long_name = "wind speed"
;************************************************
; create plots
;************************************************
  wks = gsn_open_wks("png","panel")           ; send graphics to PNG file
  gsn_define_colormap(wks,"gui_default")      ; choose colormap
  plot = new(3,graphic)                       ; create a plot array
  
  res                     = True
  res@gsnDraw             = False           ; don't draw
  res@gsnFrame            = False           ; don't advance frame
  res@cnInfoLabelOn       = False           ; turn off cn info label
  res@cnFillOn            = True            ; turn on color
  res@gsnSpreadColors     = True            ; spread out color table
  res@gsnSpreadColorStart = 2 
  res@gsnSpreadColorEnd   = -3 
  res@lbLabelBarOn        = False           ; turn off individual cb's
  res@txFontHeightF = 0.030		    ; adjust font height of gsnLeftString/gsnRightString titles
  res@tmYLLabelFontHeightF = 0.018	    ; adjust Y axis left hand label font heights
  res@tmXBLabelFontHeightF = 0.018	    ; adjust X axis bottom label font heights

; to have a common label bar, both plots should be set to the same interval
; b/c the label bar is drawn by default from the interval of the first plot.
  res@cnLevelSelectionMode =  "ManualLevels"   
  res@cnMinLevelValF       = -10.
  res@cnMaxLevelValF       =  35.
  res@cnLevelSpacingF      =   5. 

  plot(0) = gsn_csm_contour_map_ce(wks,u,res) 
  plot(1) = gsn_csm_contour_map_ce(wks,v,res) 
  plot(2) = gsn_csm_contour_map_ce(wks,windspd,res) 
;************************************************
; create panel
;************************************************
  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance the frame, so we can use gsn_text_ndc
  resP@gsnPanelLabelBar = True                   ; add common colorbar
  resP@lbLabelFontHeightF = 0.015		 ; set font height of Label Bar labels
  resP@gsnPanelBottom   = 0.2			 ; shrink panel plot by setting bottom edge of plot
  resP@gsnPanelTop      = 0.9			 ; shrink panel plot by setting top edge of plot
  resP@gsnPanelYWhiteSpacePercent = 5.	 	 ; increase spacing along Y-axis between panel plots
  resP@gsnPanelMainString = "A common title"     ; added in NCL V6.4.0
; resP@txString   = "A common title"             ; use this in NCL V6.3.0 and earlier
  gsn_panel(wks,plot,(/3,1/),resP)               ; now draw as one plot


  txres               = True
  txres@txFontHeightF = 0.015
  gsn_text_ndc(wks,"Figure 16: A smaller panel plot",0.5,0.16,txres)
  frame(wks)

end
