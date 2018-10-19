;*************************************************
; polyg_10.ncl
;
; Concepts illustrated:
;   - Drawing multiple bar charts on a page
;   - Attaching filled polygons to an XY plot
;   - Attaching polylines to an XY plot
;   - Manually creating a legend
;   - Paneling five plots on a page
;   - Turning off the top and right axes borders
;   - Drawing text on the frame
;
;*************************************************

begin
  plot = new(7,graphic)                           ; create graphical array
  wks = gsn_open_wks("png","polyg")               ; send graphics to PNG file
  gsn_define_colormap(wks,"wgne15")               ; define colormap

;*********************************************
; parameters
;********************************************* 
; these are color indices from the colormap
  litter    = "greenyellow"
  live_moss = "darkgreen"
  dead_moss = "orange"
  deep_org  = "navajowhite2"
  mineral   = "lightgray"

  x    = (/0,1/) ; arrays for fack axis
  y    = (/0,0/)

  res               = True
  res@trYMinF       = 0.    ; min  y axis value
  res@trYMaxF       = 350   ; max  y axis value
  res@trXMaxF       = 12    ; max  x axis value
  res@tmXBMinorOn   = False ; turn off minor tickmarks
  res@tmYLMinorOn   = False
  res@tmXTOn        = False ; turn off top tickmarks
  res@tmYROn        = False ; turn off right tickmarks
  res@tmXTBorderOn  = False ; turn off top axis
  res@tmYRBorderOn  = False ; turn off right axis

  res@tiXAxisString = "Depth (cm)" ; titles
  res@tiYAxisString = "Hg ng/g(dm)"


  res@tmYLLabelFontHeightF       = 0.03 ; set font heights
  res@gsnCenterStringFontHeightF = 0.03
  res@tiXAxisFontHeightF         = 0.03
  res@tiYAxisFontHeightF         = 0.03

  res@vpWidthF       = .8  ; change aspect ratio
  res@vpHeightF      = .4

  res@gsnDraw       = False ; don't draw or advance the frame
  res@gsnFrame      = False 


; polygon resources
  pgres                  = True
  pgres@gsLineThicknessF = 2.0   ; make lines thicker
;*********************************************************
; first plot
;*********************************************************
  yp1 = (/0,0,82.,82,0/)
  xp1 = (/0,5.1,5.1,0,0/)

  yp2 = (/0,0,110.,110,0/)
  xp2 = (/5.1,6.7,6.7,5.1,5.1/)

  yp3 = (/0,0,49.,49,0/)
  xp3 = (/6.7,7.7,7.7,6.7,6.7/)

  yp4 = (/0,0,7.51,7.51,0/)
  xp4 = (/7.7,8.9,8.9,7.7,7.7/)

  res@gsnCenterString = "TS1 30m Needles" ; title
  plot(0) = gsn_csm_xy(wks,x,y,res)       ; create just axis to draw on

  legend = (/litter,deep_org,deep_org,mineral/)
  ypts   = (/yp1,yp2,yp3,yp4/)
  xpts   = (/xp1,xp2,xp3,xp4/)
  nplots = dimsizes(xpts(:,0))
  dum1a  = new(nplots,graphic)
  dum1b  = new(nplots,graphic)
  do i = 0, nplots -1  
    pgres@gsFillColor = legend(i)
    dum1a(i)  = gsn_add_polygon(wks,plot(0),xpts(i,:),ypts(i,:),pgres)
    dum1b(i)  = gsn_add_polyline(wks,plot(0),xpts(i,:),ypts(i,:),pgres)
  end do
  delete(xpts)
  delete(ypts)
  delete(legend)
