;*************************************************
; histo_15.ncl
;
; Concepts illustrated:
;   - Generating dummy data using "rand"
;   - Putting your own labels on the X axis in a histogram
;   - Drawing X axis labels at a 45 degree angle
;   - Sorting data
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
; we are going to do some things to get a smaller
; sample out of array x, so that we can create
; discrete bins.
;************************************************
  x_short = x
  qsort(x)
  x_short(ind(x_short.ge.100)) = -999
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","histo")           ; send graphics to PNG file
  gsn_define_colormap(wks,"ncview_default")   ; choose colormap

; Create the histogram, but don't draw it.
  res                                = True
  res@gsnHistogramDiscreteBinValues  = ispan(0,99,3)
  res@tiMainString                   = "Every bar is labeled with a number"

  plot = gsn_histogram(wks,x_short,res)

;
; Using the information from the histogram, we can now select
; which X tickmarks to label.
;
  res@gsnDraw    = True
  res@gsnFrame   = True

  res@tmXBMode        = "Explicit" 
  res@tmXBValues      = plot@MidBarLocs(::4)
  res@tmXBLabelAngleF = -45
  res@tmXBLabelJust   = "CenterLeft"
  res@tmXBLabels      = (/"zero","twelve","twenty-four","thirty-six",\
                          "forty-eight","sixty","seventy-two","eighty-four",\
                          "ninety-six"/)

  res@tiMainString = "Every four bar labeled with a string"

  plot = gsn_histogram(wks,x_short,res)


end
