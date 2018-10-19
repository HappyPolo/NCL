; ***********************************************
; draworder_1.ncl
;
; Concepts illustrated:
;   - Filling the area between two curves in an XY plot
;   - Controlling the draw order of a polygon
;
; ***********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************************
begin
;
; Define the number of points in each curve.
;
  NPTS  = 500
  PI100 = 0.031415926535898

  ii     = ispan(0,NPTS-1,1)
  theta  = PI100*ii
  y      = 2+sin(2*sqrt(fabs(theta)))

; Arrays to hold polygon.

  xg = new(2*NPTS+1,float)
  yg = new(2*NPTS+1,float)
  xg(0:NPTS-1)      = ii
  yg(0:NPTS-1)      = sin(theta)
  xg(NPTS:2*NPTS-1) = ii(::-1)    ; reverse the order
  yg(NPTS:2*NPTS-1) = 3+sin(3*sqrt(fabs(theta)))
  xg(2*NPTS)        = xg(0)
  yg(2*NPTS)        = yg(0)

;************************************************ 
; Plotting parameters
;************************************************
 wks   = gsn_open_wks ("png","draworder")         ; send graphics to PNG file

 res                    = True                    ; plot mods desired

 res@gsnMaximize        = True                    ; maximize size of plot
 res@gsnDraw            = False                   ; don't draw
 res@gsnFrame           = False                   ; don't advance frame

 res@trYMinF            = min(yg)                 ; Y axis limits
 res@trYMaxF            = max(yg)

 res@xyLineColor        = "Brown"                 ; line color
 res@xyLineThicknessF   = 2.                      ; line thickness

 res@tiMainString       = "Drawing the polygon before the XY line"

 plot  = gsn_csm_y (wks,y,res)

;
; Set up resources for filled polygon.
;
  gsres                 = True                        ; poly res
  gsres@gsFillColor     = "SlateBlue"                 ; color chosen
  gsres@tfPolyDrawOrder = "Draw"                      ; default is "PostDraw"

  dum1 = gsn_add_polygon (wks,plot,xg,yg,gsres)

;
; Drawing the plot will cause polygon to be drawn too.
;
  draw(plot)                                            ; draw
  frame(wks)                                            ; advance frame
end
