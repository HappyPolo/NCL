;*************************************************
; histo_5.ncl
;
; Concepts illustrated:
;   - Drawing a histogram using exact min/max of data
;   - Setting the bin intervals in a histogram
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
  wks = gsn_open_wks("png","histo")              ; send graphics to PNG file
  gsn_define_colormap(wks,"temp1")               ; choose colormap

  res                            = True          ; plot mods desired
  res@gsnHistogramClassIntervals = (/10,30,40,50,60,70,80,90,100/)
  res@tmXBLabelAngleF            = 315.          ; change label angle
  plot=gsn_histogram(wks,x,res)                  ; create histogram
end
