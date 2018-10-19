;************************************************
; bootstrap_correl_1.ncl
;
; Concepts illustrated:
;   - Calculate correlation and assorted statistics using original sample
;   - Using bootstrap_correl 
;     - Bootstrapped corelations 
;     - Measures of dispersion
;   - Creating a 'text' object for plots
;   - Create a panel plot of histograms
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;*************************************************
;--- Read data file and extract LSAT and GPA
;    Law School Data: 
;    Efron & Tibshirani (1993)
;    An Introduction to the Bootstrap. Chapman and Hall 
;*************************************************
  N    = 15           ; 82 or 15
  n    = 15           ; bootstrap sub-sample size   
 
  diri = "./"
  fili = "law_school_"+N+".txt"    ; law_school_82.txt or law_school_15.txt
  data = asciiread(diri+fili,(/N,3/), "float")  ; 3 columns

  x    = data(:,1)    ; LSAT
  y    = data(:,2)    ; GPA

;*************************************************
; Basic statistics on the input x & : background information only
;*************************************************

   xStat4      = dim_stat4_n(x, 0)  ; 1st 4 moments of original sample
                                    ; explicitly extract for clarity
   xAvg        = xStat4(0)          ; original sample mean
   xStd        = sqrt(xStat4(1))    ;    "     sample std dev
   xSkew       = xStat4(2)          ; skewness; departure from symmetry
   xKurt       = xStat4(3)          ; kurtosis; relative to a normal distribution
   xMed        = dim_median_n(x,0)  ; median of original sample

                                    ; estimate confidence limits
   df          = N-1                ; degrees of freedom (full sample sixe)               
   p           = 0.975              ; match default bootstrap 'p' (0.025, 0.975)
   tval        = cdft_t(p,df)       ; 2-sided   
   xLow        = xAvg-tval*xStd     ; normal low:  2.5% 
   xHi         = xAvg+tval*xStd     ; normal hi ; 97.5%

   yStat4      = dim_stat4_n(y, 0)  ; 1st 4 moments of original sample
                                    ; explicitly extract for clarity
   yAvg        = yStat4(0)          ; original sample mean
   yStd        = sqrt(yStat4(1))    ;    "     sample std dev
   ySkew       = yStat4(2)          ; skewness; departure from symmetry
   yKurt       = yStat4(3)          ; kurtosis; relative to a normal distribution
   yMed        = dim_median_n(y,0)  ; median of original sample
                                    ; estimate confidence limits
   yLow        = yAvg-tval*yStd     ; normal low:  2.5% 
   yHi         = yAvg+tval*yStd     ; normal hi ; 97.5%

;*************************************************
;--- Compute sample corelation; 'r' distribution is skewed
;--- Fischer z-transform; assumes bivariate normal distribution; really n>=10
;--- "conventional" statistical estimates; get t-value for desired 'p'
;*************************************************

  r    = escorc(x,y)            ; sample cross-correlation

  df   = n-2                    ; degrees of freedom
  z    = 0.5*log((1+r)/(1-r))   ; Fischer z-transform
  zse  = 1.0/sqrt(n-3)          ; standard error of z statistic

  ptst = 0.975                  ; 
  zval = cdft_t(ptst,9999)      ; 2-sided; use 'big' number for normal dist   
  zLow = z-zval*zse             ; z-normal low:  2.5% 
  zHi  = z+zval*zse             ; z-normal hi ; 97.5%
                                ; transform z back to 'r' space
  rLow = tanh(zLow)             ;  =(exp(2*zlow)-1)/(exp(2*zlow)+1)
  rHi  = tanh(zHi)              ;  =(exp(2*zhi )-1)/(exp(2*zhi )+1)

  rse  = sqrt(1-r^2)/sqrt(df)   ; standard error of r statistic  
  t    = r*sqrt(df/(1-r^2))     ; 'classic' t-value for Pearson x-correlation
  p    = student_t(t, df)       ; probability

