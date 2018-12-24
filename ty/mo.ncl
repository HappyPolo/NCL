load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
    wks = gsn_open_wks("eps", "/mnt/e/scripts/ncl/ty/mo_")
    ft = addfile("/mnt/e/data/ty/air.nc", "r")
    fu = addfile("/mnt/e/data/ty/uwnd.nc", "r")
    fv = addfile("/mnt/e/data/ty/vwnd.nc", "r")
    fd = addfile("/mnt/e/data/ty/div.nc", "r")
    fq = addfile("/mnt/e/data/ty/shum.nc", "r")
    fsp = addfile("/mnt/e/data/ty/sp.nc", "r")
    u = short2flt(fu->u(:,:,:,:))
    v = short2flt(fv->v(:,:,:,:))
    T = short2flt(ft->t)
    q = short2flt(fq->q)
    sp = short2flt(fsp->sp)
    T0 = T
    T0 = 273.15
    t = T-T0
    copy_VarCoords(T, t)
printVarSummary(q)
    p0 = u&level
    p = p0(::-1)

    qu = u
    qv = v
    qu = q*u
    qv = q*v
copy_VarMeta(q,qu)
copy_VarMeta(q,qv)
    linlog=1
    pbot=max(p)
    ptop=min(p)     
    g=9.8
    print(p)
    vint_qu=vibeta(p,qu(time|:,latitude|:,longitude|:,level|:),linlog,sp,pbot,ptop)/g*100  
copy_VarMeta(qu(:,0,:,:),vint_qu)
    vint_qv=vibeta(p,qv(time|:,latitude|:,longitude|:,level|:),linlog,sp,pbot,ptop)/g*100  
copy_VarMeta(qv(:,0,:,:),vint_qv)

    mm=sqrt(vint_qu^2+vint_qv^2)
copy_VarMeta(vint_qu,mm)
    mh=sqrt((qu/g*100)^2+(qv/g*100)^2)
    copy_VarCoords(u, mh)


    

    res = True

    res@gsnFrame = False
    res@gsnDraw = False

    res@mpMaxLatF = 60
    res@mpMinLatF = 10
    res@mpMinLonF = 80
    res@mpMaxLonF = 170

    res@cnLinesOn = False
    res@cnFillOn = True
    res@cnFillPalette = "GMT_drywet"

    res@cnInfoLabelOn = False

    res@cnLevelSelectionMode = "ManualLevels"
    res@cnMaxLevelValF = 400
    res@cnMinLevelValF = 0
    res@cnLevelSpacingF = 40

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

    res@gsnRightString = "units:"+"kg (m*s)~S~-1"
    res@gsnLeftString = "vaper_flux"

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
    res@lbLabelBarOn             =False

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
  res@mpFillBoundarySets         = "National"
  res@mpOutlineBoundarySets      = "National"
  ; res@mpNationalLineColor        = "Red"
  ; res@mpProvincialLineColor      = -1
  ; res@mpGeophysicalLineColor     = "Red"
  res@mpNationalLineThicknessF   = 1
  ; res@mpProvincialLineThicknessF = 1

    resv = True
    resv@gsnDraw = False
    resv@gsnFrame = False
    resv@gsnLeftString = ""
    resv@gsnRightString = ""


    resv@vcGlyphStyle = "CurlyVector"
    resv@vcLineArrowColor          ="black"
    resv@vcLineArrowThicknessF     = 1.5
    ; ; res@vcRefAnnoPerimOn 
    resv@vcRefAnnoOn               =True
    resv@vcRefAnnoBackgroundColor  ="white"
    resv@vcRefAnnoFontHeightF      =0.005
    resv@vcRefAnnoOrthogonalPosF   =-0.25
    resv@vcRefAnnoParallelPosF     =1.
    resv@vcRefAnnoPerimOn          =True
    resv@vcRefAnnoArrowUseVecColor = False
    resv@vcRefAnnoArrowLineColor   ="Black"
    resv@vcRefAnnoSide             ="Bottom"
    resv@vcRefAnnoString1On        =False ;参考箭头上方字符
    resv@vcRefAnnoString2On        =True ;参考箭头下方字符

    resv@vcRefMagnitudeF = 50
    resv@vcRefLengthF = 0.05
    resv@vcMinDistanceF = 0.025

    resv@vcRefAnnoString2          ="50 kg (m*s)~S~-1"   




    lnres=True
    lnres@gsLineThicknessF=3.
    lnres@gsLineDashPattern=1
    lnres@gsFillColor = "gray"

base = new(4, graphic)
plot= new(4, graphic)

time = cd_calendar(T&time, -5)
id = (/7,8,9,10/)
do hh =0,3
    i = id(hh)-1
        res@tiMainString=sprinti("%4i", time(i,0))+"-"+sprinti("%02i", time(i,1))+"-"\
    +sprinti("%02i", time(i,2))+" "+sprinti("%02i", time(i,3))+":00 (GMT)"

    base(hh) = gsn_csm_contour_map_ce(wks, mm(i,:,:), res)
    plot(hh) = gsn_csm_vector(wks, vint_qu(i,:,:), vint_qv(i,:,:), resv)
    overlay(base(hh), plot(hh))   
    ; plot1 = gsn_add_shapefile_polygons(wks, plot, "/mnt/e/scripts/ncl/shapefile/tibetan/tibetan.shp", lnres)
; maximize_output(wks, False)
end do 
    resp                          =True
    resp@gsnPanelCenter           =True ;排列时居中对齐每行图
    resp@gsnPanelDebug            =True ;在图形中显示图形的坐标等信息
    ; resp@gsnPanelFigureStringsJust = True
    resp@gsnPanelFigureStrings    =(/"(a)","(b)","(c)"/) ;为每幅图添加标号
    resp@gsnPanelFigureStringsBackgroundFillColor="white"
    resp@gsnPanelFigureStringsFontHeightF =0.012
    ; resp@gsnPanelTick
    resp@amJust                   ="BottomLeft"
    resp@gsnPanelFigureStringsPerimOn     =False ;序号加边框
    resp@gsnPanelLabelBar         =True ;多图公用一个色标
    resp@gsnLeftString            ="gpm"
    resp@gsnRightString           =""
    resp@gsnMaximize              =False
    resp@txString                 =""
    resp@txFontHeightF            = 0.05
    ; resp@gsnpanfi
    ; resp@txPosYF                  = 0.85
    resp@gsnPanelLabelBar         =True
    resp@gsnPanelFigureStringsPerimOn=True
    ; resp@lbLabelOffsetF           =0.1 
    resp@lbLabelFontHeightF       =0.026
    resp@lbLabelFontColor         ="black"
    resp@lbLabelFontThicknessF    =2
    resp@lbLabelStride            =1 
    resp@pmLabelBarOrthogonalPosF =-0.05
    ; resp@gsn
    resp@lbBoxEndCapStyle         = "TriangleBothEnds"
    resp@pmLabelBarWidthF         =0.6 ;宽度
resp@pmLabelBarHeightF        =0.05 ;高度
    ; resp@gsnRightString = "units:"+"~S~o~N~"+"C"
    ; resp@gsnLeftString = "air_temperature"
    ; resp@gsnpanel
    
        gsn_panel(wks, base, (/2,2/), resp)
end
