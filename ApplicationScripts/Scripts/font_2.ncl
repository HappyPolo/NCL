;***********************************************
; font_2.ncl
;
; Concepts illustrated:
;   - Drawing black-and-white contours over a polar stereographic map
;   - Increasing the font size of labels in a polar plot
;   - Moving polar labels away from the plot
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
  wks = gsn_open_wks("png" ,"font")        ; send graphics to PNG file
  res = True                               ; plot mods desired
  res@gsnPolar                 = "NH"      ; specify the hemisphere
  plot = gsn_csm_contour_map_polar(wks,u,res)    ; create the plot

; the labels around the polar plot are not a tick mark object.  They are
; added text.  A determination was made as to how far away from the edge
; to place this text.  When the ability to blow the text up was added, it
; ran the 0 and 180 text into the line. Therefore the following resource 
; was added to move the text out.  Note that it moves all the text out, and
; not just the 0 and 180

  res@gsnPolarLabelDistance    = 1.08            ; default is 1.04
  res@gsnPolarLabelFontHeightF = 0.025           ; blow up font

  plot = gsn_csm_contour_map_polar(wks,u,res)    ; create the plot

end
