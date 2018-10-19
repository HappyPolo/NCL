;wind_600_ec
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

    fu                           =addfile("/mnt/f/data/ERA-interim/monthly/uwnd.mon.mean.nc", "r")
    fv                           =addfile("/mnt/f/data/ERA-interim/monthly/vwnd.mon.mean.nc", "r")
    ft                           =addfile("/mnt/f/data/ERA-interim/monthly/air.mon.mean.nc", "r")
    fh                           =addfile("/mnt/f/data/NCEP/hgt.sfc.nc", "r")
    fu_djf                       =addfile("/mnt/f/data/ERA-interim/monthly/uwnd.DJF.mean.nc", "r")
    fv_djf                       =addfile("/mnt/f/data/ERA-interim/monthly/vwnd.DJF.mean.nc", "r")
    ft_djf                       =addfile("/mnt/f/data/ERA-interim/monthly/air.DJF.mean.nc", "r")

    u600                         =short2flt(fu->u(0:359,{600},:,:))
    v600                         =short2flt(fv->v(0:359,{600},:,:))
    T600                         =short2flt(ft->t(0:359,{600},:,:))
    hgt                          =short2flt(fh->hgt(0,:,:))
    u600_DJF                     =short2flt(fu_djf->u(0:89,{600},:,:))
    v600_DJF                     =short2flt(fv_djf->v(0:89,{600},:,:))
    T600_DJF                     =short2flt(ft_djf->t(0:89,{600},:,:))
    

    t600                         =T600-273.15
    copy_VarCoords(T600, t600)
    t600_DJF                     =T600_DJF-273.15
    copy_VarCoords(T600_DJF, t600_DJF)
    u600_MAM                     =month_to_season(u600, "MAM")
    u600_JJA                     =month_to_season(u600, "JJA")
    u600_SON                     =month_to_season(u600, "SON")
    v600_MAM                     =month_to_season(v600, "MAM")
    v600_JJA                     =month_to_season(v600, "JJA")
    v600_SON                     =month_to_season(v600, "SON")
    t600_MAM                     =month_to_season(t600, "MAM")
    t600_JJA                     =month_to_season(t600, "JJA")
    t600_SON                     =month_to_season(t600, "SON")
    u600_MAM_avg                 =dim_avg_n_Wrap(u600_MAM, 0)
    u600_JJA_avg                 =dim_avg_n_Wrap(u600_JJA, 0)
    u600_SON_avg                 =dim_avg_n_Wrap(u600_SON, 0)
    u600_DJF_avg                 =dim_avg_n_Wrap(u600_DJF, 0)
    u600_mean                    =dim_avg_n_Wrap(u600, 0)
    v600_MAM_avg                 =dim_avg_n_Wrap(v600_MAM, 0)
    v600_JJA_avg                 =dim_avg_n_Wrap(v600_JJA, 0)
    v600_SON_avg                 =dim_avg_n_Wrap(v600_SON, 0)
    v600_DJF_avg                 =dim_avg_n_Wrap(v600_DJF, 0)
    v600_mean                    =dim_avg_n_Wrap(v600, 0)
    t600_MAM_avg                 =dim_avg_n_Wrap(t600_MAM, 0)
    t600_JJA_avg                 =dim_avg_n_Wrap(t600_JJA, 0)
    t600_SON_avg                 =dim_avg_n_Wrap(t600_SON, 0)
    t600_DJF_avg                 =dim_avg_n_Wrap(t600_DJF, 0)
    t600_mean                    =dim_avg_n_Wrap(t600, 0)

    base                         =new(4,graphic)

