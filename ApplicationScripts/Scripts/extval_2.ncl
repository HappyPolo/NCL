;***********************************************************
; extval_2.ncl
;
; Concepts illustrated:
;   - Loop over a sequence of user specified shape, scale and location values
;   - Call a function to generate the PDF and CDF for the Gumbel distribution
;   - Create a panel plot
;***********************************************************

;===========================================================
;                            MAIN
;===========================================================
; parameter specification

   N    = 100
   xMin = -10.0
   xMax =  20 
   x    = fspan(xMin,xMax,N)

; https://en.wikipedia.org/wiki/Gumbel_distribution
; http://www.mathwave.com/articles/extreme-value-distributions.html#evd_gumbel
; The shape of the Gumbel model does not depend on the distribution parameters: 
; The Gumbel distribution, also known as the Extreme Value Type I distribution, 
;     is unbounded (defined on the entire real axis)

   scale  = (/2.0, 2.0, 3.0, 4, 6, 1/)
   center = (/0.5,  1 , 1.5, 3, 3, 0/)
   nscl   = dimsizes( scale )

; plots

   data     = new((/nscl,N/), "float")
   labels   = new(  nscl    , "string")
   plot     = new(   2      , "graphic")

   wks      = gsn_open_wks ("png","extval_gumbel") 
   gsn_define_colormap(wks,"default")        

   res      = True       
   res@gsnDraw  = False
   res@gsnFrame = False

   res@xyLineThicknessF  = 2.0
   res@xyMonoDashPattern = True
   res@xyLineColors      = (/"red","green","blue","purple", "yellow", "black"/)  

   res@trYMinF  = 0.0                      ; min value on y-axis
  ;res@trYMaxF  =                          ; max value on y-axis
   res@trXMinF  = xMin                     ; min value on x-axis
   res@trXMaxF  = xMax                     ; max value on x-axis
                          
   res@pmLegendDisplayMode    = "Always"   ; turn on legend
   res@pmLegendSide           = "Top"      ; Change location of 
   res@pmLegendParallelPosF   = .75        ; move units right
   res@pmLegendWidthF         = 0.12       ; Change width and
   res@pmLegendHeightF        = 0.150      ; height of legend.
   res@lgLabelFontHeightF     = 0.0175     ; change font height
   res@lgPerimOn              = True 
   res@lgItemOrder            = ispan(nscl-1,0,1)
   res@xyExplicitLegendLabels = "c="+sprintf("%3.1f", center)+"; s="+sprintf("%3.1f", scale)

   resP                       = True                  ; modify the panel plot
   resP@gsnMaximize           = True                  ; ps, eps, pdf

; -- Gumbel: Type I, Max

   pdfcdf = extval_gumbel(x, center, scale,  1) ; minmax= 1
   pdf    = pdfcdf[0]                      ; extract from list for convenience
   cdf    = pdfcdf[1]

   res@pmLegendOrthogonalPosF = -0.4       ; more neg = down
   res@tiYAxisString = "PDF"
   plot(0) = gsn_csm_xy (wks,x,pdf,res) 

   res@pmLegendOrthogonalPosF = -0.9       ; more neg = down
   res@tiYAxisString = "CDF"
   plot(1) = gsn_csm_xy (wks,x,cdf,res)

   resP@gsnPanelMainString    = "Gumbel: Ext. Value Type I; Maxima" ; use this for NCL V6.4.0 and later
  ;resP@txString              =                                     ; use this for NCL V6.3.0 and earlier
   gsn_panel(wks,plot,(/1,2/),resP)

; -- Gumbel: Type I, Min

   pdfcdf= extval_gumbel(x, center, scale, -1)  ;  minmax=-1 
   pdf    = pdfcdf[0]                      ; extract from list for convenience
   cdf    = pdfcdf[1]

   res@pmLegendOrthogonalPosF = -0.4 
   res@tiYAxisString = "PDF"
   plot(0) = gsn_csm_xy (wks,x,pdf,res) 

   res@pmLegendOrthogonalPosF = -0.9 
   res@tiYAxisString = "CDF"
   plot(1) = gsn_csm_xy (wks,x,cdf,res)

   resP@gsnPanelMainString    = "Gumbel: Ext. Value Type I; Minima" ; use this for NCL V6.4.0 and later
 ;;resP@txString              = "Gumbel: Ext. Value Type I; Minima" ; use this for NCL V6.3.0 and earlier
   gsn_panel(wks,plot,(/1,2/),resP)
