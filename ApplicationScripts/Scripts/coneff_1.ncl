; ===========================================
; coneff_1.ncl
;
; Concepts illustrated:
;   - Drawing Hovmueller plots
;   - Drawing the zero contour line thicker
;
; ===========================================
;  As of NCL version 6.2.0, these scripts are loaded automatically.
;
;  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;=============================================
; data processing
;=============================================
 diri  = ncargpath("data") + "/cdf/"
 fili  = "chi200_ud_smooth.nc"                 ; filename
 
 f     = addfile (diri+fili , "r")             ; add file

 chi   = f->CHI                                ; get chi
 chi   = chi/1.e6                              ; scale for convenience
; ===========================
; create plot
; ===========================
 wks   = gsn_open_wks ("png", "coneff")        ; send graphics to PNG file

 res                 = True                    ; plot mods desired

 res@tiMainString    = "Pacific Region"        ; title
 res@cnLevelSpacingF = 2.                      ; contour interval

 res@cnFillOn        = True                    ; turn on color
 res@cnFillPalette   = "gui_default"           ; choose color map

 res@gsnContourZeroLineThicknessF = 2.	       ; doubles thickness of zero contour

 plot = gsn_csm_hov(wks, chi(:,{100:220}), res)
end
