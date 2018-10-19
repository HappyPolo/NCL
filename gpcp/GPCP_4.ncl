;GPCP_4.NCL
;利用GPCP资料，画出1979-2008年30年的4、7、10、1月的平均降水去趋势求方差

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

    f                            =addfile("/mnt/e/data/precip.mon.mean.nc","r")
    prc                          =f->precip(0:360,:,:)
    dsizes_prc                   =dimsizes(prc)
    nlat                         =dsizes_prc(1)
    mlon                         =dsizes_prc(2)

    prc_spring                   =new((/30,nlat,mlon/),"float")
    prc_summer                   =new((/30,nlat,mlon/),"float")
    prc_autumn                   =new((/30,nlat,mlon/),"float")
    prc_winter                   =new((/30,nlat,mlon/),"float")
do i=0,29
    a=i*12+3
    b=i*12+6
    c=i*12+9
    d=(i+1)*12
    prc_spring(i,:,:)            =prc(a,:,:)
    prc_summer(i,:,:)            =prc(b,:,:)
    prc_autumn(i,:,:)            =prc(c,:,:)
    prc_winter(i,:,:)            =prc(d,:,:)
end do

    prc_d_spring                 =dtrend_msg_n(ispan(0,29,1),prc_spring,True,True,0)
    prc_d_summer                 =dtrend_msg_n(ispan(0,29,1),prc_summer,True,True,0)
    prc_d_autumn                 =dtrend_msg_n(ispan(0,29,1),prc_autumn,True,True,0)
    prc_d_winter                 =dtrend_msg_n(ispan(0,29,1),prc_winter,True,True,0)


    copy_VarCoords(prc_spring,prc_d_spring)
    copy_VarCoords(prc_summer,prc_d_summer)
    copy_VarCoords(prc_autumn,prc_d_autumn)
    copy_VarCoords(prc_winter,prc_d_winter)

    prc_spring_var               =dim_variance_n_Wrap(prc_d_spring,0)
    prc_summer_var               =dim_variance_n_Wrap(prc_d_summer,0)
    prc_autumn_var               =dim_variance_n_Wrap(prc_d_autumn,0)
    prc_winter_var               =dim_variance_n_Wrap(prc_d_winter,0)
print(max(prc_spring_var))
print(max(prc_summer_var))
print(max(prc_autumn_var))
print(max(prc_winter_var))
    prc_spring_var               =where(prc_spring_var.lt.0.1,0.0,prc_spring_var)
    prc_summer_var               =where(prc_summer_var.lt.0.1,0.0,prc_summer_var)
    prc_autumn_var               =where(prc_autumn_var.lt.0.1,0.0,prc_autumn_var)
    prc_winter_var               =where(prc_summer_var.lt.0.1,0.0,prc_winter_var)

    plot                         =new(4,graphic) ;创建一个一维数组，为最后的组图准备


    wks                          =gsn_open_wks("x11","GPCP_season")
;gsn_define_colormap(wks, "WhiteBlueGreenYellowRed")
gsn_define_colormap(wks, "wh-bl-gr-ye-re")
    res                          =True
    res@gsnDraw                  =False
    res@gsnFrame                 =False

;地图
    ;res@mpMaxLatF                =50
    ;res@mpMinLatF                =10
    ;res@mpMaxLonF                =140
    ;res@mpMinLonF                =60
    res@mpGridAndLimbOn          =True
    res@mpGridLatSpacingF        =10
    res@mpGridLineDashPattern    =2
    res@mpGridLineThicknessF     =0.5
    res@mpGridLonSpacingF        =10
    res@pmTickMarkDisplayMode    ="Always" ;坐标标签添加符号度
    res@mpDataBaseVersion        ="MediumRes" ;中等分辨率地图，默认为低等
    res@mpDataSetName            ="Earth..4"
    res@mpGeophysicalLineColor   ="black"
    res@mpOutlineBoundarySets    ="National"
    res@mpGeophysicalLineDashPattern=16
    res@mpGeophysicalLineDashSegLenF=0.2
    res@mpGeophysicalLineThicknessF =0.2
    res@mpOutlineMaskingOn       =True
    res@mpOutlineOn              =True

    res@cnFillOn                 =True
    res@cnFillOpacityF           =0.9 ;透明度
    ;res@cnFillMode               ="RasterFill" ;填充格式
    ;res@cnFillPattern            =14 ;形状填充
    res@cnFillScaleF             =0.5 ;形状填充密度
    res@cnLinesOn                =False
    ;res@cnLevelSelectionMode     ="AutomaticLevels"
    res@cnLevelSelectionMode     ="ExplicitLevels"
    res@cnLevels                 =(/0.1,.2,.3,.4,.5,.6,.7,.8,.9,1.,1.5,2.0,2.5,3.,5.,10.,20.,30.,50.,60.,70./);21
    res@cnFillColors             =(/2,6,13,18,25,33,39,46,50,57,65,66,97,100,110,125,135,146,167,178,193,200/)
    res@lbLabelBarOn             =False


;排列多幅图形
    resp                         =True

    resp@gsnPanelCenter           =True ;排列时居中对齐每行图
    resp@gsnPanelDebug            =True ;在图形中显示图形的坐标等信息
    resp@gsnPanelFigureStrings    =(/"(a)","(b)","(c)","(d)"/) ;为每幅图添加标号
    resp@gsnPanelFigureStringsBackgroundFillColor="white"
    resp@gsnPanelFigureStringsFontHeightF =0.01
    resp@amJust                   ="TopLeft"
    resp@gsnPanelFigureStringsPerimOn     =True ;序号加边框
    resp@gsnPanelLabelBar         =True ;多图公用一个色标
    resp@gsnLeftString            =""
    resp@gsnRightString           =""
    resp@gsnCenterString          ="GPCP_season"
    resp@gsnMaximize              =True
;色标
    resp@lbLabelBarOn                =True
    resp@lbOrientation               ="Horizontal"

    resp@lbBoxLinesOn                =False
    resp@lbBoxLineColor              ="black"
    resp@lbBoxLineThicknessF         =1.5
    resp@lbBoxLineDashPattern        =16

    resp@lbLabelOffsetF              =0.1
    resp@lbLabelFontHeightF          =0.01
    resp@lbLabelFontColor            ="black"
    resp@lbLabelFontThicknessF       =1.5

    ;resp@pmLabelBarParallelPosF      =0.5

    resp@pmLabelBarWidthF            =0.45
    resp@pmLabelBarHeightF           =0.15


plot(0)=gsn_csm_contour_map(wks,prc_spring_var, res)
plot(1)=gsn_csm_contour_map(wks,prc_summer_var, res)
plot(2)=gsn_csm_contour_map(wks,prc_autumn_var, res)
plot(3)=gsn_csm_contour_map(wks,prc_winter_var, res)

gsn_panel(wks, plot,(/2,2/), resp)


end