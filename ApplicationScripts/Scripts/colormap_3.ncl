;*************************************************
; colormap_3.ncl
;
; Concepts illustrated:
;   - Selecting a different color map
;   - Drawing the current color map
;   - Reversing a color map
;
;************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;************************************************
begin
  wks = gsn_open_wks("png","colormap")             ; send graphics to PNG file
  gsn_define_colormap(wks,"tbr_240-300")           ; change colormap 

  gsn_draw_colormap(wks)                           ; draw colormap

  gsn_reverse_colormap(wks)                        ; reverse colormap
  gsn_draw_colormap(wks)                           ; draw reversed colormap

end

           
