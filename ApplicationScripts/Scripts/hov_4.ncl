; ===========================================
; hov_4.ncl
;
; Concepts illustrated:
;   - Creating a Hovmueller plot
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
 fili  = "chi200_ud_smooth.nc"
 f     = addfile (diri+fili , "r")             ; add file
 scale = 1.e6                                  ; scale factor
 chi   = f->CHI                                ; get chi
 chi   = chi/scale                             ; scale for convenience
; ===========================
; Create plot: Same as example 3 but 
; with "custom" labeling
; ===========================
 wks  = gsn_open_wks ("png", "hov" )           ; send graphics to PNG file
 res            = True                         ; plot mods desired
 res@gsnDraw    = False                        ; don't draw
 res@gsnFrame   = False                        ; don't advance frame

 res@cnLevelSelectionMode = "ManualLevels"     ; manually select contours
 res@cnMinLevelValF       = -10.               ; min level
 res@cnMaxLevelValF       =  10.               ; max leve

 res@tmYLMode      = "Explicit"                ; Define own tick mark labels.
 res@tmYLValues    = (/  0. ,  30.,  61.,   89., 120., 150. /)
 res@tmYLLabels    = (/"DEC","JAN","FEB","MAR" ,"APR","MAY" /)


 plot = gsn_csm_hov(wks, chi(:,{100:220}), res)   ; create plot
 opt  = True
 opt@gsnShadeFillType = "pattern"
 opt@gsnShadeLow      = 3
 opt@gsnShadeHigh     = 17
 plot = gsn_contour_shade(plot, -4.5, 3.5, opt)    ; add shading from <-8 and
                                                   ; > 4 contours
 draw(wks)
 frame(wks)
 
 
end
