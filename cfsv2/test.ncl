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
wks=gsn_open_wks("pdf", "/home/ys-ug/kt/prc_differ_test_monthly_2")
gsn_define_colormap(wks, "NCV_blue_red")
        pe0=f1->r(48:383,{-10:60},{40:150})
        p=(f2->pre(:,0,::-1,:))
        printVarSummary(p)
        pc0=g2fsh_Wrap(p, (/121,240/));将从高斯网格标量数量插值到固定网格（保留元数据）
        pc0=pc0(:,::-1,:)
        printVarSummary(pc0)
        pc0=pc0*86400
        pc00=pc0(:,{-10:60},{40:150})
        pe=pe0(lat|:,lon|:,time|:)
        pc=pc00(lat|:,lon|:,time|:)
        printVarSummary(pc)
        peclm=clmMonLLT(pe)
        pcclm=clmMonLLT(pc)
        pestd=stdMonLLT(pe)
        pcstd=stdMonLLT(pc)
        printVarSummary(peclm)
        printVarSummary(pcclm)
        pd=pcclm(:,:,7)-peclm(:,:,7)

        res=True
        res@cnFillOn=True
        res@cnLinesOn=False
        plot1=gsn_csm_contour_map(wks, peclm(:,:,7), res)
        plot2=gsn_csm_contour_map(wks, pcclm(:,:,7), res)
        plot3=gsn_csm_contour_map(wks, pd, res)
       end
