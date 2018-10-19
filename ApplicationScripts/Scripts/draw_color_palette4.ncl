begin
  wks = gsn_open_wks("x11","colormap")

  opt = True
  opt@Frame = False

  rgb1         = random_uniform(0,1,(/50,3/))
  rgba1        = new((/dimsizes(rgb1(:,0)),4/),float)
  rgba1(:,0:2) = rgb1
  rgba1(:,3)   = 0.5

  ncolors = dimsizes(rgba1(:,0))

  draw_color_palette(wks, rgb1,opt)

;---Add a title
  txres                       = True
  txres@txFontHeightF         = 0.03
  txres@txBackgroundFillColor = "white"
  gsn_text_ndc(wks,ncolors +" random colors",0.5,0.9,txres)
  frame(wks)

  draw_color_palette(wks, rgba1, opt)
;---Add a title
  gsn_text_ndc(wks,"same colors faded",0.5,0.9,txres)
  frame(wks)
end

