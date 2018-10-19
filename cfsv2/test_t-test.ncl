load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

    
    f1=addfile("/mnt/f/data/ERA-interim/monthly/precip.mon.mean.nc", "r")
    fed=addfile("/mnt/f/data/ERA-interim/monthly/precip.DJF.mean.nc", "r")
    fu1=addfile("/mnt/f/data/ERA-interim/monthly/uwnd.mon.mean.nc", "r")
    fv1=addfile("/mnt/f/data/ERA-interim/monthly/vwnd.mon.mean.nc", "r")
    fh=addfile("/mnt/f/data/NCEP/hgt.sfc.nc", "r")

    pe=f1->r(48:383,:,:)
    pe_DJF=fed->r(:,:,:)
    ue=short2flt(fu1->u(48:383,{850},:,:))
    ve=short2flt(fv1->v(48:383,{850},:,:))
    hgt=short2flt(fh->hgt(0,:,:))

    f2=addfile("/mnt/f/data/CFSV2_output/pre/pre.em24.out.nc", "r")
    fcd=addfile("/mnt/f/data/CFSV2_output/pre/pre.em24.DJF.out.nc", "r")
    fu2=addfile("/mnt/f/data/CFSV2_output/u850/u850.em24.out.nc", "r")
    fv2=addfile("/mnt/f/data/CFSV2_output/v850/v850.em24.out.nc", "r")

wks=gsn_open_wks("x11", "/mnt/f/pdf/prc_differ_test2")
gsn_define_colormap(wks, "NCV_blue_red")
plot_JJA=new(4, graphic)
plot_DJF=new(4, graphic)
base_DJF=new(4, graphic)
base_JJA=new(4, graphic)
base_JJA_test=new(4, graphic)
base_DJF_test=new(4, graphic)
;***********************************************************************************
;*******************************************************************************************
;*************计算************************************************************************************
    do i=0,9,3
        p=(f2->pre(:,i,:,:))
        u2=fu2->ugrd(:,i,:,:)
        v2=fv2->vgrd(:,i,:,:)
        p_DJF=fcd->pre(:,i,:,:)
        pc=g2fsh_Wrap(p, (/121,240/));将从高斯网格标量数量插值到固定网格（保留元数据）
        pc_DJF=g2fsh_Wrap(p_DJF, (/121,240/))
        pc=pc*86400
        pc_DJF=pc_DJF*86400
        ;copy_VarCoords(pe, pc)
        ;copy_VarCoords(pe_DJF, pc_DJF)

        pe_JJA=month_to_season(pe, "JJA")
        pc_JJA=month_to_season(pc, "JJA")
        ue_JJA=month_to_season(ue, "JJA")
        ve_JJA=month_to_season(ve, "JJA")
        uc_JJA=month_to_season(u2, "JJA")
        vc_JJA=month_to_season(v2, "JJA")

        pe_JJA_avg=dim_avg_n_Wrap(pe_JJA, 0)
        pe_DJF_avg=dim_avg_n_Wrap(pe_DJF, 0)
        pc_JJA_avg=dim_avg_n_Wrap(pc_JJA, 0)
        pc_DJF_avg=dim_avg_n_Wrap(pc_DJF, 0)

        pe_JJA_var=dim_variance_n_Wrap(pe_JJA, 0)
        pe_DJF_var=dim_variance_n_Wrap(pe_DJF, 0)
        pc_JJA_var=dim_variance_n_Wrap(pc_JJA, 0)
        pc_DJF_var=dim_variance_n_Wrap(pc_DJF, 0)

        copy_VarCoords(pe_JJA_var, pc_JJA_var)
        copy_VarCoords(pe_JJA_var, pc_DJF_var)

        copy_VarCoords(pe_JJA_avg, pc_JJA_avg)
        copy_VarCoords(pe_JJA_avg, pc_DJF_avg)

        p_dif_JJA=dim_avg_n_Wrap(pe_JJA, 0)-dim_avg_n_Wrap(pc_JJA, 0)
        p_dif_DJF=dim_avg_n_Wrap(pe_DJF, 0)-dim_avg_n_Wrap(pe_JJA, 0)

        pt=dim_avg_n_Wrap(pe_JJA, 0)
        copy_VarCoords(pt, p_dif_JJA)
        copy_VarCoords(pt, p_dif_DJF)

        dimce=dimsizes(pe_JJA)
        ntim=dimce(0)
        nlat=dimce(1)
        mlon=dimce(2)

        pe_tmp_JJA=pe_JJA(lat|:,lon|:,time|:)
        pe_tmp_DJF=pe_DJF(lat|:,lon|:,time|:)
        pc_tmp_JJA=pc_JJA(lat|:,lon|:,time|:)
        pc_tmp_DJF=pc_DJF(lat|:,lon|:,time|:)

        sigr=0.05

        pe_JJA_eqv=equiv_sample_size(pe_tmp_JJA, sigr, 0)
        pe_DJF_eqv=equiv_sample_size(pe_tmp_DJF, sigr, 0)
        pc_JJA_eqv=equiv_sample_size(pc_tmp_JJA, sigr, 0)
        pc_DJF_eqv=equiv_sample_size(pc_tmp_DJF, sigr, 0)

        pe_JJA_N=wgt_areaave(pe_JJA_eqv, 1., 1., 0)
        pe_DJF_N=wgt_areaave(pe_DJF_eqv, 1., 1., 0)
        pc_JJA_N=wgt_areaave(pc_JJA_eqv, 1., 1., 0)
        pc_DJF_N=wgt_areaave(pc_DJF_eqv, 1., 1., 0)

        iflag=False

        prob_JJA=ttest(pe_JJA_avg, pe_JJA_var, pe_JJA_N, pc_JJA_avg, pc_JJA_var, pc_JJA_N, iflag, False)
        prob_DJF=ttest(pe_DJF_avg, pe_DJF_var, pe_DJF_N, pc_DJF_avg, pc_DJF_var, pc_DJF_N, iflag, False)
        copy_VarCoords(pe_JJA_avg, prob_JJA)
        copy_VarCoords(pe_JJA_avg, prob_DJF)
    end do
