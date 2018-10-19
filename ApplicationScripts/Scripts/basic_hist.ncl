  y = (/3.1,0.5,3.8,3.4,2.1,1.5,2.6,2.3,3.6,1.7/)
  wks = gsn_open_wks("x11","hist")
  plot = gsn_histogram(wks,y,False)

  res = True
  res@gsnHistogramBinIntervals = (/0,1,2,3,4/)
  plot = gsn_histogram(wks,y,res)
