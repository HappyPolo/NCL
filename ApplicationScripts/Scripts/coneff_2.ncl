; ===========================================
; coneff_2.ncl
;
; Concepts illustrated:
;   - Drawing Hovmueller plots
;   - Drawing the zero contour line thicker
;   - Changing the contour level spacing
;
; ===========================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

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
; create plot
; ===========================
 wks   = gsn_open_wks ("png", "coneff")        ; send graphics to PNG file
 res                 = True                    ; plot mods desired
 res@tiMainString    = "Pacific Region"        ; title
 res@cnLevelSpacingF = 2.                      ; contour interval
 res@cnFillOn        = True                    ; turn on color
 res@cnFillPalette   = "BlAqGrYeOrReVi200"     ; set color map

 res@gsnContourZeroLineThicknessF = 3.5        ; sets thickness of zero contour to 3.5 (default=1)

 plot = gsn_csm_hov(wks, chi(:,{100:220}), res)      ; create plot
end
