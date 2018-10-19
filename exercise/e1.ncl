;11.ncl
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  
  f                               =addfile("~/ncl/precip.mon.mean.nc", "r")
  p                               =f->precip(0,:,:)
  f_u                               =addfile("~/ncl/uwnd.mon.mean.nc", "r")
  f_v                               =addfile("~/ncl/vwnd.mon.mean.nc", "r")
  u                                 =f_u->uwnd(0,:,:,:)
  v                                 =f_v->vwnd(0,:,:,:)

  wks                             =gsn_open_wks("png", "1")

  res                             =True
  res@cnFillOn                    =True
  res@cnLinesOn                   =True
  res@gsnLeftString               =""
  res@gsnRightString              =""
  res@mpMaxLatF                   =45
  res@mpMinLatF                   =15
  res@mpMaxLonF                   =100
  res@mpMinLonF                   =10

  res@cnLevelSelectionMode        ="AutomaticLevels"

  res@gsnDraw                     =False
  res@gsnFrame                    =False


  base=gsn_csm_contour_map_ce(wks,p(:,:),res)


  resv                               =True


  resv@gsnLeftString                 =""
  resv@gsnRightString                =""


  resv@vcGlyphStyle                  ="FillArrow"
  resv@vcFillArrowEdgeColor          ="white"
  resv@vcFillArrowFillColor          ="black"




  

  resv@gsnDraw                       =False
  resv@gsnFrame                      =False


  ;resv@vcFillArrowMinFracWidthF      =2
  ;resv@vcFillArrowHeadMinFracXF      =5
  ;resv@vcFillArrowHeadMinFracYF      =1


  resv@vcMinMagnitudeF                =5.0
  resv@vcMinDistanceF                 =0.03
 
  resv@vcFillArrowEdgeThicknessF      =0.02
  
  resv@vcFillArrowHeadInteriorXF      =0.25
  resv@vcFillArrowHeadXF              =0.6
  resv@vcFillArrowHeadYF              =0.2
  resv@vcFillArrowWidthF              =0.1
  resv@vcRefLengthF                   =0.01       ;单位长度箭头在图中的长度
  resv@vcRefMagnitudeF                =20        ;单位长度箭头表示的实际物理量大小





  
  resv@vcRefAnnoPerimOn              =False  ;关闭边框
  resv@vcMinAnnoOn                   =True


plot =gsn_csm_vector(wks, u({200},:,:), v({200},:,:), resv)

  overlay(base,plot)
  draw(base)
  frame(wks)
end
