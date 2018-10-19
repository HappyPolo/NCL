begin
  wks = gsn_open_wks("x11","colormap")

  txres = True
  txres@txFontHeightF = 0.05
  txres@txPerimOn     = True
  txres@txBackgroundFillColor = "white"

  opt       = True
  opt@Frame = False
  colors    = (/"red","green","blue","cyan","magenta","yellow"/)
  draw_color_palette(wks, colors, opt)

  gsn_text_ndc(wks,dimsizes(colors) + " colors",0.5,0.9,txres)
  frame(wks)

  colors := (/ "PapayaWhip", "ForestGreen", "DodgerBlue", "Goldenrod",\
               "gray25", "Brown", "Cyan", "Gray", "Navy", "PeachPuff", \
               "orchid", "beige","gold", "khaki", "plum", "Chocolate", \
               "pink","slategray1", "bisque1","aquamarine3"/)

  draw_color_palette(wks, colors, opt)
  gsn_text_ndc(wks,dimsizes(colors) + " colors",0.5,0.9,txres)
  frame(wks)

  colors := "gray" + ispan(0,100,1)
  draw_color_palette(wks, colors, opt)
  gsn_text_ndc(wks,dimsizes(colors) + " grayscale colors",0.5,0.9,txres)
  frame(wks)

end