wks=gsn_open_wks("pdf", "/mnt/f/pdf/wind_600_ec_sr")
gsn_define_colormap(wks, "NCV_blue_red")

    resc1                         =True

    resc1@gsnDraw                 =False
    resc1@gsnFrame                =False
    ;resc1@gsnMaximize             =True

    resc1@mpMaxLonF               =140
    resc1@mpMinLonF               =40
    resc1@mpMaxLatF               =60
    resc1@mpMinLatF               =-10

    resc1@cnFillOn                =True
    resc1@cnLinesOn               =False

    resc1@gsnTickMarksOn          =False 
    ;resc1@cnLevelSelectionMode    ="ExplicitLevels"
    ;resc1@cnLevels                =(/-10,-5,0,5,10,15,20,25,30,35/)
    
    ;resc1@cnFillColors            =(/49,26,2,146,161,170,177,181,191,192,600/)

    resc1@cnLevelSelectionMode    ="AutomaticLevels"
    ;resc1@cnMinLevelValF           =-10
    ;resc1@cnMaxLevelValF           =30
    ;resc1@cnLevelSpacingF          =2

  
    ;resc1@gsnLeftString           =""
    resc1@gsnRightString          =""


    resc1@mpGeophysicalLineColor      ="black"
    resc1@mpOutlineBoundarySets       ="National"
    resc1@mpGeophysicalLineDashPattern=0
    resc1@mpGeophysicalLineDashSegLenF=0.2
    resc1@mpGeophysicalLineThicknessF =0.5
    resc1@mpOutlineMaskingOn          =True
    resc1@mpOutlineOn                 =True


    ;resc1@mpGridAndLimbOn             =True
    ;esc1@mpGridLonSpacingF           =10
    ;resc1@mpGridLatSpacingF           =10
    ;resc1@mpGridLineThicknessF        =0.02
    ;resc1@mpGridLineDashPattern       =2

    ;地图边界
    resc1@mpGeophysicalLineColor      ="black"
    resc1@mpOutlineBoundarySets       ="National"
    resc1@mpGeophysicalLineDashPattern=0
    resc1@mpGeophysicalLineDashSegLenF=0.2
    resc1@mpGeophysicalLineThicknessF =0.5
    resc1@mpOutlineMaskingOn          =True
    resc1@mpOutlineOn                 =True
    resc1@mpGridLineDashPattern       =2



  


;base1=gsn_csm_contour_map(wks, t850avg(:,:), resc1)
;base1_MAM=gsn_csm_contour_map(wks, t850_MAM_avg(:,:), resc1)
;base1_JJA=gsn_csm_contour_map(wks, t850_JJA_avg(:,:), resc1)
;base1_SON=gsn_csm_contour_map(wks, t850_SON_avg(:,:), resc1)
;base1_DJF=gsn_csm_contour_map(wks, t850_DJF_avg(:,:), resc1)
    resv1                         =True

    resv1@gsnDraw                 =False
    resv1@gsnFrame                =False

    resv1@gsnLeftString                 =""
    resv1@gsnRightString                =""

    resv1@vcGlyphStyle                  ="CurlyVector"
    ;resv1@vcGlyphStyle                  ="FillArrow"
    resv1@vcFillArrowEdgeColor          ="black"
    resv1@vcFillArrowFillColor          ="black"

    resv1@vcMinMagnitudeF                =1.0
    resv1@vcMinDistanceF                 =0.03
 
    resv1@vcFillArrowEdgeThicknessF      =0.02
  
    resv1@vcFillArrowHeadInteriorXF      =0.075
    resv1@vcFillArrowHeadXF              =0.1
    resv1@vcFillArrowHeadYF              =0.05
    resv1@vcFillArrowWidthF              =0.025
    resv1@vcRefLengthF                   =0.045      ;单位长度箭头在图中的长度
    resv1@vcRefMagnitudeF                =10
    resv1@vcMinDistanceF                 =0.02 

    resv1@vcRefAnnoPerimOn               =False  ;关闭边框
    resv1@vcMinAnnoOn                    =True 

    resv1@vcRefAnnoOn                    =True
    resv1@vcRefAnnoBackgroundColor       ="white"
    resv1@vcRefAnnoFontHeightF           =0.015
    resv1@vcRefAnnoPerimOn               =False
    resv1@vcRefAnnoSide                  ="Top"
    resv1@vcRefAnnoString1On             =False
    resv1@vcRefAnnoString2On             =True
    resv1@vcRefAnnoString2               ="10m/s"


