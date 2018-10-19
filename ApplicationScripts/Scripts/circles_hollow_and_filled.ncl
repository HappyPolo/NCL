begin
  circle_types = (/"hollow", "filled"/)
  nsizes       = 8
  ncirc        = 5
  ntypes       = dimsizes(circle_types)
  
  xdist = 1./(ncirc+1)
  ydist = 1./(nsizes+1)
  xpos  = ispan(1,ncirc,1)*xdist
  ypos  = ispan(1,nsizes,1)*ydist
  sizes = ispan(1,nsizes,1)*0.01

  table_num = (/(/19, 19, 37, 19/),(/34, 36, 37, 37/)/)
  letter    = (/(/"Y","y","R","z"/),(/"7","]","m","Z"/)/)
  xlabels   = new((/ntypes,ncirc/),string)
  ylabels   = new(nsizes,string)

  circ_id = new((/ntypes,ncirc/),integer)
  circ_id(0,0)  = 4
  circ_id(1,0)  = 16

  xlabels(0,0)   = "default hollow~C~      circle"
  xlabels(1,0)   = "default filled~C~      circle"
  ylabels      = "" + sizes

  wks = gsn_open_wks("x11","circles")

;---Get indexes for rest of circles
  do ct=0,1
    do nt=0,ncirc-2
      circ_id(ct,nt+1) = NhlNewMarker(wks,letter(ct,nt),table_num(ct,nt),0.,0.,1.,1.,0.)
      xlabels(ct,nt+1) = "table #" + table_num(ct,nt) + "~C~ letter " + letter(ct,nt)
    end do
  end do

  res             = True
  res@gsnMaximize = True
  res@gsnFrame    = False
  res@gsnScale    = True
  res@vpWidthF    = 0.8
  res@vpHeightF   = 0.4
  res@trYMaxF     = 1.2
  res@trXMinF     = -0.05
  res@trXMaxF     = 1.05
  res@tmXBMode    = "Explicit"
  res@tmXTOn      = False
  res@tmYROn      = False
  res@tmXBValues  = xpos
  res@tmYLMode    = "Explicit"
  res@tmYLValues  = ypos
  res@tmYLLabels  = ylabels
  res@tmXBLabelFontHeightF = 0.01
  res@tiYAxisString = "marker sizes"
  res@tiXAxisString = "marker indexes"
  res@tiXAxisFontHeightF = 0.015
  res@tiYAxisFontHeightF = 0.015

  mkres                     = True
  mkres@gsMarkerColor      := "black"
  mkres@gsMarkerThicknessF = 2.0

  do ct=0,1
    res@tiMainString = "comparing " + circle_types(ct) + " circles"
    res@tmXBLabels   = xlabels(ct,:)
    plot = gsn_csm_blank_plot(wks,res)
    do nc=0,ncirc-1
      mkres@gsMarkerIndex = circ_id(ct,nc)
      do ns=0,nsizes-1
        mkres@gsMarkerSizeF = sizes(ns)
        gsn_polymarker(wks,plot,xpos(nc),ypos(ns),mkres)
      end do
    end do
    frame(wks)
  end do
end
