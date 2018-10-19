;----------------------------------------------------------------------
; h_lat_2.ncl
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

; ===========================
; Create a default plot
; ===========================
; note u is already on pressure levels. If this were model data, it
; would be necessary to interpolate from the hybrid coordinates to 
; pressure levels.

 plot  = gsn_csm_pres_hgt(wks, u, False )   

end
