;************************************************
; colormap_9.ncl
;
; Concepts illustrated:
;   - Creating a colormap that reverses itself at the mid point
;   - Creating a color map using span_named_colors
;   - Defining a color map by spanning between named colors
;   - Drawing the current color map
;==================================================
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"

begin
  colors = (/"red","green","blue","purple","blue","green","red"/)

;---Specify number of colors in each range.
  opt                  = True
  opt@NumColorsInRange = (/ 20, 20, 20, 20, 20, 20 /)
  rgb_array = span_named_colors(colors,opt)

  wks = gsn_open_wks("png","colormap")    ; Send graphics to PNG file

;----First frame.
  gsn_define_colormap(wks,rgb_array)
  gsn_draw_colormap(wks)

end
