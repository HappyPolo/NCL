;************************************************
; colormap_8.ncl
;
; Concepts illustrated:
;   - Creating a color map using span_named_colors
;   - Defining a color map by spanning between named colors
;   - Drawing the current color map
;==================================================
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"

begin
  colors1 = (/"SandyBrown","IndianRed","LightBlue","Purple","Yellow"/)
  colors2 = (/"NavyBlue","LimeGreen","Red","Brown","Gray"/)
  colors3 = (/"PeachPuff","DodgerBlue","HotPink"/)

;---Use all the defaults; will get close to 256 colors.
  rgb_array1 = span_named_colors(colors1,False)

;---Specify number of colors in each range.
  opt                  = True
  opt@NumColorsInRange = (/ 20, 20, 10, 5/)
  rgb_array2 = span_named_colors(colors2,opt)

;---Specify number of colors in table
  delete(opt@NumColorsInRange)
  opt@NumColorsInTable = 50
  rgb_array3 = span_named_colors(colors3,opt)

  wks = gsn_open_wks("png","colormap")    ; Send graphics to PNG file

;----First frame.
  gsn_define_colormap(wks,rgb_array1)
  gsn_draw_colormap(wks)

;----Second frame.
  gsn_define_colormap(wks,rgb_array2)
  gsn_draw_colormap(wks)

;----Second frame.
  gsn_define_colormap(wks,rgb_array3)
  gsn_draw_colormap(wks)

end