;****************图形********************************************************************************
;***********************************************************************************************************
;**********************************************************************************************************
;*******************************************************************************
        res=True
        res@gsnDraw=False
        res@gsnFrame=False
        res@gsnAddCyclic=True
        res@cnLinesOn=False
        res@pmTickMarkDisplayMode="Always"

        res@gsnLeftString="Obs-Hindcast"
        res@gsnRightString="lead_"+i

        res@cnFillOn=True
        res@cnLevelSelectionMode="ExplicitLevels"
        res@cnLevels=(/-25,-20,-15,-10,-5,0,5,10,15,20,25/)
        ;res@cnFillColors=(/2,39,59,65,70,97,130,145,177,193,200,225,255/)
        res@lbLabelBarOn=False
        res@mpMaxLatF=60
        res@mpMinLatF=-10
        res@mpMaxLonF=150
        res@mpMinLonF=40
    res@gsnMajorLatSpacing         =10
    res@gsnMajorLonSpacing         =15
    res@gsnMinorLatSpacing         =5
    res@gsnMinorLonSpacing         =5
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
    res@tmXMajorGrid             =True
    res@tmXMinorGrid             =True
    res@tmYMajorGrid             =True
    res@tmYMinorGrid              =True
    res@tmXMajorGridLineDashPattern=16
    res@tmXMajorGridLineColor      ="gray"
    res@tmXMajorGridThicknessF     =0.5
    res@tmXMajorGridLineDashPattern=3
    res@tmXMinorGridLineColor      ="red"
    res@tmXMinorGridThicknessF     =0.3
    res@tmYMajorGridLineDashPattern=16
    res@tmYMajorGridLineColor      ="gray"
    res@tmYMajorGridThicknessF     =0.5
    res@tmYMajorGridLineDashPattern=3
    res@tmYMinorGridLineColor      ="red"
    res@tmYMinorGridThicknessF     =0.3
    ;res@tmXBMode                   ="Manual"
    ;res@tmYBMode                   ="Manual"
    res@tmXBTickSpacingF           =10

    res@cnInfoLabelOn = False

        ;height 
        hres=True
        hres@gsnAddCyclic=True
        hres@cnLinesOn=True
        hres@cnFillOn=False
        hres@cnInfoLabelOn=False

        hres@tiMainString=""
        hres@cnLevelSelectionMode="ExplicitLevels"
        hres@cnLevels=(/2000/)
        hres@cnLineLabelsOn=False
        hres@cnLineColor="red"
        hres@cnLineThicknessF=3
        hres@cnLineDashPattern=12
    hres@tmXMajorGrid             =True
    hres@tmXMinorGrid             =True
    hres@tmYMajorGrid             =True
    hres@tmYMinorGrid              =True
    hres@tmXMajorGridLineDashPattern=16
    hres@tmXMajorGridLineColor      ="gray"
    hres@tmXMajorGridThicknessF     =0.5
    hres@tmXMajorGridLineDashPattern=3
    hres@tmXMinorGridLineColor      ="red"
    hres@tmXMinorGridThicknessF     =0.3
    hres@tmYMajorGridLineDashPattern=16
    hres@tmYMajorGridLineColor      ="gray"
    hres@tmYMajorGridThicknessF     =0.5
    hres@tmYMajorGridLineDashPattern=3
    hres@tmYMinorGridLineColor      ="red"
    hres@tmYMinorGridThicknessF     =0.3
    ;hres@tmXBMode                   ="Manual"
    ;hres@tmYBMode                   ="Manual"
    hres@cnInfoLabelOn = False

        ;vector
        resv=True
        resv@gsnDraw=False
        resv@gsnFrame=False
        resv@pmTickMarkDisplayMode="Always"

        resv@gsnLeftString=""
        resv@gsnRightString=""

        resv@vcGlyphStyle="FillArrow"
        resv@vcFillArrowEdgeColor="black"
        resv@vcFillArrowFillColor="black"
        resv@vcMinMagnitudeF=1.0
        resv@vcMinDistanceF=0.02

        resv@vcFillArrowWidthF=0.02
        resv@vcFillArrowHeadXF=0.2
        resv@vcFillArrowHeadInteriorXF=0.1
        resv@vcFillArrowHeadYF=0.1

        resv@vcRefAnnoOn=True
        resv@vcRefMagnitudeF=20
        resv@vcRefLengthF=0.05
        resv@vcRefAnnoBackgroundColor="white"
        resv@vcRefAnnoPerimOn=False
        resv@vcRefAnnoFontHeightF=0.015
        resv@vcRefAnnoString1On=True
        resv@vcRefAnnoString2On=False
        resv@vcRefAnnoString1="20m/s"
        resv@vcRefAnnoOrthogonalPosF=0
        resv@vcRefAnnoParallelPosF=1

        ress                           =True
        ress@gsnDraw                 =False
        ress@gsnFrame                =False

        ress@gsnLeftString                 =""
        ress@gsnRightString                =""
        ;ress@stSpanLevelPalette            ="matlab_hot"
        ress@stLevelSpacingF               =2.
        ress@stMonoLineColor               =True
        ress@stMinDistanceF                =0.03
        ress@stMinLineSpacingF             =0.007
        ress@stArrowLengthF                =0.005
        
        resb   =True
        resb@cnFillOn=False
        resb@cnLinesOn=True
        resb@gsnDraw=False
        resb@gsnFrame=False
        resb@gsnLeftString=""
        resb@gsnRightString=""
        resb@cnLevelSelectionMode="ExplicitLevels"
        resb@cnLevels=(/0.1/)
        resb@cnInfoLabelOn = False



        opt=True
        opt@gsnShadeFillType="pattern"
        opt@gsnShadeHigh     =6
        opt@gsnShadeFillScaleF=0.005;增加额外的密度
        opt@gsnShadeFillDotSizeF=0.02 ;使点更大
        ;opt@gsnShadeLow      =0
        ;opt@gsnShadeMid      =0

        rest=True
    rest@cnFillOn=True
    ;rest@cnLinesOn=True
    rest@mpMaxLatF=60
    rest@mpMinLatF=0
    rest@mpMaxLonF=140
    rest@mpMinLonF=40
    rest@gsnDraw=False
    rest@gsnFrame=False
    rest@cnLevelSelectionMode="ExplicitLevels"
    rest@cnLevels=(/0.1,0.5,0.95/)

