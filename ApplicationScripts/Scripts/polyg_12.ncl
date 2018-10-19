;*************************************************
; polyg_12.ncl
;
; Concepts illustrated:
;   - Changing the size of a PNG image
;   - Using draw order resources to mask areas in a plot
;   - Attaching filled polygons to a map
;   - Attaching polylines to a map plot
;   - Attaching text strings to a map
;   - Turning off map tickmarks
;   - Changing the size and location of a plot using viewport resources
;   - Using "getvalues" to retrieve the size of a plot
;   - Using "setvalues" to set the size of a plot
;*************************************************
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  latS  = -60.
  latN  =  60.
  lonC  = 240.

  latST = -20.
  latNT =  20.


;
; The default PNG image is rather small. This 
; shows how to increase the pixel size. NCL
; always draws things to a square canvas, so if
; you use non-square values for wkWidth/wkHeight,
; the larger of the two values will be used for
; both values.
;
  wtype          = "png"
  wtype@wkWidth  = 1500
  wtype@wkHeight = 1500

  wks  = gsn_open_wks(wtype,"polyg")     ; open a ps file
  
  res              = True
  res@gsnMaximize  = True

  res@gsnDraw      = False
  res@gsnFrame     = False

  res@mpMaxLatF    = latN
  res@mpMinLatF    = latS
  res@mpCenterLonF = lonC

  res@mpFillOn     = True
  res@mpFillColors = (/-1,0,-1,-1/)
  res@mpOutlineOn  = True

  plot = gsn_csm_map(wks,res)        ; draw global map

  resp                 = True
  resp@gsFillColor     = "blue"
  resp@tfPolyDrawOrder = "Draw"                      ; default is "PostDraw"  

  xpts = (/360.0, 0.0,0.0, 360.0,360.0/)
  ypts = (/ 20.0,  20.0,  40.0,  40.0, 20.0/) 
  dum = gsn_add_polygon(wks,plot,xpts,ypts,resp)

  ypts = (/ -20.0,  -20.0,  -40.0,  -40.0, -20.0/)
  resp@gsFillColor = "red"
  dum2 = gsn_add_polygon(wks,plot,xpts,ypts,resp)
  draw(plot)

;---------------------------------------------------------
; In order to assure that the rest of the plots are
; drawn in the same size as "plot", we need to retrieve
; these four vp resources, and set them for the rest of 
; the plots. Also, make sure gsnMaximize is NOT set for
; the rest of the plots.
;---------------------------------------------------------
  delete(res@gsnMaximize)

;---Retrieve the vp resources from the previous plot.
  getvalues plot
    "vpXF"      : vpx
    "vpYF"      : vpy
    "vpWidthF"  : vpw
    "vpHeightF" : vph
  end getvalues

;---Set the vp resources for the rest of the plots.
  res@vpXF            = vpx
  res@vpYF            = vpy
  res@vpWidthF        = vpw
  res@vpHeightF       = vph

;---------------------------------------------------------
;   Draw tropical plot, along with green/yellow polygons
;---------------------------------------------------------    
  res@mpMaxLatF    = 20.
  res@mpMinLatF    = -20
  res@tmXBOn       = False
  res@tmXTOn       = False
  res@tmXTBorderOn = False
  res@tmXBBorderOn = False
  res@tmXBLabelsOn = False
  res@tmYLBorderOn = False
  res@tmYRBorderOn = False
  res@tmYLLabelsOn = False
  res@tmYLOn       = False
  res@tmYROn       = False
  res@mpFillColors = (/-1,-1,0,-1/)

  plot2 = gsn_csm_map(wks,res)        ; draw global map

  resp@gsFillColor = "green"
  ypts = (/ 20.0,  20.0,  0.0,   0.0, 20.0/)
  dum3 = gsn_add_polygon(wks,plot2,xpts,ypts,resp)

  ypts = (/ -20.0,  -20.0,  0.0,   0.0, -20.0/)
  resp@gsFillColor = "yellow"
  dum4 = gsn_add_polygon(wks,plot2,xpts,ypts,resp)
  draw(plot2)

;-------------------------------------------------
;   Draw map border, to cover up poylgon fills
;-------------------------------------------------
  res@mpFillColors = (/-1,-1,-1,-1/)
  res@tmXTBorderOn = True
  res@tmXBBorderOn = True
  res@tmYLBorderOn = True
  res@tmYRBorderOn = True
  res@mpMaxLatF    = latN
  res@mpMinLatF    = latS
  res@mpOutlineOn  = False
  plot3 = gsn_csm_map(wks,res)        ; draw global map

;-------------------------------------------------
;   Draw text
;-------------------------------------------------    
  lonTxt = 205.
  sres = True
  sres@txFontHeightF = 0.015
  sres@txFontColor = "blue"
  dum5 = gsn_add_text(wks,plot3,"NLD",lonTxt,50,sres)
  sres@txFontColor = "white"
  dum6 = gsn_add_text(wks,plot3,"NTO",lonTxt,10,sres)
  dum7 = gsn_add_text(wks,plot3,"STO",lonTxt,-10,sres)
  sres@txFontColor = "red"
  dum8 = gsn_add_text(wks,plot3,"SLD",lonTxt,-50,sres)

;-------------------------------------------------
;   Draw lines
;-------------------------------------------------      
  pres = True
  pres@gsLineColor = "blue"
  pres@gsLineThicknessF = 1.5
  dum9 = gsn_add_polyline(wks,plot3,(/192,125/),(/48,30/),pres)
  dum10 = gsn_add_polyline(wks,plot3,(/205,240/),(/45,30/),pres)
  dum11 = gsn_add_polyline(wks,plot3,(/218,350/),(/48,35/),pres)
  
  pres@gsLineColor = "red"
  dum12 = gsn_add_polyline(wks,plot3,(/192,155/),(/-48,-30/),pres)
  dum13 = gsn_add_polyline(wks,plot3,(/205,285/),(/-43,-30/),pres)
  dum14 = gsn_add_polyline(wks,plot3,(/218,375/),(/-50,-35/),pres)
 
  draw(plot3)
  frame(wks)
end