;*************************************************
;--- bootstrap
;*************************************************

  nBoot = 1000
  opt   = False                 ; use all default options
  if (n.ne.N) then
      opt = True
      opt@sample_size = n     
  end if

  Boot_r     := bootstrap_correl(x, y, nBoot, (/0,0/) , opt)

  rBoot       = Boot_r[0] 
  rBootAvg    = Boot_r[1]       ; average of bootstrapped correlations (via Fischer z)
  rBootStd    = Boot_r[2]       ; via Fisher z 
  delete(Boot_r)                ; no longer needed

  rBootLow    = bootstrap_estimate(rBoot, 0.025, False)   ;  2.5% lower confidence bound 
  rBootMed    = bootstrap_estimate(rBoot, 0.500, False)   ; 50.0% median of bootstrapped estimates
  rBootHi     = bootstrap_estimate(rBoot, 0.975, False)   ; 97.5% upper confidence bound

  rBoot4      = dim_stat4_n(rBoot, 0)
  rBootSkew   = rBoot4(2)          ; skewness of bootstrapd distribution
  rBootKurt   = rBoot4(3)          ; Kurtosis       "           "
;+++++++++++++++++++++++++++++++++++
; PLOTS
;+++++++++++++++++++++++++++++++++++
  pltDir  = "./"
 ;pltName = "BootCor_LSAT_"+N+"_"+n+"_"+nBoot
  pltName = "bootstrap_correl"
  pltPath = pltDir+pltName
  pltType = "png"                  ; send graphics to PNG file
  wks  = gsn_open_wks (pltType,pltPath)

;************************************************
; Panel resources   
;************************************************
 resP                     = True              ; modify the panel plot
 resP@gsnMaximize         = True              ; regional data
;resP@gsnPaperOrientation = "landscape"
 resP@txFontHeightF       = 0.021

;*************************************************
;--- Raw data: x and y
;*************************************************
  resL                        = True 
  resL@gsnMaximize            = True
  resL@xyLineThicknesses      = 2                   ; thicker line
  resL@xyLineColors           = "blue"
  resL@tiYAxisString          = "LSAT [solid]"      ; axis string
  resL@tiXAxisString          = "Subset School Index"

  resR                        = True                      
  resR@xyDashPatterns         = 1                   ; dashed line for 2nd
  resR@xyLineColors           = "red"
  resR@xyDashPatterns         = 1                   ; dashed line for 2nd
  resR@xyLineThicknesses      = 2                   ; thicker line
  resR@tiYAxisString          = "GPA [dash]"        ; axis string

  resR@tiMainString           = fili+ ": LSAT and GPA"
  pltxy = gsn_csm_xy2(wks,ispan(0,N-1,1),x,y,resL,resR)

;*************************************************
;--- Histogram of original x and y samples
;*************************************************
  resh    = True
  resh@gsnDraw       = False
  resh@gsnFrame      = False
  resh@gsFillColor   = "green"
  resh@tiMainString  = "LSAT: N="+N+" n="+n 
  hstx    = gsn_histogram(wks, x ,resh)

