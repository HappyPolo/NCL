load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

    f1=addfile("/home/ys-ug/data/era-interim/precip.mon.mean.nc", "r")
    pe0=f1->r(48:383,::-1,:)
    fh=addfile("/home/ys-ug/data/hgt.sfc.nc", "r")
    h=short2flt(fh->hgt(0,::-1,:))
    feu=addfile("/home/yangsong3/data-observation/ERA-interim/monthly/uwnd.mon.mean.nc", "r")
    eu1=short2flt((feu->u(48:383,{850},::-1,:)))
    fev=addfile("/home/yangsong3/data-observation/ERA-interim/monthly/vwnd.mon.mean.nc", "r")
    ev1=short2flt((fev->v(48:383,{850},::-1,:)))
    f2=addfile("/home/yangsong3/lcz/data/cfsv2_output/pre/pre.em24.out.nc", "r")
    fcu=addfile("/home/yangsong3/lcz/data/cfsv2_output/u850/u850.em24.out.nc", "r")
    fcv=addfile("/home/yangsong3/lcz/data/cfsv2_output/v850/v850.em24.out.nc", "r")
    w=gsn_open_wks("ps","~/kt/cfs_era")
    wks=new((/3/),typeof(w) )
    delete(w)
wks(0)=gsn_open_wks("eps","~/kt/cfs_era_reg_prc_uv_Jun_lead0")
wks(1)=gsn_open_wks("eps","~/kt/cfs_era_reg_prc_uv_Jul_lead0")
wks(2)=gsn_open_wks("eps","~/kt/cfs_era_reg_prc_uv_Aug_lead0")
gsn_define_colormap(wks, "MPL_autumn")

N=3
M=5
plot=new(N, graphic)
;***TP*******
latNN = 45
latSS = 15
lonRR = 120
lonLL = 65
latN = 34
latS = 24
lonR = 111
lonL = 80
;**********************************
nlat=21
nlon=37
i=0
        p=(f2->pre(:,i,:,:))
        cu0=fcu->ugrd(:,i,:,:)
        cv0=fcv->vgrd(:,i,:,:)
        printVarSummary(p)
        printVarSummary(cu0)
        printVarSummary(cv0)
;********Regridding*********************
        cu1=g2fsh_Wrap(cu0, (/121,240/))
        cv1=g2fsh_Wrap(cv0, (/121,240/))
        copy_VarCoords(pe0, cu1)
        copy_VarCoords(pe0, cv1)
        printVarSummary(cu1)
        pc0=g2fsh_Wrap(p, (/121,240/));将从高斯网格标量数量插值到固定网格（保留元数据）
        pc0=pc0*86400
        printVarSummary(pc0)
        opt=False
        loni=eu1&longitude
        lati=eu1&latitude
        lono=pe0&lon
        lato=pe0&lat
        eu0=area_conserve_remap_Wrap(loni, lati, eu1, lono, lato, opt)
        ev0=area_conserve_remap_Wrap(loni, lati, ev1, lono, lato, opt)  
        delete([/opt,loni,lati,lono,lato/])
        printVarSummary(eu0)
