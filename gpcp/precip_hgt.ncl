;四季+年均降水
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin 
    
    f                        =addfile("/mnt/f/data/NCEP/precip.mon.mean.nc", "r")
    prc                      =f->precip(0:359,:,:)
    ;f_pd                     =addfile("/mnt/f/data/precip.1212.mean.nc", "")
    f_h                      =addfile("/mnt/f/data/NCEP/hgt.sfc.nc", "r")
    hgt                      =short2flt(f_h->hgt(0,:,:))
    f_d                      =addfile("/mnt/f/data/NCEP/precip.1212.mean.nc", "r")
    f_ud                     =addfile("/mnt/f/data/NCEP/uwnd.DJF.mean.nc", "r")
    f_vd                     =addfile("/mnt/f/data/NCEP/vwnd.DJF.mean.nc", "r")
    base                     =new(6, graphic)
    f_u                      =addfile("/mnt/f/data/NCEP/uwnd.mon.mean.nc", "r")
    f_v                      =addfile("/mnt/f/data/NCEP/vwnd.mon.mean.nc", "r")
    u850                     =f_u->uwnd(ispan(372,731,1),{850},:,:)
    v850                     =f_v->vwnd(ispan(372,731,1),{850},:,:)

    dims                     =dimsizes(prc)
    mlat                     =dims(1)
    nlon                     =dims(2)
    prc_MAM                  =month_to_season(prc, "MAM")
    prc_JJA                  =month_to_season(prc, "JJA")
    prc_SON                  =month_to_season(prc, "SON")
    prc_DJF                  =f_d->precip(2:91,:,:)

    

    prc_annaul_mean          =dim_avg_n_Wrap(prc, 0)
    prc_MAM_avg              =dim_avg_n_Wrap(prc_MAM, 0)
    prc_JJA_avg              =dim_avg_n_Wrap(prc_JJA, 0)
    prc_SON_avg              =dim_avg_n_Wrap(prc_SON, 0)
    prc_DJF_avg              =dim_avg_n_Wrap(prc_DJF, 0)
  
    u850avg                       =dim_avg_n_Wrap(u850, 0)
    v850avg                       =dim_avg_n_Wrap(v850, 0)
    u850_MAM                      =month_to_season(u850, "MAM")
    u850_JJA                      =month_to_season(u850, "JJA")
    u850_SON                      =month_to_season(u850, "SON")
    u850_DJF                      =f_ud->uwnd(ispan(95, 184, 1),{850},:,:)
    v850_MAM                      =month_to_season(v850, "MAM")
    v850_JJA                      =month_to_season(v850, "JJA")
    v850_SON                      =month_to_season(v850, "SON")
    v850_DJF                      =f_vd->vwnd(ispan(95, 184, 1),{850},:,:)
    u850_MAM_avg                  =dim_avg_n_Wrap(u850_MAM, 0)
    u850_JJA_avg                  =dim_avg_n_Wrap(u850_JJA, 0)
    u850_SON_avg                  =dim_avg_n_Wrap(u850_SON, 0)
    u850_DJF_avg                  =dim_avg_n_Wrap(u850_DJF, 0)
    v850_MAM_avg                  =dim_avg_n_Wrap(v850_MAM, 0)
    v850_JJA_avg                  =dim_avg_n_Wrap(v850_JJA, 0)
    v850_SON_avg                  =dim_avg_n_Wrap(v850_SON, 0)
    v850_DJF_avg                  =dim_avg_n_Wrap(v850_DJF, 0)


    wks                      =gsn_open_wks("png", "/mnt/f/png/precip_hgt4")
    gsn_define_colormap(wks, "wh-bl-gr-ye-re")

    res                      =True
    res@cnFillOn             =True
    res@cnLinesOn            =False
    res@cnLevelSelectionMode ="AutomaticLevels"

    res@gsnDraw              =False
    res@gsnFrame             =False
    res@mpMaxLonF            =140
    res@mpMinLonF            =40
    res@mpMaxLatF            =60
    res@mpMinLatF            =-10
    res@pmTickMarkDisplayMode       ="Always"




  
    res@mpFillOn                    =False
    res@mpGridAndLimbOn             =True
    res@mpGridLineThicknessF        =0.5
    res@mpGridLineDashPattern       =2
    res@mpGridSpacingF              =10

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
    resdjf                      =True
    resdjf@cnFillOn             =True
    resdjf@cnLinesOn            =False
    resdjf@cnLevelSelectionMode ="AutomaticLevels"

    resdjf@gsnDraw              =False
    resdjf@gsnFrame             =False
    resdjf@mpMaxLonF            =140
    resdjf@mpMinLonF            =40
    resdjf@mpMaxLatF            =60
    resdjf@mpMinLatF            =-10
    resdjf@pmTickMarkDisplayMode       ="Always"
    resdjf@cnFillOn             =True
    resdjf@cnLinesOn            =False
    resdjf@cnLevelSelectionMode ="AutomaticLevels"

    resdjf@gsnDraw              =False
    resdjf@gsnFrame             =False
    resdjf@mpMaxLonF            =140
    resdjf@mpMinLonF            =40
    resdjf@mpMaxLatF            =60
    resdjf@mpMinLatF            =-10
    resdjf@pmTickMarkDisplayMode       ="Always"




    resdjf                             =True  
    resdjf@mpFillOn                    =False
    resdjf@mpGridAndLimbOn             =True
    resdjf@mpGridLineThicknessF        =0.5
    resdjf@mpGridLineDashPattern       =2
    resdjf@mpGridSpacingF              =10

    resdjf@lbLabelBarOn                =True
    resdjf@lbOrientation               ="Horizontal"

    resdjf@lbBoxLinesOn                =False
    resdjf@lbBoxLineColor              ="black"
    resdjf@lbBoxLineThicknessF         =1.5
    resdjf@lbBoxLineDashPattern        =16

    resdjf@lbLabelOffsetF              =0.1
    resdjf@lbLabelFontHeightF          =0.01
    resdjf@lbLabelFontColor            ="black"
    resdjf@lbLabelFontThicknessF       =1.5

    resdjf@pmLabelBarParallelPosF      =0.5

    resdjf@pmLabelBarWidthF            =0.45
    resdjf@pmLabelBarHeightF           =0.15
    resdjf@gsnLeftString               ="DJF:Average Monthly Rate of Precipitation"

    
    res@gsnRightString              =""
    base(0)=gsn_csm_contour_map(wks, prc_MAM_avg, res)
    base(1)=gsn_csm_contour_map(wks, prc_JJA_avg, res)
    base(2)=gsn_csm_contour_map(wks, prc_SON_avg, res)
    base(3)=gsn_csm_contour_map(wks, prc_DJF_avg, resdjf)
    base(4)=gsn_csm_contour_map(wks, prc_annaul_mean, res)
    ;base6=gsn_csm_contour_map(wks, prc_DJF1_avg, res)

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
    res2@cnLineColor               ="red"
    res2@cnInfoLabelOn             =False

    resv1                         =True

    resv1@gsnDraw                 =False
    resv1@gsnFrame                =False

    resv1@gsnLeftString                 =""
    resv1@gsnRightString                =""

    ;resv1@vcGlyphStyle                  ="CurlyVector"
    resv1@vcGlyphStyle                  ="FillArrow"
    resv1@vcFillArrowEdgeColor          ="black"
    resv1@vcFillArrowFillColor          ="black"

    resv1@vcMinMagnitudeF                =1.0
    resv1@vcMinDistanceF                 =0.03
 
    resv1@vcFillArrowEdgeThicknessF      =0.02
  
    resv1@vcFillArrowHeadInteriorXF      =0.05
    resv1@vcFillArrowHeadXF              =0.075
    resv1@vcFillArrowHeadYF              =0.075
    resv1@vcFillArrowWidthF              =0.025
    resv1@vcRefLengthF                   =0.045      ;单位长度箭头在图中的长度
    resv1@vcRefMagnitudeF                =10 

     ;关闭边框
    resv1@vcMinAnnoOn                    =False 

    resv1@vcRefAnnoOn                    =True
    resv1@vcRefAnnoBackgroundColor       ="white"
    resv1@vcRefAnnoPerimOn               =True 
    resv1@vcRefAnnoFontHeightF           =0.015
    resv1@vcRefAnnoPerimOn               =False
    resv1@vcRefAnnoSide                  ="Top"
    resv1@vcRefAnnoString1On             =False
    resv1@vcRefAnnoString2On             =True
    resv1@vcRefAnnoString2               ="10m/s"
    resv1@vcRefAnnoOrthogonalPosF        =-0.1


