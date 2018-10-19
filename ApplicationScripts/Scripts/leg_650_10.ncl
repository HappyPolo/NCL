;*******************************************************
; leg_650_10.ncl
;
; Concepts illustrated:
;   - Drawing a legend inside an XY plot
;   - Drawing vertical grid lines in an XY plot
;   - Using draw order resource to control when tickmark grid is drawn
;   - Changing the width and height of a legend
;   - Changing the legend box fill color
;   - Adding labels to curves in an XY plot
;*******************************************************
; This script uses a resource (tmGridDrawOrder) added 
; in NCL 6.5.0. At the time this script was created 
; (Mar 20, 2017) NCL V6.5.0 had not been released yet.
;*******************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;---Define the number of points in each curve.
  NPTS  = 500
  PI100 = 0.031415926535898

;---Create data for the four XY plots.
  y      = new((/4,NPTS/),float)
  theta  = PI100*ispan(0,NPTS-1,1)
  y(0,:) = sin(theta)
  y(1,:) = 2+sin(2*sqrt(fabs(theta)))   ; Make sure they
  y(2,:) = 4+sin(3*sqrt(fabs(theta)))   ; don't intersect.
  y(3,:) = 6+sin(10*sqrt(fabs(theta)))


  wks = gsn_open_wks("png","leg")               ; send graphics to PNG file

  res                        = True             ; plot mods desired
  res@gsnMaximize            = True

  res@pmLegendDisplayMode    = "Always"         ; Turn on a legend

  res@pmLegendOrthogonalPosF = -0.35            ; Move legend inside plot
  res@pmLegendParallelPosF   =  0.8             ; Move legend to right
  res@pmLegendWidthF         = 0.13             ; Change width and height
  res@pmLegendHeightF        = 0.1

  res@xyLabelMode            = "Custom"
  res@xyExplicitLabels       = (/"w","x","y","z"/)  ; explicit labels
  res@xyLineLabelFontHeightF = 0.015                ; font height

  res@lgPerimFill            = "SolidFill"          ; Fill legend box w/white
  res@lgPerimFillColor       = "yellow"             ; Just for fun, change the color

  res@tmXMajorGrid           = True                 ; Turn on vertical grid lines.
  res@tmGridDrawOrder        = "Draw"               ; NEW RESOURCE IN NCL V6.5.0. Make sure grid is
                                                    ; drawn in an earlier phase than the legend.

  res@tiMainString           = "Grid lines drawn under legend"

  plot = gsn_csm_y(wks,y,res)


end
