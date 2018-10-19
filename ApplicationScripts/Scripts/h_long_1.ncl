;********************************************
; h_long_1.ncl
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
; ===========================
; default plot
; ===========================
 wks   = gsn_open_wks ("png", "h_long" )           ; send graphics to PNG file

 res                 = True                        ; plot mods desired
 res@tiMainString    = "January 1988"              ; title
 res@cnLevelSpacingF = 5.0                         ; contour level spacing

; note this data is already on pressure levels. If this were model data,
; it would be necessary to interpolate the data from hybrid coordinates
; to pressure levels.

 plot  = gsn_csm_pres_hgt(wks, u, res ) 
end
