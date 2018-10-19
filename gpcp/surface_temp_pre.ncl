;surface_temp_pre.ncl
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

    ft                           =addfile("/mnt/f/data/ERA-interim/monthly/2_metre_temperature.mon.mean.nc", "r")
    fh                           =addfile("/mnt/f/data/NCEP/hgt.sfc.nc", "r")
    ft_djf                       =addfile("/mnt/f/data/ERA-interim/monthly/2_metre_temperature.DJF.mean.nc", "r")
    

    T                            =short2flt(ft->t2m(0:359,:,:))
    T_DJF                        =short2flt(ft_djf->t2m(0:89,:,:))
    h                            =short2flt(fh->hgt(0,:,:))

    t                            =T-273.15
    copy_VarCoords(T, t)
    t_DJF                        =T_DJF-273.15
    copy_VarCoords(T_DJF, t_DJF)
    t@units                      ="degC"
    t_DJF@units                  ="degC"
    printVarSummary(t)
    printVarSummary(t_DJF)
    t_MAM                        =month_to_season(t, "MAM")
    t_JJA                        =month_to_season(t, "JJA")
    t_SON                        =month_to_season(t, "SON")
    
    t_MAM_avg                    =dim_avg_n_Wrap(t_MAM, 0)
    t_JJA_avg                    =dim_avg_n_Wrap(t_JJA, 0)
    t_SON_avg                    =dim_avg_n_Wrap(t_SON, 0)
    t_DJF_avg                    =dim_avg_n_Wrap(t_DJF, 0)
    t_mean                       =dim_avg_n_Wrap(t, 0)
    
    printVarSummary(t)
    printVarSummary(h)
    fp                           =addfile("/mnt/f/data/ERA-interim/monthly/Surface_pressure.mon.mean.nc", "r")
    fh                           =addfile("/mnt/f/data/NCEP/hgt.sfc.nc", "r")
    fp_djf                       =addfile("/mnt/f/data/ERA-interim/monthly/Surface_pressure.DJF.mean.nc", "r")

    p                            =short2flt(fp->sp(0:359,:,:))
    h                            =short2flt(fh->hgt(0,:,:))
    p_DJF                        =short2flt(fp_djf->sp(0:89,:,:))
    ph                           =p/100
    copy_VarCoords(p, ph)
    ph@units                     ="hPa"
    ph_DJF                       =p_DJF/100
    copy_VarCoords(p_DJF, ph_DJF)
    ph_DJF@units                 ="hPa"


    printVarSummary(ph)
    
    ph_MAM                        =month_to_season(ph, "MAM")
    ph_JJA                        =month_to_season(ph, "JJA")
    ph_SON                        =month_to_season(ph, "SON")
    ph_MAM_avg                    =dim_avg_n_Wrap(ph_MAM, 0)
    ph_JJA_avg                    =dim_avg_n_Wrap(ph_JJA, 0)
    ph_SON_avg                    =dim_avg_n_Wrap(ph_SON, 0)
    ph_DJF_avg                    =dim_avg_n_Wrap(ph_DJF, 0)
    ph_mean                       =dim_avg_n_Wrap(ph, 0)
    p_MAM                        =month_to_season(p, "MAM")
    p_MAM_avg                    =dim_avg_n_Wrap(p_MAM, 0)

    base                         =new(4, graphic)
    plot                         =new(4, graphic)
