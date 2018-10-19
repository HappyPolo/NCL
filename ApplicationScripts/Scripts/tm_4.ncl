;*******************************************************
; tm_4.ncl
;*******************************************************
; Concepts illustrated:
;   - Setting XY plot boundaries
;   - Drawing a bar chart
;   - Paneling XY plots
;   - Setting axis formats using specifiers
;*******************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  arr = random_uniform(-2.5e6,3.5e+6,101)
	
  wks = gsn_open_wks("png","tm")  ; send graphics to PNG file
  gsn_define_colormap(wks,"gsdtol")

  res = True
; The following vp resources set the boundaries of the xy plot
; in ndc grid space (0.->1.)
  res@vpWidthF = 0.8		; set width of plot 
  res@vpHeightF = 0.3		; set height of plot
  res@vpXF = 0.1		; set left hand side start point of plot
			 	; as vpWidthF = .8, plot will occupy .1->.9 in NDC coords.
						
  res@trXMinF = 0		; set minimum X-axis value
  res@trXMaxF = 100		; set maximum X-axis value

  res@gsnXYBarChart = True	; turn on bar chart option
  res@gsnYRefLine = 0.			; set the reference line equal to 0
  res@gsnAboveYRefLineColor = "White"	
  res@gsnBelowYRefLineColor = "Gray"
	
  res@gsnDraw = False		; don't draw the plots, gsn_panel will draw them
  res@gsnFrame = False		; don't advance the frame, gsn_panel will

  plot = new(3,graphic)		; preallocate graphics array for two panel plots
  plot(0) = gsn_csm_xy(wks,ispan(0,100,1),arr,res)
	
; 	default Format = "0@*+^sg"
  res@tmYLFormat = "0*+^e"	; use "e" symbol, don't force 0's (see documentation)
  res@tmYLMinorOn = False	; turn the minor tick marks off
  res@tmXBPrecision = 6		; set the precision to 6 significant digits
  plot(1) = gsn_csm_xy(wks,ispan(0,100,1),arr,res)	
	
  res@tmXBPrecision = 2		; set the precision to 2 significant digits
  res@tmYLFormat = "#+^se"	; don't use "e" symbol, always show +/-
  plot(2) = gsn_csm_xy(wks,ispan(0,100,1),arr,res)	
	
  panres = True						; panel resource list
  panres@gsnPanelYWhiteSpacePercent = 5.0		; set spacing vertically between 2 panels
  gsn_panel(wks,plot,(/3,1/),panres)	
end
