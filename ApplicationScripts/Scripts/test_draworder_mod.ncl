load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

function get_ipcc5_cmap()
begin
  cmap = (/ (/255,255,255/), (/0,0,0/), \
              (/84,  146, 205 /), \
              (/153, 0,   2 /), \
              (/196, 121, 0/), \
              (/0,   79,  0 /), \
              (/0,   170, 208/), \
              (/224, 0,   0/), \
              (/152, 251, 152/), \
              (/239, 85,  15/), \
              (/147, 112, 219/), \
              (/255, 169, 0/), \
              (/89,  169, 0 /), \
              (/0,   52,  102 /), \
              (/127, 0,   110/), \
              (/139, 139,   0/), \
              (/165, 42,  42/), \
              (/106,  90, 205/), \
              (/218, 112, 214/), \
              (/95, 158, 160/), \
              (/173, 255,  47/), \
              (/255, 192, 203 /), \
              (/255,  20, 147/), \
              (/211, 211, 211/), \
              (/190, 190, 190/), \
              (/105, 105, 105/)/)/255.
  return(cmap)
end

begin
 
 data = new((/4,120/),"float")
 data(0,:) = random_uniform(280.,400.,120)
 data(1,:) = random_uniform(280.,400.,120)
 data(2,:) = random_uniform(280.,400.,120)
 data(3,:) = random_uniform(280.,400.,120)
 data!0 = "var"
 data!1 = "time"
 data&time = ispan(1,120,1)

 cor1 = sprintf("%5.2f",escorc(data(0,:),data(1,:)))
 cor2 = sprintf("%5.2f",escorc(data(0,:),data(2,:)))
 corf3 = sprintf("%5.2f",escorc(data(0,:),data(3,:)))

;===========================================================================
; Begin plotting section.
;===========================================================================
  wks = gsn_open_wks("png","test_draworder") ; workstation
  
  gsn_define_colormap(wks,get_ipcc5_cmap())      ; define a different colormap.
;  gsn_draw_colormap(wks)

  ymin = 260
  ymax = 413
  xmin = 0.5
  xmax = 120.5

  res                  = True     ; plot mods desired
  res@gsnDraw          = False           ; don't draw
  res@gsnFrame         = False           ; don't advance frame
  res@tiMainFontHeightF  = 0.016
  res@tiYAxisFontHeightF =  0.016
  res@tiXAxisFontHeightF =  0.016
  res@tmXBLabelFontHeightF = 0.012
  res@tmYLLabelFontHeightF = 0.012
  res@gsnStringFontHeightF = 0.016
  res@tmXBMajorOutwardLengthF = 0.008
  res@tmYLMajorOutwardLengthF = 0.008
  res@tmXBMinorOutwardLengthF = 0.004
  res@tmYLMinorOutwardLengthF = 0.004
  res@tmXBMajorLengthF = 0.008
  res@tmYLMajorLengthF = 0.008
  res@tmXBMinorLengthF = 0.004
  res@tmYLMinorLengthF = 0.004
  res@gsnStringFont = "times-roman" 
  res@tmYLPrecision = 3
  res@tiYAxisString    = "Sea surface pCO~B~2~N~ (ppm)"
  res@tiXAxisString    = "Year"
;  res@vpYF             = 0.95                  ; for map plot
  res@vpWidthF         = 0.6
  res@vpHeightF        = 0.45
  res@trYMinF         = ymin
  res@trYMaxF         = ymax
  res@trXMinF         = xmin
  res@trXMaxF         = xmax
  res@tiMainString    = ""
  res@gsnLeftString = ""
  res@tiXAxisOffsetYF = -0.03
