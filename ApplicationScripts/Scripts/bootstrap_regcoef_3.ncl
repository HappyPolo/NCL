;*************************************************
; bootstrap_regcoef_3.ncl
;
; Concepts illustrated:
;   - Read simple ascii file containing 1500 annual temperatures (K)
;   - Calculate linear regression coef
;      - Classic one sample method 
;      - Bootstrap linear regression coef with opt@sequential=True
;      - Generate a distribution using methodical 'running sequence'
;   - Plot assorted distributions
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;*************************************************
; LENS: Large ENSemble
; LENS webpage: https://www2.cesm.ucar.edu/models/experiments/LENS
; years 0600-2099 were selected
;*************************************************

  year  = ispan(600,2099,1)           
  year@long_name = "years"     ; not required
  year!0= "year"               ;  "  
  year&year = year             ;  "

  diri   = "./"
  fili   = "LENS_control_TREFHT_AreaAve50S90S_ANN_0001-1500.txt"

  TA     = asciiread(diri+fili,-1, "float")  

  TA@long_name = "LENS Annual Temp: 50S-90S"
  TA@units     = "degK"        ; not required
  TA!0   = "year"              ;  "
  TA&year=  year               ;  "
  printVarSummary(TA)           ;  "

  N     = dimsizes(TA)          ; # of years
;***********************************************************
;--- Calculate some classic statistics for the temperature series
;    These statistics are used for demo pruposes only   
;***********************************************************

   TAstat4  = dim_stat4_n(TA,0)   ; 1st 4 moments of original sample
                                  ; explicitlTA extract for clarity
   TA_Avg   = TAstat4(0)          ; original sample mean
   TA_Std   = sqrt(TAstat4(1))    ;    "     sample std dev
   TA_Skew  = TAstat4(2)          ; skewness; departure from symmetry
   TA_Kurt  = TAstat4(3)          ; kurtosis; relative to a normal distribution
   TA_Med   = dim_median_n(TA,0)  ; median of original sample
   TAStdErr = TA_Std/N

   df       = N-1
   p        = 0.975               ; match default bootstrap 'p' (0.025, 0.975)
   tTA      = cdft_t(p,df)        ; 2-sided   
   TALow    = TA_Avg-tTA*TA_Std   ; normal low:  2.5% 
   TAHi     = TA_Avg+tTA*TA_Std   ; normal hi ; 97.5%

;*****************************************************************
;-- linear regression on single source sample: classic method
;-- http://www.ncl.ucar.edu/Document/Functions/Contributed/regline_stats.shtml
;*****************************************************************

  rc   = regline_stats(year,TA)  ; per year
  print( rc )                    ; many statistics including ANOVA
  print("-----")

;*****************************************************************
;--- bootstrap: random sampling with replacement (default) 
;*****************************************************************

  n     = 36                      ; sub-sample block size arbitrary; match other usage
  nBoot = 1500

  opt   = False
  if (n.ne.N) then
      opt   = True
      opt@sample_size = n     ; use sub-sample if applicable     
  end if

  tst_rc      = bootstrap_regcoef(year, TA, nBoot, 0, opt)
  rcBoot      = tst_rc[0] 
  rcBootAvg   = tst_rc[1]
  rcBootStd   = tst_rc[2]
  delete(tst_rc)

  rcBootLow   = bootstrap_estimate(rcBoot, 0.025, False)   ;  2.5% lower confidence bound 
  rcBootMed   = bootstrap_estimate(rcBoot, 0.500, False)   ; 50.0% median of bootstrapped estimates
  rcBootHi    = bootstrap_estimate(rcBoot, 0.975, False)   ; 97.5% upper confidence bound

  rcBootLow@long_name = "bootstrap r: "+rcBootLow@estimate
  rcBootMed@long_name = "bootstrap r: Median"
  rcBootHi@long_name  = "bootstrap r: "+rcBootHi@estimate

;*****************************************************************
;--- bootstrap: sampling with replacement but sub-samplea are sequential blocks 
;    Each 'start index' is random with replacement BUT then n sequential values
;*****************************************************************

  opt@sequential  = True ; random start index; then use 'n' sequential values 

  tst_rc_seq   = bootstrap_regcoef(year, TA, nBoot, 0, opt)
  rcBootSeq    = tst_rc_seq[0] 
  rcBootSeqAvg = tst_rc_seq[1]
  rcBootSeqStd = tst_rc_seq[2]
  delete(tst_rc_seq)

  rcBootSeqLow = bootstrap_estimate(rcBootSeq, 0.025, False)   ;  2.5% lower  confidence bound 
  rcBootSeqMed = bootstrap_estimate(rcBootSeq, 0.500, False)   ; 50.0% median bootstrapped estimates
  rcBootSeqHi  = bootstrap_estimate(rcBootSeq, 0.975, False)   ; 97.5% upper  confidence bound

  rcBootSeqLow@long_name = "bootstrap seq: "+rcBootSeqLow@estimate
  rcBootSeqMed@long_name = "bootstrap seq: Median"
  rcBootSeqHi@long_name  = "bootstrap seq: "+rcBootSeqHi@estimate

