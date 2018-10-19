;----------------------------------------------------------------------
; xy_23.ncl
;
; Concepts illustrated:
;   - Drawing stacked XY plots
;   - Attaching multiple XY plots along the X axes
;   - Turning off tickmarks on the left Y axis
;   - Turning on tickmarks on the right Y axis
;   - Moving tickmark labels away from axis
;----------------------------------------------------------------------
; See example xy_34.ncl for a variation of this plot that doesn't
; use gsn_attach_plots. This one adds special highlighting to two
; of the plots.
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;----------------------------------------------------------------------
;
;  This example illustrates the creation of a set of 4
;  of 'stacked' XY plots. Each plot has the same X axis.
;  By using gsn_attach_plots, all four plots can be
;  manipulated as a unit through the base plot.
;
;  To demonstrate this concept, the base plot is resized
;  in the second frame.
;
;  Each plot draws a variation of sinusoidal curve.
;----------------------------------------------------------------------

begin

;
; Define the number of points in each curve.
;
  NPTS  = 500
  PI100 = 0.031415926535898
  EXP   = 2.7182818
;
; Create data for the four XY plots.
;
  theta = PI100*ispan(0,NPTS-1,1)
  y1 = sin(theta)
  y2 = sin(theta * theta)
  y3 = sin(EXP^theta)
  y4 = sin(3*sqrt(fabs(theta)))

  wks = gsn_open_wks("png","xy")

  res             = True
  res@gsnMaximize = True
  res@gsnDraw     = False
  res@gsnFrame    = False

  res@vpWidthF    = 0.8      ; Make plots wider than 
  res@vpHeightF   = 0.2      ; they are high.

  res@tmYUseLeft           = False   ; Make right axis independent of left
  res@tmYLOn               = False   ; Turn off left tickmarks
  res@tmYROn               = True    ; Turn on right tickmarks
  res@tmXTOn               = False   ; Turn off top tickmarks
  res@tmYLLabelsOn         = False   ; Turn off left labels
  res@tmYRLabelsOn         = True    ; Turn on right labels
  res@tmYRMinorOn          = False   ; Turn off minor ticks on Y axis
  res@tmYRLabelFontHeightF = 0.015   ; Increase font height
  res@tmYRLabelDeltaF      = 2.0     ; Increase space b/w ticks and labels
  res@tmYRLabelJust        = "CenterRight"   ; right-justify labels

  res@xyLineThicknessF     = 2.0   ; Twice as thick

; Change y axis string and color for each plot.
  res@tiYAxisString = "xy1"
  res@xyLineColor   = "Purple"
  xy1 = gsn_csm_y(wks,y1,res)    ; Create the four plots.

  res@tiYAxisString = "xy2"
  res@xyLineColor   = "Brown"
  xy2 = gsn_csm_y(wks,y2,res)    ; They won't be drawn yet.

  res@tiYAxisString = "xy3"
  res@xyLineColor   = "Orange"
  xy3 = gsn_csm_y(wks,y3,res)

  res@tiYAxisString = "xy4"
  res@xyLineColor   = "ForestGreen"
  xy4 = gsn_csm_y(wks,y4,res)

; Set up resource lists for attaching the plot.
; The res1 will apply to the base plot, and the
; res2 to the plots being attached.  These resources
; lists are *not* for changing things like line color,
; but for changing things like whether the plots
; are maximized, and which axis they are attached on.
;
  res1                     = True
  res2                     = True
  res1@gsnMaximize         = True
  res2@gsnAttachPlotsXAxis = True

; xy1 will be the base plot.
  amid = gsn_attach_plots(xy1,(/xy2,xy3,xy4/),res1,res2)

  draw(xy1)    ; All four plots will be drawn.
  frame(wks)

; Resize base plot and watch how other plots follow.
  setvalues xy1
    "vpWidthF"  : 0.4
    "vpHeightF" : 0.15
  end setvalues

  draw(xy1)    ; All four plots will be smaller.
  frame(wks)
end

