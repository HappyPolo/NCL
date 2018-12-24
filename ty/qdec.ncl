load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

    ft = addfile("/mnt/e/data/ty/air.nc", "r")
    fu = addfile("/mnt/e/data/ty/u_2005.nc", "r")
    fv = addfile("/mnt/e/data/ty/v_2005.nc", "r")
    fd = addfile("/mnt/e/data/ty/div.nc", "r")
    fq = addfile("/mnt/e/data/ty/q_2005.nc", "r")
    fq0 = addfile("/mnt/e/data/ty/shum.nc", "r")
    fsp = addfile("/mnt/e/data/ty/sp.nc", "r")
    u = (fu->u(:,:,:,:))
    v = (fv->v(:,:,:,:))
    T = short2flt(ft->t)
    q0 =short2flt(fq0->q)
    q = (fq->q)
    sp = short2flt(fsp->sp)
    T0 = T
    T0 = 273.15
    t = T-T0
    copy_VarCoords(T, t)
printVarSummary(q)
    p0 = u&level
    p = p0(::-1)

;     qu = u
;     qv = v
;     qu = q0*u
;     qv = q0*v
; copy_VarMeta(q0,qu)
; copy_VarMeta(q0,qv)
;     linlog=1
;     pbot=max(p)
;     ptop=min(p)     
;     g=9.8
;     print(p)
;     vint_qu=vibeta(p,qu(time|:,latitude|:,longitude|:,level|:),linlog,sp,pbot,ptop)/g*100  
; copy_VarMeta(qu(:,0,:,:),vint_qu)
;     vint_qv=vibeta(p,qv(time|:,latitude|:,longitude|:,level|:),linlog,sp,pbot,ptop)/g*100  
; copy_VarMeta(qv(:,0,:,:),vint_qv)

;     mm=sqrt(vint_qu^2+vint_qv^2)
; copy_VarMeta(vint_qu,mm)


    

    res = True

    res@gsnFrame = False
    res@gsnDraw = False

    res@mpMaxLatF = 80
    res@mpMinLatF = 10
    res@mpMinLonF = 30
    res@mpMaxLonF = 160

    res@cnLinesOn = False
    res@cnFillOn = True
    res@cnFillPalette = "MPL_BrBG"

    res@cnInfoLabelOn = False

    res@cnLevelSelectionMode = "ManualLevels"
    res@cnMaxLevelValF = 0.008
    res@cnMinLevelValF = -0.008
    res@cnLevelSpacingF = 0.001

res@tmXBLabelFontHeightF         = 0.024
res@tmYLLabelFontHeightF         = 0.024
res@tmXBLabelFontThicknessF      = 1.5
res@tmYLLabelFontThicknessF      = 1.5
res@tiMainFontHeightF            =0.034


res@tiMainOffsetYF = -0.03



    res@cnLineThicknessF = 0.35
    ; res@cnLineDashPattern            =2 ;线型为2虚线
    ; res@cnLineDashSegLenF            =0.05 ;虚线段长度
    res@cnLineColor                  ="black"

    res@gsnRightString = "units:"+"kg/kg"
    res@gsnLeftString = "q"

res@gsnMajorLatSpacing                       =20
res@gsnMinorLatSpacing                       =10
res@gsnMajorLonSpacing                       =10
res@gsnMinorLonSpacing                       =5

    res@pmTickMarkDisplayMode="Always"
    
    res@pmLabelBarWidthF         =0.6 
    res@pmLabelBarHeightF        =0.06 
    
    res@lbLabelOffsetF           =0.1 
    res@lbLabelFontHeightF       =0.026
    res@lbLabelFontColor         ="black"
    res@lbLabelFontThicknessF    =2
    res@lbLabelStride            =1 
    res@pmLabelBarOrthogonalPosF =0.25
    res@lbBoxEndCapStyle         = "TriangleBothEnds"

res@mpGridAndLimbOn=True ;绘制经纬线
res@mpGridLatSpacingF=15 ;纬线间隔
res@mpGridLineDashPattern=2 ;线型
res@mpGridLineThicknessF=0.5
res@mpGridLonSpacingF=15 ;经线间隔
res@mpGridPolarLonSpacingF=15 ;极射赤面经线间隔
res@pmTickMarkDisplayMode="Always" ;坐标标签添加符号度


