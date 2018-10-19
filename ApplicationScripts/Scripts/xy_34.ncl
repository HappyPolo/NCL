;----------------------------------------------------------------------
; xy_34.ncl
;
; Concepts illustrated:
;   - Drawing stacked XY plots
;   - Attaching multiple XY plots along the X axes
;   - Turning off tickmarks on the left Y axis
;   - Turning on tickmarks on the right Y axis
;   - Highlighting an area of a plot using filled polygons and text
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;----------------------------------------------------------------------
;  This example is a variation of xy_23.ncl.
;
;  It illustrates how to create four "stacked" plots by changing
;  the viewport resources. Each plot has the same X axis.
; 
;  This example additionally shows how to highlight a particular part
;  of a curve using filled polgons, lines and text (see 
;  "add_highlights" below).
;----------------------------------------------------------------------

;----------------------------------------------------------------------
; This function adds an annotation box to the given plot that 
; highlights a particular area with filled boxes and a title.
; "xmin"  and "xmax" represents which part of the x range to highlight.
;----------------------------------------------------------------------
function add_highlights(wks,plot,xmin,xmax,ymin,ymax,title)
local bres, gnres, lnres, txres, xbox, ybox, nboxes, ymin, ymax, range_perc
begin
  nboxes = 10
  xbox   = fspan(xmin,xmax,nboxes)
  ybox   = (/ymin,ymin,ymax,ymax,ymin/)
  nboxes = dimsizes(xbox)-1

;---Resources for filled purple boxes.
  gnres                 = True
  gnres@tfPolyDrawOrder = "PreDraw"
  gnres@gsFillColor     = "goldenrod" ; "MediumPurple1"
  gnres@gsFillOpacityF  = 0.15

  do n=0,nboxes-1,2
    str = "box_" + n
    plot@$str$ = gsn_add_polygon(wks,plot,\
                            (/xbox(n),xbox(n+1),xbox(n+1),xbox(n),xbox(n)/),\
                            ybox,gnres)
  end do

;---Resources to outline box of interest
  lnres                  = True
  lnres@tfPolyDrawOrder  = "PreDraw"
  lnres@gsLineThicknessF = 3.0
  plot@border = gsn_add_polyline(wks,plot,(/xmin,xmax,xmax,xmin,xmin/),\
                                          (/ymin,ymin,ymax,ymax,ymin/),lnres)


  txres                 = True
  txres@txFontHeightF   = 0.022
  txres@tfPolyDrawOrder = "PreDraw"
  txres@txFont          = "Helvetica-Bold"
  txres@txJust          = "TopCenter"
  plot@text = gsn_add_text(wks,plot,title,(xmin+xmax)/2.,ymax-0.05,txres)



  return(plot)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin

;---Define the number of points in each curve.
  NPTS  = 500
  PI100 = 0.031415926535898
  EXP   = 2.7182818
;---Create data for the four XY plots.
  theta = PI100*ispan(0,NPTS-1,1)
  y1 = sin(theta)
  y2 = sin(2^theta)
  y3 = sin(4*sqrt(fabs(theta)))
  y4 = sin(theta * theta/7.)
  x  = ispan(0,NPTS-1,1)

  xmin  = min(x)
  xmax  = max(x)
  y1min = min(y1)
  y1max = max(y1)
  y2min = min(y2)
  y2max = max(y2)
  y3min = min(y3)
  y3max = max(y3)
  y4min = min(y4)
  y4max = max(y4)

  ymin = floor(min((/y1min,y2min,y3min,y4min/)))
  ymax =  ceil(max((/y1max,y2max,y3max,y4max/)))

  wtype          = "png"
  wtype@wkWidth  = 2500
  wtype@wkHeight = 2500
  wks = gsn_open_wks(wtype,"xy")

  vph   = 0.20    ; Will be used to set shape
  vpw   = 0.75    ; and location of plots.
  vpx   = 0.12
  vpy   = 0.95

