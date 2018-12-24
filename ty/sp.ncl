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

    ft = addfile("/mnt/e/data/ty/slp.nc", "r")
    T = short2flt(ft->msl)
    T0 = T
    T0 = 100
    t = T/T0
    copy_VarCoords(T, t)

    

    res = True
        maxlat = 75.
    minlat = 10.
    maxlon = 160.
    minlon = 40.
      lat_spacing = 30   ; use integers here
  lon_spacing = 30
res@mpProjection = "LambertConformal"
res@gsnMaskLambertConformal = True
    res@gsnDraw = False
    res@gsnFrame = False

    res@mpMaxLatF = 75
    res@mpMinLatF = 10
    res@mpMinLonF = 40
    res@mpMaxLonF = 160

    res@cnLinesOn = False
    res@cnFillOn = True
    res@cnFillPalette = "CBR_wet"

    res@cnInfoLabelOn = False

    res@cnLevelSelectionMode = "ManualLevels"
    res@cnMaxLevelValF = 1060
    res@cnMinLevelValF = 1010
    res@cnLevelSpacingF = 2

res@tmXBLabelFontHeightF         = 0.024
res@tmYLLabelFontHeightF         = 0.024
res@tmXBLabelFontThicknessF      = 1.5
res@tmYLLabelFontThicknessF      = 1.5
res@tiMainFontHeightF            =0.034


res@tiMainOffsetYF = -0.03



    res@cnLineThicknessF = 0.15
    ; res@cnLineDashPattern            =2 ;线型为2虚线
    ; res@cnLineDashSegLenF            =0.05 ;虚线段长度
    res@cnLineColor                  ="black"

    res@gsnRightString = "units:"+"hPa"
    res@gsnLeftString = "slp"

; res@gsnMajorLatSpacing                       =20
; res@gsnMinorLatSpacing                       =10
; res@gsnMajorLonSpacing                       =10
; res@gsnMinorLonSpacing                       =5

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
res@cnHighLabelFontHeightF       =0.02 ;字体高度
res@cnHighLabelAngleF = 0
res@cnHighLabelFontThicknessF = 1
; res@cnHighLabelPerimOn = True 
; res@cnhighlabel
; res@cnhigh

;;;;;;;;;;;;;;;;;;;;;;添加低值标签
res@cnLowLabelsOn                =False
res@cnLowLabelBackgroundColor    =-1
res@cnLowLabelFontHeightF        =0.02

res@cnLowLabelAngleF = 0

res@cnLineLabelsOn = False
; res@cnLineLabelDensityF = 1
; res@cnLineLabelAngleF = 0
; res@cnLineLabelDensityF = 2
; res@cnLineLabelFontHeightF = 0.005

    lnres=True          
    lnres@gsLineThicknessF=6.
    lnres@gsLineDashPattern=1
    lnres@gsFillColor = "gray"
    lnres@gsLineColor = -1

res@tiMainOffsetYF = 0.03

    wks = gsn_open_wks("png", "/mnt/e/scripts/ncl/ty/sp/slp")
time = cd_calendar(T&time, -5)
do i =0,15
        res@tiMainString=sprinti("%4i", time(i,0))+"-"+sprinti("%02i", time(i,1))+"-"\
    +sprinti("%02i", time(i,2))+" "+sprinti("%02i", time(i,3))+":00 (GMT)"

    plot = gsn_csm_contour_map(wks, t(i,:,:), res)
        plot1 = gsn_add_shapefile_polylines(wks, plot, "/mnt/e/scripts/ncl/shapefile/tibetan/tibetan.shp", lnres)
  add_lc_labels(wks,plot,minlat,maxlat,minlon,maxlon,lat_spacing,lon_spacing)
maximize_output(wks, False)
end do 

system("cd sp && /usr/bin/convert"+" -delay "+ "30" +" *.png slp.gif")
end