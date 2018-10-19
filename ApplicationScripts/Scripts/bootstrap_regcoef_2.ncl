;****************************************************************
; bootstrap_regcoef_2.ncl
;
; Concepts illustrated:
;   - Read UKMO tabular values from an ascii file
;   - Extract desired columns using NCL array syntax
;   - Calculate linear regression coef 
;     (1) original sample via  regline_stats
;     (2) bootstrapped estimate
;   - Draw original data w regression line
;     Draw histogram w boot
;   - Add information to plot
;   - Plot
;****************************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;****************************************************************
;--- Read ascii (text) file
;****************************************************************
   diri = "./"
   fili = "TA_Globe.1850-2014.txt"
   pthi = diri+fili

   nrow = numAsciiRow(pthi)
   ncol = 12
   data = asciiread(pthi,(/nrow,ncol/),"float")
   data@_FillValue = -999

   year = data(:,0)
   TA   = data(:,1)      ; explicitly extract desired column
   N    = dimsizes(TA)

   TA!0 = "time"
   TA&time = year
   TA@long_name = "UKMO: annual temp anomalies"
   TA@units     = "degC"

;***********************************************************
;--- Calculate some basic statistics for the temperature anomalies
;    These statistics are ust background statistics
;***********************************************************

   TAStat4  = dim_stat4_n(TA,0)  ; 1st 4 moments of original sample
                                 ; explicitly extract for clarity
   TAAvg    = TAStat4(0)         ; original sample mean
   TAStd    = sqrt(TAStat4(1))   ;    "     sample std dev
   TASkew   = TAStat4(2)         ; skewness; departure from symmetry
   TAKurt   = TAStat4(3)         ; kurtosis; relative to a normal distribution
   TAMed    = dim_median_n(TA,0) ; median of original sample
   TAStdErr = TAStd/N

   df       = N-1
   p        = 0.975              ; match default bootstrap 'p' (0.025, 0.975)
   tTA      = cdft_t(p,df)       ; 2-sided   
   TALow    = TAAvg-tTA*TAStd    ; normal low:  2.5% 
   TAHi     = TAAvg+tTA*TAStd    ; normal hi ; 97.5%

;****************************************************************
;--- simple linear regression on original sample
;****************************************************************

   rc   = regline_stats(year,TA)
   print( rc )

;****************************************************************
;--- bootstrap
;****************************************************************

  N     = 165      ; 30 annual samples
  n     = N        ; no sub-sampling

  nBoot = 1000  
  opt   = False
  if (n.ne.N) then
      opt   = True
      opt@sample_size = n     
    ;;opt@sequential  = True  
  end if

  tst_rc := bootstrap_regcoef(year, TA, nBoot, 0, opt)
  rcBoot       = tst_rc[0] 
  rcBootAvg    = tst_rc[1]
  rcBootStd    = tst_rc[2]
  rcBoot@long_name = "reg coef: "+fili

  rcBootLow    = bootstrap_estimate(rcBoot, 0.025, False)   ;  2.5% lower confidence bound 
  rcBootMed    = bootstrap_estimate(rcBoot, 0.500, False)   ; 50.0% median of bootstrapped estimates
  rcBootHi     = bootstrap_estimate(rcBoot, 0.975, False)   ; 97.5% upper confidence bound

  rcBootLow@long_name = "bootstrap r: "+rcBootLow@estimate
  rcBootMed@long_name = "bootstrap r: Median"
  rcBootHi@long_name  = "bootstrap r: "+rcBootHi@estimate

;+++++++++++++++++++++++++++++++++++
; PLOTS
;+++++++++++++++++++++++++++++++++++
  pltDir  = "./"
  pltName = "BOOT_regcoef_"+N+"_"+n
  pltName = "bootstrap_regcoef"
  pltPath = pltDir+pltName
  pltType = "png"    ; send graphics to PNG file
  wks  = gsn_open_wks (pltType,pltPath)

;***************************************************************
;--- histogram for the TA  (hTA)
;***************************************************************

  reshTA               = True
  reshTA@gsnDraw       = False
  reshTA@gsnFrame      = False
  reshTA@gsnHistogramClassIntervals = fspan(-0.8, 0.8, 17) 
  reshTA@tmXBLabelStride = 4
  reshTA@gsFillColor   = "green"
  reshTA@tiMainString  = "UKMO Annual Anomalies: "+year(0)+"-"+year(N-1)
  reshTA@tiXAxisString = "Anomaly Distribution"
  hstTA                = gsn_histogram(wks, TA ,reshTA)  