;plot1=gsn_csm_streamline(wks, u850avg(:,:), v850avg(:,:), resv1)
;plot1_MAM=gsn_csm_streamline(wks, u850_MAM_avg(:,:),v850_MAM_avg(:,:), resv1)
;plot1_JJA=gsn_csm_streamline(wks, u850_JJA_avg(:,:),v850_JJA_avg(:,:), resv1)
;plot1_SON=gsn_csm_streamline(wks,u850_SON_avg(:,:),v850_SON_avg(:,:), resv1)
;plot1_DJF=gsn_csm_streamline(wks, u850_DJF_avg(:,:),v850_DJF_avg(:,:), resv1)

 ;   overlay(base1,plot1)
  ;  draw(base1)
   ; frame(wks)
    ;overlay(base1_MAM, plot1_MAM)
    ;draw(base1_MAM)
    ;frame(wks)
    ;overlay(base1_JJA, plot1_JJA)
    ;;draw(base1_JJA)
    ;frame(wks)
    ;overlay(base1_SON, plot1_SON)
    ;draw(base1_SON)
    ;frame(wks)
    ;overlay(base1_DJF, plot1_DJF)
    ;draw(base1_DJF)
    ;frame(wks)
;************************************************************************
    res2                           =True
    res2@gsnDraw                   =False
    res2@gsnFrame                  =False
    res2@gsnLeftString             =""
    res2@gsnRightString            =""
    res2@cnFillOn                  =False
    res2@cnLinesOn                 =True
    res2@cnLevelSelectionMode      ="ExplicitLevels"
    res2@cnLevels                  =(/2000/)
    res2@cnLineThicknessF          =3.0
    res2@cnLineColor               ="black"
    res2@cnInfoLabelOn             =False
    res2@cnLineLabelBackgroundColor=-1
;**************************************************************************

        resc2                         =True

    resc2@gsnDraw                 =False
    resc2@gsnFrame                =False

    resc2@mpMaxLonF               =140
    resc2@mpMinLonF               =40
    resc2@mpMaxLatF               =60
    resc2@mpMinLatF               =0

    resc2@cnFillOn                =True
    resc2@cnLinesOn               =False
    ;resc2@cnLevelSelectionMode    ="ExplicitLevels"
    ;resc2@cnLevels                =(/-10,-5,0,5,10,15,20,25,30,35/)
    
    ;resc2@cnFillColors            =(/49,26,2,146,161,170,177,181,191,192,600/)

    resc2@cnLevelSelectionMode    ="AutomaticLevels"
    ;resc2@cnMinLevelValF           =-64
    ;resc2@cnMaxLevelValF           =-40
    ;resc2@cnLevelSpacingF          =1
  
    resc2@gsnLeftString           =""
    resc2@gsnRightString          =""
    ;resc2@gsnMaximize             =True


      resc2@mpGeophysicalLineColor      ="black"
  resc2@mpOutlineBoundarySets       ="National"
  resc2@mpGeophysicalLineDashPattern=0
  resc2@mpGeophysicalLineDashSegLenF=0.2
  resc2@mpGeophysicalLineThicknessF =0.5
  resc2@mpOutlineMaskingOn          =True
  resc2@mpOutlineOn                 =True

    resc2@mpGeophysicalLineColor      ="black"
    resc2@mpOutlineBoundarySets       ="National"
    resc2@mpGeophysicalLineDashPattern=0
    resc2@mpGeophysicalLineDashSegLenF=0.2
    resc2@mpGeophysicalLineThicknessF =0.5
    resc2@mpOutlineMaskingOn          =True
    resc2@mpOutlineOn                 =True


    ;resc2@mpGridAndLimbOn             =True
    ;resc2@mpGridLonSpacingF           =10
    ;resc2@mpGridLatSpacingF           =10
    ;resc2@mpGridLineThicknessF        =0.02
    ;resc2@mpGridLineDashPattern       =2

    
  


