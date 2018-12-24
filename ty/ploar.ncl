load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

    ft = addfile("/mnt/e/data/ty/geo.nc", "r")
    T = short2flt(ft->z)
    T0 = T
    T0 = 100
    t = T/T0
    copy_VarCoords(T, t)

    

    res = True

    ; res@mpMaxLatF = 80
    ; res@mpMinLatF = 10
    ; res@mpMinLonF = 30
    ; res@mpMaxLonF = 160

    res@cnLinesOn = True
    res@cnFillOn = True
    res@cnFillPalette = "MPL_winter"

    res@cnInfoLabelOn = False

    res@cnLevelSelectionMode = "ManualLevels"
    res@cnMaxLevelValF = 600
    res@cnMinLevelValF = 490
    res@cnLevelSpacingF = 4

res@tmXBLabelFontHeightF         = 0.024
res@tmYLLabelFontHeightF         = 0.024
res@tmXBLabelFontThicknessF      = 1.5
res@tmYLLabelFontThicknessF      = 1.5
res@tiMainFontHeightF            =0.034


res@tiMainOffsetYF = -0.03



    res@cnLineThicknessF = 1.5
    ; res@cnLineDashPattern            =2 ;线型为2虚线
    ; res@cnLineDashSegLenF            =0.05 ;虚线段长度
    res@cnLineColor                  ="black"

    res@gsnRightString = "units:"+" 10~S~2~N~ m~S~2~N~ s~S~-2~N"
    res@gsnLeftString = "Geopotential"

; res@gsnMajorLatSpacing                       =20
; res@gsnMinorLatSpacing                       =10
; res@gsnMajorLonSpacing                       =10
; res@gsnMinorLonSpacing                       =5

res@gsnPolar = "NH"

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

; res@mpFillColor="gray"
res@mpInlandWaterFillColor = "gray" ;内陆湖泊白色
res@mpLandFillColor = 0 
res@mpMonoFillColor = False 
res@mpOceanFillColor = 0


res@cnHighLabelsOn               =True
res@cnHighLabelBackgroundColor   =-1 ;背景透明
res@cnHighLabelFontHeightF       =0.014 ;字体高度
res@cnHighLabelAngleF = 0
res@cnHighLabelFontThicknessF = 1
; res@cnhigh

;;;;;;;;;;;;;;;;;;;;;;添加低值标签
res@cnLowLabelsOn                =True 
res@cnLowLabelBackgroundColor    =-1
res@cnLowLabelFontHeightF        =0.014

res@cnLowLabelAngleF = 0

res@cnLineLabelsOn = False
; res@cnLineLabelDensityF = 1
; res@cnLineLabelAngleF = 0
; res@cnLineLabelDensityF = 2
; res@cnLineLabelFontHeightF = 0.005





    wks = gsn_open_wks("png", "/mnt/e/scripts/ncl/ty/geo/geo")
time = cd_calendar(T&time, -5)
do i =0,15
        res@tiMainString=sprinti("%4i", time(i,0))+"-"+sprinti("%02i", time(i,1))+"-"\
    +sprinti("%02i", time(i,2))+" "+sprinti("%02i", time(i,3))+":00 (GMT)"

    plot1 = gsn_csm_contour_map_polar(wks, t(i,{500},:,:), res)
end do 

system("cd geo && /usr/bin/convert"+" -delay "+ "30" +" *.png geo.gif")
end