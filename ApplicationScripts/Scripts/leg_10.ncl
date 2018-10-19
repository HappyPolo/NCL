;*******************************************************
; leg_10.ncl
;
; Concepts illustrated:
;   - Drawing a legend inside an XY plot
;   - Masking the XY curves behind a legend
;   - Drawing a legend on top of everything in an XY plot
;   - Drawing vertical grid lines in an XY plot
;   - Changing the width and height of a legend
;   - Changing the legend box fill color
;   - Adding labels to curves in an XY plot
;
;*******************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;
; Define the number of points in each curve.
;
  NPTS  = 500
  PI100 = 0.031415926535898
;
; Create data for the four XY plots.
;
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

  res@lgPerimFill            = "SolidFill"      ; Fill legend box w/white
  res@lgPerimFillColor       = "white"          ; so it masks XY curves

  res@tiMainString           = "Legend drawn on top of curves"

  plot = gsn_csm_y(wks,y,res)    ; Draw plot with grid, no legend yet
  
  res@lgPerimFillColor       = "yellow"   ; Just for fun, change the color

  res@tmXMajorGrid           = True    ; Turn on vertical grid lines. The
                                       ; legend will be under the grid lines.

  res@tiMainString           = "Grid lines drawn on top of legend"

  plot = gsn_csm_y(wks,y,res)

;
; To get the legend to draw on top of grid lines, we have to draw the 
; plot first with the grid lines and no legend, and then draw
; the plot again with no grid lines but the legend turned on.
;
  res@pmLegendDisplayMode    = "Never"     ; Turn off legend for now
  res@gsnFrame               = False       ; Don't advance frame

  res@tiMainString           = "Legend drawn on top of grid lines"

  plot = gsn_csm_y(wks,y,res)    ; Draw plot with grid lines, but no legend

  res@pmLegendDisplayMode    = "Always"    ; Turn legend back on
  res@tmXMajorGrid           = False       ; Don't draw grid lines 2nd time
  res@gsnFrame               = True        ; This time advance the frame

  plot = gsn_csm_y(wks,y,res)    ; Draw plot again without grid
end