;*****************************************
        pe=pe0(lat|:,lon|:,time|:)
        pc=pc0(lat|:,lon|:,time|:)
        cu=cu1(lat|:,lon|:,time|:)
        cv=cv1(lat|:,lon|:,time|:)
        eu=eu0(lat|:,lon|:,time|:)
        ev=ev0(lat|:,lon|:,time|:)
        printVarSummary(pe({latSS:latNN},\
                                   {lonLL:lonRR},:))
        assignFillValue(pe, pc)
        assignFillValue(pe, cu)
        assignFillValue(pe, cv)
        assignFillValue(pe, eu)
        assignFillValue(pe, ev)
        printVarSummary(pe)
        printVarSummary(pc)
        printVarSummary(cu)
        pe_mon=new((/N,121,240,28/), typeof(pe), getFillValue(pe))
        pc_mon=new((/N,121,240,28/), typeof(pe), getFillValue(pe))
        cu_mon=new((/N,121,240,28/), typeof(pe), getFillValue(pe))
        cv_mon=new((/N,121,240,28/), typeof(pe), getFillValue(pe))
        eu_mon=new((/N,121,240,28/), typeof(pe), getFillValue(pe))
        ev_mon=new((/N,121,240,28/), typeof(pe), getFillValue(pe))
        hgt=new((/121,240/), typeof(pe), getFillValue(pe))
        do k=0,N-1
            do j=0,27
                pe_mon(k,:,:,j)=pe(:,:,(k+5)+j*12)
                pc_mon(k,:,:,j)=pc(:,:,(k+5)+j*12)
                cu_mon(k,:,:,j)=cu(:,:,(k+5)+j*12)
                cv_mon(k,:,:,j)=cv(:,:,(k+5)+j*12)
                eu_mon(k,:,:,j)=eu(:,:,(k+5)+j*12)
                ev_mon(k,:,:,j)=ev(:,:,(k+5)+j*12)
            end do
        end do
        pe_mon!0="month"
        pe_mon!1="lat"
        pe_mon!2="lon"
        pe_mon!3="year"
        pe_mon&month=ispan(0, N-1, 1)
        pe_mon&year = ispan(1983, 2010, 1)
        pe_mon&lat = pe&lat
        pe_mon&lon = pe&lon
        cu_mon!0="month"
        cu_mon!1="lat"
        cu_mon!2="lon"
        cu_mon!3="year"
        cu_mon&month=ispan(0, N-1, 1)
        cu_mon&year = ispan(1983, 2010, 1)
        cu_mon&lat = cu&lat
        cu_mon&lon = cu&lon
        eu_mon!0="month"
        eu_mon!1="lat"
        eu_mon!2="lon"
        eu_mon!3="year"
        eu_mon&month=ispan(0, N-1, 1)
        eu_mon&year = ispan(1983, 2010, 1)
        eu_mon&lat = eu&lat
        eu_mon&lon = eu&lon
        copy_VarCoords(pe_mon, pc_mon)
        copy_VarCoords(cu_mon, cv_mon)
        copy_VarCoords(eu_mon, ev_mon)

        printVarSummary(pe_mon)
        pr_era=new((/N,28/), typeof(pe), getFillValue(pe))
        pr_cfsv2=new((/N,28/), typeof(pe), getFillValue(pe))
 ;       d=new((/N,28/), typeof(pe), getFillValue(pe))
        rccu_mon=new((/N,nlat,nlon/), typeof(pe), getFillValue(pe))
        rccv_mon=new((/N,nlat,nlon/), typeof(pe), getFillValue(pe))
        rceu_mon=new((/N,nlat,nlon/), typeof(pe), getFillValue(pe))
        rcev_mon=new((/N,nlat,nlon/), typeof(pe), getFillValue(pe))
        rccun_mon=new((/N,nlat,nlon/), typeof(pe), getFillValue(pe))
        rccvn_mon=new((/N,nlat,nlon/), typeof(pe), getFillValue(pe))
        rceun_mon=new((/N,nlat,nlon/), typeof(pe), getFillValue(pe))
        rcevn_mon=new((/N,nlat,nlon/), typeof(pe), getFillValue(pe))
        rcpe_mon=new((/N,nlat,nlon/), typeof(pe), getFillValue(pe))
        rcpc_mon=new((/N,nlat,nlon/), typeof(pe), getFillValue(pe))

        do k=0,N-1,1
            pr_era(k,:) = dim_avg_n_Wrap(pe_mon(k,{latS:latN},\
                                   {lonL:lonR},:) ,(/0,1/))
            pr_cfsv2(k,:) = dim_avg_n_Wrap(pc_mon(k,{latS:latN},\
                                   {lonL:lonR},:), (/0,1/))
            rccu_mon(k,:,:)=regCoef(pr_cfsv2(k,:), cu_mon(k,{latSS:latNN},\
                                   {lonLL:lonRR},:))
            rccv_mon(k,:,:)=regCoef(pr_cfsv2(k,:), cv_mon(k,{latSS:latNN},\
                                   {lonLL:lonRR},:))
            rceu_mon(k,:,:)=regCoef(pr_era(k,:), eu_mon(k,{latSS:latNN},\
                                   {lonLL:lonRR},:))
            rcev_mon(k,:,:)=regCoef(pr_era(k,:), ev_mon(k,{latSS:latNN},\
                                   {lonLL:lonRR},:))
            rcpe_mon(k,:,:)=regCoef(pr_era(k,:), pe_mon(k,{latSS:latNN},\
                                   {lonLL:lonRR},:))
            rcpc_mon(k,:,:)=regCoef(pr_cfsv2(k,:), pc_mon(k,{latSS:latNN},\
                                   {lonLL:lonRR},:))

        end do
            pr_era!0="month"
            pr_era!1="year"
            pr_era&year=ispan(1983, 2010, 1)
            copy_VarCoords(pr_era, pr_cfsv2)
        ;rccu_mon@units="m/s"
        ;rccv_mon@units="m/s"
        ;rceu_mon@units="m/s"
        ;rcev_mon@units="m/s"
        ;rcpe_mon@units="mm/day"
        ;rcpc_mon@units="mm/day"
        copy_VarCoords(cu_mon(:,{latSS:latNN},\
                                   {lonLL:lonRR},0),rccu_mon)
        copy_VarCoords(cu_mon(:,{latSS:latNN},\
                                   {lonLL:lonRR},0),rccv_mon)
        copy_VarCoords(cu_mon(:,{latSS:latNN},\
                                   {lonLL:lonRR},0),rceu_mon)
        copy_VarCoords(cu_mon(:,{latSS:latNN},\
                                   {lonLL:lonRR},0),rcev_mon)
        copy_VarCoords(cu_mon(:,{latSS:latNN},\
                                   {lonLL:lonRR},0),rcpe_mon)
        copy_VarCoords(cu_mon(:,{latSS:latNN},\
                                   {lonLL:lonRR},0),rcpc_mon)
        printVarSummary(rccu_mon)
        printVarSummary(rceu_mon)
        probcu_mon=new((/N,nlat,nlon/), typeof(pe), getFillValue(pe))
        probcv_mon=new((/N,nlat,nlon/), typeof(pe), getFillValue(pe))
        probeu_mon=new((/N,nlat,nlon/), typeof(pe), getFillValue(pe))
        probev_mon=new((/N,nlat,nlon/), typeof(pe), getFillValue(pe))
        probpe_mon=new((/N,nlat,nlon/), typeof(pe), getFillValue(pe))
        probpc_mon=new((/N,nlat,nlon/), typeof(pe), getFillValue(pe))
        ;hgt=new((/nlon,nlat/), typeof(pe), getFillValue(pe))




        do k=0,N-1
            tval=onedtond(rccu_mon@tval , dimsizes(rccu_mon(0,:,:)))
            df  =onedtond(rccu_mon@nptxy, dimsizes(rccu_mon(0,:,:))) - 2
            b = tval   ; b must be same size as tval (and df)
            b = 0.5
            probcu_mon(k,:,:) = betainc(df/(df+tval^2),df/2.0,b)
            delete([/tval,df,b/])
            tval=onedtond(rccv_mon@tval , dimsizes(rccv_mon(0,:,:)))
            df  =onedtond(rccv_mon@nptxy, dimsizes(rccv_mon(0,:,:))) - 2
            b = tval   ; b must be same size as tval (and df)
            b = 0.5
            probcv_mon(k,:,:) = betainc(df/(df+tval^2),df/2.0,b) 
            delete([/tval,df,b/])
            tval=onedtond(rceu_mon@tval , dimsizes(rceu_mon(0,:,:)))
            df  =onedtond(rceu_mon@nptxy, dimsizes(rceu_mon(0,:,:))) - 2
            b = tval   ; b must be same size as tval (and df)
            b = 0.5
            probeu_mon(k,:,:) = betainc(df/(df+tval^2),df/2.0,b) 
            delete([/tval,df,b/])
            tval=onedtond(rcev_mon@tval , dimsizes(rcev_mon(0,:,:)))
            df  =onedtond(rcev_mon@nptxy, dimsizes(rcev_mon(0,:,:))) - 2
            b = tval   ; b must be same size as tval (and df)
            b = 0.5
            probev_mon(k,:,:) = betainc(df/(df+tval^2),df/2.0,b)
            delete([/tval,df,b/])
            tval =onedtond(rcpe_mon@tval , dimsizes(rcpe_mon(0,:,:)))
            df  =onedtond(rcpe_mon@nptxy, dimsizes(rcpe_mon(0,:,:))) - 2
            b = tval    ; b must be same size as tval (and df)
            b = 0.5
            probpe_mon(k,:,:) = betainc(df/(df+tval^2),df/2.0,b)
            delete([/tval,df,b/])
            tval=onedtond(rcpc_mon@tval , dimsizes(rcpc_mon(0,:,:)))
            df  =onedtond(rcpc_mon@nptxy, dimsizes(rcpc_mon(0,:,:))) - 2
            b = tval    ; b must be same size as tval (and df)
            b = 0.5
            probpc_mon(k,:,:) = betainc(df/(df+tval^2),df/2.0,b)
            delete([/tval,df,b/])
        end do
        probc_mon=probpc_mon
        probc_mon=where(abs(probcu_mon).lt.0.1.or.\
                       abs(probcv_mon).lt.0.1,1.0,2.0)
        probe_mon=probpc_mon
        probe_mon=where(abs(probeu_mon).lt.0.1.or.\
                       abs(probev_mon).lt.0.1,1.0,2.0)
        printVarSummary(h)
        xo=fspan(0, 358.5, 240)
        yo=fspan(-90, 90, 121)
        hgt=linint2_Wrap(h&lon, h&lat, h, True, xo, yo, 0) 
        copy_VarCoords(pe_mon(0,:,:,0), hgt)
        print(hgt) 
        hgt=hgt(lat|:,lon|:)
        printVarSummary(hgt({latSS:latNN},{lonLL:lonRR}))
        do k=0,N-1
            rccu_mon(k,:,:)=where(hgt({latSS:latNN},{lonLL:lonRR}).lt.1500, rccu_mon(k,:,:), rccu_mon@_FillValue)
            rccv_mon(k,:,:)=where(hgt({latSS:latNN},{lonLL:lonRR}).lt.1500, rccv_mon(k,:,:), rccu_mon@_FillValue)
            rceu_mon(k,:,:)=where(hgt({latSS:latNN},{lonLL:lonRR}).lt.1500, rceu_mon(k,:,:), rccu_mon@_FillValue)
            rcev_mon(k,:,:)=where(hgt({latSS:latNN},{lonLL:lonRR}).lt.1500, rcev_mon(k,:,:), rccu_mon@_FillValue)
        end do

        copy_VarCoords(cu_mon(:,{latSS:latNN},\
                                   {lonLL:lonRR},0),probc_mon)
        copy_VarCoords(cu_mon(:,{latSS:latNN},\
                                   {lonLL:lonRR},0),probe_mon)
        copy_VarCoords(cu_mon(:,{latSS:latNN},\
                                   {lonLL:lonRR},0),probpe_mon)
        copy_VarCoords(cu_mon(:,{latSS:latNN},\
                                   {lonLL:lonRR},0),probpc_mon)
