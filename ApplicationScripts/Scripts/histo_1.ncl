;*************************************************
; histo_1.ncl
;
; Concepts illustrated:
;   - Drawing a default histogram
;   - Manually creating an array of random data
;   - Setting the bin intervals in a histogram
;************************************************
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
;************************************************
begin
  y = (/3.1,0.5,3.8,3.4,2.1,1.5,2.6,2.3,3.6,1.7/)

  wks = gsn_open_wks("png","histo")

;---Let NCL pick the bin intervals
  res = True
  res@tiMainString = "Let NCL pick bin intervals"
  plot = gsn_histogram(wks,y,res)

;--Manually set the bin intervals
  res@tiMainString = "Manually set the bin intervals"
  res@gsnHistogramBinIntervals = (/0,1,2,3,4/)
  plot = gsn_histogram(wks,y,res)

end
