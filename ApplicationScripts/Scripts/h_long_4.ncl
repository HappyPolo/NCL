;********************************************
; h_long_4.ncl
;********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
 fili  = "uvt.nc"                                  ; filename
 
 f     = addfile (fili , "r")                      ; add file
 lat   = f->lat                                    ; get latitude
 ind14S= ind(lat.eq.-1.395307)                     ; subscript index of 1.4S
 u     = f->U(0,:,ind14S,:)                        ; get u at 1.4S
 wks   = gsn_open_wks ("png", "h_long" )           ; send graphics to PNG file
; ===========================
; shade less than -10 and 
; greater than +10
; ===========================
 res   = True
 res@tiMainString    = "January 1988"
 res@cnLevelSpacingF = 5.0  
 res@gsnDraw  = False
 res@gsnFrame = False

; note this data is already on pressure levels. If this were model data,
; it would be necessary to interpolate the data from hybrid coordinates
; to pressure levels.
 plot  = gsn_csm_pres_hgt(wks, u, res )   ; place holder
 opt   = True
 opt@gsnShadeFillType = "pattern"
 opt@gsnShadeLow      = 3
 opt@gsnShadeHigh     = 17
 plot  = gsn_contour_shade(plot, -12., 9.5, opt)   ; add shading to areas
                                                    ; <-15. contour and >10. contour
 draw(plot)
 frame (wks)
end
