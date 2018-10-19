;***********************************************************
; extval_1.ncl
;
; Concepts illustrated:
;   - Loop over a sequence of user specified shape, scale and location values
;   - Call a function to generate the PDF and CDF for the GEV distribution
;   - Create a panel plot
;***********************************************************

;===========================
; parameter specifications
;===========================

   N      =  200
   xMin   = -4.0 
   xMax   =  6.0 
   x      = fspan(xMin,xMax,N)
 
   shape  = (/-0.5, 0.0, 0.5 /)   
   scale  = (/ 1.0, 1.0, 1.0 /)            ; sigma
   center = (/ 0.0, 0.0, 0.0 /)            ; location, shift

   nscl   = dimsizes( scale )

; Generate PDF and GDF distribution

   pdfcdf = extval_gev(x, shape, scale, center, 0)  ; return a variable of type 'list'
   pdf    = pdfcdf[0]                               ; extract from list for convenience
   cdf    = pdfcdf[1]

   printVarSummary(pdf)
   printMinMax(pdf,1)
   print("---")

   printVarSummary(cdf)
   printMinMax(cdf,1)
   print("---")

; plots

   labels  = new(  nscl    , "string")
   plot    = new(   2      , "graphic")

   wks     = gsn_open_wks ("png","extval") 
;; gsn_define_colormap(wks,"default")        

   res     = True       
   res@gsnDraw  = False
   res@gsnFrame = False

   res@xyLineThicknessF  = 2.0
   res@xyMonoDashPattern = True
   res@xyLineColors      = (/"green","red","blue"/)
   res@trYMinF           =-0.02            ; min value on y-axis
   res@trYMaxF           = 0.5             ; max value on y-axis
   res@trXMinF           = xMin            ; min value on x-axis
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

   res@tiYAxisString = "PDF: extval_gev"
   plot(0)= gsn_csm_xy (wks,x,pdf,res) ; create plot

   res@trYMinF  = 0.0   
   res@trYMaxF  = 1.0  
   res@pmLegendOrthogonalPosF = -0.95      ; more neg = down
   res@tiYAxisString = "CDF: extval_gev"
   plot(1)= gsn_csm_xy (wks,x,cdf,res) ; create plot

   resP                       = True                  ; modify the panel plot
   resP@gsnMaximize           = True                  ; ps, eps, pdf
   resP@gsnPanelMainString    = "GEV: PDF and CDF"    ; use this for NCL V6.4.0 and later
  ;resP@txString              =                       ; use this for NCL V6.3.0 and earlier
   gsn_panel(wks,plot,(/1,2/),resP)  
