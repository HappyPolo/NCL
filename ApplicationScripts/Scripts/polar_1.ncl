;*************************************************
; NCL Graphics: polar_1.ncl
;
; Concepts illustrated:
;   - Drawing black-and-white contours over a polar stereographic map
;   - Drawing the northern hemisphere of a polar stereographic map
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
; create plot
;************************************************
  wks = gsn_open_wks("png","polar")              ; send graphics to PNG file
  res            = True                          ; plot mods desired
  res@gsnPolar   = "NH"                          ; specify the hemisphere
  plot = gsn_csm_contour_map_polar(wks,u,res)    ; create the plot

end
