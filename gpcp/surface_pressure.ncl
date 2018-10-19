;surface_presuse.ncl
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

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

    base                         =new(4, graphic)
wks=gsn_open_wks("pdf", "/mnt/f/pdf/surface_pressure")
gsn_define_colormap(wks, "MPL_rainbow")

    resp                             =True
    resp@gsnDraw                     =False
    resp@gsnFrame                    =False
    
    resp@cnFillOn                    =True
    resp@cnLinesOn                   =False
    resp@cnLevelSelectionMode        ="ExplicitLevels"
    ;resp@cnLevels                     =(/500,510,520,530,540,550,600,650,700,750,800,850,900,940,960,980,1000,1020,1040/)
    resp@cnLevels                    =(/500,520,530,540,550,560,570,580,600,650,700,750,800,850,900,920,940,960,980,982,984,986,988,990,991,992,993,994,995,996,997,998,999,1000,1001,1002,1003,1004,1005,1006,1007,1008,1009,1010,1012,1014,1016,1018,1020,1040,1050,1100/)
    resp@cnInfoLabelOn              =True
    resp@cnHighLabelsOn            =True
    resp@cnHighLabelBackgroundColor=-1
    resp@cnHighLabelPerimOn        =False
    resp@cnHighLabelFontHeightF    =0.024
    resp@cnLowLabelsOn             =True
    resp@cnLowLabelBackgroundColor =-1
    resp@cnLowLabelPerimOn         =False
    resp@cnLowLabelFontHeightF     =0.024
    ;resp@cnLineLabelPerimOn        =True
    resp@cnLineLabelsOn            =True
    resp@cnLineLabelBackgroundColor=-1
    resp@cnLineLabelDensityF       =0.5
    ;等值线颜色
    resp@cnLineThicknessF             =2.0
    resp@cnMonoLineColor              =False
    resp@cnLinePalette                ="MPL_winter"


    resp@mpMaxLonF               =140
    resp@mpMinLonF               =40
    resp@mpMaxLatF               =60
    resp@mpMinLatF               =0

    resp@mpGeophysicalLineColor      ="black"
    resp@mpOutlineBoundarySets       ="National"
    resp@mpGeophysicalLineDashPattern=0
    resp@mpGeophysicalLineDashSegLenF=0.2
    resp@mpGeophysicalLineThicknessF =0.5
    resp@mpOutlineMaskingOn          =True
    resp@mpOutlineOn                 =True
    resp@mpGridLineDashPattern       =2

    base(0)=gsn_csm_contour_map(wks, ph_MAM_avg, resp)
    base(1)=gsn_csm_contour_map(wks, ph_JJA_avg, resp)
    base(2)=gsn_csm_contour_map(wks, ph_SON_avg, resp)
    base(3)=gsn_csm_contour_map(wks, ph_DJF_avg, resp)
    plot=gsn_csm_contour_map(wks, ph_mean, resp)

    
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
    resh@cnLineLabelBackgroundColor=-1
    



    plot1=gsn_csm_contour(wks, h, resh)
    plot2=gsn_csm_contour(wks, h, resh)
    plot3=gsn_csm_contour(wks, h, resh)
    plot4=gsn_csm_contour(wks, h, resh)
    plot5=gsn_csm_contour(wks, h, resh)

overlay(base(0), plot1)
;draw(base(0))
;frame(wks)

overlay(base(1), plot2)
;draw(base(1))
;frame(wks)

overlay(base(2), plot3)
;draw(base(2))
;frame(wks)

overlay(base(3), plot4)
;draw(base(3))
;frame(wks)

overlay(plot, plot5)
draw(plot)
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
    respa@txString                 ="Surface pressure"
    respa@gsnPanelLabelBar         =False
    respa@gsnPanelFigureStringsPerimOn=False
    gsn_panel(wks, base, (/2,2/), respa)
print("All Down")

end