base0=gsn_csm_contour_map(wks, t600_mean(:,:), resc2)
base(0)=gsn_csm_contour_map(wks, t600_MAM_avg(:,:), resc2)
base(1)=gsn_csm_contour_map(wks, t600_JJA_avg(:,:), resc2)
base(2)=gsn_csm_contour_map(wks, t600_SON_avg(:,:), resc2)
base(3)=gsn_csm_contour_map(wks, t600_DJF_avg(:,:), resc2)
    resv2                         =True

    resv2@gsnDraw                 =False
    resv2@gsnFrame                =False

    ;resv2@gsnLeftString                 =""
    ;resv2@gsnRightString                =""

    resv2@vcGlyphStyle                  ="CurlyVector"
    ;resv2@vcGlyphStyle                  ="FillArrow"
    resv2@vcFillArrowEdgeColor          ="black"
    resv2@vcFillArrowFillColor          ="black"

    ;resv2@vcMinMagnitudeF                =1.0
    resv2@vcMinDistanceF                 =0.025
 
    resv2@vcFillArrowEdgeThicknessF      =0.02
  
    resv2@vcFillArrowHeadInteriorXF      =0.075
    resv2@vcFillArrowHeadXF              =0.1
    resv2@vcFillArrowHeadYF              =0.15
    resv2@vcFillArrowWidthF              =0.025
    resv2@vcRefLengthF                   =0.055      ;单位长度箭头在图中的长度
    resv2@vcRefMagnitudeF                =60
    ;resv2@vcMinDistanceF                 =0.02

    resv2@vcRefAnnoPerimOn              =False  ;关闭边框
    resv2@vcMinAnnoOn                   =False 

    resv2@vcRefAnnoOn                    =True
    resv2@vcRefAnnoBackgroundColor       ="white"
    resv2@vcRefAnnoFontHeightF           =0.015
    resv2@vcRefAnnoPerimOn               =False
    resv2@vcRefAnnoSide                  ="Top"
    resv2@vcRefAnnoString1On             =False
    resv2@vcRefAnnoString2On             =True
    resv2@vcRefAnnoString2               ="60m/s"

        resv4                         =True

    resv4@gsnDraw                 =False
    resv4@gsnFrame                =False

    resv4@gsnLeftString                 ="DJF:Monthly mean u wind"
    resv4@gsnRightString                =""

    resv4@vcGlyphStyle                  ="CurlyVector"
    ;resv4@vcGlyphStyle                  ="FillArrow"
    resv4@vcFillArrowEdgeColor          ="black"
    resv4@vcFillArrowFillColor          ="black"

    ;resv4@vcMinMagnitudeF                =1.0
    resv4@vcMinDistanceF                 =0.025
 
    resv4@vcFillArrowEdgeThicknessF      =0.02
  
    resv4@vcFillArrowHeadInteriorXF      =0.075
    resv4@vcFillArrowHeadXF              =0.1
    resv4@vcFillArrowHeadYF              =0.015
    resv4@vcFillArrowWidthF              =0.025
    resv4@vcRefLengthF                   =0.045      ;单位长度箭头在图中的长度
    resv4@vcRefMagnitudeF                =60 

    resv4@vcRefAnnoPerimOn              =False  ;关闭边框
    resv4@vcMinAnnoOn                   =False 

    resv4@vcRefAnnoOn                    =True
    resv4@vcRefAnnoBackgroundColor       ="white"
    resv4@vcRefAnnoFontHeightF           =0.015
    resv4@vcRefAnnoPerimOn               =False
    resv4@vcRefAnnoSide                  ="Top"
    resv4@vcRefAnnoString1On             =False
    resv4@vcRefAnnoString2On             =True
    resv4@vcRefAnnoString2               ="60m/s"

    res3                                 =True
    res3@stArrowLengthF                  =0.02
    res3@stArrowStride                   =3
    res3@stMinArrowSpacingF              =0.04
    res3@gsnDraw                         =False
    res3@gsnFrame                        =False
    ;ress@stLevelSpacingF                 =1.
    ;ress@stLineThicknessF                =0.5
    res3@stLineColor                     ="black"
    ;ress@stMinDistanceF                  =0.3
    ;ress@stMinLineSpacingF               =0.007

    ress                           =True
    ress@gsnDraw                 =False
    ress@gsnFrame                =False

    ress@gsnLeftString                 =""
    ress@gsnRightString                =""
    ;ress@stSpanLevelPalette            ="matlab_hot"
    ress@stLevelSpacingF               =1.0
    ress@stMonoLineColor               =True
    ress@stMinDistanceF                =0.1
    ress@stMinLineSpacingF             =0.007
    ress@stArrowLengthF                =0.01
    ress@stArrowStride                 =6
    ress@stMinArrowSpacingF            =0.01
    ress@stLineThicknessF              =2.5
    ress@stLineOpacityF                =0.7


    plot1=gsn_csm_contour(wks, hgt, res2)
    ploth2=gsn_csm_contour(wks, hgt, res2)
    plot3=gsn_csm_contour(wks, hgt, res2)
    plot4=gsn_csm_contour(wks, hgt, res2)
    plot5=gsn_csm_contour(wks, hgt, res2)
