
procedure add_lc_labels(wks,map,minlat,maxlat,minlon,maxlon,\
                        lat_spacing[1]:integer,lon_spacing[1]:integer)
local lat_values, nlat, lat1_ndc, lat2_ndc, lon1_ndc, lon2_ndc,slope,txres, \
lon_values, PI, RAD_TO_DEG, dum_lft, dum_rgt, dum_bot
begin
  PI         = 3.14159
  RAD_TO_DEG = 180./PI

;kk---Pick some "nice" values for the latitude labels.
  lat_values = ispan(toint(minlat),toint(maxlat),lat_spacing) * 1.
  nlat       = dimsizes(lat_values)
;
; We need to get the slope of the left and right min/max longitude lines.
; Use NDC coordinates to do this.
;
  lat1_ndc = new(1,float)
  lon1_ndc = new(1,float)
  lat2_ndc = new(1,float)
  lon2_ndc = new(1,float)
  datatondc(map,minlon,lat_values(0),lon1_ndc,lat1_ndc)
  datatondc(map,minlon,lat_values(nlat-1),lon2_ndc,lat2_ndc)
  if(lon2_ndc.eq.lon1_ndc) then
      print("add_lc_labels: error: not enough valid latitude values to generate labels")
      print("    You may need to decrease the lat_spacing")
      exit
  end if
  slope_lft = (lat2_ndc-lat1_ndc)/(lon2_ndc-lon1_ndc)

  datatondc(map,maxlon,lat_values(0),lon1_ndc,lat1_ndc)
  datatondc(map,maxlon,lat_values(nlat-1),lon2_ndc,lat2_ndc)
  if(lat2_ndc.eq.lat1_ndc) then
      print("add_lc_labels: error: not enough valid longitude values to generate labels")
      print("    You may need to decrease the lon_spacing")
      exit
  end if
  slope_rgt = (lat2_ndc-lat1_ndc)/(lon2_ndc-lon1_ndc)

;---Set some text resources
  txres               = True
  txres@txFontHeightF = 0.02
  txres@txPosXF       = 0.1
;
; Loop through lat values, and attach labels to the left and
; right edges of the masked LC plot.  The labels will be 
; rotated to fit the line better.
;
  dum_lft = new(nlat,graphic)    ; Dummy array to hold attached strings.
  dum_rgt = new(nlat,graphic)    ; Dummy array to hold attached strings.
  do n=0,nlat-1
; Add extra white space to labels.
    lat_label_rgt = "          "  + lat_values(n) + "~S~o~N~"

;---Check if North, South, or Zero
    if(lat_values(n).lt.0) then
      lat_label_lft = lat_values(n) + "~S~o~N~S          "
      lat_label_rgt = lat_label_rgt + "S"
    end if
    if(lat_values(n).gt.0) then
      lat_label_lft = lat_values(n) + "~S~o~N~N          "
      lat_label_rgt = lat_label_rgt + "N"
    end if
    if(lat_values(n).eq.0) then
      lat_label_lft = lat_values(n) + "~S~o~N~           "
    end if

;---Left label
    txres@txAngleF = RAD_TO_DEG * atan(slope_lft) - 90
    dum_lft(n) = gsn_add_text(wks,map,lat_label_lft,minlon,lat_values(n),txres)

;---Right label
    txres@txAngleF = RAD_TO_DEG * atan(slope_rgt) + 90
    dum_rgt(n) = gsn_add_text(wks,map,lat_label_rgt,maxlon,lat_values(n),txres)
  end do

;----------------------------------------------------------------------
; Now do longitude labels. These are harder because we're not
; adding them to a straight line.
;
; Loop through lon values, and attach labels to the bottom edge of the
; masked LC plot.
;
  delete(txres@txPosXF)
  txres@txPosYF = -5.0

;---Pick some "nice" values for the longitude labels.
  lon_values = ispan(toint(minlon+10),toint(maxlon-10),lon_spacing) * 1.
  nlon       = dimsizes(lon_values)

  dum_bot = new(nlon,graphic)    ; Dummy array to hold attached strings.

  do n=0,nlon-1
;
; For each longitude label, we need to figure out how much to rotate
; it, so get the approximate slope at that point.
;
    datatondc(map,lon_values(n)-0.25,minlat,lon1_ndc,lat1_ndc)
    datatondc(map,lon_values(n)+0.25,minlat,lon2_ndc,lat2_ndc)
    slope_bot = (lat1_ndc-lat2_ndc)/(lon1_ndc-lon2_ndc)
    txres@txAngleF  = atan(slope_bot) * RAD_TO_DEG
