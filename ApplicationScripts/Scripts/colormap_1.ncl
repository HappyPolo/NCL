;*************************************************
; colormap_1.ncl
;
; Concepts illustrated:
;   - Drawing the current color map associated with the workstation
;
;************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;************************************************
begin
  wks = gsn_open_wks("png","colormap")             ; send graphics to PNG file
  gsn_draw_colormap(wks)                           ; draw colormap

end
