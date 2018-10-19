;********************************************
; h_long_3.ncl
;********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

 fili  = "uvt.nc"                                  ; filename
 
 f     = addfile (fili , "r")                      ; add file
 lat   = f->lat                                    ; get latitude
 ind14S= ind(lat.eq.-1.395307)                     ; subscript index of 1.4S
 u     = f->U(0,:,ind14S,:)                        ; get u at 1.4S
 wks   = gsn_open_wks ("png", "h_long" )           ; send graphics to PNG file
; ===========================
; Double Thickness of Zero contour 
; and dashed negative lines
; ===========================
 res   = True
 res@gsnContourZeroLineThicknessF = 2. 	  	; doubles thickness of zero contour
 res@gsnContourNegLineDashPattern = 1 		; sets negative contours to dash pattern 1
 res@tiMainString    = "January 1988"
 res@cnLevelSpacingF = 5.0  

; note this data is already on pressure levels. If this were model data,
; it would be necessary to interpolate the data from hybrid coordinates
; to pressure levels.
 plot  = gsn_csm_pres_hgt(wks, gsn_add_cyclic_point(u), res ) 
end
