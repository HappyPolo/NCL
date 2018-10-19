; ***********************************************
; xy_35.ncl
;
; Concepts illustrated:
;   - Use of new (with NCL 6.4.0) opacity resources
;     to control opacity of curves and markers in 
;     XYPlots.
;   - The per-curve/per-marker resource arrays override
;     the single-value opacity resources.      
;   - Unlike color resources, the opacity resources
;     are applicable with the Mono-color resources
;     are in effect.
; ***********************************************

begin

 f = fspan(0., 1., 64)
 twopi = 2 * 3.141592654

 x = cos(f * 2*twopi)
 y = cos(f * 3*twopi)
 z = x * y

 wks   = gsn_open_wks ("png", "xy_35")
 plots = new(6, graphic)

 res                  = True 
 res@gsnDraw          = False
 res@gsnFrame         = False
 res@xyLineThicknessF = 4.
 res@xyDashPattern    = 0
 res@xyMarker         = 16
 res@xyLineColors     = (/ "Red", "Green", "Blue" /)
 res@xyMarkerColors   = (/ "Green", "blue", "red" /)
 res@tiMainString     = "Opaque lines"

 plots(0)  = gsn_csm_xy (wks,f, (/x, y, z/), res) ; create plot

 res@tiMainString     = "Uniformly translucent"
 res@xyLineOpacityF = .4
 plots(1)  = gsn_csm_xy (wks,f, (/x, y, z/), res) ; create plot

 res@tiMainString     = "Independently translucent"
 res@xyLineOpacities  = (/ .8, .4, .15 /)
 plots(2)  = gsn_csm_xy (wks,f, (/x, y, z/), res) ; create plot

 res@tiMainString     = "Uniformly translucent markers" 
 delete(res@xyLineOpacities)  ; go back to uniformly translucent
 res@xyMarkLineMode   = "MarkLines"
 res@xyMarkerOpacityF = .4
 plots(3)  = gsn_csm_xy (wks,f, (/x, y, z/), res) ; create plot

 res@tiMainString     = "Independently translucent markers"
 res@xyMarkerOpacities = (/ .8, .4, .15/)
 plots(4)  = gsn_csm_xy (wks,f, (/x, y, z/), res) ; create plot

 res@tiMainString     = "Opacities still apply in MonoColor modes"
 res@xyMonoLineColor = True
 res@xyMonoMarkerColor = True
 plots(5)  = gsn_csm_xy (wks,f, (/x, y, z/), res) ; create plot

 gsn_panel(wks, plots, (/3,2/), False)
end
