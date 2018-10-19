;GPCP_1.ncl

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

    f                               =addfile("gpcp_v2.2.1979-2015.nc","r")
    precip                          =f->Precip
    
    prc_clm                         =clmMonTLL(precip)
    ;printVarSummary(prc_clm)
    prc_clm                         =where(prc_clm.lt.0.10,0.0,prc_clm)
    prc_ann                         =dim_avg_n_Wrap(prc_clm,0)
    clat                            =latRegWgt(prc_ann&lat,"float",0)
    prcAVG                          =wgt_areaave(prc_ann,clat,1.0,0)


    ;date                            =f->date
    ;ntim                            =dimsizes(date)
    ;yrStrt                          =date(0)/10000
    ;yrLast                          =date(ntim-1)/10000




    wks                             =gsn_open_wks("x11","GPCP_1")
    colors=(/"Snow","PaleTurquoise","PaleGreen","SeaGreen3","Yellow","orange","HotPink","Red","Violet","Purple","Brown","Black"/)
    

    res                             =True
    res@gsnMaximize                 =True

    res@cnFillOn                    =True
    res@cnFillPalette               =colors
    res@cnLinesOn                   =False
    ;res@cnFillMode                  ="RasterFill"
    res@cnLineLabelsOn              =False    
    res@cnLevelSelectionMode        ="ExplicitLevels"
    res@cnLevels                    =(/0.5,1,2,3,4,5,6,7,8,9,10/)

    res@lbOrientation               ="Vertical"
    res@lbLabelFontHeightF          =0.012
    res@pmLabelBarWidthF            =0.1
    res@pmLabelBarOrthogonalPosF    =-0.01

    res@mpFillOn                    =False
    ;res@mpMaxLatF                   =55
    ;res@mpMinLatF                   =0
    ;res@mpMaxLonF                   =120
    ;res@mpMinLonF                   =60


    res@mpGeophysicalLineColor      ="black"
    res@mpOutlineBoundarySets       ="National"
    res@mpGeophysicalLineDashPattern=16
    res@mpGeophysicalLineDashSegLenF=0.2
    res@mpGeophysicalLineThicknessF =0.5
    res@mpOutlineMaskingOn          =True
    res@mpOutlineOn                 =True


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

  res@mpGeophysicalLineColor      ="black"
  res@mpOutlineBoundarySets       ="National"
  res@mpGeophysicalLineDashPattern=16
  res@mpGeophysicalLineDashSegLenF=0.2
  res@mpGeophysicalLineThicknessF =0.5
  res@mpOutlineMaskingOn          =True
  res@mpOutlineOn                 =True


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
  res@tiMainString                ="precip"

  



    ;res@tiMainString                ="*****"
    ;res@gsnCenterString             ="aaaaa"
plot=gsn_csm_contour_map_ce(wks,prc_ann, res)






end