;*****************************************************************
;--- running_block: generate large distribution because N is large
;    not bootstrap per se, rather methodical 
;*****************************************************************

   nBlok  = N-n                            ; max # usable 'blocks'                           
   rcBlok = new (nBlok, typeof(TA))
   do nB=0,nBlok-1
      rcBlok(nB) = (/ regline(year(nB:nB+n-1),TA(nB:nB+n-1)) /)
   end do
   rcBlok@long_name = rcBootSeq@long_name
   
   rcBlokAvg = dim_avg_n(rcBlok,0)         ; Average of block samples
   rcBlokStd = dim_stddev_n(rcBlok,0)      ; Std Dev  "   "      "
   rcBlokStdErr = rcBlokStd/nBlok          ; Std. Error of running block estimates
                                           ; blocks are size 'n'
   ia = dim_pqsort_n(rcBlok, 2, 0)         ; sort block values into ascending order
   
   rcBlokLow = bootstrap_estimate(rcBlok, 0.025, False)   ;  2.5% lower confidence bound 
   rcBlokMed = bootstrap_estimate(rcBlok, 0.500, False)   ;  2.5% lower confidence bound 
   rcBlokHi  = bootstrap_estimate(rcBlok, 0.975, False)   ;  2.5% lower confidence bound 

;*****************************************************************
; PLOTS
;*****************************************************************
  print("def : "+rcBootAvg+"  "+rcBootStd  +"  "+rcBootLow +"  "+rcBootMed +"  "+rcBootHi) 
  print("Seq : "+rcBootSeqAvg +"  "+rcBootSeqStd +"  "+rcBootSeqLow +"  "+rcBootSeqMed +"  "+rcBootSeqHi) 
  print("Blok: "+rcBlokAvg+"  "+rcBlokStd+"  "+rcBlokLow+"  "+rcBlokMed+"  "+rcBlokHi) 

  pltDir  = "./"
  pltName = "bootstrap_regcoef"
 ;pltName = "BOOT_LENS_regcoef_"+N+"_"+n
  pltPath = pltDir+pltName
  pltType = "png"     ; send graphics to PNG file
  wks  = gsn_open_wks (pltType,pltPath)

;+++++++++++++++++++++++++++++++++++
; --- PLOT 1: plot TA as time series + regression line
;+++++++++++++++++++++++++++++++++++

  dplt      = new ( (/2,N/), typeof(TA), TA@_FillValue)
  dplt(0,:) = TA
  dplt(1,:) = rc*(year-rc@xave) + rc@yave

  resxy                     = True                   ; plot mods desired
  resxy@gsnDraw             = False 
  resxy@gsnFrame            = False 
  resxy@xyDashPatterns      = 0                      ; solid line 
  resxy@xyLineColors        = (/"black", "blue"/) 
  resxy@xyLineThicknesses   = (/1,3/)                
  resxy@tiMainString        = TA@long_name
  resxy@vpHeightF           = 0.4                    ; change aspect ratio of plot
  resxy@vpWidthF            = 0.8                  
  resxy@vpXF                = 0.125                  ; start plot at x ndc coord 

  resxy@trXMinF             = year(0) 
  resxy@trXMaxF             = year(N-1)+1
  plot  = gsn_csm_xy (wks,year,dplt,resxy)

; add text 

  txres                  =  True
  txres@txFontHeightF    = 0.02
  txres@txJust           = "CenterCenter"
  txres@txFontThicknessF = 2.0      ; default=1.00
  txres@txFontHeightF    = 0.025    ; default=0.05
  text                   = "degC/decade="+sprintf("%8.5f",rc*10)
  plot@$unique_string("dum")$ = gsn_add_text(wks,plot,text, year(750), (TA_Avg-3*TA_Std),txres)
  draw(plot)    
  frame(wks)

