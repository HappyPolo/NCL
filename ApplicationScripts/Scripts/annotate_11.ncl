;----------------------------------------------------------------------
; annotate_11.ncl
;
; Concepts illustrated:
;   - Attaching a plot as an annotation of another plot
;   - Using annotations to draw a curve outside the frame of an XY plot
;   - Using functions for cleaner code
;   - Using gsn_add_annotation to attach one plot as an annotation of another
;   - Using gsn_csm_blank_plot to get custom tickmark labels
;----------------------------------------------------------------------
; If you draw a curve outside the bounds of an XY plot, NCL will 
; automatically clip it. There's no way to turn this feature off.
;
; To create a plot that looks like it hasn't been clipped, you
; need to create two plots: the two XY curves on one plot, but with
; all tickmarks turned off, and then a blank plot with the same size and 
; axis limits as the smaller XY curve.  gsn_add_annotation is used to 
; add the blank plot as an annotation of the XY plot. This allows you 
; to resize it if necessary (say, in a panel plot, which is done below). 
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;----------------------------------------------------------------------
; This function attaches tickmarks and labels to an existing XY
; plot with two curves, using the area around the smaller curve.
;----------------------------------------------------------------------
undef("create_blank_plot")
function create_blank_plot(wks,xyplot,y)
local bres, vpx, vpy, vpw, vph, xmin, xmax, ymin, tstart, tend, tspace, \
mperm, fonth, xndc, yndc, amres
begin
;
; Retrieve the size of the XY plot so we can use 
; this to set size of blank plot.
;
  getvalues xyplot
    "vpXF"                 : vpx
    "vpYF"                 : vpy
    "vpWidthF"             : vpw
    "vpHeightF"            : vph
    "trXMinF"              : xmin
    "trXMaxF"              : xmax
    "trYMinF"              : ymin
;
; The following only necessary if you want the
; tickmarks to be the same as in original plot
;
    "tmYLTickStartF"       : tstart
    "tmYLTickEndF"         : tend
    "tmYLTickSpacingF"     : tspace
    "tmYLMinorPerMajor"    : mperm
    "tmYLLabelFontHeightF" : fonth
  end getvalues

;---Get the upper left corner in NDC coordinates of the "smaller" curve
  xndc = new(1,float)
  yndc = new(1,float)
  datatondc(xyplot,xmin,max(y(0,:)),xndc,yndc)

;---Create blank plot that has axis labels and tickmarks
  bres                   = True

  bres@gsnDraw           = False   ; Again, just create plot;
  bres@gsnFrame          = False   ; don't draw or advance frame.

;---Use a size based on what the size would be of the smaller plot
  bres@vpXF              = vpx
  bres@vpYF              = yndc
  bres@vpWidthF          = vpw
  bres@vpHeightF         = vph-(vpy-yndc)

;---Use same axis limits as XY plot, except for trYMaxF.
  bres@trXMinF           = xmin
  bres@trXMaxF           = xmax
  bres@trYMinF           = ymin
;---Use smaller of two Y maxes. 
  bres@trYMaxF           = min((/max(y(0,:)),max(y(1,:))/))

  bres@tmEqualizeXYSizes = True         ; Scale tickmarks and labels

;
; The following is only necessary if you want the
; tickmarks to be the same as in original plot
;
  bres@tmYLMode               = "Manual"
  bres@tmYLTickStartF         = tstart
  bres@tmYLTickEndF           = tend
  bres@tmYLTickSpacingF       = tspace
  bres@tmYLMinorPerMajor      = mperm
  bres@tmYLFormat             = "0@;*.2f"    ; Force a ".0" format
  bres@tmYLLabelFontHeightF   = fonth

  blank_plot = gsn_csm_blank_plot(wks,bres)

;---Attach blank plot with tickmarks as annotation of xy2
  amres                  = True
  amres@amJust           = "BottomCenter"
  amres@amOrthogonalPosF =  0.5     ; This will align bottom of two plots

  anno = gsn_add_annotation(xyplot, blank_plot, amres)

  return(anno)
end

;----------------------------------------------------------------------
; Main code 
;----------------------------------------------------------------------
begin
;
; Create dummy data for two XY plots. Make sure one of them has
; a larger Y axis maximum.
;
  NPTS  = 500
  PI100 = 0.031415926535898
  x     = ispan(0,NPTS-1,1)
  y     = new((/2,NPTS/),float)
  theta = PI100*x
  y(0,:) = sin(theta)
  y(1,:) = 2*sin(3*sqrt(fabs(theta))) + 1

;---Start the graphics
  wks = gsn_open_wks("png","annotate")   ; send graphics to PNG file

  res                   = True

  res@gsnDraw           = False    ; Don't draw the plot or
  res@gsnFrame          = False    ; advance the frame.

  res@xyMonoDashPattern = True
  res@xyLineColors      =  (/"Brown","NavyBlue"/)
  res@xyLineThicknessF  = 2.0

;---Create a plot with tickmarks and labels
  xy1 = gsn_csm_xy(wks,x,y,res)

  res@gsnTickMarksOn   = False    ; Turn off all tickmarks and labels

;---Create a plot without tickmarks and labels
  xy2 = gsn_csm_xy(wks,x,y,res)    ; Create the plot with two curves

;
; Add tickmarks and labels as annotation of second plot, but
; based on the smaller of the two curves. The "create_blank_plot"
; function is defined at the top of this file.
;
  annoid = create_blank_plot(wks,xy2,y)

;---Panel both plots for comparison
  pres             = True
  pres@gsnMaximize = True
  pres@txString    = "Identical XY curves with different tickmarks"

  gsn_panel(wks,(/xy1,xy2/),(/1,2/),pres)
end
