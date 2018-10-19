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
wks=gsn_open_wks("pdf", "/home/ys-ug/kt/prc_differ_test_monthly_23")
gsn_define_colormap(wks, "NCV_blue_red")
base5=new(4, graphic)
base6=new(4, graphic)
base7=new(4, graphic)
base8=new(4, graphic)
plot5=new(4, graphic)
plot6=new(4, graphic)
plot7=new(4, graphic)
plot8=new(4, graphic)
    do i=0,9,30
        p=(f2->pre(:,i,::-1,:))
        printVarSummary(p)
        pc0=g2fsh_Wrap(p, (/121,240/));将从高斯网格标量数量插值到固定网格（保留元数据）
        pc0=pc0*86400
        printVarSummary(pc0)
        pe0=f1->r(48:383,:,:)
        pe=pe0(lat|:,lon|:,time|:)
        pc=pc0(lat|:,lon|:,time|:)
        peclm=clmMonLLT(pe)
        pcclm=clmMonLLT(pc)
        pestd=stdMonLLT(pe)
        pcstd=stdMonLLT(pc)
        printVarSummary(peclm)
        printVarSummary(pcclm)
        printVarSummary(pestd)
        printVarSummary(pcstd(:,:,4))
        pce=pcclm-peclm
        copy_VarCoords(peclm,pce)
        printVarSummary(pce)
        res=True
        res@gsnDraw=False
        res@gsnFrame=False
        res@gsnAddCyclic=True
        res@cnLinesOn=False
        res@pmTickMarkDisplayMode="Always"

        res@gsnLeftString="Hind-Obs"
        res@gsnRightString="lead_"+i

        res@cnFillOn=True
        res@cnLevelSelectionMode="ExplicitLevels"
        res@cnLevels=(/-15,-12,-9,-6,-3,-2,-1,-0.8,-0.5,-0.3,0,0.3,0.5,0.8,1,2,3,6,9,12,15/)
        res@lbLabelBarOn=False
        res@mpMaxLatF=60
        res@mpMinLatF=-10
        res@mpMaxLonF=150
        res@mpMinLonF=40
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
    hres@tmYMinorGridLineColor      ="red"
    hres@tmYMinorGridThicknessF     =0.3
    ;hres@tmXBMode                   ="Manual"
    ;hres@tmYBMode                   ="Manual"
    hres@cnInfoLabelOn = False
    plot=gsn_csm_contour_map_overlay(wks, pce(:,:,4), hgt, res, hres)
    draw(plot)
end do
end
res@cnLineDashPattern

