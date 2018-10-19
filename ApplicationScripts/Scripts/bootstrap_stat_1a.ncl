load "./histogram_marker.ncl"

;************************************************
; bootstrap_stat_1a.ncl
;
; Concepts illustrated:
;   - Using bootstrap_stat 
;   - Calculate basic statistics (here, the mean)
;     - Basic statistics of the original sample
;     - Bootstrapped means and other statistics 
;   - Creating a 'text' object to attach to plots
;   - Attach markers to indicate the low, medain and high bootstrao values
;   - Create a panel plot of histograms
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;***************************************************************
;--- Read data file and extract LSAT
;    Law School Data: Efron & Tibshirani (1993) 
;    An Introduction to the Bootstrap. Chapman and Hall 
;***************************************************************

  N     = 82                        ; 82; 15
  diri  = "./"
  fili  = "law_school_"+N+".txt"    ; law_school_82.txt or law_school_15.txt
  LSAT  = asciiread(diri+fili,(/N,3/), "float")  ; 3 columns
  x     = LSAT(:,1)    
  x@long_name = "Sample LSAT"

;***************************************************************
;--- Set bootstrap parameters and any desired options
;***************************************************************

  stat  = 0                         ; 0=mean; 1=variance; 2=std. dev; ...
  n     = 15                        ; sub-sample size;  default is n=N       
  nBoot = 1000                      ; bootstrap replications

  opt   = False                     ; use defaults
  if (isvar("n") .and. (n.lt.N)) then
      opt   = True
      opt@sample_size = n           ; default N
  end if

;***************************************************************
;--- set seeds (optional)
;***************************************************************
                                    ; opt=True is required
 ;;opt@rseed1  = 1119494848         ; manually set seeds ... for reproducibility
 ;;opt@rseed2  =  536433749
 ;;opt@rseed3  =  "clock"           ; use clock
      
;***************************************************************
;--- bootstrap_stat: extract information from returned 'list' variable: Bootstrap
;***************************************************************

   BootStrap   = bootstrap_stat(x, stat, nBoot, 0, opt)
                                    ; For 'clarity' extract from 'list' variable
   xBoot       = BootStrap[0]       ; Bootstrapped values in ascending order (use for histogram)
   xBootAvg    = BootStrap[1]       ; Mean of bootstrapped estimates
   xBootStd    = BootStrap[2]       ; Std dev of bootstrapped estimates
   delete( BootStrap )              ; no longer needed

   xBootLow    = bootstrap_estimate(xBoot, 0.025, False)   ;  2.5% lower confidence bound 
   xBootMed    = bootstrap_estimate(xBoot, 0.500, False)   ; 50.0% median of bootstrapped estimates
   xBootHi     = bootstrap_estimate(xBoot, 0.975, False)   ; 97.5% upper confidence bound

   xBoot4      = dim_stat4_n(xBoot, 0)
   xBootSkew   = xBoot4(2)          ; skewness of bootstrapd distribution
   xBootKurt   = xBoot4(3)          ; Kurtosis       "           "

;***************************************************************
;--- "normal" (conventional) estimates for full sample 
;     get t-value for desired 'p' and degrees of freedom
;***************************************************************
   
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

;***************************************************************
;--- PLOTS
;***************************************************************
   xBoot@long_name = "Bootstrapped LSAT Means"
   pltDir          = "./"
  ;pltName         = "Boot_LSAT_"+N+"_"+n+"_"+nBoot
   pltName         = "bootstrap_stat"
   pltType         = "png"          ; send graphics to PNG file
   pltPath         =  pltDir+pltName

   wks  = gsn_open_wks (pltType,pltPath)         
   resh = True
   resh@gsnDraw      = False
   resh@gsnFrame     = False
  ;resh2gsnHistogramNumberOfBins = 11

;***************************************************************
;--- create histogram for the original sample
;***************************************************************

   resh@gsFillColor  = "green"
   resh@tiMainString = "Original Sample: N="+N
   hstSample         = gsn_histogram(wks, x ,resh)  

;***************************************************************
;--- text object original sample statistics 
;***************************************************************

   txres                       = True
   txres@txFont                = "helvetica-bold"
   txres@txFontHeightF         = 0.0150
   textSample  = (/"  Mean="+sprintf("%5.1f", xAvg) +"~C~"+  \
                   "   Std="+sprintf("%5.1f", xStd) +"~C~"+  \
                   "  Skew="+sprintf("%5.2f", xSkew) +"~C~"+  \
                   "  Kurt="+sprintf("%5.2f", xKurt) +"~C~"+  \
                   "  xLow="+sprintf("%5.1f", xLow) +"~C~"+  \
                   "  xMed="+sprintf("%5.1f", xMed) +"~C~"+  \
                   "   xHi="+sprintf("%5.1f", xHi ) /)
   txBoxSample  = gsn_create_text(wks,textSample, txres)

   amres  = True
   amres@amParallelPosF   =  0.30             ; move legend to the right
   amres@amOrthogonalPosF = -0.30             ; move the legend up
   annoSample = gsn_add_annotation(hstSample, txBoxSample, amres)  ; Attach string to plot

;***************************************************************
;--- create histogram for the bootstrapped samples  
;***************************************************************

   resh@gsFillColor   = "blue"
   resh@tiYAxisString = ""                   ; do not want a 2nd 'Frequency' label 
   resh@tiMainString  = "nBoot="+nBoot+": N="+N+" n="+n
   hstBoot = gsn_histogram(wks, xBoot ,resh)

;***************************************************************
;--- add polymarkers to the low (2.5%) , median and high (97.5%) bootstrapped estimates 
;    NOTE: histogram_mark is local to this script
;***************************************************************

   gsHst = False                              ; use default settings
   histogram_mark(wks, hstBoot, (/xBootLow, xBootMed, xBootHi/), (/0,0,0/), gsHst)

;***************************************************************
;--- text object bootstrapped statistics 
;***************************************************************

   textBoot  = (/"  Mean="+sprintf("%5.1f", xBootAvg) +"~C~"+  \
                 "   Std="+sprintf("%5.1f", xBootStd) +"~C~"+  \
                 "  Skew="+sprintf("%5.2f", xBootSkew)+"~C~"+  \
                 "  Kurt="+sprintf("%5.2f", xBootKurt)+"~C~"+  \
                 "  xLow="+sprintf("%5.1f", xBootLow) +"~C~"+  \
                 "  xMed="+sprintf("%5.1f", xBootMed) +"~C~"+  \
                 "   xHi="+sprintf("%5.1f", xBootHi ) /)
   txBoxBoot  = gsn_create_text(wks,textBoot, txres)
 
   amres@amParallelPosF   = -0.35             ; move legend to the left
   amres@amOrthogonalPosF = -0.30             ; move the legend up
   annoBoot = gsn_add_annotation(hstBoot, txBoxBoot, amres)  ; Attach string to plot

;************************************************
; create panel
;************************************************
 resP                     = True              ; modify the panel plot
 resP@gsnMaximize         = True              ; regional data
;resP@gsnPaperOrientation = "landscape"
 resP@txFontHeightF       = 0.021
 resP@txString            = fili+": Sample and Bootstrap"

 gsn_panel(wks,(/hstSample, hstBoot/),(/1,2/), resP)             ; now draw as one plot
