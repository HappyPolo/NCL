;***************************************************************
; bootstrap_diff_1.ncl
;
; Concepts illustrated:
;   - Using bootstrap_stat 
;   - Calculate mean differences via bootstrap
;     - Conventional statistics of the difference betewwn two samples
;     - Bootstrapped differences and other statistics 
;   - Creating a 'text' object to attach to plots
;   - Create a plot with histogram
;***************************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;***************************************************************
; Data source:
; http://www.di.fc.ul.pt/~jpn/r/bootstrap/resamplings.html#bootstrap-to-find-pearson-correlation-of-two-samples
;***************************************************************

  X = (/27,20,21,26,27,31,24,21,20,19,23,24,28,19,24,29,18,20,17,31,20,25,28,21,27/)  ; treated
  Y = (/21,22,15,12,21,16,19,15,22,24,19,23,13,22,20,24,18,20/)                       ; control

;***************************************************************
; NCL function for significance testing of difference between two means
;***************************************************************

  aveX    = avg (X)
  aveY    = avg (Y)
  varX    = variance (X)
  varY    = variance (Y)
  NX      = dimsizes (X)        ; X and Y can be of
  NY      = dimsizes (Y)        ; different sizes
  iflag   = True                ; different variances (Welsh's test)
  probt   = ttest(aveX,varX,NX, aveY,varY,NY, iflag, True) 

  p       = probt(0,0)          ; p     = 0.0007474
  p_tval  = probt(1,0)          ; p_tval= 3.65825

;***************************************************************
; Conventional approach: Welch Two Sample t-test: unequal variances
;***************************************************************

  diffXY  = aveX - aveY                             ; difference     = 4.38
  varP    = ((NX-1)*varX + (NY-1)*varY)/(NX+NY-2)   ; pooled variance
  stdP    = sqrt( varP )                            ; pooled std dev = 3.95 
  stdErr  = stdP*sqrt(1.0/NX + 1.0/NY)              ; std error      = 1.22
  df      = (varX/NX+varY/NY)^2 \                   ; deg of freedom = 39.11
            /((varX/NX)^2/(NX-1)+(varY/NY)^2/(NY-1)) 
  tval    = cdft_t(0.975,df)                        ; tval = 3.658 = p_tval
  diffHi  = diffXY + tval*stdErr                    ;  2.5% CI = 1.90939
  diffLow = diffXY - tval*stdErr                    ; 97.5% CI = 6.84617

;***************************************************************
;--- Set bootstrap parameters and any desired options
;***************************************************************

  nBoot = 1000                      ; bootstrap replications
  opt   = False                     ; Use defaults

;***************************************************************
;--- bootstrap_stat: extract information from returned 'list' variable: Bootstrap
;***************************************************************

  BootStrap     = bootstrap_diff(X, Y, nBoot, 0, opt)
  xyBootDiff    = BootStrap[0]       ; avg  of 'nBoot' bootstrapped differences
  xyBootDiffAvg = BootStrap[1]       ; avg  of 'nBoot' bootstrapped differences
  xyBootDiffStd = BootStrap[2]       ; std dev  of 'nBoot' bootstrapped differences
  delete(BootStrap)

  xyBootDiffLow = bootstrap_estimate(xyBootDiff, 0.025, False)   ;  2.5% lower confidence bound 
  xyBootDiffMed = bootstrap_estimate(xyBootDiff, 0.500, False)   ; 50.0% median of bootstrapped estimates
  xyBootDiffHi  = bootstrap_estimate(xyBootDiff, 0.975, False)   ; 97.5% upper confidence bound

  xyBootDiff@long_name = "Bootstrapped Differences"

;***************************************************************
;--- PLOTS
;***************************************************************
  pltDir  = "./"
 ;pltName = "Boot_DIFF_"+NX+"_"+NY+"_"+nBoot
  pltName = "bootstrap_diff"
  pltPath = pltDir+pltName
  pltType = "png"                 ; send graphics to PNG file
  wks  = gsn_open_wks (pltType,pltPath)

  resh = True
  resh@gsnDraw      = False
  resh@gsnFrame     = False

;***************************************************************
;--- create histogram for the original sample
;***************************************************************

  NXY = max( (/NX,NY/) )
  XY  = new((/2,NXY/), "float")   ; easier to put both in same array for plotting
  XY(0,0:NX-1) = X
  XY(1,0:NY-1) = Y

  resh@gsFillColor  = "green"     ; all original sample plots are green
  resh@tiMainString = "Original Samples: NX="+NX+"  NY="+NY
  resh@gsnHistogramCompare = True
  hstSample         = gsn_histogram(wks, XY ,resh)  

;***************************************************************
;--- text object original sample statistics 
;***************************************************************

  txres                       = True
  txres@txFont                = "helvetica-bold"
  txres@txFontHeightF         = 0.0150
  textSample = (/" xyDiff="+sprintf("%5.2f", diffXY)   +"~C~"+  \
                 "   xAvg="+sprintf("%5.2f", aveX)     +"~C~"+  \
                 "   yAvg="+sprintf("%5.2f", aveY)     +"~C~"+  \
                 "diffLow="+sprintf("%5.2f", diffLow)  +"~C~"+  \
                 "diffHi ="+sprintf("%5.2f", diffHi )  +"~C~"+  \
                 "      p="+sprintf("%5.2f",    p)     +"~C~"+  \
                 "      t="+sprintf("%5.2f", tval)     /)
  txBoxSample= gsn_create_text(wks,textSample, txres)
 
  amres = True
  amres@amParallelPosF   =  0.25             ; move legend to the right
  amres@amOrthogonalPosF = -0.35             ; move the legend up
  annoDiff = gsn_add_annotation(hstSample, txBoxSample, amres)  ; Attach string to plot

;***************************************************************
;--- create histogram for the bootstrapped samples  
;***************************************************************
  delete(resh@gsnHistogramCompare)          ; not applicable to next plot

  resh@gsFillColor   = "mediumturquoise"    ; bootstrapped are blue
  resh@tiYAxisString = ""                   ; do not want a 2nd 'Frequency' label 
  resh@tiMainString  = "nBoot="+nBoot+": NX="+NX+" NY="+NY
  hstBoot = gsn_histogram(wks, xyBootDiff ,resh)

;***************************************************************
;--- text object bootstrapped statistics 
;***************************************************************

  textBoot  = (/"BootDiffAvg="+sprintf("%5.2f", xyBootDiffAvg)    +"~C~"+  \
                "BootDiffStd="+sprintf("%5.2f", xyBootDiffStd) +"~C~"+  \
                "BootDiffLow="+sprintf("%5.2f", xyBootDiffLow) +"~C~"+  \
                "BootDiffHi ="+sprintf("%5.2f", xyBootDiffHi ) /)
  txBoxyBoot  = gsn_create_text(wks,textBoot, txres)
 
  amres@amParallelPosF   = -0.30             ; move legend to the left
  amres@amOrthogonalPosF = -0.35             ; move the legend up
  annoBoot = gsn_add_annotation(hstBoot, txBoxyBoot, amres)  ; Attach string to plot

;************************************************
; create panel
;************************************************
  resP                     = True              ; modify the panel plot
  resP@gsnMaximize         = True              ; regional data
  resP@txFontHeightF       = 0.021
  resP@txString            = "Sample and Bootstrap"
  gsn_panel(wks,(/hstSample, hstBoot/),(/1,2/), resP)             ; now draw as one plot
