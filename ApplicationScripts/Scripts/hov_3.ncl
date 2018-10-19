; ===========================================
; hov_3.ncl
; ===========================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin
;=============================================
; data processing
;=============================================
 diri  = ncargpath("data") + "/cdf/"
 fili  = "chi200_ud_smooth.nc"                 ; filename
 
 f     = addfile (diri+fili , "r")             ; add file
 scale = 1.e6                                  ; scale factor
 chi   = f->CHI                                ; get chi
 chi   = chi/scale                             ; scale for convenience
; ===========================
; Create plot:Select Pacific region via 
; coordinate subscripting
; hatch all contours < 4 and stiple > 4
; ===========================
 wks  = gsn_open_wks ("png", "hov")           ; send graphics to PNG file
 res                 = True                   ; plot mods desired
 res@gsnDraw         = False                  ; don't draw yet
 res@gsnFrame        = False                  ; don't advance frame yet
 res@tiMainString    = "Pacific Region"       ; title
 res@cnLevelSpacingF = 2.                     ; contour interval
 res@gsnContourZeroLineThicknessF = 2.	      ; doubles thickness of zero contour

 plot = gsn_csm_hov(wks, chi(:,{100:220}), res)   ; create plot
 opt  = True
 opt@gsnShadeFillType = "pattern"
 opt@gsnShadeLow      = 3
 opt@gsnShadeHigh     = 17
 plot = gsn_contour_shade(plot, -5.5, 3.5, opt)   ; add shading from <-5 and
 draw(wks)                                        ; > 4 contours  
 frame(wks)
end
