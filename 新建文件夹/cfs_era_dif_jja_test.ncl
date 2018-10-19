load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

    ;f1=addfile("/mnt/f/data/ERA-interim/monthly/precip.mon.mean.nc", "r")
    ;fh=addfile("/mnt/f/data/NCEP/hgt.sfc.nc", "r")
    ;f2=addfile("/mnt/f/data/CFSV2_output/pre/pre.em24.out.nc", "r")
    f1=addfile("/home/ys-ug/data/era-interim/precip.mon.mean.nc", "r")
    fh=addfile("/home/ys-ug/data/hgt.sfc.nc", "r")
    hgt=short2flt(fh->hgt(0,:,:))
    f2=addfile("//home/ys-ug/data/cfsv2/pre.em24.out.nc", "r")
wks=gsn_open_wks("png", "/home/ys-ug/kt/prc_era_dif_ttest_JJ")
gsn_define_colormap(wks, "MPL_RdYlBu")
base=new(4, graphic)
plot=new(4, graphic)
    do i=0,9,3
        p=(f2->pre(:,i,::-1,:))
        printVarSummary(p)
        pc0=g2fsh_Wrap(p, (/121,240/));将从高斯网格标量数量插值到固定网格（保留元数据）
        pc0=pc0*86400
        printVarSummary(pc0)
        pe0=f1->r(48:383,:,:)
        pe_JJA=month_to_season(pe0, "JJA")
        pc_JJA=month_to_season(pc0, "JJA")
        pe_avg_JJA=dim_avg_n_Wrap(pe_JJA, 0)
        pc_avg_JJA=dim_avg_n_Wrap(pc_JJA, 0)
        pe_std_JJA=dim_stddev_n_Wrap(pe_JJA, 0)
        pc_std_JJA=dim_stddev_n_Wrap(pc_JJA, 0)
        pce=pc_avg_JJA-pe_avg_JJA
        copy_VarCoords(pe_avg_JJA,pce)
        printVarSummary(pce)
        prob=ttest(pc_avg_JJA, pc_std_JJA^2, 28, \
              pe_avg_JJA, pe_std_JJA^2, 28,False, False)
        copy_VarCoords(pe_avg_JJA,prob)
   
        res=True
        res@gsnDraw=False
        res@gsnFrame=False
        res@gsnAddCyclic=True
        res@cnLinesOn=False
        res@pmTickMarkDisplayMode="Always"

        res@gsnLeftString="Hind-Obs"
        res@gsnRightString="lead_"+i
        res@gsnCenterString=" 5% Stippled "

        res@cnFillOn=True
        res@cnLevelSelectionMode="ExplicitLevels"
        res@cnLevels=(/-10,-8,-6,-4,-2,-1,0,1,2,4,6,8,10/)
        res@cnFillColors=(/12,25,33,40,45,52,62,78,88,94,99,105,114,128/)
        res@lbLabelBarOn=False
        res@mpMaxLatF=60
        res@mpMinLatF=0
        res@mpMaxLonF=150
        res@mpMinLonF=45
    res@gsnMajorLatSpacing         =15
    res@gsnMajorLonSpacing         =15
    ;res@gsnMinorLatSpacing         =5
    ;res@gsnMinorLonSpacing         =5
    res@mpGridAndLimbOn          =True
    res@mpGridLatSpacingF        =15
    res@mpGridLineDashPattern    =2
    res@mpGridLineThicknessF     =0.5
    res@mpGridLonSpacingF        =15
    res@pmTickMarkDisplayMode    ="Always" ;
    res@mpDataBaseVersion        ="MediumRes" 
    res@mpDataSetName            ="Earth..4"
    res@mpGeophysicalLineColor   ="black"
    res@mpGeophysicalLineDashPattern=16
    res@mpGeophysicalLineDashSegLenF=0.2
    res@mpGeophysicalLineThicknessF =0.2
    res@mpOutlineMaskingOn       =True
    res@mpOutlineOn              =True
    res@tmXMajorGrid             =True
    ;res@tmXMinorGrid             =True
    res@tmYMajorGrid             =True
    ;res@tmYMinorGrid              =True
    res@tmXMajorGridLineDashPattern=16
    res@tmXMajorGridLineColor      ="gray"
    res@tmXMajorGridThicknessF     =0.5
    res@tmXMajorGridLineDashPattern=3
    ;res@tmXMinorGridLineColor      ="red"
    ;res@tmXMinorGridThicknessF     =0.3
    res@tmYMajorGridLineDashPattern=16
    res@tmYMajorGridLineColor      ="gray"
    res@tmYMajorGridThicknessF     =0.5
    res@tmYMajorGridLineDashPattern=3
    ;res@tmYMinorGridLineColor      ="red"
    ;res@tmYMinorGridThicknessF     =0.3
    ;res@tmXBMode                   ="Manual"
    ;res@tmYBMode                   ="Manual"
    res@tmXBTickSpacingF           =15

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
        hres@cnLineColor="black"
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
        resb@cnLinesOn=False
        resb@gsnDraw=False
        resb@gsnFrame=False
        resb@gsnLeftString=""
        resb@gsnRightString=""
        resb@cnLevelSelectionMode="ExplicitLevels"
        resb@cnLevels=(/0.05/)
        resb@cnInfoLabelOn = False
        resb@cnLineDashPattern=13
        resb@cnLineLabelsOn=False


        opt=True
        opt@gsnShadeFillType="pattern"
        opt@gsnShadeLow    =17
        opt@gsnShadeFillScaleF=0.005
        opt@gsnShadeFillDotSizeF=0.02 
        ;opt@gsnShadeLow      =0
        ;opt@gsnShadeMid      =0
;*********************************************************************************************



base(i/3)=gsn_csm_contour_map_overlay(wks, pce, hgt, res, hres)
plot(i/3)=gsn_csm_contour(wks,prob , resb)
plot(i/3)=gsn_contour_shade(plot(i/3), 0.05, 100, opt)
overlay(base(i/3), plot(i/3))


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
    resp3=resp
    resp4=resp
    resp@txString          ="Hind-ERA-JJA"

    ;gsn_panel(wks, base5, (/2,2/), resp)
    gsn_panel(wks, base, (/2,2/), resp)
    ;gsn_panel(wks, base7, (/2,2/), resp3)
    ;gsn_panel(wks, base8, (/2,2/), resp4)
end