;  res@xyCurveDrawOrder = "PreDraw"
;  res@tfPolyDrawOrder = "PreDraw"

  res@gsnYRefLine           = 0.              ; reference line   
  res@gsnXYBarChart         = True            ; create bar chart 
  res@gsnAboveYRefLineColor = 0          ; above ref line fill red
  res@gsnBelowYRefLineColor = 0          ; below ref line fill blue
  res@xyLineColors = (/24,24/)         ; colors for the above/blow
  yy = fspan(413.,413.,120)

  ii             = ispan(0,9,1)
  res@tmXBMode   = "Explicit"
  res@tmXBValues = 6 + 12*ii
  res@tmXBLabels = sprinti("2002%02i",ii)

;---This is the main plot, that will serve as the "base" plot
  thin_bar_plot = gsn_csm_xy(wks,data&time,yy,res)

  res@gsnAboveYRefLineColor = 24          ; above ref line fill red
  res@gsnBelowYRefLineColor = 24          ; below ref line fill blue
  res@xyLineColors          = (/0,0/)     ; colors for the above/blow
  res@gsnLeftString         = ""

  gray_bar_plot = gsn_csm_xy(wks,data&time,data(0,:),res)

  overlay(thin_bar_plot,gray_bar_plot)

  res1                  = True     ; plot mods desired
  res1@gsnDraw          = False           ; don't draw
  res1@gsnFrame         = False           ; don't advance frame
  res1@xyMarkLineMode   = "Markers"
  res1@trYMinF          = ymin
  res1@trYMaxF          = ymax
  res1@trXMinF          = xmin
  res1@trXMaxF          = xmax

  res1@xyMarkers        = (/16,16,16/)
  res1@xyMarkerColors   = (/1,2,7/)
  res1@xyLineColors     = (/1,2,7/)
  res1@xyMarkerSizes    = (/0.006,0.006,0.006/)
  res1@xyDashPatterns   = (/0,0,0/)

  marker_plot = gsn_csm_xy(wks,data&time,data(1:3,:),res1)
  overlay(thin_bar_plot,marker_plot)

  llid1 = create "ll" logLinPlotClass wks 
    "trXMinF" : xmin
    "trXMaxF" : xmax
    "trYMinF" : ymin
    "trYMaxF" : ymax
  end create

  txres               = True                     ; text mods desired
  txres@txFontHeightF = 0.014                  ; font smaller. default big
  txres@txJust = "CenterLeft"

  gmres = True
  gmres@gsMarkerIndex   = 16
  gmres@gsMarkerSizeF     = 0.02
  gmres@gsMarkerThicknessF = 5.

  glres = True
  glres@gsLineColor = 23
  glres@gsLineDashPattern = 0.
  glres@gsLineThicknessF = 1.

  ggres = True
  ggres@gsFillColor      = "beige"

  xbox0 = (/4.,95.,95.,4.,4./)
  ybox0 = (/411.,411.,389.,389.,411./)
  dum04 = gsn_add_polygon(wks,llid1,xbox0,ybox0,ggres)

  xbox = (/7,14,14,7,7/)
  ybox = (/406.,406.,404.,404.,406./)
  ggres@gsFillColor      = 24
  dum00 = gsn_add_polygon(wks,llid1,xbox,ybox,ggres)
  dum01 = gsn_add_text(wks,llid1,"SOCAT",17.,405.,txres) 
  gmres@gsMarkerColor    = 1 
  dum02 = gsn_add_polymarker(wks,llid1,58.,405.,gmres)
  dum03 = gsn_add_text(wks,llid1,"Assimilation: "+cor1,61.,405.,txres) 
  gmres@gsMarkerColor    = 7
  dum10 = gsn_add_polymarker(wks,llid1,8.,395.,gmres)
  dum11 = gsn_add_text(wks,llid1,"Initialized(yr3): "+corf3,11.,395.,txres) 
  gmres@gsMarkerColor    = 2
  dum12 = gsn_add_polymarker(wks,llid1,58.,395.,gmres)
  dum13 = gsn_add_text(wks,llid1,"Uninitialized: "+cor2,61.,395.,txres) 

  overlay(thin_bar_plot,llid1)

  draw(thin_bar_plot)
  frame(wks)


end     
