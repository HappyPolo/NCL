; ===========================================
; coneff_13.ncl
;
; Concepts illustrated:
;   - Drawing pressure/height contours
;   - Adding shading or color fill between specified contour levels
;   - Paneling four plots on a page
;
; ===========================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin 
 f     = addfile ("uvt.nc", "r")                   ; add file
 lat   = f->lat                                    ; get latitude
 ind14S= ind(lat.eq.-1.395307)                     ; subscript index of 1.4S
 u     = f->U(0,:,ind14S,:)                        ; get u at 1.4S

 wks   = gsn_open_wks ("png", "coneff" )           ; send graphics to PNG file

 res   = True
 res@cnLevelSpacingF = 5.0  
 res@gsnDraw         = False    ; We're going to panel later, so don't
 res@gsnFrame        = False    ; draw or advance frame.

 plot = new(4,graphic)
 arr = (/"Le -5","Ge 5","LeGe -10.1,-4","GeLe -10.1,6"/)
 do gg = 0,3
    res@tiMainString = arr(gg)
    plot(gg)  = gsn_csm_pres_hgt(wks, u, res )     
 end do

 opt                  = True
 opt@gsnShadeFillType = "Pattern"
 opt@gsnShadeLow      = 3                            ; Use fill Pattern #3
 plot(0) = gsn_contour_shade(plot(0),-5,-999, opt)   ; Shade contours below -5.
 delete(opt@gsnShadeLow)
 
 opt@gsnShadeHigh = 17                               ; Use fill pattern #17 (stipple)
 plot(1) = gsn_contour_shade(plot(1),-999,5, opt)    ; Pattern shade contours above 5.
 
 opt@gsnShadeHigh = 17                               ; Use fill pattern #17 (stipple)
 opt@gsnShadeLow  = 3                                ; Use fill pattern #3
 plot(2) = gsn_contour_shade(plot(2), -10.1,-4., opt) ; Shade contours below -10.1 and above -4.
 delete(opt@gsnShadeHigh)
 delete(opt@gsnShadeLow)

 opt@gsnShadeMid = 17                                 ; Use fill pattern #17 (stipple) to 
 plot(3)  = gsn_contour_shade(plot(3), -10.1,6., opt) ; shade contours between -10.1 and 6.
 
 panres = True
 panres@gsnMaximize = True
 gsn_panel(wks,plot,(/2,2/),panres)   ; Panel these four plots.
 
 delete(plot)    ; Clean up for next set of plots.
 delete(opt)
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
 gsn_define_colormap(wks,"wh-bl-gr-ye-re")    ; Change color map.

 plot = new(4,graphic)
 do gg = 0,3
    res@tiMainString = arr(gg)
    plot(gg) = gsn_csm_pres_hgt(wks, u, res )     
 end do

;
; Code below is same as previous frame, except now we're using
; color instead of shading.
;
 opt = True
 opt@gsnShadeLow = 52                                ; Use fill color #52 (blue)
 plot(0) = gsn_contour_shade(plot(0),-5,-999, opt)   ; Shade contours below -5
 delete(opt@gsnShadeLow)
 
 opt@gsnShadeHigh = 150                              ; Use fill color #150 (yellow)
 plot(1) = gsn_contour_shade(plot(1),-999,5, opt)    ; Shade contours above 5
 
 opt@gsnShadeHigh = 150                              ; Use fill color #150 (yellow)
 opt@gsnShadeLow = "blue"                            ; You can use color indices or named colors. 
 plot(2)  = gsn_contour_shade(plot(2), -10.1,-4., opt) ; Shade contours > -4 yellow, and shade contours < -10.1 blue
 
 delete(opt@gsnShadeHigh)
 delete(opt@gsnShadeLow)
 opt@gsnShadeMid = "green"                           ; Use green
 plot(3)  = gsn_contour_shade(plot(3), -10.1,6., opt)  ; Shade contours < -10.1 and < 6.0 green
 gsn_panel(wks,plot,(/2,2/),panres)

end