plot2=gsn_csm_streamline(wks, u600_mean(:,:), v600_mean(:,:), ress)
plot2_MAM=gsn_csm_streamline(wks, u600_MAM_avg(:,:),v600_MAM_avg(:,:), ress)
plot2_JJA=gsn_csm_streamline(wks, u600_JJA_avg(:,:),v600_JJA_avg(:,:), ress)
plot2_SON=gsn_csm_streamline(wks, u600_SON_avg(:,:),v600_SON_avg(:,:), ress)
plot2_DJF=gsn_csm_streamline(wks, u600_DJF_avg(:,:),v600_DJF_avg(:,:), ress)
;plot2_MAM_SR=gsn_csm_streamline(wks, u600_MAM_avg, v600_MAM_avg, res3)
;plot2_JJA_SR=gsn_csm_streamline(wks, u600_JJA_avg, v600_JJA_avg, res3)
;plot2_SON_SR=gsn_csm_streamline(wks, u600_SON_avg, v600_SON_avg, res3)
;plot2_DJF_SR=gsn_csm_streamline(wks, u600_DJF_avg, v600_DJF_avg, res3)

    overlay(base0,plot2)
    overlay(base0,plot1)
    draw(base0)
    frame(wks)
    overlay(base(0), plot2_MAM)
    ;draw(base(0))
    ;frame(wks)
    overlay(base(0), ploth2)
    ;draw(base(0))
    ;frame(wks)
    ;************************************
    overlay(base(1), plot2_JJA)
    ;draw(base(1))
    ;frame(wks)
    overlay(base(1), plot5)
    ;draw(base(1))
    ;frame(wks)
    ;***************************
    overlay(base(2), plot2_SON)
    ;draw(base(2))
    ;frame(wks)
    overlay(base(2), plot3)
    ;draw(base(2))
    ;frame(wks)
    overlay(base(3), plot2_DJF)
    ;draw(base(3))
    ;frame(wks)
    overlay(base(3), plot4)
    ;draw(base(3))
    ;frame(wks)
    ;overlay(base2_MAM, plot2_MAM_SR)
    ;draw(base2_MAM)
    ;frame(wks)
    ;overlay(base2_JJA, plot2_JJA_SR)
    ;draw(base2_JJA)
    ;frame(wks)
    ;overlay(base2_SON, plot2_SON_SR)
    ;draw(base2_SON)
   ; frame(wks)
    ;overlay(base2_DJF, plot2_DJF_SR)
    ;draw(base2_DJF)
    ;frame(wks)
    resp                          =True
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
    ;resp@gsnCenterString          ="GPCP_season"
    ;resp@gsnMaximize              =True
    resp@txString                 ="Temp 600hPa"
    resp@gsnPanelLabelBar         =False
    resp@gsnPanelFigureStringsPerimOn=False
    gsn_panel(wks, base, (/2,2/), resp)
print("All Down")

end