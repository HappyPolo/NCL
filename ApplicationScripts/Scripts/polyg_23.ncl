;----------------------------------------------------------------------
; polyg_23.ncl
;
; Concepts illustrated:
;   - Adding arrows to a plot using the "arrow" function.
;   - Customizing arrows using color, line thickness, and dash patterns
;----------------------------------------------------------------------
; This script shows how to add arrows to a plot, using a start and 
; end (X,Y) location. 
;
; The arrow function was contributed by Arindam Chakraborty.
;----------------------------------------------------------------------
; The arrows can be customized using the same resources used to 
; customize lines drawn with gsn_add_polyline.
;
; Some of these resources include:
;
;    gsLineColor
;    gsLineThicknessF
;    gsLineDashPattern
;    gsLineLabelString
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;----------------------------------------------------------------------
; Draws an arrow on a plot. Calling syntax is same as gsn_add_polyline
;----------------------------------------------------------------------
function arrow(wks,plt,xpts,ypts,res)
local x0, x1, y0, y1, xp1, xp2, yp1, yp2, xp1n, xp2n, yp1n, yp2n, pi, \
rad2deg, theta, asp, fhead, ahead, phi, resp, lambda1, lambda2, arr_str, \
x1an, ya1n, xa1, ya1, xpts1, ypts1, xa2n, ya2n, xa2, ya2, xpts2, ypts2
begin

 res2 = res    ; make a copy so we can modify it if needed.

 getvalues plt
  "trXMinF": x0
  "trXMaxF": x1
  "trYMinF": y0
  "trYMaxF": y1
 end getvalues

 arr_str = unique_string("arr")   ; need to make sure this is unique
 plt@$arr_str$ = gsn_add_polyline(wks,plt,xpts,ypts,res2)

; determines how broad should the arrow be
 asp = 0.4

 xp1 = xpts(0)
 xp2 = xpts(1)
 yp1 = ypts(0)
 yp2 = ypts(1)

 xp1n = (xp1 - x0)/(x1-x0)
 xp2n = (xp2 - x0)/(x1-x0)
 yp1n = (yp1 - y0)/(y1-y0)
 yp2n = (yp2 - y0)/(y1-y0)

 pi = get_pi("float")
 rad2deg = get_r2d("float")

 theta = atan2((yp2n-yp1n),(xp2n-xp1n))

 if(theta.lt.0 .and. yp2.gt.yp1)then
  theta = pi + theta
 else
  if(theta.gt.0 .and. yp2.lt.yp1)then
   theta = pi + theta
  end if
 end if

; length of the line of arrowhead as a fraction of the length of the given line
 fhead = 0.3
 ahead = sqrt((xp2n-xp1n)*(xp2n-xp1n) + (yp2n-yp1n)*(yp2n-yp1n))*fhead
 phi = atan(asp)

 lambda1 = theta + phi
 xa1n = xp2n - ahead*cos(lambda1)
 ya1n = yp2n - ahead*sin(lambda1)
 xa1 = x0 + xa1n*(x1-x0)
 ya1 = y0 + ya1n*(y1-y0)

;---Don't add line labels to arrowhead.
 if(isatt(res2,"gsLineLabelString")) then
    delete(res2@gsLineLabelString)
 end if

 xpts1 = (/xa1,xp2/)
 ypts1 = (/ya1,yp2/)
 arr_str = unique_string("arr")   ; need to make sure this is unique
 plt@$arr_str$ = gsn_add_polyline(wks,plt,xpts1,ypts1,res2)

 lambda2 = theta - phi
 xa2n = xp2n - ahead*cos(lambda2)
 ya2n = yp2n - ahead*sin(lambda2)
 xa2 = x0 + xa2n*(x1-x0)
 ya2 = y0 + ya2n*(y1-y0)
 xpts2 = (/xa2,xp2/)
 ypts2 = (/ya2,yp2/)
 arr_str = unique_string("arr")   ; need to make sure this is unique
 plt@$arr_str$ = gsn_add_polyline(wks,plt,xpts2,ypts2,res2)

 return (plt)
end


;----------------------------------------------------------------------
; Main code showing how to use arrow function.
;----------------------------------------------------------------------
begin

 th = ispan(0,360,1)
 y = sin(th*3.1415/180)*10

 wks = gsn_open_wks("png","polyg")

;---Create two XY plots to attach arrows to. Don't draw them yet
 res                  = True
 res@gsnMaximize      = True
 res@gsnDraw          = False
 res@gsnFrame         = False
 res@trXMinF          = min(th)
 res@trXMaxF          = max(th)
 res@xyLineThicknessF = 3.0
 res@xyLineColor      = "NavyBlue"

 res@tiMainString     = "Adding default arrows to a plot"
 plot1 = gsn_csm_xy(wks,th,y,res)

 res@tiMainString     = "Adding customized arrows to a plot"
 plot2 = gsn_csm_xy(wks,th,y,res)

;---Values for three arrows.
 xarrow1 = (/300,200/)
 yarrow1 = (/  8,  4/)
 xarrow2 = (/ 50,150/)
 yarrow2 = (/  0,  0/)
 imin    = minind(y)
 imax    = maxind(y)
 xarrow3 = (/th(imin),th(imax)/)
 yarrow3 = (/y(imin),y(imax)/)

 resp = True   ; Resource list for customizing arrows. Start with default arrows.
 plot1 = arrow(wks,plot1,xarrow1,yarrow1,resp)
 plot1 = arrow(wks,plot1,xarrow2,yarrow2,resp)
 plot1 = arrow(wks,plot1,xarrow3,yarrow3,resp)

 draw(plot1)
 frame(wks)

;--Customize each arrow and draw again.
 resp@gsLineColor       = "Brown"
 resp@gsLineDashPattern = 0    ; solid line
 resp@gsLineThicknessF  = 3.0  ; 3x thicker
 plot2 = arrow(wks,plot2,xarrow1,yarrow1,resp)

 resp@gsLineColor = "Purple"
 resp@gsLineDashPattern = 2    ; dashed line
 resp@gsLineThicknessF  = 4.
 plot2 = arrow(wks,plot2,xarrow2,yarrow2,resp)

 resp@gsLineDashPattern = 16    ; dashed line
 resp@gsLineThicknessF  = 5.
 resp@gsLineColor       = "SeaGreen"
 resp@gsLineLabelString = "label this"
 plot2 = arrow(wks,plot2,xarrow3,yarrow3,resp)
 draw(plot2)
 frame(wks)

end
