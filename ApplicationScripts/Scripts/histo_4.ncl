;*************************************************
; histo_4.ncl
;
; Concepts illustrated:
;   - Drawing a histogram using exact min/max of data
;   - Generating dummy data using "rand"
;   - Drawing X axis labels at a 45 degree angle
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
  wks = gsn_open_wks("png","histo")             ; send graphics to PNG file
  gsn_define_colormap(wks,"temp1")              ; choose colormap

  res                                 = True
  res@gsnHistogramSelectNiceIntervals = False   ; intervals now float
  res@gsnHistogramComputePercentages  = True    ; change left axis to %
  res@tmXBLabelAngleF                 = 315.    ; change label angle
  plot=gsn_histogram(wks,x,res)                 ; create histogram with 10 bins
end