;*********************************************************
; second plot
;*********************************************************
  yp1 = (/0,0,80.,80,0/)
  xp1 = (/0,  .2,  .2, 0, 0/)

  yp2 = (/0,0,57.,57,0/)
  xp2 = (/0.2,5.4,5.4,0.2,0.2/)

  yp3 = (/0,0,114.,114,0/)
  xp3 = (/5.4,6,6,5.4,5.4/)

  yp4 = (/0,0,170.,170,0/)
  xp4 = (/6,6.9,6.9,6,6/)

  yp5 = (/0,0,156.,156,0/)
  xp5 = (/6.9,8,8,6.9,6.9/)

  yp6 = (/0,0,93,93.,0/)
  xp6 = (/8,9.2,9.2,8,8/)

  yp7 = (/0,0,7.5,7.5,0/)
  xp7 = (/9.2,11.2,11.2,9.2,9.2/)

  res@gsnCenterString = "TS1 90m Moss"
  plot(1) = gsn_csm_xy(wks,x,y,res)  ; create just axis to draw on

  legend = (/litter, live_moss,dead_moss,deep_org,deep_org,deep_org,mineral/)
  ypts   = (/yp1,yp2,yp3,yp4,yp5,yp6,yp7/)
  xpts   = (/xp1,xp2,xp3,xp4,xp5,xp6,xp7/)
  nplots = dimsizes(xpts(:,0))
  dum2a = new(nplots,graphic)
  dum2b = new(nplots,graphic)
  do i = 0, nplots -1  
    pgres@gsFillColor = legend(i)
    dum2a(i)  = gsn_add_polygon(wks,plot(1),xpts(i,:),ypts(i,:),pgres)
    dum2b(i)  = gsn_add_polyline(wks,plot(1),xpts(i,:),ypts(i,:),pgres)
  end do
  delete(xpts)
  delete(ypts)
  delete(legend)

;*********************************************************
; third plot
;*********************************************************
  yp1 = (/0,0,41,41,0/)
  xp1 = (/0,5.3,5.3,0,0/)

  yp2 = (/0,0,155.,155,0/)
  xp2 = (/5.3,5.9,5.9,5.3,5.3/)

  yp3 = (/0,0,172.,172,0/)
  xp3 = (/5.9,8.4,8.4,5.9,5.9/)

  yp4 = (/0,0,13.2,13.2,0/)
  xp4 = (/8.4,10.4,10.4,8.4,8.4/)

  res@gsnCenterString = "TS3 30m Needles"
  plot(2) = gsn_csm_xy(wks,x,y,res)  ; create just axis to draw on

  legend = (/litter,deep_org,deep_org,mineral/)
  ypts   = (/yp1,yp2,yp3,yp4/)
  xpts   = (/xp1,xp2,xp3,xp4/)
  nplots = dimsizes(xpts(:,0))
  dum3a = new(nplots,graphic)
  dum3b = new(nplots,graphic)
  do i = 0, nplots -1  
    pgres@gsFillColor = legend(i)
    dum3a(i)  = gsn_add_polygon(wks,plot(2),xpts(i,:),ypts(i,:),pgres)
    dum3b(i)  = gsn_add_polyline(wks,plot(2),xpts(i,:),ypts(i,:),pgres)
  end do
  delete(xpts)
  delete(ypts)
  delete(legend)
;*********************************************************
; forth plot
;*********************************************************
  yp1 = (/0,0,80,80,0/)
  xp1 = (/0,.2,.2,0,0/)

  yp2 = (/0,0,67.,67,0/)
  xp2 = (/.2,6.3,6.3,.2,.2/)

  yp3 = (/0,0,113.,113,0/)
  xp3 = (/6.3,7.4,7.4,6.3,6.3/)

  yp4 = (/0,0,115.,115,0/)
  xp4 = (/7.4,9.1,9.1,7.4,7.4/)

  yp5 = (/0,0,108,108,0/)
  xp5 = (/9.1,10.3,10.3,9.1,9.1/)

  yp6 = (/0,0,3.64,3.64,0/)
  xp6 = (/10.3,12.3,12.3,10.3,10.3/)

  res@gsnCenterString = "TS3 100m Moss"
  plot(3) = gsn_csm_xy(wks,x,y,res)  ; create just axis to draw on

  legend = (/litter,live_moss,dead_moss,deep_org,deep_org,mineral/)
  ypts   = (/yp1,yp2,yp3,yp4,yp5,yp6/)
  xpts   = (/xp1,xp2,xp3,xp4,xp5,xp6/)
  nplots = dimsizes(xpts(:,0))
  dum4a = new(nplots,graphic)
  dum4b = new(nplots,graphic)
  do i = 0, nplots -1  
    pgres@gsFillColor = legend(i)
    dum4a(i)  = gsn_add_polygon(wks,plot(3),xpts(i,:),ypts(i,:),pgres)
    dum4b(i)  = gsn_add_polyline(wks,plot(3),xpts(i,:),ypts(i,:),pgres)
  end do
  delete(xpts)
  delete(ypts)
  delete(legend)
