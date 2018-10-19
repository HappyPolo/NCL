;*************************************************
; color_17.ncl
;
; Concepts illustrated:
;   - Drawing the given named colors
;
;************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;************************************************
begin
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","color") ; Send graphics to PNG file

  colors = (/"white", "black", "PeachPuff", "MintCream", "SlateBlue",  \
             "Khaki", "OliveDrab","BurlyWood", "LightSalmon", "Coral", \
             "HotPink", "LemonChiffon", "AliceBlue", "LightGrey",      \
             "MediumTurquoise", "DarkSeaGreen", "Peru", "Tomato",      \
             "Orchid","PapayaWhip"/)

  rows = 4
  cols = 5
  gsn_draw_named_colors(wks,colors,(/rows,cols/))  ; Draw the named colors.
end



