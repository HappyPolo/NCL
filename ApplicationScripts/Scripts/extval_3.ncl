;***********************************************************
; extval_3.ncl
;
; Concepts illustrated:
;   - Loop over a sequence of user specified shape, scale and location values
;   - Call a function to generate the PDF and CDF for the Frechet distribution
;   - Create a panel plot
;***********************************************************

; parameter specification

   N    = 1000
   xMin = 0.05
   xMax = 5.5
   x    = fspan(xMin,xMax,N)

; https://en.wikipedia.org/wiki/Fr%C3%A9chet_distribution
; - the (0.5,1.0)  is additional
; - with all center=0.0, this is the two-parameter Frechet distribution

   shape  = (/0.5, 1.0, 2.0, 3.0, 1.0, 2.0, 3.0/)
   scale  = (/1.0, 1.0, 1.0, 1.0, 2.0, 2.0, 2.0/)
   center = (/0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0/)
   nscl   = dimsizes( scale )

; Generate PDF and CDF: Returned as type list

   pdfcdf = extval_frechet(x, shape, scale, center, 0)   
   pdf    = pdfcdf[0]                      ; extract from list for convenience
   cdf    = pdfcdf[1]

   printVarSummary(pdf)
   printMinMax(pdf,1)
   print("---")
   printVarSummary(cdf)
   printMinMax(cdf,1)
   print("---")

; plots
; Compare with: https://en.wikipedia.org/wiki/Fr%C3%A9chet_distribution
; color schemes do not match; this has one (or more) additional parameters

   data   = new((/nscl,N/), "float")
   labels = new(  nscl    , "string")
   plot   = new(   2      , "graphic")

   wks    = gsn_open_wks ("png","extval_frechet") 
 ;;gsn_define_colormap(wks,"default")        

   res    = True       
   res@gsnDraw  = False
   res@gsnFrame = False

   res@xyLineThicknessF  = 2  
   res@xyMonoDashPattern = True
   res@xyLineColors      = (/"black","blue","DarkGreen","red","turquoise", "purple", "orange"/)  
   res@trYMinF           = -0.1            ; graphical purposes
  ;res@trYMaxF           =                 ; max value on y-axis (optional)
   res@trXMinF           = 0.0             ; graphical purposes
   res@trXMaxF           = xMax            ; max value on x-axis
                          
   res@pmLegendDisplayMode    = "Always"   ; turn on legend
   res@pmLegendSide           = "Top"      ; Change location of 
   res@pmLegendParallelPosF   = .75        ; move units right
   res@pmLegendOrthogonalPosF = -0.4       ; more neg = down
   res@pmLegendWidthF         = 0.12       ; Change width and
   res@pmLegendHeightF        = 0.200      ; height of legend.
   res@lgLabelFontHeightF     = 0.0175     ; change font height
   res@lgPerimOn              = True 
   res@lgItemOrder            = ispan(nscl-1,0,1)  
   res@xyExplicitLegendLabels = " shp="+sprintf("%3.1f", shape)+"; scl="+sprintf("%3.1f", scale)

   res@tiYAxisString = "PDF"
   plot(0)= gsn_csm_xy (wks,x,pdf,res) ; create plot

   res@trYMinF  = 0.0   
   res@trYMaxF  = 1.0  
   res@pmLegendOrthogonalPosF = -0.95      ; more neg = down
   res@tiYAxisString = "CDF"
   plot(1)= gsn_csm_xy (wks,x,cdf,res) ; create plot

   resP                       = True                  ; modify the panel plot
   resP@gsnMaximize           = True                  ; ps, eps, pdf
   resP@gsnPanelMainString    = "Frechet: Ext. Value Type II: Maxima" ; use this for NCL V6.4.0 and later
 ;;resP@txString              =                                       ; use this for NCL V6.3.0 and earlier
   gsn_panel(wks,plot,(/1,2/),resP)  
