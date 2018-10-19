;************************************************
; bootstrap_diff_2.ncl
;
; Concepts illustrated:
;   - Using bootstrap_diff 
;   - Calculate mean differences via bootstrap
;     - Basic statistics of the difference betewwn two samples
;     - Bootstrapped differences and other statistics 
;   - Creating a 'text' object to attach to plots
;   - Create a plot with histogram
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;*************************************************
; load "/Users/shea/NCL/gsun/contributed.ncl"
;***************************************************************
;--- Read data file 
;***************************************************************
  vName   = "PRECIP"

  diri    = "./"
  fili    = "Boulder.precip.1897-2014.nc"
  f       = addfile(diri+fili, "r")
  vNamFil = vName+"_ANNUAL"
  VAR     = f->$vNamFil$
  nyrs    = dimsizes(VAR)

  printVarSummary(VAR)
  printMinMax(VAR,1)
;***************************************************************
;--- Split array
;***************************************************************
  YYYY    = VAR&TIME                ; convenience
  yyyy    = 1979                    ; this is arbitrary
  nyr     = ind(YYYY .eq. yyyy)     ; index
  X       = VAR(0:nyr)              ; 1897-1979
  Y       = VAR(nyr+1:nyrs-1)       ; 1980-2014

;***************************************************************
; NCL function for significance testing of difference between two means
;***************************************************************

  aveY    = avg (Y)             ; 528.20
  aveX    = avg (X)             ; 467.63
  varY    = variance (Y)
  varX    = variance (X)
  NY      = dimsizes (Y)        ; different sizes
  NX      = dimsizes (X)        ; X and Y can be of
  iflag   = True                ; different variances (Welsh's test)
  probt   = ttest(aveY,varY,NY, aveX,varX,NX, iflag, True) 
  p       = probt(0,0)          ; p     = 0.01
  p_tval  = probt(1,0)          ; p_tval= 2.61    

;***************************************************************
; Conventional approach: Welch Two Sample t-test: unequal variances
;***************************************************************

  diffYX  = aveY - aveX                             ; difference     = 60.57
  varP    = ((NX-1)*varX + (NY-1)*varY)/(NX+NY-2)   ; pooled variance
  stdP    = sqrt( varP )                            ; pooled std dev =111.69
  stdErr  = stdP*sqrt(1.0/NX + 1.0/NY)              ; std error      = 22.51
  df      = (varX/NX+varY/NY)^2 \                   ; deg of freedom = 59.94
            /((varX/NX)^2/(NX-1)+(varY/NY)^2/(NY-1)) 
  tval    = cdft_t(0.975,df)                        ; tval = 2.00
 ;diffHi  = diffYX + tval*stdErr                    ;  2.5% CI = 15.53   
 ;diffLow = diffYX - tval*stdErr                    ; 97.5% CI = 105.607
  diffHi  = diffYX + p_tval*stdErr                  ;  2.5% CI =  1.81   
  diffLow = diffYX - p_tval*stdErr                  ; 97.5% CI = 119.137

;***************************************************************
;--- Set bootstrap parameters and any desired options
;***************************************************************

  nBoot = 5000                      ; bootstrap replications
  opt   = False                     ; use default settings

;***************************************************************
;--- set seeds (optional)
;***************************************************************

;;opt@rseed1  = 1119494848         ; manually set seeds ... for reproducibility
;;opt@rseed2  =  536433749
;;opt@rseed3  =  "clock"           ; use clock
      
;***************************************************************
;--- bootstrap_stat: extract information from returned 'list' variable: Bootstrap
;***************************************************************

  BootStrap     = bootstrap_diff(Y, X, nBoot, 0, opt)
  xyBootDiff    = BootStrap[0]    ; All the bootstrapped differences (use for histogram)
  xyBootDiffAvg = BootStrap[1]    ; avg  of 'nBoot' bootstrapped differences
  xyBootDiffStd = BootStrap[2]    ; std dev  of 'nBoot' bootstrapped differences
  delete(BootStrap)

  xyBootDiffLow = bootstrap_estimate(xyBootDiff, 0.025, False)   ;  2.5% lower confidence bound 
  xyBootDiffMed = bootstrap_estimate(xyBootDiff, 0.500, False)   ; 50.0% median bootstrap estimate
  xyBootDiffHi  = bootstrap_estimate(xyBootDiff, 0.975, False)   ; 97.5% upper confidence bound

;***************************************************************
;--- PLOTS
;***************************************************************
  xyBootDiff@long_name = "Bootstrapped Differences (mm)"

  pltDir  = "./"
 ;pltName = "Boot_DIFF_"+vName+"_"+NX+"_"+NY+"_"+nBoot
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
  XY@long_name = Y@long_name+" ("+Y@units+")"

  resh@gsFillColor  = "green"     ; all original sample plots are green
  resh@gsnHistogramCompare = True
  hstSample         = gsn_histogram(wks, XY ,resh)  

;***************************************************************
;--- text object original sample statistics 
;***************************************************************

  txres                       = True
  txres@txFont                = "helvetica-bold"
  txres@txFontHeightF         = 0.0150
  textSample = (/" yxDiff="+sprintf("%5.2f", diffYX)   +"~C~"+  \
                 "   xAvg="+sprintf("%5.2f", aveX)     +"~C~"+  \
                 "   yAvg="+sprintf("%5.2f", aveY)     +"~C~"+  \
                 "diffLow="+sprintf("%5.2f", diffLow)  +"~C~"+  \
                 "diffHi ="+sprintf("%5.2f", diffHi )  +"~C~"+  \
                 "      p="+sprintf("%5.2f",    p)     +"~C~"+  \
                 "      t="+sprintf("%5.2f",p_tval  )     /)
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
                "BootDiffMed="+sprintf("%5.2f", xyBootDiffMed) +"~C~"+  \
                "BootDiffHi ="+sprintf("%5.2f", xyBootDiffHi ) /)
  txBoxBoot  = gsn_create_text(wks,textBoot, txres)
 
  amres@amParallelPosF   = -0.30             ; move legend to the left
  amres@amOrthogonalPosF = -0.35             ; move the legend up
  annoBoot = gsn_add_annotation(hstBoot, txBoxBoot, amres)  ; Attach string to plot

;************************************************
; create panel
;************************************************
  resP                     = True              ; modify the panel plot
  resP@gsnMaximize         = True              ; regional data
  resP@txFontHeightF       = 0.021
  resP@txString            = "Boulder "+ vName+": "+ YYYY(0)+"-"+YYYY(nyr)+" vs "+ \
                                                    YYYY(nyr+1)+"-"+YYYY(nyrs-1)
  gsn_panel(wks,(/hstSample, hstBoot/),(/1,2/), resP)             ; now draw as one plot