;;;;;;;;;;;;;;;;;;;;;;;;;地图数据
res@mpDataBaseVersion="MediumRes" ;中等分辨率，默认为低等
res@mpDataSetName="Earth..4" ;


;;;;;;;;;;;;;;;;;;;;;;;;地图边线
res@mpGeophysicalLineColor="black" 
res@mpGeophysicalLineDashPattern=16
res@mpGeophysicalLineDashSegLenF=0.2 ;虚线段长度
res@mpGeophysicalLineThicknessF=1 

res@mpFillOn=True
res@mpFillColor="gray"
res@mpInlandWaterFillColor = "gray" ;内陆湖泊白色
res@mpLandFillColor = 0 
res@mpMonoFillColor = False 
res@mpOceanFillColor = 0

  ;   res@mpFillOn                   = True
  ;   res@mpDataSetName              = "/mnt/e/scripts/ncl/NCL-Chinamap/database/Earth..4"
  ;   res@mpDataBaseVersion          = "MediumRes" ; or "Ncarg4_1"
  ;   res@mpAreaMaskingOn            = True
  ;   res@mpMaskAreaSpecifiers       = (/"China"/)
  ;   res@mpOutlineSpecifiers        = (/"China","China:Provinces"/)
  ;     res@mpLandFillColor            := "white"
  ; res@mpInlandWaterFillColor     = "white"
  ; res@mpOceanFillColor           := "white"
  ; res@mpFillBoundarySets         = "National"
  ; res@mpOutlineBoundarySets      = "National"
  ; res@mpNationalLineColor        = "Red"
  ; res@mpProvincialLineColor      = -1
  ; res@mpGeophysicalLineColor     = "Red"
  res@mpNationalLineThicknessF   = 1.8
  ; res@mpProvincialLineThicknessF = 1

    resv = True
    resv@gsnDraw = False
    resv@gsnFrame = False
    resv@gsnLeftString = ""
    resv@gsnRightString = ""


    resv@vcGlyphStyle = "CurlyVector"
    resv@vcLineArrowColor          ="black"
    resv@vcLineArrowThicknessF     = 2.5
    ; ; res@vcRefAnnoPerimOn 
    resv@vcRefAnnoOn               =True
    resv@vcRefAnnoBackgroundColor  ="white"
    resv@vcRefAnnoFontHeightF      =0.008
    resv@vcRefAnnoOrthogonalPosF   =-0.5
    resv@vcRefAnnoParallelPosF     =1.
    resv@vcRefAnnoPerimOn          =True
    resv@vcRefAnnoArrowUseVecColor = False
    resv@vcRefAnnoArrowLineColor   ="Black"
    resv@vcRefAnnoSide             ="Bottom"
    resv@vcRefAnnoString1On        =False ;参考箭头上方字符
    resv@vcRefAnnoString2On        =True ;参考箭头下方字符

    resv@vcRefMagnitudeF = 10
    resv@vcRefLengthF = 0.05
    resv@vcMinDistanceF = 0.025

    resv@vcRefAnnoString2          ="50 m/s"   




    lnres=True
    lnres@gsLineThicknessF=3.
    lnres@gsLineDashPattern=1
    lnres@gsFillColor = "gray"



    wks = gsn_open_wks("png", "/mnt/e/scripts/ncl/ty/qd/qd")
time = ispan(20050301, 20050315, 1)
do i =0,14
        res@tiMainString=sprinti("%8i", time(i))

    base = gsn_csm_contour_map_ce(wks, q(i,{850},:,:), res)
    plot = gsn_csm_vector(wks, u(i,{850},:,:), v(i,{850},:,:), resv)
    overlay(base, plot)   
    ; plot1 = gsn_add_shapefile_polygons(wks, plot, "/mnt/e/scripts/ncl/shapefile/tibetan/tibetan.shp", lnres)
maximize_output(wks, False)
end do 

system("cd mo && /usr/bin/convert"+" -delay "+ "30" +" *.png mo.gif")
end
