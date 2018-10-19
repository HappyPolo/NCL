;----------------------------------------------------------------------
; h_lat_5.ncl
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
;----------------------------------------------------------------------
begin
 fili  = "mxclim.nc"                              ; filename
 
 f     = addfile (fili , "r")                     ; add file
 u     = f->U(0,:,:)                              ; get u for January
 
 wks   = gsn_open_wks ("png", "h_lat" )           ; send graphics to PNG file

 res=True    
 res@cnLevelSpacingF = 5.0        
 res@gsnDraw         = False                      ; do not draw  
 res@gsnFrame        = False                      ; do not advance frame

; note u is already on pressure levels. If this were model data, it
; would be necessary to interpolate from the hybrid coordinates to 
; pressure levels.
 plot  = gsn_csm_pres_hgt(wks, u, res )   

;----------------------------------------------------------------------
; Add pattern shading for contours less than -10 and stipple > 10.
;
; Note that the shading starts at the first contour less than -9.8, in
; this case the -10 contour. Also note that the shading starts at the
; first contour greater-than-equal 10, in this case the 10.0 contour.
;----------------------------------------------------------------------
 opt                  = True
 opt@gsnShadeLow      = 3          ; slashes
 opt@gsnShadeHigh     = 17         ; filled dots
 opt@gsnShadeFillType = "pattern"
 plot = gsn_contour_shade(plot,-9.8, 10, opt)

 draw(plot)
 frame (wks)
end