printVarSummary(probcu_mon)
printVarSummary(rcev_mon)
printVarSummary(probpc_mon)

;**************************************************************
        res=True
        res@cnLinesOn=False
        res@cnFillOn=True
        res@gsnAddCyclic=False
        res@mpMaxLatF=latNN
        res@mpMinLatF=latSS
        res@mpMinLonF=lonLL+0.5
        res@mpMaxLonF=lonRR
        res@gsnDraw=False
        res@gsnFrame=False
        res@cnFillPalette="MPL_RdYlBu"

        res@cnLevelSelectionMode="ExplicitLevels"
        res@cnLevels=(/fspan(-2, 2, 9)/)
        res@cnFillColors=(/33,40,50,56,62,78,81,94,99,105/)
        res@cnInfoLabelOn = False
        ;res@cnLineLabelsOn=False
                res@lbLabelBarOn=False
 res2=res
        resv1                         =True
        resv1@gsnDraw                 =False
        resv1@gsnFrame                =False
        resv1@gsnAddCyclic=False
     resv1@vcGlyphStyle     = "LineArrow"   ; curly vectors"Fillarrow"
    resv1@vcFillArrowEdgeColor          ="black"
    resv1@vcFillArrowFillColor          ="black"
 
    resv1@vcFillArrowEdgeThicknessF      =0.02
    resv1@vcMinMagnitudeF=0.03
    resv1@vcFillArrowHeadInteriorXF      =0.075
    resv1@vcFillArrowHeadXF              =0.1
    resv1@vcFillArrowHeadYF              =0.05
    resv1@vcFillArrowWidthF              =0.025
    resv1@vcRefLengthF                   =0.015    ;单位长度箭头在图中的长度
    resv1@vcRefMagnitudeF                =1
    resv1@vcMinDistanceF                 =0.02

    resv1@vcRefAnnoPerimOn               =False  ;关闭边框
    resv1@vcMinAnnoOn                    =False 

    resv1@vcRefAnnoOn                    =True
    resv1@vcRefAnnoString1On             =False
    resv1@vcRefAnnoString2On             =True    
    resv1@vcRefAnnoBackgroundColor       ="white"
    resv1@vcRefAnnoFontHeightF           =0.01
    resv1@vcRefAnnoPerimOn               =True
    resv1@vcRefAnnoSide                  ="Bottom"
    resv1@vcRefAnnoString2              ="1 m/s"
    resv1@vcRefAnnoString1On             =False
    resv1@vcRefAnnoString2On             =True 
     resv1@gsnSpreadColors     = True
 resv1@gsnSpreadColorEnd   = 18
 resv1@gsnSpreadColorStart  = 1
 resv1@lbLabelBarOn        = False
     resv1@vcLineArrowThicknessF=1.5
    resv1@vcVectorDrawOrder ="PostDraw"
    resv1@vcRefAnnoOrthogonalPosF = -.12

    resv2=resv1

    resv1@vcFillArrowEdgeColor           ="red" 
    resv1@vcFillArrowFillColor           ="red"
    resv2@vcFillArrowEdgeColor           ="black" 
    resv2@vcFillArrowFillColor           ="black"


            opt=True
        opt@gsnShadeFillType="pattern"
        opt@gsnShadeLow    =17
        opt@gsnShadeFillScaleF=0.005
        opt@gsnShadeFillDotSizeF=0.02 