;
; Create longitude label. Add extra carriage returns to
; move label away from plot.
;
;---Check if East, West, or Zero
    lon_label_bot = "  ~C~  ~C~" + abs(lon_values(n)) + "~S~o~N~"
    if(lon_values(n).lt.0) then
      lon_label_bot = lon_label_bot + "W"
    end if
    if(lon_values(n).gt.0) then
      lon_label_bot = lon_label_bot + "E"
    end if

;---Attach to map.
    dum_bot(n) = gsn_add_text(wks,map,lon_label_bot,lon_values(n),minlat,txres)
  end do
end
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

    fu = addfile("/mnt/e/data/ty/uwnd.nc", "r")
    fv = addfile("/mnt/e/data/ty/vwnd.nc", "r")
    ft = addfile("/mnt/e/data/ty/air.nc", "r")

    u = short2flt(fu->u(:,:,::-1,:))
    v = short2flt(fv->v(:,:,::-1,:))

    T = short2flt(ft->t(:,:,::-1,:))
    T0 = T
    T0 = 273.15
    t = T-T0
    copy_VarCoords(T, t)
    ; print(u&latitude+"  "+v&latitude+"  "+t&latitude)

    t_grad_lon = t
    t_grad_lat = t

    t_grad_lon@long_name = "longitudinal gradient"
    t_grad_lat@long_name = "latitudinal gradient"
    t_grad_lat@units     = "K/m"
    t_grad_lon@units     = "K/m"

    gradsf(t,t_grad_lon, t_grad_lat)

    tu = t_grad_lon*u 
    tv = t_grad_lat*v



    ; t00 = T
    ; t00 = 100000
    t_adv = -(tu+tv)*10^5

    copy_VarCoords(u, t_adv)

       res = True
        maxlat = 60.
    minlat = 20.
    maxlon = 140.
    minlon = 80.
      lat_spacing = 30   ; use integers here
  lon_spacing = 30
    res@mpMaxLatF = 60
    res@mpMinLatF = 20
    res@mpMinLonF = 80
    res@mpMaxLonF = 140

    res@cnLinesOn = False
    res@cnFillOn = True
    res@cnFillPalette = "BlueWhiteOrangeRed"

    res@cnInfoLabelOn = False

    res@cnLevelSelectionMode = "ManualLevels"
    res@cnMaxLevelValF = 30
    res@cnMinLevelValF = -30
    res@cnLevelSpacingF = 2

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

    ; res@gsnRightString = "units:"+"~S~o~N~"+"C"
    ; res@gsnLeftString = "air_temperature"
res@gsnLeftString =""
res@gsnRightString=""
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

; res@mpFillOn=True
res@mpFillColor="gray"
res@mpInlandWaterFillColor = "gray" ;内陆湖泊白色
res@mpLandFillColor = 0 
res@mpMonoFillColor = False 
res@mpOceanFillColor = 0



res@cnInfoLabelOn = False



res@lbLabelBarOn             =False
res@cnLineLabelsOn               =False
    wks = gsn_open_wks("eps", "/mnt/e/scripts/ncl/ty/air_a")
time = cd_calendar(T&time, -5)
id=(/7,8,9,10/)
    base = new(4, graphic)
    res@gsnDraw =False
    res@gsnFrame =False

    res@mpProjection = "LambertConformal"
res@gsnMaskLambertConformal = True
do j =0,3
  i:= id(j)-2 
        res@tiMainString=sprinti("%4i", time(i,0))+"-"+sprinti("%02i", time(i,1))+"-"\
    +sprinti("%02i", time(i,2))+" "+sprinti("%02i", time(i,3))+":00 (GMT)"

    base(j) = gsn_csm_contour_map(wks, t_adv(i,{700},:,:), res)
add_lc_labels(wks,base(j),minlat,maxlat,minlon,maxlon,lat_spacing,lon_spacing)
 ; plot = gsn_csm_vector(wks, tu(i,{850},:,:), tv(i,{850},:,:), res)
end do 

; system("cd air && /usr/bin/convert"+" -delay "+ "30" +" *.png air.gif")
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
    resp@txString                 =""
    resp@txFontHeightF            = 0.05
    resp@txPosYF                  = 0.85
    resp@gsnPanelLabelBar         =True
    resp@gsnPanelFigureStringsPerimOn=True
    ; resp@lbLabelOffsetF           =0.1 
    resp@lbLabelFontHeightF       =0.026
    resp@lbLabelFontColor         ="black"
    resp@lbLabelFontThicknessF    =2
    resp@lbLabelStride            =1 
    resp@pmLabelBarOrthogonalPosF =-0.05
    resp@lbBoxEndCapStyle         = "TriangleBothEnds"
    resp@pmLabelBarWidthF         =0.6 ;宽度
resp@pmLabelBarHeightF        =0.05 ;高度

    ; resp@gsnpanel
    
        gsn_panel(wks, base, (/2,2/), resp)
; system("cd geo && /usr/bin/convert"+" -del


end
