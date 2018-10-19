;*************************************************
; color_16_old.ncl
;
; Concepts illustrated:
;   - Retrieving the current color map as an array of RGB triplets
;   - Adding a color to an existing color map
;   - Changing the color of map outlines
;   - Spanning part of a color map for contour fill
;   - Using a blue-white-red color map
;************************************************
; Note: This script is the old way of doing 
; color in NCL (NCL versions 6.0.0 and older).
;
; See color_16.ncl for a more modern way.
;*************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

begin
  f      = addfile ("80.nc", "r")
  x      = f->U(0,17,:,:)       ;Grab first timestep, 17th sigma level

  wks = gsn_open_wks("ps","color")
  gsn_define_colormap(wks,"BlWhRe")	  ; use the BlWhRe colormap (instead of default colormap)
  colors = gsn_retrieve_colormap(wks)     ; retrieve color map for editing. dimensioned (103,3)
  colors(102,:) = (/ .68, .68, .68 /)     ; replace the last color with a medium gray
  gsn_define_colormap(wks,colors)         ; redefine colormap to workstation, color map now includes a gray

  res                      = True
  res@mpGeophysicalLineColor = "gray70"            ; draw the map outlines in a medium gray defined above (.68,.68,.68)=~gray70
  res@cnFillOn             = True
  res@gsnSpreadColors      = True                  ; use full colormap
  res@gsnSpreadColorStart  = 10                    ; start at color 10
  res@gsnSpreadColorEnd    = 101                   ; end at color 101
  res@cnLinesOn            = False		   ; turn off the contour lines
  plot = gsn_csm_contour_map(wks,x,res)    
end     
