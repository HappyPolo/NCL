;***********************************************************
; extval_4.ncl
;
; Concepts illustrated:
;   - Loop over a sequence of user specified shape, scale and location values
;   - Call a function to generate the PDF and CDF for the Weibull distribution
;   - Create a panel plot
;***********************************************************

; parameter specifications

   N      = 300
   xMin   = 0.01
   xMax   = 2.5 
   x      = fspan(xMin,xMax,N)
 
; https://en.wikipedia.org/wiki/Weibull_distribution
; -- with all center=0.0, this is the two-parameter Weibull distribution

   shape  = (/0.5,  1 , 1.5, 5/)
   scale  = (/1.0, 1.0, 1.0, 1/)
   center = (/0.0, 0.0, 0.0, 0/)
   nscl   = dimsizes( scale )

; Generate distribution


   pdfcdf = extval_weibull(x, shape, scale, center, 0)
   pdf    = pdfcdf[0]                      ; extract from list for convenience
   cdf    = pdfcdf[1]

   printVarSummary(pdf)
   printMinMax(pdf,1)
   print("---")
   printVarSummary(cdf)
   printMinMax(cdf,1)
   print("---")

; plots
; Compare with https://en.wikipedia.org/wiki/Weibull_distribution
; color schemes do not match

   data    = new((/nscl,N/), "float")
   labels  = new(  nscl    , "string")
   plot    = new(   2      , "graphic")

   wks     = gsn_open_wks ("png","extval_weibull") 
   gsn_define_colormap(wks,"default")        

   res     = True       
   res@gsnDraw  = False
   res@gsnFrame = False

   res@xyLineThicknessF  = 2.0
   res@xyMonoDashPattern = True
   res@xyLineColors      = (/"blue","red","purple","green"/)
   res@trYMinF           = 0.0             ; min value on y-axis
   res@trYMaxF           = 2.5             ; max value on y-axis
   res@trXMinF           = 0.0             ; min value on x-axis
   res@trXMaxF           = xMax            ; max value on x-axis
                          
   res@pmLegendDisplayMode    = "Always"   ; turn on legend
   res@pmLegendSide           = "Top"      ; Change location of 
   res@pmLegendParallelPosF   = 0.675      ; move units right
   res@pmLegendOrthogonalPosF = -0.30      ; more neg = down
   res@pmLegendWidthF         = 0.12       ; Change width and
   res@pmLegendHeightF        = 0.150      ; height of legend.
   res@lgLabelFontHeightF     = 0.0175     ; change font height
   res@lgPerimOn              = True 
   res@lgItemOrder            = ispan(nscl-1,0,1)
   res@xyExplicitLegendLabels = " shp="+sprintf("%3.1f", shape)+ \
                                "; scl="+sprintf("%3.1f", scale)+"; ctr="+sprintf("%3.1f", center) 
   res@tiYAxisString = "PDF"
   plot(0)= gsn_csm_xy (wks,x,pdf,res) ; create plot

   res@trYMinF  = 0.0   
   res@trYMaxF  = 1.0  
   res@pmLegendOrthogonalPosF = -0.95      ; more neg = down
   res@tiYAxisString = "CDF"
   plot(1)= gsn_csm_xy (wks,x,cdf,res) ; create plot

   resP                       = True                  ; modify the panel plot
   resP@gsnMaximize           = True                  ; ps, eps, pdf
   resP@gsnPanelMainString    = "Weibull: Ext. Value Type III" ; use this for NCL V6.4.0 and later
  ;resP@txString              =                       ; use this for NCL V6.3.0 and earlier
  ;gsn_panel(wks,plot,(/2,1/),resP)                   ; now draw as one plot
   gsn_panel(wks,plot,(/1,2/),resP)  


   
