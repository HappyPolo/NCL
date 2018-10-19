;************************************************
; extvalv_5.ncl
;
; Concepts illustrated:
;   - Using extval_mlegev  and extval_gev
;   - Calculate basic statistics 
;     - Basic statistics of the original sample
;     - Estimate GEV distribution parameters
;   - Creating a 'text' object to attach to a plot
;*************************************************
; These are the max river flow values in any year:  Block Maxima 
;*************************************************

   river_flow = (/  \ 
          312,590,248,670,365,770,465,545,315,115,232,260,655,675,  \
          455,1020,700,570,853,395,926,99,680,121,976,916,921,191,  \
          187,377,128,582,744,710,520,672,645,655,918,512,255,1126, \
         1386,1394,600,950,731,700,1407,1284,165,1496,809           /)
   
   river_flow@long_name = "Maximum Annual River Flow Rate"
   river_flow@units     = "???"
   river_flow!0         = "year"
   river_flow&year      = ispan(1951,2003,1)   ; bogus years

   ntim = dimsizes(river_flow)
   yyyy = river_flow&year 

;***************************************************************
;--- "Normal" (conventional) statistical estimates for full sample 
;***************************************************************
   
   xStat4 = dim_stat4_n(river_flow, 0)  ; 1st 4 moments of original sample
                                   ; explicitly extract for clarity
   xAvg   = xStat4(0)              ; original sample mean
   xStd   = sqrt(xStat4(1))        ;    "     sample std dev
   xSkew  = xStat4(2)              ; skewness; departure from symmetry
   xKurt  = xStat4(3)              ; kurtosis; relative to a normal distribution
   xLow   = min(river_flow)
   xMed   = dim_median_n(river_flow,0)  ; median of original sample
   xHi    = max(river_flow)

;***************************************************************
;---GEV parameter estimation
;***************************************************************

   vals     = extval_mlegev (river_flow, 0, False)    ; dims=0
   print(vals) 

   center   = vals(0)                            ; extract for clarity
   scale    = vals(1)
   shape    = vals(2)

   pdfcdf   = extval_gev(river_flow, shape, scale, center,0)
   pdf      = pdfcdf[0]                          ; extract from list for convenience
   cdf      = pdfcdf[1]
   delete(pdfcdf)

   printVarSummary(pdf)
   printMinMax(pdf,1)
   print("---")
   printVarSummary(cdf)
   printMinMax(cdf,1)
   print("---")

;***************************************************************
;--- PLOTS
;***************************************************************

   pltDir          = "./"
  ;pltName         = "MLE_GEV_River_Flow"
   pltName         = "extval_5"
   pltType         = "x11"
   pltPath         =  pltDir+pltName

   wks  = gsn_open_wks (pltType, pltPath)         
   gsn_define_colormap(wks,"default")        
   plot = new(2, "graphic")

;***************************************************************
;--- Plot original values: (a) time series, (b) ascending order
;***************************************************************

   res     = True       
   res@gsnDraw  = False
   res@gsnFrame = False
   res@tiYAxisString = ""

   res@tiMainString  = "River Flow: Time Series"
   plot(0) = gsn_csm_xy (wks,yyyy, river_flow,res) ; create plot

   it      = dim_pqsort_n(river_flow, 1, 0)        ; for plot reasons make  'x' is asebding 
   res@tiMainString = "River Flow: Rank (Ascending) Order"
   plot(1) = gsn_csm_xy (wks,ispan(1,ntim,1),river_flow(it),res) ; create plot

;************************************************
; Panel
;************************************************

   resP                     = True                  ; modify the panel plot
   resP@gsnMaximize         = True                  ; ps, eps, pdf
   resP@gsnPanelMainString  = "River Flow Rate"     ; use this for NCL V6.4.0 and later
   resP@txFontHeightF       = 0.020
   gsn_panel(wks,plot,(/1,2/), resP)                ; now draw as one plot

;***************************************************************
;--- create histogram for the original sample
;***************************************************************

   resh = True
   resh@gsnDraw      = False
   resh@gsnFrame     = False
   resh2gsnHistogramNumberOfBins = 11

   resh@gsFillColor  = "green"
   resh@tiMainString = "River Flow Rate: N="+ntim
   plt_hist          = gsn_histogram(wks, river_flow ,resh)  

;***************************************************************
;--- text object original sample statistics; place on histogram 
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
   amres@amOrthogonalPosF = -0.10             ; move the legend up
   annoSample = gsn_add_annotation(plt_hist, txBoxSample, amres)  ; Attach string to plot

   draw(plt_hist)
   frame(wks)

;***************************************************************
;--- Plot PDF and CDF ; create panel
;************************************************

   res@tiMainString = "PDF: River Flow Rate"
   plot(0) = gsn_csm_xy (wks,river_flow(it),pdf(it),res) ; create plot

   res@trYMinF  = 0.0   
   res@trYMaxF  = 1.0  
   res@tiMainString = "CDF: River Flow Rate"
   plot(1) = gsn_csm_xy (wks,river_flow(it),cdf(it),res) ; create plot
   resP@gsnPanelMainString  = "GEV: Flood: " + \    ; use this for NCL V6.4.0 and later
                              "shp="+sprintf("%4.3f", shape)+ \
                              "; scl="+sprintf("%3.1f", scale)+"; ctr="+sprintf("%3.1f", center) 
   gsn_panel(wks,plot,(/1,2/), resP)             ; now draw as one plot
