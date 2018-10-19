;*************************************************
; overlay_4.ncl
;
; Concepts illustrated:
;   - Overlaying plots manually by not advancing the frame
;   - Maximizing plots after they've been created
;   - Comparing two sets of histograms
;   - Outlining bars in a histogram
;   - Overlaying multiple histograms for comparison
;
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  x = floattointeger(random_uniform(-6,5,150))
  y = floattointeger(random_uniform(-6,5,150))
  
  wks = gsn_open_wks("png","overlay")               ; send graphics to PNG file
  
  res = True
  res@gsnHistogramClassIntervals = fspan(-6,6,13)   ; explicitly set the histogram bins
  res@trYMaxF = 40.                                 ; set the maximum Y-axis value
  res@gsnHistogramBarWidthPercent = 100.            ; set the bar width to 100% of bin size
  res@gsFillColor = "gray70"                        ; color fill the bars gray 
  res@gsEdgeColor = res@gsFillColor                 ; set the bar edge to the same color as the bar itself
  res@gsnDraw = False                               ; do not draw the plot
  res@gsnFrame = False                              ; do not advance the frame
  res@tiXAxisOn = False                             ; turn off the X-axis title
  res@tiYAxisOn = False                             ; turn off the Y-axis title
  
  plot = gsn_histogram(wks,x,res)                   ; create the 1st histogram
  
  res2 = True                                       
  res2@gsnHistogramClassIntervals = fspan(-6,6,13)  ; explicitly set the histogram bins (same as 1st histogram plot)
  res2@trYMaxF = 40.                                ; set the maximum Y-axis value (same as 1st histogram plot)
  res2@gsnHistogramBarWidthPercent = 100            ; set the bar width to 100% of bin size
  res2@gsFillColor = -1                             ; set the bar fill color to transparent
  res2@gsEdgeColor = "blue"                         ; set the edge of the bars to blue
  res2@gsnDraw = False                              ; do not draw the plot
  res2@gsnFrame = False                             ; do not advance the fram
  res2@tiXAxisOn = False                            ; turn off the X-axis title
  res2@tiYAxisOn = False                            ; turn off the Y-axis title

  plot2 = gsn_histogram(wks,y,res2)                 ; create the 2nd histogram
  
; You can't use gsnMaximize above to maximize plots in the frame,
; because you will be maximizing the individual plots, and not
; the two of them together.
;
; Instead, after the plots have been created, 
; maximize them with the maximize_output procedure.
;
  psres = True
  psres@gsnPaperOrientation = "portrait"
  maximize_output(wks,psres)
end
  
