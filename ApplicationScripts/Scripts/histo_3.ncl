;*************************************************
; histo_3.ncl
;
; Concepts illustrated:
;   - Drawing a histogram using discrete bin values
;   - Sorting data
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
; we are going to do some things to get a smaller
; sample out of array x, so that we can create
; discrete bins.
;************************************************
  x_short = x
  qsort(x)
  x_short(ind(x_short.ge.25)) = -999
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","histo")          ; send graphics to PNG file
  gsn_define_colormap(wks,"temp1")           ; choose colormap

  res                                = True
  res@tmXBLabelStride                = 2     ; every other x-label
  res@gsnHistogramDiscreteBinValues  = ispan(0,25,1)
  plot=gsn_histogram(wks,x,res)         ; create histogram with 20 bins
end