;*********绘图************************************************************************************
;*********************************************************************************************

do i=0,9,3
    base_JJA(i/3)=gsn_csm_contour_map_overlay(wks, p_dif_JJA, hgt, res, hres)
    base_DJF(i/3)=gsn_csm_contour_map_overlay(wks, p_dif_DJF, hgt, res, hres)
    plot_JJA(i/3)=gsn_csm_contour(wks,prob_JJA , resb)
    plot_DJF(i/3)=gsn_csm_contour(wks,prob_DJF , resb)
    plot_JJA(i/3)=gsn_contour_shade(plot_JJA(i/3), 0, 0.1, opt)
    plot_DJF(i/3)=gsn_contour_shade(plot_DJF(i/3), 0, 0.1, opt)
overlay(base_JJA(i/3), plot_JJA(i/3))
overlay(base_DJF(i/3), plot_DJF(i/3))

    end do

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
    resp@gsnMaximize              =False
    ;resp@txString                 ="Surface pressure"
    resp@gsnPanelLabelBar         =True
    resp@gsnPanelFigureStringsPerimOn=True
    
    resp2=resp
    resp@txString          ="Obs_Hindcast_JJA"
    resp2@txString          ="Obs_Hindcast_DJF"
    gsn_panel(wks, base_JJA, (/2,2/), resp)
    gsn_panel(wks, base_DJF, (/2,2/), resp2)
    gsn_panel(wks, base_JJA_test, (/2,2/), resp)
    gsn_panel(wks, base_DJF_test, (/2,2/), resp2)
end
