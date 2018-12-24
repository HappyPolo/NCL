load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

    ft = addfile("/mnt/e/data/ty/prc/prc_obs.nc", "r")
    ; fu = addfile("/mnt/e/data/ty/uwnd.nc", "r")
    ; fv = addfile("/mnt/e/data/ty/vwnd.nc", "r")
    ; fd = addfile("/mnt/e/data/ty/div.nc", "r")
    ; u = short2flt(fu->u(:,:,:,:))
    ; v = short2flt(fv->v(:,:,:,:))
    T = (ft->T)
    T0 = T
    T0 = 1000
    t = T
    copy_VarCoords(T, t)

    
lat = T&lat
lon = T&lon
    res = True

    res@gsnFrame = False
    res@gsnDraw = False

    res@mpMaxLatF = max(lat)+0.5
    res@mpMinLatF = min(lat)-0.5
    res@mpMinLonF = min(lon)-0.5
    res@mpMaxLonF = max(lon)+0.5

    res@cnLinesOn = False
    res@cnFillOn = True
    res@cnFillPalette = "WhBlGrYeRe"

    res@cnInfoLabelOn = False

    res@cnLevelSelectionMode = "ManualLevels"
    res@cnMaxLevelValF = 30
    res@cnMinLevelValF = 2
    res@cnLevelSpacingF = 2

res@tmXBLabelFontHeightF         = 0.024
res@tmYLLabelFontHeightF         = 0.024
res@tmXBLabelFontThicknessF      = 1.5
res@tmYLLabelFontThicknessF      = 1.5
res@tiMainFontHeightF            =0.034


res@tiMainOffsetYF = -0.03
res@gsnAddCyclic = False


    res@cnLineThicknessF = 0.35
    ; res@cnLineDashPattern            =2 ;线型为2虚线
    ; res@cnLineDashSegLenF            =0.05 ;虚线段长度
    res@cnLineColor                  ="black"

    res@gsnRightString = "units:"+"mm/day"
    res@gsnLeftString = "prc"

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
; res@mpGeophysicalLineDashPattern=16
; res@mpGeophysicalLineDashSegLenF=0.2 ;虚线段长度
res@mpGeophysicalLineThicknessF=1.5 

res@mpFillOn=True
res@mpFillColor="gray"
res@mpInlandWaterFillColor = "gray" ;内陆湖泊白色
res@mpLandFillColor = 0 
res@mpMonoFillColor = False 
res@mpOceanFillColor = 0


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

    resv@vcRefAnnoString2          ="10 m/s"   


    res@mpOutlineMaskingOn=True ;打开边界线mask
    res@mpOutlineOn=True ;绘制边界线
    ; res@mpOutlineSpecifiers=(/"China"/) ;指定绘图边界
    res@mpFillOn                   = True
    res@mpDataSetName              = "/mnt/e/scripts/ncl/NCL-Chinamap/database/Earth..4"
    res@mpDataBaseVersion          = "MediumRes" ; or "Ncarg4_1"
    res@mpAreaMaskingOn            = True
    res@mpMaskAreaSpecifiers       = (/"China"/)
    res@mpOutlineSpecifiers        = (/"China","China:Provinces"/)
      res@mpLandFillColor            := "white"
  res@mpInlandWaterFillColor     = "white"
  res@mpOceanFillColor           := "white"
  res@mpFillBoundarySets         = "NoBoundaries"
  res@mpOutlineBoundarySets      = "NoBoundaries"
  res@mpNationalLineColor        = "black"
  res@mpProvincialLineColor      = "black"
  res@mpGeophysicalLineColor     = "black"
  res@mpNationalLineThicknessF   = 2
  res@mpProvincialLineThicknessF = 1


  nhres                          = res
  nhres@gsnMaximize              = False

  nhres@vpHeightF                = 0.11    
  nhres@vpWidthF                 = 0.11
    
  nhres@mpMinLatF                =   2.0    
  nhres@mpMaxLatF                =  23.0
  nhres@mpMinLonF                = 105.0
  nhres@mpMaxLonF                = 123.0

  nhres@lbLabelBarOn             = False
  nhres@tmXBOn                   = False 
  nhres@tmXTOn                   = False
  nhres@tmYLOn                   = False
  nhres@tmYROn                   = False
  nhres@gsnLeftString            = ""
  nhres@gsnRightString           = ""

  river                          = True
  river@gsLineThicknessF         = 3.0       
  river@gsLineColor              = "yellow"



