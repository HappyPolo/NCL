;*******************************************************
; leg_14.ncl
;
; Concepts illustrated:
;   - Overlaying XY plots on each other
;   - Drawing a legend for only two of four curves
;   - Moving a legend into to a plot
;*******************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;---Create dummy data for four curves
  NPTS  = 500
  PI100 = 0.031415926535898

  x      = ispan(0,NPTS-1,1)
  y      = new((/4,NPTS/),float)
  theta  = PI100*x
  y(0,:) = sin(theta)
  y(1,:) = 2+sin(2*sqrt(fabs(theta)))   ; Make sure they
  y(2,:) = 4+sin(3*sqrt(fabs(theta)))   ; don't intersect.
  y(3,:) = 6+sin(10*sqrt(fabs(theta)))

  wks = gsn_open_wks("png","leg")       ; send graphics to PNG file 

  res                        = True
  res@gsnMaximize            = True       ; Maximize plot in frame.
  res@gsnDraw                = False
  res@gsnFrame               = False

  res@xyMonoDashPattern      = True       ; make all lines are solid

  res@trYMinF                = min(y)-2   ; leave a margin for legend
  res@trYMaxF                = max(y)+1
  res@trXMinF                = min(x)
  res@trXMaxF                = max(x)

  res@xyLineThicknessF       = 2.5                  ; line thickness

;---These two resources will apply to the two curves in the first plot
  res@xyLineColors           = (/"green","purple"/)
  plot1 = gsn_csm_xy(wks,x,y(0:1,:),res)

;---For the second plot, turn on a legend.
  res@xyLineColors           = (/"blue","red"/)
  res@xyExplicitLegendLabels = (/"line3","line4"/)
  res@pmLegendDisplayMode    = "Always"   ; Display a legend.
  res@pmLegendWidthF         = 0.2        ; Make it smaller
  res@pmLegendHeightF        = 0.1        ; Make it smaller
  res@pmLegendOrthogonalPosF = -0.32      ; Move into to plot
  res@pmLegendParallelPosF   =  0.75      ; Move to right
  res@lgPerimOn              = False      ; No legend perimeter.
  res@lgLabelFontHeightF     = 0.01

  plot2 = gsn_csm_y(wks,y(2:3,:),res)

;
; Once you overlay, all four lines will be on one plot,
; but only one legend will appear.
;
  overlay(plot1,plot2)
  draw(plot1)
  frame(wks)
end