;---Set resources common to all four plots
  res                       = True
  res@gsnDraw               = False
  res@gsnFrame              = False
  res@vpXF                  = vpx
  res@vpWidthF              = vpw        ; Make plots wider than 
  res@vpHeightF             = vph        ; they are high.
  res@trXMinF               = xmin
  res@trXMaxF               = xmax
  res@trYMinF               = ymin-0.2    ; Add a margin
  res@trYMaxF               = ymax+0.2
  res@xyLineThicknessF      = 5.0         ; 5x as thick
  res@tiYAxisFontHeightF    = 0.02
  res@tiYAxisFontThicknessF = 2.
  res@tiYAxisFont           = "Helvetica-Bold"
  res@tmYRMinorOn           = False
  res@tmYLMinorOn           = False

;---Set resources common to plots #1 and 3
  res13                      = res
  res13@tmYLLabelFontHeightF = 0.015          ; Increase font height
  res13@tmYLLabelDeltaF      = 2.0            ; Increase space b/w ticks and labels
  res13@tmYLLabelJust        = "CenterLeft"   ; left-justify labels
  res13@tmYRLabelsOn         = False
  res13@tmYROn               = False
            
;---Set resources common to plots #2 and 4
  res24                      = res
  res24@tiYAxisSide          = "right"
  res24@tiYAxisAngleF        = -90
  res24@tmYUseLeft           = False          ; Make right axis independent of left
  res24@tmYLOn               = False          ; Turn off left tickmarks
  res24@tmYROn               = True           ; Turn on right tickmarks
  res24@tmYLLabelsOn         = False          ; Turn off left labels
  res24@tmYRLabelsOn         = True           ; Turn on right labels
  res24@tmYRLabelFontHeightF = 0.015          ; Increase font height
  res24@tmYRLabelDeltaF      = 2.5            ; Increase space b/w ticks and labels
  res24@tmYRLabelJust        = "CenterRight"  ; right-justify labels

;---Copy over common resources to the individual plot resources.
  res1 = res13
  res2 = res24
  res3 = res13
  res4 = res24

;---Plot #1
  res1@vpYF              = vpy
  res1@xyLineColor       = "Seagreen"
  res1@tiYAxisFontColor  = res1@xyLineColor 
  res1@tiYAxisString     = "xy1"
  res1@tmXBBorderOn      = False 
  res1@tmXBOn            = False 

  xy1 = gsn_csm_y(wks,y1,res1)

;---Plot #2
  res2@vpYF              = res1@vpYF - vph
  res2@xyLineColor       = "Brown"
  res2@tiYAxisString     = "xy2"
  res2@tiYAxisFontColor  = res2@xyLineColor 
  res2@tmXTOn            = False 
  res2@tmXBOn            = False 
  res2@tmXTBorderOn      = False 
  res2@tmXBBorderOn      = False 

  xy2 = gsn_csm_y(wks,y2,res2)

;---Plot #3
  res3@vpYF              = res2@vpYF - vph
  res3@xyLineColor       = "NavyBlue"
  res3@tiYAxisString     = "xy3"
  res3@tiYAxisFontColor  = res3@xyLineColor 
  res3@tmXTOn            = False 
  res3@tmXTBorderOn      = False 
  res3@tmXBOn            = False 
  res3@tmXBBorderOn      = False 

  xy3 = gsn_csm_y(wks,y3,res3)

;---Plot #4
  res4@vpYF              = res3@vpYF - vph
  res4@xyLineColor       = "Magenta4"
  res4@tiYAxisString     = "xy4"
  res4@tmXTOn            = False 
  res4@tmXTBorderOn      = False 
  res4@tiYAxisFontColor  = res4@xyLineColor 

  xy4 = gsn_csm_y(wks,y4,res4)

;---Add special highlighting to the given plots
  xy1 = add_highlights(wks,xy1, 50,250,y1min-0.2,y1max+0.2,"highlight #1")
  xy4 = add_highlights(wks,xy4,300,500,y4min-0.2,y4max+0.2,"highlight #4")

;---Draw all four plots and advance the frame.
  draw((/xy1,xy2,xy3,xy4/))
  frame(wks)

end

