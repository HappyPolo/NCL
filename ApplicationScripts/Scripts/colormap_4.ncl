;*************************************************
; colormap_4.ncl
;
; Concepts illustrated:
;   - Selecting a different color map
;   - Selecting a grayscale color map
;   - Drawing the current color map
;   - Merging two color maps
;
;************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;************************************************
begin
  wks = gsn_open_wks("png","colormap")             ; send graphics to PNG file

  cmap1 = "BlAqGrYeOrRe"                           ; 102 colors
  cmap2 = "gsltod"                                 ;  33 colors

  gsn_define_colormap(wks,cmap1)
  gsn_draw_colormap(wks)

  gsn_define_colormap(wks,cmap2)
  gsn_draw_colormap(wks)

  gsn_merge_colormaps(wks,cmap1,cmap2)             ; merge colormaps
  gsn_draw_colormap(wks)                           ; draw colormap

end
