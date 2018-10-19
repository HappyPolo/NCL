;----------------------------------------------------------------------
; annotate_10.ncl
;
; Concepts illustrated:
;   - Adding small XY plots to a big XY plot as an annotation
;   - Filling in an XY background to hide plot elements under it
;   - Attaching a plot as an annotation of another plot
;   - Resizing a plot
;   - Using "setvalues" to change the main title of an existing plot
;----------------------------------------------------------------------
; This script creates a large XY plot and adds three smaller XY
; plots at the bottom as annotations.
;----------------------------------------------------------------------

;----------------------------------------------------------------------
; This function takes an existing plot and fills its background in the
; given color.
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

function fill_background(wks,plot,color)
local xmin,xmax,ymin,yma,gres,xbox,ybox
begin
  getvalues plot
    "trXMinF"  : xmin
    "trXMaxF"  : xmax
    "trYMinF"  : ymin
    "trYMaxF"  : ymax
  end getvalues

  xbox = (/xmin,xmax,xmax,xmin,xmin/)
  ybox = (/ymin,ymin,ymax,ymax,ymin/)

;---Resources for filling the polygon
  gres                 = True
  gres@gsFillColor     = color
  gres@tfPolyDrawOrder = "PreDraw"    ; This is necessary so that the 
                                      ; fill doesn't cover the curves.

;---Attach polygon to existing plot and return
  dum = gsn_add_polygon(wks,plot,xbox,ybox,gres)
  return(dum)
end

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
  wks = gsn_open_wks("png","annotate") ; send graphics to PNG file

;---First plot will be the large XY plot.
  res             = True
  res@gsnMaximize = True
  res@gsnDraw     = False
  res@gsnFrame    = False

  res@tiMainString      = "Big plot curve can been seen under little plots"
  res@tiMainFontHeightF = 0.02
  xy1 = gsn_csm_y(wks,y1,res)    ; Create the "base" plot.
  delete(res@tiMainString) 
  delete(res@tiMainFontHeightF)

;---Create the three small plots. Be sure to turn off gsnMaximize!

  res@gsnMaximize   = False

  res@vpWidthF      = 0.2       ; Make plots quite a bit smaller.
  res@vpHeightF     = 0.2

;---Create each plot with a different line color
  res@xyLineColor   = "NavyBlue"
  xy2 = gsn_csm_y(wks,y2,res)

  res@xyLineColor   = "Firebrick"
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

;---Change main title
  setvalues xy1
    "tiMainString"      : "Big plot curve covered by little plots"
    "tiMainFontHeightF" : 0.03
  end setvalues

;---Fill the backgrounds in NavajoWhite so they cover the big plot.
  dum2 = fill_background(wks,xy2,"NavajoWhite")
  dum3 = fill_background(wks,xy3,"NavajoWhite")
  dum4 = fill_background(wks,xy4,"NavajoWhite")

  draw(xy1)
  frame(wks)

end