wks=gsn_open_wks("pdf", "/mnt/f/pdf/surface_temp_pre")
gsn_define_colormap(wks, "NCV_blue_red")
    rest                         =True

    rest@gsnDraw                 =False
    rest@gsnFrame                =False
    ;rest@gsnMaximize             =True

    rest@mpMaxLonF               =140
    rest@mpMinLonF               =40
    rest@mpMaxLatF               =60
    rest@mpMinLatF               =-10

    rest@cnFillOn                =True
    rest@cnLinesOn               =False

    rest@gsnTickMarksOn          =False 

    rest@cnLevelSelectionMode    ="ManualLevels"
    rest@cnMinLevelValF           =-10
    rest@cnMaxLevelValF           =30
    rest@cnLevelSpacingF          =2

  
    ;rest@gsnLeftString           =""
    rest@gsnRightString          =""

    ;地图边界
    rest@mpGeophysicalLineColor      ="black"
    rest@mpOutlineBoundarySets       ="National"
    rest@mpGeophysicalLineDashPattern=0
    rest@mpGeophysicalLineDashSegLenF=0.2
    rest@mpGeophysicalLineThicknessF =0.5
    rest@mpOutlineMaskingOn          =True
    rest@mpOutlineOn                 =True
    rest@mpGridLineDashPattern       =2

    base(0)=gsn_csm_contour_map(wks, t_MAM_avg, rest)
    base(1)=gsn_csm_contour_map(wks, t_JJA_avg, rest)
    base(2)=gsn_csm_contour_map(wks, t_SON_avg, rest)
    base(3)=gsn_csm_contour_map(wks, t_DJF_avg, rest)
    baset=gsn_csm_contour_map(wks, t_mean, rest)
    

    
    resp                             =True
    resp@gsnDraw                     =False
    resp@gsnFrame                    =False
    
    resp@cnFillOn                    =False
    resp@cnLinesOn                   =True
    resp@cnLevelSelectionMode        ="ManualLevels"
    resp@cnInfoLabelOn              =True
    resp@cnHighLabelsOn            =True
    resp@cnHighLabelBackgroundColor=-1
    resp@cnHighLabelPerimOn        =False
    resp@cnHighLabelFontHeightF    =0.024
    resp@cnLowLabelsOn             =True
    resp@cnLowLabelBackgroundColor =-1
    resp@cnLowLabelPerimOn         =False
    resp@cnLowLabelFontHeightF     =0.024
    resp@cnLineLabelPerimOn        =False

    resp@cnLineLabelDensityF       =1.0
    resp@cnLineLabelBackgroundColor=-1
    ;等值线颜色
    resp@cnLineThicknessF             =2.0
    resp@cnMonoLineColor              =False
    resp@cnLinePalette                ="MPL_summer"


    ;resp@mpMaxLonF               =140
    ;resp@mpMinLonF               =40
    ;resp@mpMaxLatF               =60
    ;resp@mpMinLatF               =0

    ;resp@mpGeophysicalLineColor      ="black"
    ;resp@mpOutlineBoundarySets       ="National"
    ;resp@mpGeophysicalLineDashPattern=0
    ;resp@mpGeophysicalLineDashSegLenF=0.2
    ;resp@mpGeophysicalLineThicknessF =0.5
    ;resp@mpOutlineMaskingOn          =True
    ;resp@mpOutlineOn                 =True
    ;resp@mpGridLineDashPattern       =2

    plot(0)=gsn_csm_contour(wks, ph_MAM_avg, resp)
    plot(1)=gsn_csm_contour(wks, ph_JJA_avg, resp)
    plot(2)=gsn_csm_contour(wks, ph_SON_avg, resp)
    plot(3)=gsn_csm_contour(wks, ph_DJF_avg, resp)
    plotp=gsn_csm_contour(wks, ph_mean, resp)

    
    resh                           =True
    resh@gsnDraw                   =False
    resh@gsnFrame                  =False
    resh@gsnLeftString             =""
    resh@gsnRightString            =""
    resh@cnFillOn                  =False
    resh@cnLinesOn                 =True
    resh@cnLevelSelectionMode      ="ExplicitLevels"
    resh@cnLevels                  =(/2000/)
    resh@cnLineThicknessF          =3.0
    resh@cnLineColor               ="black"
    resh@cnInfoLabelOn             =False
    



    plot1=gsn_csm_contour(wks, h, resh)
    plot2=gsn_csm_contour(wks, h, resh)
    plot3=gsn_csm_contour(wks, h, resh)
    plot4=gsn_csm_contour(wks, h, resh)
    plot5=gsn_csm_contour(wks, h, resh)

overlay(base(0), plot(0))
;draw(base(0))
;frame(wks)
overlay(base(0), plot1)
;draw(base(0))
;frame(wks)

overlay(base(1), plot(1))
;draw(base(1))
;frame(wks)
overlay(base(1), plot2)
;draw(base(1))
;frame(wks)

overlay(base(2), plot(2))
;draw(base(2))
;frame(wks)
overlay(base(2), plot3)
;draw(base(2))
;frame(wks)

overlay(base(3), plot(3))
;draw(base(3))
;frame(wks)
overlay(base(3), plot4)
;draw(base(3))
;frame(wks)

overlay(baset, plotp)
;draw(baset)
;frame(wks)
overlay(baset, plot5)
draw(baset)
frame(wks)
    respa                          =True
    respa@gsnPanelCenter           =True ;排列时居中对齐每行图
    respa@gsnPanelDebug            =True ;在图形中显示图形的坐标等信息
    respa@gsnPanelFigureStrings    =(/"(a)","(b)","(c)","(d)"/) ;为每幅图添加标号
    respa@gsnPanelFigureStringsBackgroundFillColor="white"
    respa@gsnPanelFigureStringsFontHeightF =0.01
    respa@amJust                   ="TopLeft"
    respa@gsnPanelFigureStringsPerimOn     =True ;序号加边框
    respa@gsnPanelLabelBar         =True ;多图公用一个色标
    respa@gsnLeftString            =""
    respa@gsnRightString           =""
    ;respa@gsnCenterString          ="GPCP_season"
    ;respa@gsnMaximize              =True
    respa@txString                 ="Sueface_temperature_pressure"
    respa@gsnPanelLabelBar         =False
    respa@gsnPanelFigureStringsPerimOn=False
    gsn_panel(wks, base, (/2,2/), respa)
print("All Down")
end