 ;ex2.ncl

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

  f_u                               =addfile("~/ncl/uwnd.mon.mean.nc", "r")
  f_v                               =addfile("~/ncl/vwnd.mon.mean.nc", "r")
  f_t                               =addfile("~/ncl/air.mon.mean.nc", "r")
  u                                 =f_u->uwnd(0,:,:,:)
  v                                 =f_v->vwnd(0,:,:,:)
  Temp                              =f_t->air(0,:,:,:)


  wks                               =gsn_open_wks("png", "21")



  res                               =True
  


  res@mpMaxLatF                     =45
  res@mpMinLatF                     =15
  res@mpMaxLonF                     =120
  res@mpMinLonF                     =60

  res@mpGridAndLimbOn               =True
  res@mpGridLineThicknessF          =0.5
  res@mpGridLineDashPattern         =2
  res@mpGridSpacingF                =10

  res@gsnLeftString                 =""
  res@gsnRightString                =""

  ;resv                              =res

  res@gsnAddCyclic                  =True
  res@cnFillOn                      =True
  res@cnLinesOn                     =True

  res@cnLineDashPattern             =2;绘制线型为2的虚线
  res@cnLineColor                   ="black"



  res@cnLevelSelectionMode          ="AutomaticLevels"

  


  res@gsnDraw                       =False
  res@gsnFrame                      =False

  





base =gsn_csm_contour_map(wks,Temp({200},:,:), res)

;********************************************************************** 
  

  delete(res) 


  resv                               =True





  resv@vcGlyphStyle                  ="FillArrow"
  resv@vcFillArrowEdgeColor          ="white"
  resv@vcFillArrowFillColor          ="black"




  

  resv@gsnDraw                       =False
  resv@gsnFrame                      =False
  resv@gsnLeftString                 =""
  resv@gsnRightString                =""


  ;resv@vcFillArrowMinFracWidthF      =2
  ;resv@vcFillArrowHeadMinFracXF      =5
  ;resv@vcFillArrowHeadMinFracYF      =1


  resv@vcMinMagnitudeF                =1.0
  resv@vcMinDistanceF                 =0.01
 
  resv@vcFillArrowEdgeThicknessF      =1 

  resv@vcFillArrowHeadInteriorXF      =0.25
  resv@vcFillArrowHeadXF              =0.6
  resv@vcFillArrowHeadYF              =0.2
  resv@vcFillArrowWidthF              =0.1
  resv@vcRefLengthF                   =0.045  ;单位长度箭头在图中的长度
  resv@vcRefMagnitudeF                =80     ;单位长度箭头表示的实际物理量大小

  resv@vcRefAnnoOn                    =True
  resv@vcRefAnnoFontHeightF           =0.015
  resv@vcRefAnnoOrthogonalPosF        =-0.12;调整垂直位置
  resv@vcRefAnnoParallelPosF          =0.95 ;调整水平位置
  resv@vcRefAnnoSide                  ="Top"
  resv@vcRefAnnoString1On             =False;不设定参考箭头上方的字符
  resv@vcRefAnnoString2On             =True
  resv@vcRefAnnoString2               ="80 m/s"







  
  resv@vcRefAnnoPerimOn              =False  ;关闭边框
  resv@vcMinAnnoOn                   =True


plot =gsn_csm_vector(wks, u({200},:,:), v({200},:,:), resv)

  overlay(base,plot)
  draw(base)
  frame(wks)
end

