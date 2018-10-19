begin
  wks = gsn_open_wks("x11","colormap")

  colormap_names = (/"default","precip_diff_1lev","perc2_9lev","amwg256",\
                     "WhiteBlue","temp_diff_18lev","MPL_Paired"/)
  opt = True
  opt@Frame = False
  txres = True
  txres@txFontHeightF = 0.03
  txres@txPerimOn     = True
  txres@txBackgroundFillColor = "white"

  ntotal = 0
  do n=0,dimsizes(colormap_names)-1
    cmap := read_colormap_file(colormap_names(n))
    ncmap = dimsizes(cmap(:,0))
    ntotal = ntotal + ncmap
    draw_color_palette(wks, colormap_names(n), opt)
    gsn_text_ndc(wks,colormap_names(n) + " (" + ncmap + " colors)",\
                 0.5,0.9,txres)
    frame(wks)
  end do

  opt@FontHeight = 0.01
  draw_color_palette(wks, colormap_names, opt)
  gsn_text_ndc(wks,ntotal + " colors (w/labels)",0.5,0.9,txres)
  frame(wks)

  opt@LabelBoxesOn = False
  draw_color_palette(wks, colormap_names(2:), opt)
  gsn_text_ndc(wks,ntotal + " colors (w/o labels)",0.5,0.9,txres)
  txres@txFontHeightF = 0.022
  gsn_text_ndc(wks,str_join(colormap_names(2:),", "),0.5,0.8,txres)

  frame(wks)

  opt@Vertical = True
  draw_color_palette(wks, colormap_names(2:), opt)
  gsn_text_ndc(wks,ntotal + " colors (vertical, w/o labels)",0.5,0.9,txres)

  frame(wks)
end

