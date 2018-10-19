;
; overlay_7.ncl
;
; Concepts illustrated:
;   - Overlaying three sets of lines on a xy plot
;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
;****************************************************
begin
;***************************
; read in data
;***************************
  lon = (/82., -69., 0./)

  f   = addfile ("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
  lat = f->lat
  u   = f->U
  u0  = u(0,:,{lon(0)})
  u1  = u(0,:,{lon(1)})
  u2  = u(0,:,{lon(2)})

  colors = (/"red","green","blue"/)

  wks = gsn_open_wks("png","overlay") ; send graphics to PNG file

; resources for "left" variable
  res                  = True 

  res@gsnMaximize      = True
  res@gsnPaperOrientation = "portrait"
  res@gsnDraw          = False
  res@gsnFrame         = False

  res@trYMinF          = min(u)    ; You could also just use
  res@trYMaxF          = max(u)    ; min/max of u0,u1,u2.

  res@xyLineThicknessF = 2.0

  res@xyLineColor      = colors(0)

  plot0 = gsn_csm_xy(wks,lat,u0,res)

  res@xyLineColor     = colors(1)
  plot1 = gsn_csm_xy(wks,lat,u1,res)

  res@xyLineColor   = colors(2)

  plot2 = gsn_csm_xy(wks,lat(5:),u2(5:),res)

  overlay(plot0,plot1)
  overlay(plot0,plot2)
; 
; Attach a legend

  lgres                    = True
  lgres@lgLineColors       = colors
  lgres@lgItemType         = "Lines"        ; show lines only (default)
  lgres@lgLabelFontHeightF = .08            ; legend label font thickness
  lgres@vpWidthF           = 0.13           ; width of legend (NDC)
  lgres@vpHeightF          = 0.10           ; height of legend (NDC)
  lgres@lgPerimThicknessF  = 2.0            ; thicken the box perimeter
  lgres@lgMonoDashIndex    = True
  lgres@lgDashIndex        = 0

  labels = "lon="+lon
  legend = gsn_create_legend (wks, 3, labels,lgres)

;
; Use gsn_add_annotation to attach this legend to our existing plot.
; This way, if we resize the plot, the legend will stay with the
; plot and be resized automatically.
;
; Point (0,0) is the dead center of the plot. Point (0,.5) is center,
; flush bottom. Point (0.5,0.5) is flush bottom, flush right.
;
  amres                  = True
  amres@amJust           = "BottomRight"    ; Use bottom right corner of box
                                            ; for determining its location.
  amres@amParallelPosF   = 0.5              ; Move legend to right
  amres@amOrthogonalPosF = 0.5              ; Move legend down.

  annoid = gsn_add_annotation(plot0,legend,amres)  ; add legend to plot

  draw(plot0)
  frame(wks)
end
