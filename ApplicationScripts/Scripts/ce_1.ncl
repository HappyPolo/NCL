;*************************************************
; ce_1.ncl
;
; Concepts illustrated:
;   - Drawing black-and-white contours over a cylindrical equidistant map
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
;************************************************
; read in zonal winds
;************************************************
  u = a->U(1,:,:)                                ; read July zonal winds
;************************************************
; create default plot
;************************************************
  wks = gsn_open_wks("png","ce")                  ; send graphics to PNG file
  plot = gsn_csm_contour_map(wks,u,False)         ; create a default plot
end



