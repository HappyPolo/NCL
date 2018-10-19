;*************************************************
; bootstrap_regcoef_1.ncl
;
; Concepts illustrated:
;   - Read tabular values from an ascii file
;   - Extract desired columns using NCL array syntax
;   - Calculate linear regression coefficient and confidence interval via 
;     (1) regline_stats 
;     (2) bootstrapping
;   - Plot
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;*************************************************
;--- Read data Law School Data: file and extract LSAT
;    Efron & Tibshirani (1993) 
;    An Introduction to the Bootstrap. Chapman and Hall 
;*************************************************
  N    = 82           ; 82 or 15
  n    = 82           ; sub-sample size;  15 or 82

  diri = "./"
  fili = "law_school_"+N+".txt"    ; law_school_82.txt or law_school_15.txt
  LSAT = asciiread(diri+fili,(/N,3/), "float")  ; 3 columns

  data = asciiread(diri+fili,(/N,3/), "float")
  x    = data(:,1)    ; LSAT
  y    = data(:,2)    ; GPA

;*************************************************
;-- simple linear regression
;-- http://test.www.ncl.ucar.edu/Document/Functions/Contributed/regline_stats.shtml
;*************************************************

  rc   = regline_stats(x,y)  ; many statistics including ANOVA
  print( rc )        

;*************************************************
;--- bootstrap
;*************************************************

  nBoot = 5000
  opt   = False              ; defaults will be used
  if (n.ne.N) then
      opt   = True           
      opt@sample_size = n     
  end if
 ;opt@sequential  = True  

  tst_rc       = bootstrap_regcoef(x, y, nBoot, 0, opt)
  rcBoot       = tst_rc[0] 
  rcBootAvg    = tst_rc[1]
  rcBootStd    = tst_rc[2]
  delete(tst_rc)

  rcBootLow    = bootstrap_estimate(rcBoot, 0.025, False)   ;  2.5% lower confidence bound 
  rcBootMed    = bootstrap_estimate(rcBoot, 0.500, False)   ; 50.0% median of bootstrapped estimates
  rcBootHi     = bootstrap_estimate(rcBoot, 0.975, False)   ; 97.5% upper confidence bound

;+++++++++++++++++++++++++++++++++++
; PLOTS
;+++++++++++++++++++++++++++++++++++
  pltDir  = "./"
  pltName = "BOOT_LAW_refcoef_"+N+"_"+n
  pltName = "bootstrap_regcoef"
  pltPath = pltDir+pltName
  pltType = "png"    ; send graphics to PNG file
  wks  = gsn_open_wks (pltType,pltPath)

  resh = True
  resh@gsnDraw  = False
  resh@gsnFrame = False
  resh@tmXBLabelFontHeightF = 0.01
  resh@tmXBLabelAngleF = 90
  resh@tmXBLabelJust = "CenterRight"
  resh@gsnHistogramBinIntervals = ispan(-8,80,4) * 0.0001

  resh@gsFillColor  = "yellow"
  resh@tiMainString = "Boot regcoef: nBoot="+nBoot+" N="+N+" n="+n
  hst = gsn_histogram(wks, rcBoot  ,resh)

;***************************************************************
;--- text object original sample statistics 
;***************************************************************
  txres                       = True
  txres@txFont                = "helvetica-bold"
  txres@txFontHeightF         = 0.0150
  textSample  = (/" rcOrig="+sprintf("%7.4f",rc)+"~C~"+  \          
                  "  rcLow="+sprintf("%7.4f",rc@b95(0))+"~C~"+  \          
                  "   rcHi="+sprintf("%7.4f",rc@b95(1))+"~C~"+  \          
                  "      p="+sprintf("%7.4f",rc@pval(1)) /)         
  txBoxSample  = gsn_create_text(wks,textSample, txres)

  amres  = True
  amres@amParallelPosF   = -0.30             ; move legend to the left
  amres@amOrthogonalPosF = -0.40             ; move the legend up
  annoSample = gsn_add_annotation(hst, txBoxSample, amres)  ; Attach string to plot

;***************************************************************
;--- text object bootstrapped statistics 
;***************************************************************

   textBoot  = (/"rcBootAvg="+sprintf("%7.4f", rcBootAvg) +"~C~"+  \
                 "rcBootLow="+sprintf("%7.4f", rcBootLow) +"~C~"+  \
                 "rcBootMed="+sprintf("%7.4f", rcBootMed) +"~C~"+  \
                 " rcBootHi="+sprintf("%7.4f", rcBootHi ) /)
   txBoxBoot = gsn_create_text(wks,textBoot, txres)

   amres@amParallelPosF   = -0.30             ; move legend to the left 
   amres@amOrthogonalPosF = -0.25             ; move the legend up
   annoBoot  = gsn_add_annotation(hst, txBoxBoot, amres)  ; Attach string to plot

   draw(hst)
   frame(wks)
