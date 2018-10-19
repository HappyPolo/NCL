;hgt.ncl
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  
  f                               =addfile("/mnt/e/data/NCEP/hgt.sfc.nc", "r")
  hgt                             =short2flt(f->hgt)

  wks                             =gsn_open_wks("pdf", "/mnt/e/pdf/hgt_TP")
  gsn_define_colormap(wks, "rainbow+white+gray")
;print(hgt)

  res                             =True
  res@cnFillOn                    =True
  res@cnLinesOn                   =False
  res@cnLevelSelectionMode        ="ManualLevels"
  ;res@cnLevels                    =(/1500,2000,2500,3000,4000,5000,6000/)
  res@cnMaxLevelValF              =6000
  res@cnMinLevelValF              =2000
  res@cnLevelSpacingF             =500
  res@cnFillOpacityF              =0.9   ;透明度
  res@cnFillColors                =(/238,49,65,113,145,177,193,209,225,237/)


;等值线数值标签
  res@cnLineLabelsOn              =True
  res@cnLineLabelAngleF           =15.0
  res@cnLineLabelBackgroundColor  ="white"
  res@cnLineLabelDensityF         =0.5
  res@cnLineLabelPerimOn          =True
  res@cnLineLabelPerimColor       ="white"


  res@cnHighLabelsOn              =True
  res@cnHighLabelFontHeightF      =0.014  


  ;地图边界线
  res@mpGeophysicalLineColor      ="black"
  res@mpOutlineBoundarySets       ="National"
  res@mpGeophysicalLineDashPattern=16
  res@mpGeophysicalLineDashSegLenF=0.2
  res@mpGeophysicalLineThicknessF =0.5
  res@mpOutlineMaskingOn          =True
  res@mpOutlineOn                 =True
  
  ;绘制色标
  res@lbLabelBarOn                =True
  res@lbOrientation               ="Horizontal"

  res@lbBoxLinesOn                =False
  res@lbBoxLineColor              ="black"
  res@lbBoxLineThicknessF         =1.5
  res@lbBoxLineDashPattern        =16

  res@lbLabelOffsetF              =0.1
  res@lbLabelFontHeightF          =0.01
  res@lbLabelFontColor            ="black"
  res@lbLabelFontThicknessF       =1.5

  res@pmLabelBarParallelPosF      =0.5

  res@pmLabelBarWidthF            =0.45
  res@pmLabelBarHeightF           =0.15

  res@gsnLeftString               =""
  res@gsnRightString              =""
  ;res@gsnMaximize                 =True

  res@pmTickMarkDisplayMode       ="Always"


  res@mpMaxLonF                   =120
  res@mpMinLonF                   =60
  res@mpMaxLatF                   =45
  res@mpMinLatF                   =15
  res@mpFillOn                    =False
  res@mpGridAndLimbOn             =True
  res@mpGridLineThicknessF        =0.5
  res@mpGridLineDashPattern       =2
  res@mpGridSpacingF              =10

  ;图题
  res@tiMainOn                    =True
  res@tiMainFontColor             ="black"
  ;res@tiMainFontHeightF           =0.25
  ;res@tiMainFontHeightF           =1
  res@tiMainFuncCode              =":"
  res@tiMainJust                  ="CenterCenter"
  ;res@tiMainOffsetXF              =1
  ;res@tiMainOffsetYF              =1
  res@tiMainPosition              ="Center"
  res@tiMainSide                  ="Top"
  res@tiMainString                ="Hgt_tp"






  plot =gsn_csm_contour_map_ce(wks,hgt(0,:,:), res)
end