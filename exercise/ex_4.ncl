;4.ncl
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin


;do i=1,800
  fu                                 =addfile("/mnt/f/data/NCEP/uwnd.mon.mean.nc", "r")
  fw                                 =addfile("/mnt/f/data/NCEP/omega.mon.mean.nc", "r")
   u                                 =fu->uwnd(0,:,:,:)
   w                                 =fw->omega(0,:,:,:)
  ;u                                 =fu->uwnd(i,:,:,:)
  ;w                                 =fw->omega(i,:,:,:)
;end do
  wave                               =avg((w(:,{30},:)))
  uave                               =avg((u(:,{30},:)))
  scale                              =fabs(uave/wave)
  wscale                             =w*scale
  copy_VarCoords(w,wscale)

;************************************************************************************
  
  wks                                =gsn_open_wks("x11", "41")
  gsn_define_colormap(wks,"rainbow+white+gray")

  res                                =True

  res@cnFillOn                       =True
  res@cnLinesOn                      =False
  res@cnLevelSelectionMode           ="ManualLevels"
  res@cnMinLevelValF                 =-0.3
  res@cnMaxLevelValF                 =0.7
  res@cnLevelSpacingF                =0.1
  res@cnFillColors                   =(/238,33,49,65,81,97,113,129,161,193,209,225,237/);15

  


  res@vcGlyphStyle                   ="CurlyVector"
  res@vcMinMagnitudeF                =0.5
  res@vcMinDistanceF                 =0.015
  res@vcRefLengthF                   =0.045
  res@vcRefMagnituedF                =80
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
  res@gsnMaximize                 =True

  res@pmTickMarkDisplayMode       ="Always"


  
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
  res@tiMainString                ="Four"










plot =gsn_csm_pres_hgt_vector(wks,w(:,{30},:),u({1000:100},{30},:),wscale(:,{30},:), res)

end