;*********************************************************
; fifth plot
;*********************************************************
  yp1 = (/0,0,80,80,0/)
  xp1 = (/0,1.2,1.2,0,0/)

  yp2 = (/0,0,120.,120,0/)
  xp2 = (/1.2,5.8,5.8,1.2,1.2/)

  yp3 = (/0,0,226.,226,0/)
  xp3 = (/5.8,7.2,7.2,5.8,5.8/)

  yp4 = (/0,0,257.,257,0/)
  xp4 = (/7.2,8.8,8.8,7.2,7.2/)

  yp5 = (/0,0,192,192,0/)
  xp5 = (/8.8,10.4,10.4,8.8,8.8/)

  yp6 = (/0,0,6.5,6.5,0/)
  xp6 = (/10.4,12.4,12.4,10.4,10.4/)

  res@gsnCenterString = "TS2 -5 Needles"
  plot(4) = gsn_csm_xy(wks,x,y,res)  ; create just axis to draw on

  legend = (/litter,deep_org,deep_org,deep_org,deep_org,mineral/)
  ypts   = (/yp1,yp2,yp3,yp4,yp5,yp6/)
  xpts   = (/xp1,xp2,xp3,xp4,xp5,xp6/)
  nplots = dimsizes(xpts(:,0))
  dum5a = new(nplots,graphic)
  dum5b = new(nplots,graphic)
  do i = 0, nplots -1  
    pgres@gsFillColor = legend(i)
    dum5a(i)  = gsn_add_polygon(wks,plot(4),xpts(i,:),ypts(i,:),pgres)
    dum5b(i)  = gsn_add_polyline(wks,plot(4),xpts(i,:),ypts(i,:),pgres)
  end do
  delete(xpts)
  delete(ypts)
  delete(legend)
;*********************************************************
; sixth plot
;*********************************************************
  yp1 = (/0,0,80,80,0/)
  xp1 = (/0,.2,.2,0,0/)

  yp2 = (/0,0,108.,108,0/)
  xp2 = (/.2,5.3,5.3,.2,.2/)

  yp3 = (/0,0,284.,284,0/)
  xp3 = (/5.3,6.3,6.3,5.3,5.3/)

  yp4 = (/0,0,305.,305,0/)
  xp4 = (/6.3,8.3,8.3,6.3,6.3/)

  yp5 = (/0,0,256,256,0/)
  xp5 = (/8.3,11.2,11.2,8.3,8.3/)

  yp6 = (/0,0,111,111,0/)
  xp6 = (/11.2,11.7,11.7,11.2,11.2/)

  yp7 = (/0,0,12.4,12.4,0/)
  xp7 = (/11.7,13.7,13.7,11.7,11.7/)

  yp8 = (/0,0,8.38,8.38,0/)
  xp8 = (/13.7,15.7,15.7,13.7,13.7/)

  yp9 = (/0,0,10.2,10.2,0/)
  xp9 = (/15.7,17.7,17.7,15.7,15.7/)

  res@gsnCenterString = "TS2 30 Moss"
  res@trXMaxF         = 18
  plot(5) = gsn_csm_xy(wks,x,y,res)  ; create just axis to draw on

  legend = (/litter,live_moss,deep_org,deep_org,deep_org,deep_org,mineral,\
             mineral,mineral/)
  ypts   = (/yp1,yp2,yp3,yp4,yp5,yp6,yp7,yp8,yp9/)
  xpts   = (/xp1,xp2,xp3,xp4,xp5,xp6,xp7,xp8,xp9/)
  nplots = dimsizes(xpts(:,0))
  dum6a = new(nplots,graphic)
  dum6b = new(nplots,graphic)
  do i = 0, nplots -1  
    pgres@gsFillColor = legend(i)
    dum6a(i)  = gsn_add_polygon(wks,plot(5),xpts(i,:),ypts(i,:),pgres)
    dum6b(i)  = gsn_add_polyline(wks,plot(5),xpts(i,:),ypts(i,:),pgres)
  end do
  delete(xpts)
  delete(ypts)
  delete(legend)

