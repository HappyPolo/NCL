begin
  wks = gsn_open_wks("x11","colormap")

  color_map_names = (/"MPL_prism","WhiteBlueGreenYellowRed","WhiteBlue","nice_gfdl"/)
  nlevels         = (/        100,                      200,         75,         25/)
  ncmaps          = dimsizes(color_map_names)

  opt = True
  opt@Frame = False

;---Add a title
  txres                       = True
  txres@txFontHeightF         = 0.025
;  txres@txBackgroundFillColor = "white"

  do n=0,ncmaps-1
    rgba_tmp := read_colormap_file(color_map_names(n))
    ncolors = dimsizes(rgba_tmp(:,0))

    rgba := span_color_rgba(color_map_names(n),nlevels(n))
    draw_color_palette(wks,rgba,opt)

    gsn_text_ndc(wks,color_map_names(n),0.5,0.9,txres)
    gsn_text_ndc(wks,nlevels(n) + " colors selected, " + ncolors + " originally",0.5,0.85,txres)
    frame(wks)
  end do

end

