;----------------------------------------------------------------------
; tm_3.ncl
;
; Concepts illustrated:
;   - Explicitly setting tickmarks and labels on the bottom X axis
;   - Setting the spacing for tickmarks
;   - Setting the mininum/maximum value of the Y axis in an XY plot
;   - Changing the width and height of a plot
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  arr = random_uniform(-3.5,4.,56)
	
  wks = gsn_open_wks("png","tm")        ; send graphics to PNG file
  gsn_define_colormap(wks,"gsdtol")

  res = True
	
; The following vp resources set the boundaries of the xy plot
; in ndc grid space (0.->1.)
  res@vpWidthF = 0.8			; set width of plot 
  res@vpHeightF = 0.3			; set height of plot
  res@vpXF = 0.1			; set left hand side start point of plot
					; as vpWidthF = .8, plot will occupy .1->.9 in NDC coords.
						
  res@trXMinF = 1949			; set minimum X-axis value
  res@trXMaxF = 2006			; set maximum X-axis value

  res@gsnXYBarChart = True		; turn on bar chart option
  res@gsnYRefLine = 0.			; set the reference line equal to 0
  res@gsnAboveYRefLineColor = "White"	
  res@gsnBelowYRefLineColor = "Gray"
	
  res@gsnDraw = False			; don't draw the plots, gsn_panel will draw them
  res@gsnFrame = False			; don't advance the frame, gsn_panel will

  plot = new(2,graphic)			; preallocate graphics array for two panel plots

  res@tmYROn = False
  res@tmXTOn = False
  res@tmYRBorderOn = False
  res@tmXTBorderOn = False
  res@tmXBLabelFontHeightF = 0.015
  plot(0) = gsn_csm_xy(wks,ispan(1950,2005,1),arr,res)
	
  ; res@tmXBLabelFontHeightF = 0.015
  plot(1) = gsn_csm_xy(wks,ispan(1950,2005,1),arr,res)	
	
  panres = True						; panel resource list
  panres@gsnPanelYWhiteSpacePercent = 5.0		; set spacing vertically between 2 panels
  gsn_panel(wks,plot,(/2,1/),panres)	
end
