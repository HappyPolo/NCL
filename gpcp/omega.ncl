load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin 
    f_o                      =addfile("/mnt/f/data/NCEP/omega.mon.mean.nc", "r")
    f_od                     =addfile("/mnt/f/data/NCEP/omega.DJF.mean.nc", "r")
    f_h                      =addfile("/mnt/f/data/NCEP/hgt.sfc.nc", "r")
    hgt                      =short2flt(f_h->hgt(0,:,:))
    o500                     =f_o->omega(ispan(372,731,1),{500},:,:)
    o500_MAM                      =month_to_season(o500, "MAM")
    o500_JJA                      =month_to_season(o500, "JJA")
    o500_SON                      =month_to_season(o500, "SON")
    o500_DJF                      =f_od->omega(ispan(95, 184, 1),{500},:,:)
    o500_MAM_avg                  =dim_avg_n_Wrap(o500_MAM, 0)
    o500_JJA_avg                  =dim_avg_n_Wrap(o500_JJA, 0)
    o500_SON_avg                  =dim_avg_n_Wrap(o500_SON, 0)
    o500_DJF_avg                  =dim_avg_n_Wrap(o500_DJF, 0)
    o500_mean                     =dim_avg_n_Wrap(o500, 0)
    base                          =new(4,graphic)
       wks                      =gsn_open_wks("x11", "/mnt/f/png/omega_500")
    gsn_define_colormap(wks, "NCV_blue_red")

    res                           =True
    res@gsnDraw                   =False
    res@gsnFrame                  =False
    res@cnLinesOn                 =False
    res@cnFillOn                  =True
    res@cnLevelSelectionMode      ="ManualLevels"
    res@cnMaxLevelValF            =0.12
    res@cnMinLevelValF            =-0.1
    res@cnLevelSpacingF           =0.01
    res@mpMaxLatF                 =60
    res@mpMinLatF                 =10
    res@mpMinLonF                 =60
    res@mpMaxLonF                 =120

        res3                           =True
    res3@gsnDraw                   =False
    res3@gsnFrame                  =False
    res3@cnLinesOn                 =False
    res3@cnFillOn                  =True
    res3@cnLevelSelectionMode      ="ManualLevels"
    res3@cnMaxLevelValF            =0.12
    res3@cnMinLevelValF            =-0.1
    res3@cnLevelSpacingF           =0.01
    res3@mpMaxLatF                 =60
    res3@mpMinLatF                 =10
    res3@mpMinLonF                 =60
    res3@mpMaxLonF                 =120
    res3@gsnLeftString            ="DJF:Monthly Mean of Omega"


    base(0)=gsn_csm_contour_map(wks, o500_MAM_avg, res)
    base(1)=gsn_csm_contour_map(wks, o500_JJA_avg, res)
    base(2)=gsn_csm_contour_map(wks, o500_SON_avg, res)
    base(3)=gsn_csm_contour_map(wks, o500_DJF_avg, res3)
    base5=gsn_csm_contour_map(wks, o500_mean, res)

    res2                           =True
    res2@gsnDraw                   =False
    res2@gsnFrame                  =False
    res2@gsnLeftString             =""
    res2@gsnRightString            =""
    res2@cnFillOn                  =False
    res2@cnLinesOn                 =True
    res2@cnLevelSelectionMode      ="ExplicitLevels"
    res2@cnLevels                  =(/2000/)
    res2@cnLineThicknessF          =2.5
    res2@cnLineColor               ="black"
    res2@cnInfoLabelOn             =False

    plot1=gsn_csm_contour(wks, hgt, res2)
    plot2=gsn_csm_contour(wks, hgt, res2)
    plot3=gsn_csm_contour(wks, hgt, res2)
    plot4=gsn_csm_contour(wks, hgt, res2)
    plot5=gsn_csm_contour(wks, hgt, res2)

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
    resp@gsnMaximize              =True
    resp@txString                 ="Omega 500hPa"
    resp@gsnPanelLabelBar         =False
    resp@gsnPanelFigureStringsPerimOn=False

    overlay(base(0), plot1)
    draw(base(0))
    frame(wks)
    overlay(base(1), plot2)
    draw(base(1))
    frame(wks)
    overlay(base(2), plot3)
    draw(base(2))
    frame(wks)
    overlay(base(3), plot4)
    draw(base(3))
    frame(wks)
    overlay(base5, plot5)
    draw(base5)
    frame(wks)
    gsn_panel(wks, base, (/2,2/), resp)
end


 
