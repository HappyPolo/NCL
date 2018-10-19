;=========================================================
; tm_7.ncl
;=========================================================
; Concepts illustrated:
;   - Explicitly setting axis tickmark locations
;   - Comparing linear and logarithmic axes
;   - Paneling two or more plots
;=========================================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  arr = random_uniform(-25.,18.,10)	; set up dummy array
  arr!0 = "lev"
  arr&lev = fspan(1000., 225., 10)
;=========================================================
  wks = gsn_open_wks("png","tm")	        ; send graphics to PNG file

  res = True
  res@gsnDraw = False     ; don't draw the plots
  res@gsnFrame = False    ; don't advance the frame

  res@trYMinF = 250
  res@xyLineThicknessF   = 3.5  		; Define line thickness
  res@xyLineColors        = "blue"		; set the line color
  res@tmYLMode   = "Explicit"			; explicitly set the Y-axis labels
  res@tmYLValues = (/1000,925,850,700,600,500,400,300,250/)
  res@tmYLLabels = "" + res@tmYLValues
  res@trYReverse = True				; reverse the Y-axis	
		
  res@tiXAxisString = "Amplitude"                   ; x-axis label
  res@tiYAxisString = "Pressure (hPa)"              ; y-axis label

  plot = new(2,graphic)   	; preallocate graphics array for two panel plots
  res@gsnLeftString = "Linear Y-axis"
  plot(0) = gsn_csm_xy(wks,arr,arr&lev,res)

  res@tmXBLabelStride = 2
  res@trYLog     = True		; use a logarithmic coordinate system for the Y-axis
  res@gsnLeftString = "Logarithmic Y-axis"
  plot(1) = gsn_csm_xy(wks,arr,arr&lev,res)

  gsn_panel(wks,plot,(/1,2/),False)		; gsn_panel draws the plots, advances the frame
									; automatically
end

	
