;***********************************************************
; resampling_1.ncl
;
; Concepts illustrated:
;   - Generating random number seeds based on a 'clock'
;   - Generate 'resampling with replacement' indices
;     Use: generate_sample_indices( N, 1 )
;   - Use histogram to display distribution
;   - create a panel plot
;***********************************************************
;--- Specify sample sizes
;***********************************************************

  NS    = (/ 25, 100, 500, 1000, 5000, 10000, 100000, 1000000 /)
  NP    = dimsizes(NS)
  plot  = new (NP, "graphic", "No_FillValue")

;***********************************************************
;--- Generate and use random number seeds for initialization
;***********************************************************

  rand1 = toint(systemfunc(" date +%s"))
  rand2 = toint((54321l*rand1)%2147483398l)
  random_setallseed(rand1, rand2)

;***********************************************************
;--- Plot a histogram of index distributions for each sample size
;    
;***********************************************************

  wks  = gsn_open_wks ("png","resampling")  ; send graphics to PNG file
  gsn_define_colormap(wks,"default")  ; 30 distinct colors

  resh           = True
  resh@gsnDraw   = False
  resh@gsnFrame  = False
  resh@tmXBLabelStride = 1   
  resh@tiMainOffsetYF  = -0.020       ; move tiMain down into plot
 ;resh@gsnHistogramBinWidth = ?? ; for 'tuning' ... if desired

;***********************************************************
;--- Loop 
;***********************************************************
  
  do plotnum=0,2
    do np=0,NP-1
       iw := generate_sample_indices( NS(np), 1 )

       iw@long_name = "N="+NS(np)
       printMinMax(iw, 0)
       resh@tiMainString = iw@long_name
       delete(iw@long_name)  ; do not want on plot

       if (np.eq.0 .or. np.eq.4) then      ; reduce clutter
           resh@tiYAxisString = "Frequency"
       else
         resh@tiYAxisString = " "         ; No title on Y axis.
       end if

       plot(np) = gsn_histogram(wks, iw  ,resh)
    end do

  resP              = True
  resP@gsnMaximize  = True
  resP@txString     = "Distribution: Uniform Random Indices w/ Replacement"
  resP@gsnPanelLeft  = 0.01  ; make room on left and right side of paneled
  resP@gsnPanelRight = 0.99  ; plots for text and tickmarks
  gsn_panel(wks,plot,(/2,4/),resP)
  end do
