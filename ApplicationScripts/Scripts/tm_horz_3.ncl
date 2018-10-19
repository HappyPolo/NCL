;----------------------------------------------------------------------
; tm_horz_3.ncl
;
; Concepts illustrated:
;   - Explicitly setting tickmarks and labels on the left Y axis
;   - Setting the spacing for tickmarks
;   - Setting the minimum/maximum value of the X axis in an XY plot
;   - Changing the width and height of a plot
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  arr = random_uniform(-3.5,4.,56)
	
  wks = gsn_open_wks("png","tm_horz")   ; send graphics to PNG file
  gsn_define_colormap(wks,"gsdtol")

  res = True
	
; The following vp resources set the boundaries of the xy plot
; in ndc grid space (0.->1.)
  res@vpWidthF = 0.3			; set width of plot 
  res@vpHeightF = 0.8			; set height of plot
  res@vpYF = 0.1			; set left hand side start point of plot
					; as vpWidthF = .8, plot will occupy .1->.9 in NDC coords.
						
  res@trYMinF = 1949			; set minimum X-axis value
  res@trYMaxF = 2006			; set maximum X-axis value

  res@gsnXYBarChart = True		; turn on bar chart option
  res@gsnXRefLine = 0.			; set the reference line equal to 0
  res@gsnRightXRefLineColor = "White"	
  res@gsnLeftXRefLineColor  = "Gray"
	
  res@gsnDraw = False			; don't draw the plots, gsn_panel will draw them
  res@gsnFrame = False			; don't advance the frame, gsn_panel will

  plot = new(2,graphic)			; preallocate graphics array for two panel plots

  res@tmXTOn = False
  res@tmYROn = False
  res@tmXTBorderOn = False
  res@tmYRBorderOn = False
  plot(0) = gsn_csm_xy(wks,arr,ispan(1950,2005,1),res)
	
;  res@tmXBLabelsOn = False
;  res@tmYLLabelFontHeightF = 0.015
  plot(1) = gsn_csm_xy(wks,arr,ispan(1950,2005,1),res)	
	
  panres = True						; panel resource list
  panres@gsnPanelXWhiteSpacePercent = 5.0		; set spacing vertically between 2 panels
  gsn_panel(wks,plot,(/1,2/),panres)	
end