opt2=opt


                hres=True
        hres@gsnAddCyclic=True
        hres@cnLinesOn=True
        hres@cnFillOn=False
        hres@cnInfoLabelOn=False
        ;hres@gsnLeftString=""
        ;'hres@gsnRightString=""

        hres@tiMainString=""
        hres@cnLevelSelectionMode="ExplicitLevels"
        hres@cnLevels=(/1500/)
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

            resb   =True
        resb@cnFillOn=False
        resb@cnLinesOn=False

        resb@gsnLeftString=""
        resb@gsnRightString=""
        resb@cnLevelSelectionMode="ExplicitLevels"
        resb@cnLevels=(/0.1/)
        resb@cnInfoLabelOn = False
        resb@cnLineDashPattern=13
        resb@gsnAddCyclic=False
        resb@gsnDraw=False
        resb@gsnFrame=False
        resb@cnLineLabelsOn=False

base=new((/2,3/), graphic)
plotep=new((/3/), graphic)
plotev=new((/3/), graphic)
plotcp=new((/3/), graphic)
plotcv=new((/3/), graphic)


    do k=0,2,1
;*****obs**************************
kk=k+6
      
        res@gsnLeftString="month:"+kk+"  lead:"+i
        res@gsnRightString="ERA-interim"
         
        res2@gsnLeftString="month:"+kk+"  "+"  lead:"+i
        res2@gsnRightString="CFSv2"

        base(0,k)=gsn_csm_contour_map_overlay(wks(k), rcpe_mon(k,:,:), hgt, res, hres)
        plotep(k)=gsn_csm_contour(wks(k),probpe_mon(k,:,:) , resb)
        plotep(k)=gsn_contour_shade(plotep(k), 0.1, 100, opt)
        plotev(k)=gsn_csm_vector_scalar(wks(k), rceu_mon(k,:,:), rcev_mon(k,:,:), probe_mon(k,:,:), resv1)
        overlay(base(0,k), plotep(k))
        overlay(base(0,k), plotev(k))
        ;draw(base(0,k))
