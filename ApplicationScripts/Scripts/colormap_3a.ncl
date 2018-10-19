;----------------------------------------------------------------------
; colormap_3a.ncl
;
; Concepts illustrated:
;   - Reversing a color map
;   - Drawing color maps using draw_color_palette
;----------------------------------------------------------------------
; Note: you must have NCL V6.3.0 or later to
; run this example.
;----------------------------------------------------------------------
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"

begin
  wks = gsn_open_wks("png","colormap")              ; send graphics to PNG file

  draw_color_palette(wks,"tbr_240-300",False)

  cmap = read_colormap_file("tbr_240-300")
  draw_color_palette(wks,cmap(::-1,:),False)

end

           
