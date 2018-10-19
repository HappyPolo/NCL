load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

    f1=addfile("/home/ys-ug/data/era-interim/precip.mon.mean.nc", "r")
    pe0=f1->r(48:383,:,:)
    fh=addfile("/home/ys-ug/data/hgt.sfc.nc", "r")
    hgt=short2flt(fh->hgt(0,:,:))
    feu=addfile("/home/yangsong3/data-observation/ERA-interim/monthly/uwnd.mon.mean.nc", "r")
    eu1=short2flt((feu->u(48:383,{850},:,:)))
    fev=addfile("/home/yangsong3/data-observation/ERA-interim/monthly/vwnd.mon.mean.nc", "r")
    ev1=short2flt((fev->v( 48:383,{850},:,:)))
    f2=addfile("/home/yangsong3/lcz/data/cfsv2_output/pre/pre.em24.out.nc", "r")
    fcu=addfile("/home/yangsong3/lcz/data/cfsv2_output/u850/u850.em24.out.nc", "r")
    fcv=addfile("/home/yangsong3/lcz/data/cfsv2_output/v850/v850.em24.out.nc", "r")
wks=gsn_open_wks("x11", "/home/ys-ug/kt/prc_differ_test_monthly_smooth")
gsn_define_colormap(wks, "NCV_blue_red")
base5=new(4, graphic)
base6=new(4, graphic)
base7=new(4, graphic)
base8=new(4, graphic)
plot5=new(4, graphic)
plot6=new(4, graphic)
plot7=new(4, graphic)
plot8=new(4, graphic)
;***TP*******
latNN = 39
latSS = 24
lonRR = 1
lonLL = 72
    do i=0,9,30
        p=(f2->pre(:,i,::-1,:))
        cu0=fcu->ugrd(:,i,::-1,:)
        cv0=fcv->vgrd(:,i,::-1,:)
        printVarSummary(p)
        cu1=g2fsh_Wrap(cu0, (/181,360/))
        cv1=g2fsh_Wrap(cv0, (/181,360/))
        printVarSummary(cu1)
        pc0=g2fsh_Wrap(p, (/181,360/));将从高斯网格标量数量插值到固定网格（保留元数据）
        pc0=pc0*86400
        printVarSummary(pc0)  
        pe=pe0(lat|:,lon|:,time|:)
        pc=pc0(lat|:,lon|:,time|:)
        pr_era = dim_avg_n_Wrap(pe({latSS:latNN},\
                                   {lonLL:lonRR},:) ,(/0,1/))
        pr_cfsv2 = dim_avg_n_Wrap(pc({latSS:latNN},\
                                   {lonLL:lonRR},:), (/0,1/))
printVarSummary(eu1)
        cu=cu1(lat|:,lon|:,time|:)
        cv=cv1(lat|:,lon|:,time|:)
        eu=eu1(latitude|:,longitude|:,time|:)
        ev=ev1(latitude|:,longitude|:,time|:)
printVarSummary(cu)
printVarSummary(eu)
        rccu=regCoef(pr_cfsv2, cu({latSS:latNN},\
                                   {lonLL:lonRR},:))
        rccv=regCoef(pr_cfsv2, cv({latSS:latNN},\
                                   {lonLL:lonRR},:))
        rceu=regCoef(pr_era, eu({latSS:latNN},\
                                   {lonLL:lonRR},:))
        rcev=regCoef(pr_era, ev({latSS:latNN},\
                                   {lonLL:lonRR},:))
        rccu@units="m/s"
        copy_VarCoords(cu({latSS:latNN},\
                                   {lonLL:lonRR},0),rccu)
        copy_VarCoords(cu({latSS:latNN},\
                                   {lonLL:lonRR},0),rccv)
        copy_VarCoords(cu({latSS:latNN},\
                                   {lonLL:lonRR},0),rceu)
        copy_VarCoords(cu({latSS:latNN},\
                                   {lonLL:lonRR},0),rcev)
        printVarSummary(rccu)
        printVarSummary(rceu)
        tvalcu=onedtond(rccu@tval , dimsizes(rccu))
        dfcu  =onedtond(rccu@nptxy, dimsizes(rccu)) - 2
        bcu = tvalcu    ; b must be same size as tval (and df)
        bcu = 0.5
        probcu = betainc(dfcu/(dfcu+tvalcu^2),dfcu/2.0,bcu) 
        tvalcv=onedtond(rccv@tval , dimsizes(rccv))
        dfcv  =onedtond(rccv@nptxy, dimsizes(rccv)) - 2
        bcv = tvalcv    ; b must be same size as tval (and df)
        bcv = 0.5
        probcv = betainc(dfcv/(dfcv+tvalcv^2),dfcv/2.0,bcv) 
        tvaleu=onedtond(rceu@tval , dimsizes(rceu))
        dfeu  =onedtond(rceu@nptxy, dimsizes(rceu)) - 2
        beu = tvaleu    ; b must be same size as tval (and df)
        beu = 0.5
        probeu = betainc(dfeu/(dfeu+tvaleu^2),dfeu/2.0,beu) 
        tvalev=onedtond(rcev@tval , dimsizes(rcev))
        dfev  =onedtond(rcev@nptxy, dimsizes(rcev)) - 2
        bev = tvalev    ; b must be same size as tval (and df)
        bev = 0.5
        probev = betainc(dfev/(dfev+tvalev^2),dfev/2.0,bev)

;**************************************************************
        res=True
        res@cnLinesOn=True
        res@cnFillOn=False
        res@gsnAddCyclic=False
        res@lbLabelBarOn=False
        resv1                         =True

    resv1@gsnDraw                 =False
    resv1@gsnFrame                =False

    resv1@gsnLeftString                 =""
    resv1@gsnRightString                =""

    resv1@vcGlyphStyle                  ="CurlyVector"
    ;resv1@vcGlyphStyle                  ="FillArrow"
    resv1@vcFillArrowEdgeColor          ="black"
    resv1@vcFillArrowFillColor          ="black"

    resv1@vcMinMagnitudeF                =1.0
    resv1@vcMinDistanceF                 =0.03
 
    resv1@vcFillArrowEdgeThicknessF      =0.02
  
    resv1@vcFillArrowHeadInteriorXF      =0.075
    resv1@vcFillArrowHeadXF              =0.1
    resv1@vcFillArrowHeadYF              =0.05
    resv1@vcFillArrowWidthF              =0.025
    resv1@vcRefLengthF                   =0.045      ;单位长度箭头在图中的长度
    resv1@vcRefMagnitudeF                =10
    resv1@vcMinDistanceF                 =0.02 

    resv1@vcRefAnnoPerimOn               =False  ;关闭边框
    resv1@vcMinAnnoOn                    =True 

    resv1@vcRefAnnoOn                    =True
    resv1@vcRefAnnoBackgroundColor       ="white"
    resv1@vcRefAnnoFontHeightF           =0.015
    resv1@vcRefAnnoPerimOn               =False
    resv1@vcRefAnnoSide                  ="Top"
    resv1@vcRefAnnoString1On             =False
    resv1@vcRefAnnoString2On             =True
    plot1=gsn_csm_contour_map(wks, probcu, res)
    plot2=gsn_csm_vector_map(wks, rccu, rccv, res)

        end do
end
