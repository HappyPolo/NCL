;************************************************
; bootstrap_stat_2.ncl
;
; Concepts illustrated:
;   - Using bootstrap_stat 
;   - Calculate basic statistics (here, the mean)
;     - Basic statistics of the original sample
;     - Bootstrapped means 
;   - Creating a 'text' object for plots
;   - Create a panel plot of histograms
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;***************************************************************
;--- Specify month and variable
;***************************************************************
  vName  = "precip"     ; precip or temp

  month  = (/"Jan","Feb","Mar","Apr","May","Jun"\
            ,"Jul","Aug","Sep","Oct","Nov","Dec"/)
  if (vName.eq."precip") then
      mon    = 4        ; 0=Jan, 1=Feb, 2=Mar, 3=Apr, 4=May, ....
  else
      mon    = 0        ; temperature        
  end if

;***************************************************************
;--- Read data file 
;***************************************************************

  diri   = "./"
  fili   = "Boulder."+vName+".1897-2014.nc"
  f      = addfile(diri+fili, "r")
  x      = f->$vName$(mon::12)     ; Boulder Monthly Temperature Means or Precip Totals   

  if (vName.eq."temp") then        ; long_names; better for plots
      x@long_name = "Boulder Temp (F): "+month(mon)
  else
      x@long_name = "Boulder Precip (in): "+month(mon)
  end if

  printVarSummary(x)
  printMinMax(x,1)

;***************************************************************
;--- Set parameters and any desired options
;***************************************************************

  N     = dimsizes(x)               ; number of years
;  n     = N  ; 30                   ; sub-sample size; default n=N; n=30 means 30 years  
  n = 30
  df    = n-1

  stat  = 0                         ; 0=mean; 1=variance; 2=std. dev; ...
  nBoot = 1000                      ; bootstrap replications

  opt   = False                     ; use defaults
  if (isvar("n") .and. (n.lt.N)) then
      opt   = True   
      opt@sample_size = n           ; default n=N; n=30 means 30 years 
  end if

;***************************************************************
;--- set seeds (optional)
;***************************************************************
                                    ; opt=True is required
 ;;opt@rseed1  = 1119494848         ; manually set seeds
 ;;opt@rseed2  =  536433749
 ;;opt@rseed3  =  "clock"           ; use clock
      
;***************************************************************
;--- bootstrap_stat: extract information from returned 'list' variable: Bootstrap
;***************************************************************

   BootStrap   = bootstrap_stat(x, stat, nBoot, 0, opt)
   xBoot       = BootStrap[0]       ; All the bootstrapped values (use for histogram)
   xBootAvg    = BootStrap[1]       ; average of 'nBoot' bootstrapped samples
   xBootStd    = BootStrap[2]       ; standard deviation of bootstrapped estimates
   delete(BootStrap)                ; no longer needed

   xBootLow    = bootstrap_estimate(xBoot, 0.025, False)   ;  2.5% lower confidence bound 
   xBootMed    = bootstrap_estimate(xBoot, 0.500, False)   ; 50.0% median of bootstrapped estimates
   xBootHi     = bootstrap_estimate(xBoot, 0.975, False)   ; 97.5% upper confidence bound

   xBoot4      = dim_stat4_n(xBoot, 0)
   xBootSkew   = xBoot4(2)          ; skewness of bootstrapd distribution
   xBootKurt   = xBoot4(3)          ; Kurtosis       "           "

;***************************************************************
;--- Origial sample; uses full sample size
;--- "normal" estimates: get t-value for desired 'p' and degrees of freedom
;***************************************************************

   xStat4      = dim_stat4_n(x, 0)  ; 1st 4 moments of original sample
                                    ; explicitly extract for clarity
   xAvg        = xStat4(0)          ; original sample mean
   xStd        = sqrt(xStat4(1))    ;    "     sample std dev
   xSkew       = xStat4(2)          ; skewness; departure from symmetry
   xKurt       = xStat4(3)          ; kurtosis; relative to a normal distribution
   xMed        = dim_median_n(x,0)  ; median of original sample

   df          = N-1                ; degrees of freedom                
   p           = 0.975              ; match default bootstrap 'p' (0.025, 0.975)
   tval        = cdft_t(p,df)       ; 2-sided   
   xLow        = xAvg-tval*xStd     ; normal low:  2.5% 
   xHi         = xAvg+tval*xStd     ; normal hi ; 97.5%

;***************************************************************
;--- PLOTS
;***************************************************************

   if (vName.eq."temp") then        ; long_names; better for plots
       xBoot@long_name = "Bootstrapped Temp (F): "+month(mon)
   else
       xBoot@long_name = "Bootstrapped Precip (in): "+month(mon)
   end if
   pltDir  = "./"
  ;pltName = "Boot_Boulder_"+vName+"_"+month(mon)+"_"+N+"_"+n+"_"+nBoot
   pltName = "bootstrap_stat"
   pltPath =  pltDir+pltName
   pltType = "png"                  ; send graphics to PNG file

   wks  = gsn_open_wks (pltType,pltPath)         
   plot = new( 2, "graphic")

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
   txBoxSample = gsn_create_text(wks,textSample, txres)

   amres  = True
   amres@amParallelPosF   =  0.35             ; move legend to the right
   if (vName.eq."temp") then
       amres@amParallelPosF= -0.35            ; move legend to the left  
   end if
   amres@amOrthogonalPosF = -0.325            ; move the legend up
   annoSample = gsn_add_annotation(hstSample, txBoxSample, amres)  ; Attach string to plot

;***************************************************************
;--- create histogram for the bootstrapped samples  
;***************************************************************

   resh@gsFillColor   = "blue"
   resh@tiYAxisString = ""                   ; do not want a 2nd 'Frequency' label 
   resh@tiMainString  = "nBoot="+nBoot+": N="+N+" n="+n
   hstBoot = gsn_histogram(wks, xBoot ,resh)

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
   txBoxBoot = gsn_create_text(wks,textBoot, txres)
 
   amres@amParallelPosF   = -0.375            ; move legend to the left
   amres@amOrthogonalPosF = -0.325            ; move the legend up
   annoBoot = gsn_add_annotation(hstBoot, txBoxBoot, amres)  ; Attach string to plot

;************************************************
; create panel
;************************************************
   fili_ext = get_file_suffix(fili, 0)          ; file extension 
   fili_pre = fili_ext@fBase

   resP                     = True              ; modify the panel plot
   resP@gsnMaximize         = True              ; regional data
  ;resP@gsnPaperOrientation = "landscape"
   resP@txFontHeightF       = 0.021

   resP@txString            = fili_pre+": "+month(mon)+": Sample and Bootstrap"
   gsn_panel(wks,(/hstSample, hstBoot/),(/1,2/), resP)             ; now draw as one plot

