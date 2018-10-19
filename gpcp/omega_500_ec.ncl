;omega_500_ec.ncl
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

    f_w                      =addfile("/mnt/f/data/ERA-interim/monthly/wwnd.mon.mean.nc", "r")
    f_w_djf                  =addfile("/mnt/f/data/ERA-interim/monthly/wwnd.DJF.mean.nc", "r")
    f_h                      =addfile("/mnt/f/data/ERA-interim/monthly/hgt.mon.mean.nc", "r")
    f_h_djf                  =addfile("/mnt/f/data/ERA-interim/monthly/hgt.DJF.mean.nc", "r")
    w500                     =short2flt(f_w->w(0:359,{500},:,:))
    w500_DJF                 =short2flt(f_w_djf->w(0:89,{500},:,:))
    ;h                        =short2flt(f_h->z(0:359,{,:,:))
    ;h_DJF                    =short2flt(f_h_djf->z(0:89,:,:,:))
    f_h                      =addfile("/mnt/f/data/NCEP/hgt.sfc.nc", "r")
    hgt                      =short2flt(f_h->hgt(0,:,:))
    w500_MAM                 =month_to_season(w500, "MAM")
    w500_JJA                 =month_to_season(w500, "JJA")
    w500_SON                 =month_to_season(w500, "SON")
    ;h_MAM                    =month_to_season(h, "MAM")
    ;h_JJA                    =month_to_season(h, "JJA")
    ;h_SON                    =month_to_season(h, "SON")
    w500_MAM_avg             =dim_avg_n_Wrap(w500_MAM, 0)
    w500_JJA_avg             =dim_avg_n_Wrap(w500_JJA, 0)
    w500_SON_avg             =dim_avg_n_Wrap(w500_SON, 0)
    w500_DJF_avg             =dim_avg_n_Wrap(w500_DJF, 0)
    w500_mean                =dim_avg_n_Wrap(w500, 0)
    ;h_MAM_avg                =dim_avg_n_Wrap(h_MAM, 0)
    ;h_JJA_avg                =dim_avg_n_Wrap(h_JJA, 0)
    ;h_SON_avg                =dim_avg_n_Wrap(h_SON, 0)
    ;h_DJF_avg                =dim_avg_n_Wrap(h_DJF, 0)
    ;h_mean                   =dim_avg_n_Wrap(h, 0)

base                          =new(4,graphic)
    wks=gsn_open_wks("pdf", "/mnt/f/pdf/w500.pdf")
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
    res@mpMinLatF                 =-20
    res@mpMinLonF                 =40
    res@mpMaxLonF                 =140

    res@mpGeophysicalLineColor      ="black"
    res@mpOutlineBoundarySets       ="National"
    res@mpGeophysicalLineDashPattern=0
    res@mpGeophysicalLineDashSegLenF=0.2
    res@mpGeophysicalLineThicknessF =0.5
    res@mpOutlineMaskingOn          =True
    res@mpOutlineOn                 =True
    res@mpGridLineDashPattern       =2

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
    res3@mpMinLatF                 =-20
    res3@mpMinLonF                 =40
    res3@mpMaxLonF                 =140
    res3@gsnLeftString            ="DJF:Monthly Mean of Omega"
    res3@mpGeophysicalLineColor      ="black"
    res3@mpOutlineBoundarySets       ="National"
    res3@mpGeophysicalLineDashPattern=0
    res3@mpGeophysicalLineDashSegLenF=0.2
    res3@mpGeophysicalLineThicknessF =0.5
    res3@mpOutlineMaskingOn          =True
    res3@mpOutlineOn                 =True
    res3@mpGridLineDashPattern       =2



    base(0)=gsn_csm_contour_map(wks, w500_MAM_avg, res)
    base(1)=gsn_csm_contour_map(wks, w500_JJA_avg, res)
    base(2)=gsn_csm_contour_map(wks, w500_SON_avg, res)
    base(3)=gsn_csm_contour_map(wks, w500_DJF_avg, res3)
    base5=gsn_csm_contour_map(wks, w500_mean, res)

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
    res2@cnLineLabelBackgroundColor=-1

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
    ;resp@gsnMaximize              =True
    resp@txString                 ="Omega 500hPa"
    resp@gsnPanelLabelBar         =False
    resp@gsnPanelFigureStringsPerimOn=False
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
    overlay(base5, plot5)
    draw(base5)
    frame(wks)
    gsn_panel(wks, base, (/2,2/), resp)
end


 
