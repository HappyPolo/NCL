;********************************************************
; tm_6.ncl
;********************************************************
; Concepts illustrated:
;   - Drawing a time series plot
;   - Setting boundaries on XY plots
;   - Setting axis tickmarks and location
;   - Using function codes for superscript symbols
;********************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  a = addfile("tempcarbon.nc","r")
  temp   = a->TEMP		;time series, 1851-2000
;==========================================================
  wks = gsn_open_wks("png","tm")                ; send graphics to PNG file
  gsn_define_colormap(wks,"gsdtol")	

  res=True   
  res@tmYLLabelFontHeightF = 0.017
  res@tmXBLabelFontHeightF = 0.017
  res@trYMinF = -0.80       			; set Y-axis min
  res@trYMaxF = 0.6		  		; set Y-axis max
  res@trXMinF = 1860				; set X-axis min
  res@trXMaxF = 2000				; set X-axis max
  res@xyLineThicknessF    = 2.5
	
  res@tmYLMode   = "Explicit"  			; explicitly set Y-axis labels
  res@tmYLValues = (/"-.8","-.6","-.4","-.2","0",".2",".4",".6"/)
  res@tmYLLabels = (/"-0.8","-0.6","-0.4","-0.2","0","0.2","0.4","0.6"/)
  res@tmXBMajorOutwardLengthF = 0.021	; set tickmarks 
  res@tmXBMinorOutwardLengthF = 0.015
  res@tmXBMajorLengthF = 0.021
  res@tmXBMinorLengthF = 0.008

  res@tmYRLabelsOn = True		; turn the YR labels on
  res@tmYUseLeft = False		; use different resources for the right Y-axis
					; and the left Y-axis. 
  res@tmYRLabelFontColor = 18		; set the YR Labels to a medium gray color
  res@tmYRPrecision = 3			; set the precision to 4 significant digits

  res@tiYAxisSide = "Right"		; put the Y-axis title on the right
  res@tiYAxisString = "Global Temperature (~S~o~N~C)"
  res@tiXAxisString = "Year"

  plot = gsn_csm_xy(wks,ispan(1851,2000,1),temp,res)
end

	
