;*************************************************
; pub_3.ncl
; Concepts Illustrated:
;   - Manually loading extension scripts
;   - Drawing the grid of Normalized Device Coordinates (NDCs)
;   - Using default plotting
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"  
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
;************************************************
; read in zonal winds
;************************************************
  u = a->U(1,:,:)                                    ; read July zonal winds
;************************************************
; create default plot
;************************************************
  wks          = gsn_open_wks("png","pub")           ; send graphics to PNG file
  drawNDCGrid(wks)                                   ; draw the ndc grid
  plot         = gsn_csm_contour_map_ce(wks,u,False) ; create a default plot
  
end
 



