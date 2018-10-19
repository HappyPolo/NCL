;*******************************************************
; leg_12.ncl
;
; Concepts illustrated:
;   - Drawing a legend inside an XY plot
;   - Moving a legend closer to a plot
;   - Changing the font size of legend labels
;   - Changing the width and height of a legend
;   - Changing the length of the lines in a legend
;
;*******************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;---Create dummy data for four XY plots.
  NPTS   = 500
  y      = new((/4,NPTS/),float)
  theta  = 0.031415926535898*ispan(0,NPTS-1,1)
  y(0,:) = sin(theta)
  y(1,:) = 2+sin(2*sqrt(fabs(theta)))   ; Make sure they
  y(2,:) = 4+sin(3*sqrt(fabs(theta)))   ; don't intersect.
  y(3,:) = 6+sin(10*sqrt(fabs(theta)))

  wks = gsn_open_wks("png","leg")       ; send graphics to PNG file

  res                        = True
  res@gsnMaximize            = True       ; Maximize plot in frame.

  res@pmLegendDisplayMode    = "Always"   ; Display a legend.
  res@xyExplicitLabels       = "y" + ispan(1,4,1)
  res@xyLineThicknessF       = 2.0
  res@xyLineColors           = (/"brown","purple","orange","green"/) 
  res@tiMainString           = "Default legend"
  res@xyDashPatterns         = (/1,8,11,15/)
 
  plot = gsn_csm_y(wks,y,res)

;---Further customize the legend
  res@trYMinF                = -3.5      ; Leave space at bottom for legend

  res@xyExplicitLegendLabels = "These are long legend labels, y" + ispan(1,4,1)

  res@lgJustification        = "TopRight"
  res@pmLegendOrthogonalPosF = -0.32     ; Move into plot
  res@pmLegendParallelPosF   = 1.0       ; Move to right
  res@pmLegendWidthF         = 0.3       ; Decrease width
  res@pmLegendHeightF        = 0.1       ; Decrease height
  res@lgBoxMinorExtentF      = 0.1       ; Shorten the legend lines
  res@lgLabelFontHeightF     = 0.015     ; Change the font size

  res@tiMainString           = "Customized legend"

  plot = gsn_csm_y(wks,y,res)
end
