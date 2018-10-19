;----------------------------------------------------------------------
; annotate_9.ncl
;
; Concepts illustrated:
;   - Adding small XY plots to a big XY plot as an annotation
;   - Attaching a plot as an annotation of another plot
;   - Resizing a plot
;   - Setting trYMinF to get more white space at bottom of XY plot
;----------------------------------------------------------------------
; This script creates a large XY plot and adds three smaller XY
; plots at the bottom as annotations.
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;---Define the number of points in each curve.
  NPTS  = 500
  PI100 = 0.031415926535898
  EXP   = 2.7182818

;---Create dummy data for four XY plots.
  theta = PI100*ispan(0,NPTS-1,1)
  y1    = sin(theta)
  y2    = sin(theta * theta)
  y3    = sin(EXP^theta)
  y4    = sin(3*sqrt(fabs(theta)))

;---Start the graphics
  wks = gsn_open_wks("png","annotate")  ; send graphics to PNG file

;---First plot will be the large XY plot.
  res             = True
  res@gsnMaximize = True
  res@gsnDraw     = False
  res@gsnFrame    = False

  res@trYMinF     = -2.0         ; Leave some white space for small plots

  xy1 = gsn_csm_y(wks,y1,res)    ; Create the "base" plot.

;---Create the three small plots. Be sure to turn off gsnMaximize!
  delete(res@trYMinF)

  res@gsnMaximize   = False

  res@vpWidthF      = 0.2       ; Make plots quite a bit smaller.
  res@vpHeightF     = 0.2

;---Create each plot with a different line color
  res@xyLineColor   = "Brown"
  xy2 = gsn_csm_y(wks,y2,res)

  res@xyLineColor   = "Orange"
  xy3 = gsn_csm_y(wks,y3,res)

  res@xyLineColor   = "ForestGreen"
  xy4 = gsn_csm_y(wks,y4,res)

;
; Set up a resource list to add smaller plots as
; annotations of bigger plots.
;
  amres                  = True
  amres@amJust           = "BottomLeft"  ; Corner of plot for positioning

  amres@amOrthogonalPosF =  0.47   ;  0.5 is the bottom edge of the plot.
                                   ; Need to leave room for tickmarks.


  amres@amParallelPosF   = -0.45   ; -0.5 is the left edge of the plot.
  anno2 = gsn_add_annotation(xy1, xy2, amres)  ; Attach first plot

  amres@amParallelPosF  = -0.14
  anno3 = gsn_add_annotation(xy1, xy3, amres)  ; Attach second plot

  amres@amParallelPosF  =  0.17
  anno4 = gsn_add_annotation(xy1, xy4, amres)  ; Attach third plot

;---Drawing the "base" plot will draw all four plots.
  draw(xy1)
  frame(wks)
end
