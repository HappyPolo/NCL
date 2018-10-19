;*************************************************
; regress_6.ncl
;
; Concepts illustrated:
;   - Calculating the least squares line fit via 'lspoly_n'           
;   - Calculating the simple linear regression via 'regline_stats'
;   - Drawing a scatter plot and regression and polynomial curves
;*************************************************

;**************************
; read monthly data
;**************************

   diri = "./"
   nxy  = numAsciiRow(diri+"ipoind_8yrTrend.asc")               ; # values
   y    = asciiread(diri+"ipoind_8yrTrend.asc",nxy, "float")
   x    = asciiread(diri+"tsind_8yrTrend.asc" ,nxy, "float")

   y@_FillValue = y(nxy-1)             ; last valu on the file is _FillValue
   x@_FillValue = x(nxy-1)

;**************************
; least squares: x,y pairs can be in any order
;**************************

   nc   = 4                            ; 3rd degree polynomial
   coef = lspoly_n(x, y, 1, nc, 0)     ; Least Squares Fit; all weights are set to one 
   print(coef)
   print("======")

;**************************
; linear regression: x,y pairs can be in any order
;**************************

   rc = regline (x,y)                  ; linear regression
   print(rc)
   print("======")

;**************************
; Plot lines require that the abscissa be in monotonic order (ascending or descending)
; Note: markers do *not* require any ordering
;**************************

   mono = 1                            ; ascending=1 , descending=-1
   ii   =  dim_pqsort_n(x,mono,0)
   xx   = x(ii)                        ; ascending order 
   yy   = y(ii)

;**************************
; generate the lines
;**************************

   ypoly = coef(0) + coef(1)*xx + coef(2)*xx^2 + coef(3)*xx^3  ; polyline
   yregr = rc*xx + rc@yintercept                               ; regression

;**************************
; PLOT
;**************************

  tplt      = new((/3,nxy/), typeof(x), x@_FillValue)
  tplt(0,:) = yy    
  tplt(1,:) = ypoly
  tplt(2,:) = yregr

  wks = gsn_open_wks("png","regress")              ; send graphics to PNG file

  res                     = True                   ; plot mods desired
  res@gsnMaximize         = True                   ; maximize plot in frame
  res@xyMarkLineModes     = (/"Markers","Lines", "Lines"/)  ; choose which have markers
  res@xyMarkers           = 16                     ; choose type of marker 
  res@xyMarkerColor       = "red"
  res@xyMonoLineColor     = False
  res@xyLineColors        = (/"green","blue","black"/)
  res@xyMarkerSizeF       = 0.005                  ; Marker size (default 0.01)
  res@xyDashPatterns      = 1                      ; solid line 
  res@xyLineThicknesses   = (/1,5,5/) 
  res@vpWidthF            = 0.75
  res@vpHeightF           = 0.5

  res@tiXAxisString       = "IPO trend"
  res@tiYAxisString       = "Temperature trend (~S~o~N~C/dec)"
  res@tiMainString        = "Decadal trend of IPO and Global mean T (8-yr)"  ; title
 
  plot  = gsn_csm_xy (wks,xx,tplt,res)             ; create plot