;***************************************************************
;--- PLOT 1: text object for original TA
;***************************************************************

  txres                       = True
  txres@txFont                = "helvetica-bold"
  txres@txFontHeightF         = 0.0150
  textTA   = (/"  Mean="+sprintf("%5.2f", TAAvg) +"~C~"+  \
               "   Std="+sprintf("%5.2f", TAStd) +"~C~"+  \
               "  Skew="+sprintf("%5.2f", TASkew) +"~C~"+  \
               "  Kurt="+sprintf("%5.2f", TAKurt) +"~C~"+  \
               "  tval="+sprintf("%5.2f",   tTA) +"~C~"+  \
               "TA_Low="+sprintf("%5.2f", TALow) +"~C~"+  \
               " TA_Hi="+sprintf("%5.2f", TAHi ) /)
  txBoxTA   = gsn_create_text(wks,textTA,txres)

  amres  = True
  amres@amParallelPosF   =  0.35             ; move legend to the right
  amres@amOrthogonalPosF = -0.35             ; move the legend up
  annoTA  = gsn_add_annotation(hstTA , txBoxTA , amres)  ; Attach string to plot

  draw(hstTA) 
  frame(wks)

;+++++++++++++++++++++++++++++++++++
; --- PLOT 2: plot TA as time series + regression line
;+++++++++++++++++++++++++++++++++++

  dplt = new ( (/2,N/), typeof(TA), TA@_FillValue)
  dplt(0,:) = TA
  dplt(1,:) = rc*(year-rc@xave) + rc@yave

  resxy                     = True                   ; plot mods desired
  resxy@gsnDraw             = False 
  resxy@gsnFrame            = False 
  resxy@xyDashPatterns      = 0                      ; solid line 
  resxy@xyLineColors        = (/"black", "blue"/) 
  resxy@xyLineThicknesses   = (/1,3/)                
  resxy@tiMainString        = "UKMO Annual Global Anomalies: "+year(0)+"-"+year(N-1)
  resxy@vpHeightF           = 0.4                    ; change aspect ratio of plot
  resxy@vpWidthF            = 0.8                  
  resxy@vpXF                = 0.1                    ; start plot at x ndc coord 

  resxy@trXMinF  = year(0) 
  resxy@trXMaxF  = year(N-1)+1
  resxy@trYMinF  = -0.6      
  resxy@trYMaxF  =  0.6
  resxy@gsnYRefLine      = 0.0

  plot  = gsn_csm_xy (wks,year,dplt,resxy)

; add text 

  txres               =  True
  txres@txFontHeightF = 0.02
  txres@txJust        = "CenterCenter"
  txres@txFontThicknessF = 2.0      ; default=1.00
  txres@txFontHeightF    = 0.025    ; default=0.05
  text          = "degC/decade="+sprintf("%7.3f",rc*10)
  plot@$unique_string("dum")$ = gsn_add_text(wks,plot,text, 1920, 0.30 ,txres)
  draw(plot)    
  frame(wks)
 
;***************************************************************
; --- PLOT 3: Histogram: plot bootstrapped estimates
;***************************************************************

  reshBoot = True
  reshBoot@gsnDraw  = False
  reshBoot@gsnFrame = False
  reshBoot@tmXBLabelStride = 4
  reshBoot@gsnHistogramClassIntervals = fspan(0.003, 0.006, 16)
  reshBoot@gsFillColor  = "yellow"
  reshBoot@tiMainString = "Boot regcoef: nBoot="+nBoot+" N="+N+" n="+n
  hst = gsn_histogram(wks, rcBoot  ,reshBoot)   

;***************************************************************
;--- text object conventional regression statistics 
;***************************************************************
  textSample  = (/"     rc="+sprintf("%7.4f",rc)+"~C~"+  \          
                  "  rcLow="+sprintf("%7.4f",rc@b95(0))+"~C~"+  \          
                  "   rcHi="+sprintf("%7.4f",rc@b95(1))+"~C~"+  \          
                  "      p="+sprintf("%7.4f",rc@pval(1)) /)         
  txres@txFontHeightF = 0.0125 
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