plot_annual=gsn_csm_vector(wks, u850avg(:,:), v850avg(:,:), resv1)
plot_MAM=gsn_csm_vector(wks, u850_MAM_avg(:,:),v850_MAM_avg(:,:), resv1)
plot_JJA=gsn_csm_vector(wks, u850_JJA_avg(:,:),v850_JJA_avg(:,:), resv1)
plot_SON=gsn_csm_vector(wks,u850_SON_avg(:,:),v850_SON_avg(:,:), resv1)
plot_DJF=gsn_csm_vector(wks, u850_DJF_avg(:,:),v850_DJF_avg(:,:), resv1)



    plot1=gsn_csm_contour(wks, hgt, res2)
    plot2=gsn_csm_contour(wks, hgt, res2)
    plot3=gsn_csm_contour(wks, hgt, res2)
    plot4=gsn_csm_contour(wks, hgt, res2)
    plot5=gsn_csm_contour(wks, hgt, res2)
    ;plot6=gsn_csm_contour(wks, hgt, res2)

    overlay(base(0), plot1)
    overlay(base(0),plot_MAM)
    draw(base(0))
    frame(wks)
    overlay(base(1), plot2)
    overlay(base(1),plot_JJA)
    draw(base(1))
    frame(wks)
    overlay(base(2), plot3)
    overlay(base(2),plot_SON)
    draw(base(2))
    frame(wks)
    overlay(base(3), plot4)
    overlay(base(3),plot_DJF)
    draw(base(3))
    frame(wks)
    overlay(base(4), plot5)
    overlay(base(4),plot_annual)
    draw(base(4))
    frame(wks)
    ;overlay(base6, plot6)
    ;draw(base6)
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
    resp@gsnMaximize              =True
    resp@txString                 ="Seasons"
    resp@gsnPanelLabelBar         =False
    resp@gsnPanelFigureStringsPerimOn=False
    gsn_panel(wks, base, (/3,2/), resp)

end
