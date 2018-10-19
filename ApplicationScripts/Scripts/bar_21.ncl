;----------------------------------------------------------------------
; bar_21.ncl
;
; Concepts illustrated:
;   - Drawing bars instead of curves in an XY plot
;   - Drawing a bar chart of already-binned data
;   - Drawing a histogram
;   - Setting the bin intervals in a histogram
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
;----------------------------------------------------------------------

begin
;---Generate 1D array of random data
  npts = 50
  y = random_uniform(0,100,npts)

  levels = ispan(0,100,10)

  wks = gsn_open_wks("png","bar")

;---Create a histogram of random data.
  hres                          = True
  hres@gsnMaximize              = True
  hres@gsnHistogramBinIntervals = levels
  hres@tiMainString             = "Histogram"
  plot = gsn_histogram(wks,y,hres)

;
; Using the bin counts from the previous plot, create
; a bar chart of the already binned data.
;
  nlevels = dimsizes(levels)
  ybinned = plot@NumInBins        ; the binned data
  x       = (levels(1:)+levels(0:nlevels-2))*0.5  ; the mid point of each range

  xyres                       = True
  xyres@gsnMaximize           = True

  xyres@gsnXYBarChart         = True
  xyres@gsnXYBarChartColors   = "blue"
  xyres@gsnXYBarChartBarWidth = 0.8*(levels(1)-levels(0))  ; 80% of the width

  xyres@trYMinF               = 0.
  xyres@trYMaxF               = max(ybinned)+1 
  xyres@trXMinF               = min(levels)
  xyres@trXMaxF               = max(levels)

  xyres@tmXBMode              = "Explicit"
  xyres@tmXBValues            = levels
  xyres@tmXBLabels            = ""+levels

  xyres@tiMainString          = "Bar chart of already-binned data"
  xyres@tiXAxisString         = "Intervals"
  xyres@tiYAxisString         = "Frequency"

  plot = gsn_csm_xy(wks,x,ybinned,xyres)

end
