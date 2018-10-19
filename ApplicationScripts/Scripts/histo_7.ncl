;*************************************************
; histo_7.ncl
;
; Concepts illustrated:
;   - Specifying the bar fill colors in a histogram
;   - Generating dummy data using "rand"
;
;************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
;************************************************
begin
;************************************************
; Generate some random data.
;************************************************
  x = new(1000,integer)
  do i=0,dimsizes(x)-1
    x(i) = rand()
  end do
  x = x/320
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","histo")          ; send graphics to PNG file

  res             = True
;---Use this with NCL 6.3.0 and earlier
  res@gsFillColor = (/"black","red","blue","green","brown","yellow"/)

;---Use this with NCL 6.4.0 and later
;  res@gsnHistogramBarColors = (/"black","red","blue","green","brown","yellow"/)
  plot = gsn_histogram(wks,x,res)            ; create histogram with 10 bins
end
