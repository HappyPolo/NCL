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
    f2=addfile("/home/yangsong3/lcz/data/cfsv2_output/pre/pre.em24.out.nc", "r")
wks=gsn_open_wks("pdf", "/home/ys-ug/kt/prc_differ_test_mon_2")
gsn_define_colormap(wks, "NCV_blue_red")
base5=new(4, graphic)
base6=new(4, graphic)
base7=new(4, graphic)
base8=new(4, graphic)
plot5=new(4, graphic)
plot6=new(4, graphic)
plot7=new(4, graphic)
plot8=new(4, graphic)
    do i=0,9,3
        pe0=f1->r(48:383,{-9:61},{39:151})
        p=(f2->pre(:,i,::-1,:))
        printVarSummary(p)
        pc0=g2fsh_Wrap(p, (/121,240/));将从高斯网格标量数量插值到固定网格（保留元数据）
        pc0=pc0(:,::-1,:)
        printVarSummary(pc0)
        pc0=pc0*86400
        pc00=pc0(:,:,:)
        pe=pe0(lat|:,lon|:,time|:)
        pc=pc00(lat|:,lon|:,time|:)
        printVarSummary(pc)
        peclm=clmMonLLT(pe)
        pcclm=clmMonLLT(pc)
        pestd=stdMonLLT(pe)
        pcstd=stdMonLLT(pc)
        printVarSummary(peclm)
        printVarSummary(pcclm)
        printVarSummary(pestd)
        printVarSummary(pcstd(:,:,4))
        pce=pcclm({-9:61},{39:151},:)-peclm
        copy_VarCoords(peclm,pce)
        printVarSummary(pce)
        prob5=ttest(peclm(:,:,4), pestd(:,:,4)^2, 28,\
              pcclm({-9:61},{39:151},4), pcstd({-9:61},{39:151},4)^2, 28, False, False)
        printVarSummary(prob5)
        prob6=ttest(peclm(:,:,5), pestd(:,:,5)^2, 28,\
              pcclm({-9:61},{39:151},5), pcstd({-9:61},{39:151},5)^2, 28, False, False)       
        prob7=ttest(peclm(:,:,6), pestd(:,:,6)^2, 28,\
              pcclm({-9:61},{39:151},6), pcstd({-9:61},{39:151},6)^2, 28, False, False)
        prob8=ttest(peclm(:,:,7), pestd(:,:,7)^2, 28,\
              pcclm({-9:61},{39:151},7), pcstd({-9:61},{39:151},7)^2, 28, False, False)
        copy_VarCoords(peclm(:,:,0),prob5)
        copy_VarCoords(peclm(:,:,0),prob6)
        copy_VarCoords(peclm(:,:,0),prob7)
        copy_VarCoords(peclm(:,:,0),prob8)
        printVarSummary(prob8)

        res=True
        res@gsnDraw=False
        res@gsnFrame=False
        res@gsnAddCyclic=True
        res@cnLinesOn=False
        res@pmTickMarkDisplayMode="Always"
        res@gsnAddCyclic=False

        res@gsnLeftString="Hind-Obs"
        res@gsnRightString="lead_"+i
        res@gsnCenterString      = "5% stippled"

        res@cnFillOn=True
        res@cnLevelSelectionMode="ExplicitLevels"
        res@cnLevels=(/-15,-12,-9,-6,-3,-2,-1,-0.8,-0.6,-0.3,0,0.3,0.6,0.8,1,2,3,6,9,12,15/)
        res@lbLabelBarOn=False
        res@mpMaxLatF=60
        res@mpMinLatF=-10
        res@mpMaxLonF=150
        res@mpMinLonF=40
        ;res@cnSmoothingOn=True
    res@gsnMajorLatSpacing         =10
    res@gsnMajorLonSpacing         =15
    ;res@gsnMinorLatSpacing         =5
    ;res@gsnMinorLonSpacing         =5
    res@mpGridAndLimbOn          =True
    res@mpGridLatSpacingF        =10
    res@mpGridLineDashPattern    =2
    res@mpGridLineThicknessF     =0.5
    res@mpGridLonSpacingF        =10
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
    hres@tmYMinorGridLineColor      ="black"
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
        resb@cnLevels=(/0.05/)
        resb@cnInfoLabelOn = False



        opt=True
        opt@gsnShadeFillType="pattern"
        opt@gsnShadeLow    =17
        opt@gsnShadeFillScaleF=0.005
        opt@gsnShadeFillDotSizeF=0.02 
        ;opt@gsnShadeLow      =0
        ;opt@gsnShadeMid      =0
;*********************************************************************************************

base5(i/3)=gsn_csm_contour_map_overlay(wks, pce(:,:,4), hgt, res, hres)
plot5(i/3)=gsn_csm_contour(wks,prob5 , resb)
plot5(i/3)=gsn_contour_shade(plot5(i/3), 0.05, 100, opt)
overlay(base5(i/3), plot5(i/3))
base6(i/3)=gsn_csm_contour_map_overlay(wks, pce(:,:,5), hgt, res, hres)
plot6(i/3)=gsn_csm_contour(wks,prob6 , resb)
plot6(i/3)=gsn_contour_shade(plot6(i/3), 0.05, 100, opt)
overlay(base6(i/3), plot6(i/3))
base7(i/3)=gsn_csm_contour_map_overlay(wks, pce(:,:,6), hgt, res, hres)
plot7(i/3)=gsn_csm_contour(wks,prob7 , resb)
plot7(i/3)=gsn_contour_shade(plot7(i/3), 0.05, 100, opt)
overlay(base7(i/3), plot7(i/3))
base8(i/3)=gsn_csm_contour_map_overlay(wks, pce(:,:,7), hgt, res, hres)
plot8(i/3)=gsn_csm_contour(wks,prob8 , resb)
plot8(i/3)=gsn_contour_shade(plot8(i/3), 0.05, 100, opt)
overlay(base8(i/3), plot8(i/3))

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
    resp@txString          ="Hind-Obs_May"
    resp2@txString          ="Hind-Obs_June"
    resp3@txString          ="Hind-Obs_July"
    resp4@txString          ="Hind-Obs_August"
    gsn_panel(wks, base5, (/2,2/), resp)
    gsn_panel(wks, base6, (/2,2/), resp2)
    gsn_panel(wks, base7, (/2,2/), resp3)
    gsn_panel(wks, base8, (/2,2/), resp4)
end
