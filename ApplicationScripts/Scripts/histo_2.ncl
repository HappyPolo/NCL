;*************************************************
; histo_2.ncl
;
; Concepts illustrated:
;   - Drawing a histogram
;   - Setting the number of bins in a histogram
;   - Setting the bin intervals in a histogram
;   - Generating dummy data using "rand"
;   - Paneling histograms
;
;************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
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

  plot = new(3,graphic)

  res                          = True
  res@gsnDraw                  = False
  res@gsnFrame                 = False
  res@gsnHistogramNumberOfBins = 10
  res@tiMainFuncCode           = ":"   ; default is ~
  res@tiMainString             = "# of bins ~= 10"
  plot(0)=gsn_histogram(wks,x,res)

  res@gsnHistogramNumberOfBins = 20
  res@tiMainString             = "# of bins ~= 20"
  plot(1)=gsn_histogram(wks,x,res)
  delete(res@gsnHistogramNumberOfBins)

  res@gsnHistogramClassIntervals = (/0,5,15,30,50,70,100/)
  res@tiMainString               = "Explicitly setting bin intervals"
  plot(2)=gsn_histogram(wks,x,res)

  gsn_panel(wks,plot,(/1,3/),False)
end
