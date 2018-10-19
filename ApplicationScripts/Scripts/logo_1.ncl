;*************************************************
; logo_1.ncl
;
; Concepts illustrated:
;   - Using "ngezlogo" to quickly add the NCAR logo to a plot
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
  wks = gsn_open_wks("png","logo") ; send graphics to PNG file
  
  gsn_define_colormap(wks,"default")  
  
  res          = True            ; plot mods desired
  res@gsnFrame = False           ; don't advance frame yet
  res@gsnDraw  = False          ; don't draw yet
  
  res@tiMainString = "Example of quick NCAR Logo" ; title
  
  plot = gsn_csm_contour_map_ce(wks,u,res) ; create a default plot
  
; use ngezlogo to quickly put a logo in the bottom right hand corner
 
  ngezlogo(wks)
  draw(wks)
  frame(wks)
end



