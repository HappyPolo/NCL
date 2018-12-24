load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

    ft = addfile("/mnt/e/data/ty/prc.nc", "r")
    ; fu = addfile("/mnt/e/data/ty/uwnd.nc", "r")
    ; fv = addfile("/mnt/e/data/ty/vwnd.nc", "r")
    ; fd = addfile("/mnt/e/data/ty/div.nc", "r")
    ; u = short2flt(fu->u(:,:,:,:))
    ; v = short2flt(fv->v(:,:,:,:))
    T = short2flt(ft->tp)
    T0 = T
    T0 = 1000
    t = T*T0
    copy_VarCoords(T, t)

    

    res = True

    res@gsnFrame = False
    res@gsnDraw = False

    res@mpMaxLatF = 80
    res@mpMinLatF = 10
    res@mpMinLonF = 30
    res@mpMaxLonF = 160

    res@cnLinesOn = True
    res@cnFillOn = True
    res@cnFillPalette = "WhBlGrYeRe"

    res@cnInfoLabelOn = False

    res@cnLevelSelectionMode = "ManualLevels"
    ; res@cnMaxLevelValF = 24
    ; res@cnMinLevelValF = -24
    ; res@cnLevelSpacingF = 2

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

    res@gsnRightString = "units:"+"~S~o~N~"+"C"
    res@gsnLeftString = ""

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
res@mpGeophysicalLineThicknessF=0.5 

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




    lnres=True
    lnres@gsLineThicknessF=3.
    lnres@gsLineDashPattern=1
    lnres@gsFillColor = "gray"



    wks = gsn_open_wks("x11", "/mnt/e/scripts/ncl/ty/prc/prc")
time = cd_calendar(T&time, -5)
time0 = cd_calendar(T&time, -3)
; print(time0)
id = ind(time(:,2).le.13.and.time(:,2).ge.10)
print(time0(id))
do i =min(id),max(id)-1
        res@tiMainString=sprinti("%4i", time(i,0))+"-"+sprinti("%02i", time(i,1))+"-"\
    +sprinti("%02i", time(i,2))+" "+sprinti("%02i", time(i,3))+":00 (GMT)"

    base = gsn_csm_contour_map_ce(wks, t(i,:,:), res)
    ; plot = gsn_csm_vector(wks, u(i,{850},:,:), v(i,{850},:,:), resv)
    ; overlay(base, plot)   
    plot1 = gsn_add_shapefile_polygons(wks, base, "/mnt/e/scripts/ncl/shapefile/tibetan/tibetan.shp", lnres)
maximize_output(wks, False)
end do 

system("cd prc && /usr/bin/convert"+" -delay "+ "30" +" *.png prc.gif")
end