;***************************************************************
;--- text object 'x' sample statistics 
;***************************************************************

  txres                       = True
  txres@txFont                = "helvetica-bold"
  txres@txFontHeightF         = 0.0150

  textSample_x = (/"  Mean="+sprintf("%5.1f", xAvg) +"~C~"+  \
                   "   Std="+sprintf("%5.1f", xStd) +"~C~"+  \
                   "  Skew="+sprintf("%5.2f", xSkew) +"~C~"+  \
                   "  Kurt="+sprintf("%5.2f", xKurt) +"~C~"+  \
                   "  xLow="+sprintf("%5.1f", xLow) +"~C~"+  \
                   "  xMed="+sprintf("%5.1f", xMed) +"~C~"+  \
                   "   xHi="+sprintf("%5.1f", xHi ) /)
  txBoxSample_x  = gsn_create_text(wks,textSample_x, txres)

  amres  = True
  amres@amParallelPosF   =  0.30             ; move legend to the right
  amres@amOrthogonalPosF = -0.30             ; move the legend up
  annoSample_x = gsn_add_annotation(hstx, txBoxSample_x, amres)  

  resh@tiYAxisString = ""                            ; do not want a 2nd 'Frequency' label 
  resh@tiMainString  = "GPA: N="+N+" n="+n
  hsty    = gsn_histogram(wks, y ,resh)   

  textSample_y = (/"  Mean="+sprintf("%5.1f", yAvg) +"~C~"+  \
                   "   Std="+sprintf("%5.1f", yStd) +"~C~"+  \
                   "  Skew="+sprintf("%5.2f", ySkew) +"~C~"+  \
                   "  Kurt="+sprintf("%5.2f", yKurt) +"~C~"+  \
                   "  yLow="+sprintf("%5.1f", yLow) +"~C~"+  \
                   "  yMed="+sprintf("%5.1f", yMed) +"~C~"+  \
                   "   yHi="+sprintf("%5.1f", yHi ) /)
  txBoxSample_y  = gsn_create_text(wks,textSample_y, txres)

  amres  = True
  amres@amParallelPosF   = -0.30             ; move legend to the left
  amres@amOrthogonalPosF = -0.30             ; move the legend up
  annoSample_y = gsn_add_annotation(hsty, txBoxSample_y, amres)  

  resP@txString      = "LSAT and GPA distributions"
  gsn_panel(wks,(/hstx, hsty/),(/1,2/), resP)        ; now draw as one plot

;*************************************************
;--- Histogram of bootstrapped cross-correlations (rBoot)
;*************************************************
  resr             = True
  resr@gsnDraw     = False
  resr@gsnFrame    = False
  resr@gsnHistogramNumberOfBins = 25
  resr@tmXBLabelStride = 4
  resr@gsFillColor     = "red"
  rBoot@long_name  = "Bootstrapped cross-correlations"
  hstr    = gsn_histogram(wks, rBoot  ,resr)   

;***************************************************************
;--- text object original sample statistics 
;***************************************************************

   txres                       = True
   txres@txFont                = "helvetica-bold"
   txres@txFontHeightF         = 0.0150
   textSample  = (/"     r="+sprintf("%5.2f",r)    +"~C~"+  \
                   "rStdEr="+sprintf("%5.2f",rse ) +"~C~"+  \
                   "  rLow="+sprintf("%5.2f",rLow) +"~C~"+  \
                   "   rHi="+sprintf("%5.2f",rHi) /)
   txBoxSample  = gsn_create_text(wks,textSample, txres)

   amres  = True
   amres@amParallelPosF   = -0.35             ; move legend to the left
   amres@amOrthogonalPosF = -0.35             ; move the legend up
   annoSample = gsn_add_annotation(hstr, txBoxSample, amres)  ; Attach string to plot

;***************************************************************
;--- text object bootstrapped statistics 
;***************************************************************

   textBoot  = (/"rBootAvg="+sprintf("%5.2f", rBootAvg) +"~C~"+  \
                 "rBootLow="+sprintf("%5.2f", rBootLow) +"~C~"+  \
                 "rBootMed="+sprintf("%5.2f", rBootMed) +"~C~"+  \
                 " rBootHi="+sprintf("%5.2f", rBootHi ) /)
   txBoxBoot  = gsn_create_text(wks,textBoot, txres)

   amres@amParallelPosF   = -0.35             ; move legend to the left 
   amres@amOrthogonalPosF = -0.175            ; move the legend up
   annoBoot = gsn_add_annotation(hstr, txBoxBoot, amres)  ; Attach string to plot

;***************************************************************
;--- Draw
;***************************************************************

   resP@txString          = fili+": (LSAT,GPA): nBoot="+nBoot+" N="+N+" n="+n
   gsn_panel(wks,hstr,(/1,1/), resP)             ; now draw as one plot