;*********************************************************
; seventh plot
;*********************************************************
  yp1 = (/0,0,127,127,0/)
  xp1 = (/0,1.,1.,0,0/)

  yp2 = (/0,0,91.,91,0/)
  xp2 = (/1.,8.5,8.5,1.,1./)

  yp3 = (/0,0,166.,166,0/)
  xp3 = (/8.5,11.5,11.5,8.5,8.5/)

  yp4 = (/0,0,200.,200,0/)
  xp4 = (/11.5,14.5,14.5,11.5,11.5/)

  yp5 = (/0,0,253,253,0/)
  xp5 = (/14.5,17.5,17.5,14.5,14.5/)

  yp6 = (/0,0,258,258,0/)
  xp6 = (/17.5,20.5,20.5,17.5,17.5/)

  yp7 = (/0,0,138,138,0/)
  xp7 = (/20.5,23.5,23.5,20.5,20.5/)

  yp8 = (/0,0,25.2,25.2,0/)
  xp8 = (/23.5,26.5,26.5,23.5,23.5/)


  res@gsnCenterString = "Tree Beard Moss"
  res@trXMaxF       = 27
  plot(6) = gsn_csm_xy(wks,x,y,res)  ; create just axis to draw on

  legend = (/litter,live_moss,deep_org,deep_org,deep_org,deep_org,deep_org,\
             mineral/)
  ypts   = (/yp1,yp2,yp3,yp4,yp5,yp6,yp7,yp8/)
  xpts   = (/xp1,xp2,xp3,xp4,xp5,xp6,xp7,xp8/)
  nplots = dimsizes(xpts(:,0))
  dum7a = new(nplots,graphic)
  dum7b = new(nplots,graphic)
  do i = 0, nplots -1  
    pgres@gsFillColor = legend(i)
    dum7a(i)  = gsn_add_polygon(wks,plot(6),xpts(i,:),ypts(i,:),pgres)
    dum7b(i)  = gsn_add_polyline(wks,plot(6),xpts(i,:),ypts(i,:),pgres)
  end do
  delete(xpts)
  delete(ypts)
  delete(legend)

;***********************************************
; panel plots together
;***********************************************
  pres                 = True
  pres@gsnMaximize     = True
  pres@gsnPanelRowSpec = True
  pres@gsnPanelCenter  = False
  pres@gsnFrame        = False
  gsn_panel(wks,plot,(/2,2,2,1/),pres)
;*********************************************
; add legend polygons
;*********************************************
; text resources
  txtres               = True
  txtres@txFontHeightF = 0.015        ; font height
  txtres@txJust        = "CenterLeft" ; align text to left

  xpts = (/0.6,0.65,0.65,0.6,0.6/)
  ypts = (/0.2,0.2,0.23,0.23,0.2/)
  pgres@gsFillColor = litter
  gsn_polygon_ndc(wks,xpts,ypts,pgres)
  gsn_polyline_ndc(wks,xpts,ypts,pgres)
  gsn_text_ndc(wks,"Litter",.66,.215,txtres)

  ypts = (/0.19,0.19,0.16,0.16,0.19/)
  pgres@gsFillColor = live_moss
  gsn_polygon_ndc(wks,xpts,ypts,pgres)
  gsn_polyline_ndc(wks,xpts,ypts,pgres)
  gsn_text_ndc(wks,"Live Moss",.66,.175,txtres)

  ypts = (/0.15,0.15,0.12,0.12,0.15/)
  pgres@gsFillColor = dead_moss
  gsn_polygon_ndc(wks,xpts,ypts,pgres)
  gsn_polyline_ndc(wks,xpts,ypts,pgres)
  gsn_text_ndc(wks,"Dead Moss",.66,.135,txtres)

  ypts = (/0.11,0.11,0.08,0.08,0.11/)
  pgres@gsFillColor = deep_org
  gsn_polygon_ndc(wks,xpts,ypts,pgres)
  gsn_polyline_ndc(wks,xpts,ypts,pgres)
  gsn_text_ndc(wks,"Deep Organic",.66,.095,txtres)


  ypts = (/0.07,0.07,0.04,0.04,0.07/)
  pgres@gsFillColor = mineral
  gsn_polygon_ndc(wks,xpts,ypts,pgres)
  gsn_polyline_ndc(wks,xpts,ypts,pgres)
  gsn_text_ndc(wks,"Mineral",.66,.055,txtres)

  frame(wks)

end

