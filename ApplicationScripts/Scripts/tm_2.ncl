;----------------------------------------------------------------------
; tm_2.ncl
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
  arr = random_uniform(-4.,4.,56)
	
  wks = gsn_open_wks("png","tm") ; send graphics to PNG file
  gsn_define_colormap(wks,"gsdtol")

  res = True
	
; The following vp resources set the boundaries of the xy plot
; in ndc grid space (0.->1.)
  res@vpWidthF        = 0.8	; set width of plot 
  res@vpHeightF       = 0.3	; set height of plot
  res@vpXF            = 0.1	; set left hand side start point of plot
				; as vpWidthF = .8, plot will occupy .1->.9 in NDC coords.
						
  res@trXMinF         = 1949	; set minimum X-axis value
  res@trXMaxF         = 2006	; set maximum X-axis value
	
  res@gsnDraw         = False	; don't draw the plots, gsn_panel will draw them
  res@gsnFrame        = False	; don't advance the frame, gsn_panel will
  res@txFontHeightF   = 0.015	; set font height of gsn*String

  res@tmXBMode        = "Manual"	
  res@tmXBTickStartF  = 1950
  res@tmXBTickEndF    = 2005
  res@tmXBTickSpacingF= 5
  res@gsnLeftString   = "tmXBMode = Manual"

  plot = new(2,graphic)		; preallocate graphics array for two panel plots

  plot(0) = gsn_csm_xy(wks,ispan(1950,2005,1),arr,res)
	
  res@tmXBMode        = "Explicit"	
  res@tmXBValues      = (/1950,1960,1970,1980,1990,2000,2005/)
  res@tmXBLabels      = "" + res@tmXBValues 
  res@tmXBMinorValues = ispan(1949,2006,1)
  res@gsnLeftString   = "tmXBMode = Explicit"

  plot(1) = gsn_csm_xy(wks,ispan(1950,2005,1),arr,res)	
	
  panres = True					; panel resource list
  panres@gsnPanelYWhiteSpacePercent = 5.0	; set spacing vertically 
                                                ; between 2 panels
	
  gsn_panel(wks,plot,(/2,1/),panres)	
end
