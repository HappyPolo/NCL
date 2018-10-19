;对1979-2008 30年降水去趋势求方差
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

  f                            =addfile("/mnt/e/data/precip.mon.mean.nc","r")
  prc                          =f->precip(0:359,:,:)

  dsizes_prc                   =dimsizes(prc)

  prc_d                        =dtrend_msg_n(ispan(0,359,1),prc,True,True,0)
  copy_VarCoords(prc,prc_d)
  prc_var                      =dim_variance_n_Wrap(prc_d,0)
;printVarSummary(prc_var)

  wks                          =gsn_open_wks("x11", "GPCP")
gsn_define_colormap(wks,"GMT_wysiwygcont")
  res                          =True

  res@mpMaxLatF                =60
  res@mpMinLatF                =10
  res@mpMaxLonF                =140
  res@mpMinLonF                =60


    
  res@cnFillOn                    =True
  res@cnLinesOn                   =False
  res@cnLevelSelectionMode        ="ExplicitLevels"
  ;res@cnLevels                    =(/1500,2000,2500,3000,4000,5000,6000/)
  res@cnLevels                = (/0.1,0.2,0.4,0.6,0.8,1.0,1.2,1.5,2.0,3.0,5.0,10.0,11.0,12.0,13.0,15.0,20./)
  res@cnFillOpacityF              =0.9   ;透明度
  res@cnFillColors                =(/201,193,183,177,170,161,145,138,130,114,97,91,73,66,55,46,24,17/)











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
  res@gsnMaximize                 =True

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
  res@tiMainJust                  ="GPCP"
  ;res@tiMainOffsetXF              =1
  ;res@tiMainOffsetYF              =1
  res@tiMainPosition              ="Center"
  res@tiMainSide                  ="Top"
  res@tiMainString                ="gpcp"

plot=gsn_csm_contour_map(wks,prc_var, res)

end