;*****Hi;nd***********************
        base(1,k)=gsn_csm_contour_map_overlay(wks(k), rcpc_mon(k,:,:), hgt, res2, hres)
        plotcp(k)=gsn_csm_contour(wks(k),probpc_mon(k,:,:) , resb)
        plotcp(k)=gsn_contour_shade(plotcp(k), 0.1, 100, opt)
        plotcv(k)=gsn_csm_vector_scalar(wks(k), rccu_mon(k,:,:), rccv_mon(k,:,:), probc_mon(k,:,:), resv2)
        overlay(base(1,k), plotcp(k))
        overlay(base(1,k), plotcv(k))
        ;draw(base(1,k))
        resp                          =True
        resp@gsnPanelCenter           =True ;排列时居中对齐每行图
        resp@gsnPanelDebug            =True ;在图形中显示图形的坐标等信息
        resp@gsnPanelFigureStrings    =(/"(a)","(b)"/) ;为每幅图添加标号
        resp@gsnPanelFigureStringsBackgroundFillColor="white"
        resp@gsnPanelFigureStringsFontHeightF =0.01
        resp@amJust                   ="BottomLeft"
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
        ;resp@txString          ="Hind-Obs_May"
        ;resp2@txString          ="Hind-Obs_June"
        ;resp3@txString          ="Hind-Obs_July"
        ;resp4@txString          ="Hind-Obs_August"
        gsn_panel(wks(k), base(:,k), (/1,2/), resp)
    end do        
end
