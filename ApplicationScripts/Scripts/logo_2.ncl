;*************************************************
; logo_2.ncl
;
; Concepts illustrated:
;   - Using "nglogo" to add the UCAR logo and name to a plot
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
  
  res@tiMainString = "Example of using nglogo" ; title
  
  plot = gsn_csm_contour_map_ce(wks,u,res) ; create a default plot
  
; use nglogo to precisely place an NCAR logo on a page. Arguments are:
; (workstation name, xcoord, ycoord, size in ndc coord, type, color
; index, colorindex for type=5)
  
; types: 1 = NCAR logo
;        2 = UCAR logo (Star symbol)
;        3 = The text "NCAR" in Bell Gothic Black font 
;        4 = The text "UCAR in Bell Gothic Black font
;        5 = UCAR star logo plus "UCAR" text  
  
; this example draws the UCAR star in the center of the plot. It (0.7)
; is HUGE!
  
  nglogo(wks,0.6,0.5,0.7,2,3,0)
  draw(wks)
  frame(wks)
end



