;----------------------------------------------------------------------
; h_lat_3.ncl
;----------------------------------------------------------------------
;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
 fili  = "mxclim.nc"                              ; filename
 
 f     = addfile (fili , "r")                     ; add file
 u     = f->U(0,:,:)                              ; get u for January
 
 wks   = gsn_open_wks ("png", "h_lat" )           ; send graphics to PNG file
;
; Modify default plot with double thickness of zero
; contour and dashed negative lines
;
 res   = True                                     ; plot mods desired
 res@tiMainString    = "Ensemble Average 1987-89" ; title 
 res@cnLevelSpacingF = 8.0                        ; contour level spacing
 res@gsnContourZeroLineThicknessF = 2. 	          ; doubles thickness of zero contour
 res@gsnContourNegLineDashPattern = 1 		  ; sets negative contours to dash pattern 1
; ===========================
; plot 1: default latitude range 
; ===========================
; note u is already on pressure levels. If this were model data, it
; would be necessary to interpolate from the hybrid coordinates to 
; pressure levels.

 plot  = gsn_csm_pres_hgt(wks, u, res ) 

; ===========================
; plot 2: latitude range from -90 to 90 
; ===========================
 plot  = gsn_csm_pres_hgt(wks, add90LatX(u), res ) 
end
