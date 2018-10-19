;----------------------------------------------------------------------
; tm_5.ncl
;
; Concepts illustrated:
;   - Moving tickmark labels away from axis
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  arr = random_uniform(-250.,230.,101)
	
  wks = gsn_open_wks("png","tm") ; send graphics to PNG file

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
  res@gsnYRefLine = 0.		; set the reference line equal to 0
  res@gsnAboveYRefLineColor = "Red"	
  res@gsnBelowYRefLineColor = "Blue"
  res@trYReverse = True		; reverse the Y-axis
  res@tmXBLabelAngleF = 45	; tilt the XB labels 45 degrees
  res@tmXBLabelDeltaF = 1.5	; push the XB labels down from plot
  res@tmXBLabelFontColor = "green"

  plot = gsn_csm_xy(wks,ispan(0,100,1),arr,res)
end
