begin
  wks = gsn_open_wks("x11","colormap")

  opt = True
  opt@Frame = False
  ii = ispan(0,255,5)
  draw_color_palette(wks, ii,opt)

;---Text resources
  txres               = True
  txres@txFontHeightF = 0.03
  txres@txPerimOn     = True
  txres@txBackgroundFillColor = "white"

;---Add a title
  gsn_text_ndc(wks,"Default color map",0.5,0.94,txres)
  gsn_text_ndc(wks,"Every fifth color (" + dimsizes(ii) + \
               " colors)",0.5,0.87,txres)
  gsn_text_ndc(wks,"First color is white",0.5,0.80,txres)
  frame(wks)
  
;---Second color map
  ii := ispan(1,255,2)
  draw_color_palette(wks,ii,opt)

;---Add a title
  gsn_text_ndc(wks,"Default color map",0.5,0.94,txres)
  gsn_text_ndc(wks,"Every other color (" + dimsizes(ii) + \
               " colors)",0.5,0.87,txres)
  gsn_text_ndc(wks,"First color is black",0.5,0.80,txres)

  frame(wks)

  opt@Vertical = True
  draw_color_palette(wks,ii,opt)

;---Add a title
  gsn_text_ndc(wks,"Default color map (vertical)",0.5,0.94,txres)
  gsn_text_ndc(wks,"Every other color (" + dimsizes(ii) + \
               " colors)",0.5,0.87,txres)
  gsn_text_ndc(wks,"First color is black",0.5,0.80,txres)
  frame(wks)

end