;***************************************************************
;--- PLOT 2: histogram for the original series
;***************************************************************

  resh               = True
  resh@gsnDraw       = False
  resh@gsnFrame      = False
  resh@tmXBLabelStride = 2
  resh@gsFillColor   = "green"           ; histogram of source data values
  resh@tiMainString  = TA@long_name
  resh@tiXAxisString = "Annual T (K)"
  hst_TA              = gsn_histogram(wks, TA ,resh)  

;***************************************************************
;---PLOT 3: histogram for the standard bootstrap with subsampling
;***************************************************************
  resh@gsFillColor  = "mediumturquoise"   ; histogram of 'bootstrapped' values

  resh@tiMainString = "Boot Standard: nBoot="+nBoot+" N="+N+" n="+n
  hst   = gsn_histogram(wks, rcBoot   ,resh)   

;***************************************************************
;---PLOT 4: histogram for the standard bootstrap with sequential subsampling
;***************************************************************

  resh@tiMainString = "Boot Sequential: nBoot="+nBoot+" N="+N+" n="+n
  hst_s = gsn_histogram(wks, rcBootSeq,resh)   

;***************************************************************
;---PLOT 5: histogram of methodical running sequential
;***************************************************************

  resh@tiMainString = "Boot Running Block: nBlok="+nBlok+" N="+N+" n="+n
  hst_k = gsn_histogram(wks, rcBlok   ,resh)   

;***************************************************************
;--- text object original sample statistics 
;***************************************************************
  txres                       = True
  txres@txFont                = "helvetica-bold"
  txres@txFontHeightF         = 0.0150
  textSample  = (/"     rc="+sprintf("%8.5f",rc)+"~C~"+  \          
                  "  rcLow="+sprintf("%8.5f",rc@b95(0))+"~C~"+  \          
                  "   rcHi="+sprintf("%8.5f",rc@b95(1))+"~C~"+  \          
                  "      p="+sprintf("%8.5f",rc@pval(1)) /)         
  txBoxSample  = gsn_create_text(wks,textSample, txres)

  amres  = True
  amres@amParallelPosF   = -0.325            ; move legend to the left
  amres@amOrthogonalPosF = -0.40             ; move the legend up
  annoSample = gsn_add_annotation(hst_TA, txBoxSample, amres)  ; Attach string to plot

;***************************************************************
;--- text object bootstrapped, bootstrapped-sequential  and block statistics 
;***************************************************************

   textBoot     = (/"rcBootAvg="+sprintf("%8.5f", rcBootAvg) +"~C~"+  \
                    "rcBootLow="+sprintf("%8.5f", rcBootLow) +"~C~"+  \
                    "rcBootMed="+sprintf("%8.5f", rcBootMed) +"~C~"+  \
                    " rcBootHi="+sprintf("%8.5f", rcBootHi ) /)
   txBoxBoot    = gsn_create_text(wks,textBoot, txres)

   textBootSeq  = (/"rcBootSeqAvg="+sprintf("%8.5f", rcBootSeqAvg) +"~C~"+  \
                    "rcBootSeqLow="+sprintf("%8.5f", rcBootSeqLow) +"~C~"+  \
                    "rcBootSeqMed="+sprintf("%8.5f", rcBootSeqMed) +"~C~"+  \
                    " rcBootSeqHi="+sprintf("%8.5f", rcBootSeqHi ) /)
   txBoxBootSeq = gsn_create_text(wks,textBootSeq, txres)

   textBlok     = (/"rcBlokAvg="+sprintf("%8.5f", rcBlokAvg) +"~C~"+  \
                    "rcBlokLow="+sprintf("%8.5f", rcBlokLow) +"~C~"+  \
                    "rcBlokMed="+sprintf("%8.5f", rcBlokMed) +"~C~"+  \
                    " rcBlokHi="+sprintf("%8.5f", rcBlokHi ) /)
   txBoxBlok    = gsn_create_text(wks,textBlok, txres)


   amres@amParallelPosF   = -0.300            ; move legend to the left 
   amres@amOrthogonalPosF = -0.250            ; move the legend up
   annoBoot    = gsn_add_annotation(hst  , txBoxBoot   , amres) 
   amres@amOrthogonalPosF = -0.40             ; move the legend up
   annoBootSeq = gsn_add_annotation(hst_s, txBoxBootSeq, amres)
   annoBootBlok= gsn_add_annotation(hst_k, txBoxBlok   , amres)

;***************************************************************
;--- plot the histograms
;***************************************************************

   draw(hst_TA)
   frame(wks)

   draw(hst)
   frame(wks)

   draw(hst_s)
   frame(wks)

   draw(hst_k)
   frame(wks)