;--- add City --- 
  city                           = True
  city@gsLineThicknessF          = 0.5       
  city@gsLineColor               = "grey"


  adres                          = True
  adres@amParallelPosF           = 0.495 ; -0.5 is the left edge of the plot.
  adres@amOrthogonalPosF         = 0.49  ; -0.5 is the top edge of the plot.
  adres@amJust                   = "BottomRight"

  ; plotnh = gsn_add_annotation(map,map_nanhai,adres)
    lnres=True
    lnres@gsLineThicknessF=3.
    lnres@gsLineDashPattern=1
    lnres@gsFillColor = "gray"


res@lbLabelBarOn             =False
    wks = gsn_open_wks("eps", "/mnt/e/scripts/ncl/ty/prc/prc_obs")
; time = cd_calendar(T&time, -5)
; time0 = cd_calendar(T&time, -3)
; ; print(time0)
; id = ind(time(:,2).le.13.and.time(:,2).ge.10)
; print(time0(id))
  ; map_nanhai = gsn_csm_contour_map(wks,t,nhres)
time = (/"2005-03-10","2005-03-11","2005-03-12","2005-03-13"/)
base = new(4, graphic)
do i = 0,3
        res@tiMainString=time(i)

    base(i) = gsn_csm_contour_map_ce(wks, t(i,:,:), res)
  ; plotrv = gsn_add_shapefile_polylines(wks,base,"/mnt/e/scripts/ncl/NCL-Chinamap/cnmap_NetCDF/river.nc",river)

  ; plotct = gsn_add_shapefile_polylines(wks,base,"/mnt/e/scripts/ncl/NCL-Chinamap/cnmap_NetCDF/diquJie_polyline.nc",city)
    
    map_nanhai = gsn_csm_contour_map(wks,t(i,:,:),nhres)
    ; plot = gsn_csm_vector(wks, u(i,{850},:,:), v(i,{850},:,:), resv)
    ; overlay(base, plot)   
    ; plot1 = gsn_add_shapefile_polygons(wks, base, "/mnt/e/scripts/ncl/shapefile/tibetan/tibetan.shp", lnres)

    plotnh = gsn_add_annotation(base(i),map_nanhai,adres)
; maximize_output(wks, False)
end do 
    resp                          =True
    resp@gsnPanelCenter           =True ;排列时居中对齐每行图
    resp@gsnPanelDebug            =True ;在图形中显示图形的坐标等信息
    resp@gsnPanelFigureStrings    =(/"(a)","(b)","(c)","(d)"/) ;为每幅图添加标号
    resp@gsnPanelFigureStringsBackgroundFillColor="white"
    resp@gsnPanelFigureStringsFontHeightF =0.012
    ; resp@gsnPanelTick
    resp@amJust                   ="BottomLeft"
    resp@gsnPanelFigureStringsPerimOn     =True ;序号加边框
    resp@gsnPanelLabelBar         =True ;多图公用一个色标
    resp@gsnLeftString            =""
    resp@gsnRightString           =""
    resp@gsnMaximize              =False
    resp@txString                 ="Precipitation"
    resp@txFontHeightF            = 0.05
    resp@txPosYF                  = 0.85
    resp@gsnPanelLabelBar         =True
    resp@gsnPanelFigureStringsPerimOn=True
    ; resp@gsnpanel
    
        gsn_panel(wks, base, (/2,2/), resp)
; system("cd prc && /usr/bin/convert"+" -delay "+ "30" +" *.png prc.gif")
end