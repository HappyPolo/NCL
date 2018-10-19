;*************************************************
; color_16.ncl
;
; Concepts illustrated:
;   - Retrieving the current color map as an array of RGB triplets
;   - Changing the color of map outlines
;   - Spanning part of a color map for contour fill
;   - Using a blue-white-red color map
;
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

begin
  f      = addfile ("80.nc", "r")
  x      = f->U(0,17,:,:)       ;Grab first timestep, 17th sigma level

  wks = gsn_open_wks("png","color")    ; send graphics to PNG file
  colors = read_colormap_file("BlWhRe")

  res                      = True
  res@mpGeophysicalLineColor = "gray70"
  res@cnFillOn             = True
  res@cnFillPalette        = colors(8:,:)      ; Subset the color map
  res@cnLinesOn            = False		   ; turn off the contour lines
  plot = gsn_csm_contour_map(wks,x,res)    
end     
