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
wks=gsn_open_wks("pdf", "/home/ys-ug/kt/test")
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
        pe02=f1->r(48:383,:,:)
        p=(f2->pre(:,i,::-1,:))
        printVarSummary(p)
        pc0=g2fsh_Wrap(p, (/121,240/));将从高斯网格标量数量插值到固定网格（保留元数据）
        pc0=pc0(:,::-1,:)
        printVarSummary(pc0)
        pc0=pc0*86400
        pc00=pc0(:,:,:)
        pe=pe0(lat|:,lon|:,time|:)
        pe2=pe02(lat|:,lon|:,time|:)
        pc=pc00(lat|:,lon|:,time|:)
        printVarSummary(pc)
        peclm=clmMonLLT(pe)
        pcclm=clmMonLLT(pc)
        pestd=stdMonLLT(pe)
        pcstd=stdMonLLT(pc)
        pc2clm=clmMonLLT(pc({-9:61},{39:151},:))
        pe2clm=clmMonLLT(pe2)
        printVarSummary(peclm)
        printVarSummary(pcclm)
        printVarSummary(pestd)
        printVarSummary(pcstd(:,:,4))
        pce=pcclm({-9:61},{39:151},:)-peclm
        pce2=pcclm(:,:,:)-pe2clm
        pce3=pc2clm-peclm
        copy_VarCoords(peclm,pce)
        copy_VarCoords(peclm,pce2)
        copy_VarCoords(peclm,pce3)
        printVarSummary(pce)
end do
        res=True
        res@cnFillOn=True
        res@cnLinesOn=False
        res@gsnAddCyclic=False
        res@mpMaxLonF=150
        res@mpMinLonF=40
        res@mpMaxLatF=60
        res@mpMinLatF=-10
        res@cnLevels=(/-15,-12,-9,-6,-3,-2,-1,-0.8,-0.6,\
                      -0.3,0,0.3,0.6,0.8,1,2,3,6,9,12,15/)
        plot1=gsn_csm_contour_map(wks, pce(:,:,7), res)
        plot2=gsn_csm_contour_map(wks, pce2(:,:,7), res)
        plot3=gsn_csm_contour_map(wks, pce3(:,:,7), res)
        end