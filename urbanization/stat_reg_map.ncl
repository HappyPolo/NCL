load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
;====================== read ===============================================
    f1            = addfile("/home/ys-ug/data/Station/5sta_daily_lc.nc","r")
    f2            = addfile("/home/ys-ug/data/Station/5sta_daily_tmin.nc","r")
    f3            = addfile("/home/ys-ug/data/Station/5sta_daily_tmax.nc","r")
    f4            = addfile("/home/ys-ug/data/Station/5sta_daily_wnd.nc","r")
    lc            = f1->f
    tmin          = f2->f
    tmax          = f3->f
    wnd           = f4->f

    windy_cly_tmin=new((/20819,5/),typeof(lc),getFillValue(tmin))
    copy_VarCoords(tmin, windy_cly_tmin)
    windy_cly_tmax=new((/20819,5/),typeof(lc),getFillValue(tmax))
    copy_VarCoords(tmin, windy_cly_tmax)
    calm_ccs_tmin=new((/20819,5/),typeof(lc),getFillValue(tmin))
    copy_VarCoords(tmin, calm_ccs_tmin)
    calm_ccs_tmax=new((/20819,5/),typeof(lc),getFillValue(tmax))
    copy_VarCoords(tmin, calm_ccs_tmax)
    
    wcy_tmin_mon = new((/684,5/), typeof(lc),getFillValue(tmin))  
    tmin_mon = new((/684,5/), typeof(lc),getFillValue(tmin))  
    wcy_tmax_mon = new((/684,5/), typeof(lc),getFillValue(tmin))
    ccs_tmin_mon = new((/684,5/), typeof(lc),getFillValue(tmin))
    ccs_tmax_mon = new((/684,5/), typeof(lc),getFillValue(tmin))
    wcy_tmin_ann = new((/57,5/), typeof(lc),getFillValue(tmin))
    wcy_tmax_ann = new((/57,5/), typeof(lc),getFillValue(tmin))
    ccs_tmin_ann = new((/57,5/), typeof(lc),getFillValue(tmin))
    ccs_tmax_ann = new((/57,5/), typeof(lc),getFillValue(tmin))
    tmin_ann = new((/57,5/), typeof(lc),getFillValue(tmin))  




do sta=0,4
;====================== 计算百分位数 =========================================
yrs = 1961
i=0
do ny = 0, 56
    year=yrs+ny
    if (isleapyear(year)) then
        nd=366
    else 
        nd =365
    end if
    opt=False
    opt@PrintStat=False
    lc_stat =stat_dispersion(lc(i:i+nd-1,sta), opt)
    wnd_stat=stat_dispersion(wnd(i:i+nd-1,sta), opt)
    delete(opt)
;=====================================================================================
;====================================================================================


    windy_cly_tmin(i:i+nd-1,sta) = where((wnd(i:i+nd-1,sta)\
        .ge.wnd_stat(9).and.(lc(i:i+nd-1,sta).ge.lc_stat(9))), tmin(i:i+nd-1,sta), tmin@_FillValue)
    calm_ccs_tmin(i:i+nd-1,sta) = where((wnd(i:i+nd-1,sta)\
        .le.wnd_stat(7).and.(lc(i:i+nd-1,sta).le.lc_stat(7))), tmin(i:i+nd-1,sta), tmin@_FillValue)
    windy_cly_tmax(i:i+nd-1,sta) = where((wnd(i:i+nd-1,sta)\
        .ge.wnd_stat(9).and.(lc(i:i+nd-1,sta).ge.lc_stat(9))), tmax(i:i+nd-1,sta), tmax@_FillValue)
    calm_ccs_tmax(i:i+nd-1,sta) = where((wnd(i:i+nd-1,sta)\
        .le.wnd_stat(7).and.(lc(i:i+nd-1,sta).le.lc_stat(7))), tmax(i:i+nd-1,sta), tmax@_FillValue)
 
    i=i+nd
end do
copy_VarCoords(tmin, windy_cly_tmin)
copy_VarCoords(tmin, calm_ccs_tmin)
copy_VarCoords(tmax, windy_cly_tmax)
copy_VarCoords(tmax, calm_ccs_tmax)

;============================ day to month =============================================
;======================================================================================
yrs = 1961
j=0
k=0
    wcy_tmin_mon(:,sta)=calculate_monthly_values(windy_cly_tmin(:,sta),"avg",0,False)
    wcy_tmax_mon(:,sta)=calculate_monthly_values(windy_cly_tmax(:,sta),"avg",0,False)
    ccs_tmin_mon(:,sta)=calculate_monthly_values(calm_ccs_tmin(:,sta),"avg",0,False)
    ccs_tmax_mon(:,sta)=calculate_monthly_values(calm_ccs_tmax(:,sta),"avg",0,False)
    copy_VarCoords(tmin(0:683,:), wcy_tmin_mon)
    copy_VarCoords(tmin(0:683,:), wcy_tmax_mon)
    copy_VarCoords(tmin(0:683,:), ccs_tmin_mon)
    copy_VarCoords(tmin(0:683,:), ccs_tmax_mon)
;========================= month to annual ==============================================
;========================================================================================
do ny = 0, 56
    year=yrs+ny
    
    wcy_tmin_ann(k,sta)=dim_avg_n_Wrap(wcy_tmin_mon(j:j+11,sta), 0)
    wcy_tmax_ann(k,sta)=dim_avg_n_Wrap(wcy_tmax_mon(j:j+11,sta), 0)
    ccs_tmin_ann(k,sta)=dim_avg_n_Wrap(ccs_tmin_mon(j:j+11,sta), 0)
    ccs_tmax_ann(k,sta)=dim_avg_n_Wrap(ccs_tmax_mon(j:j+11,sta), 0)

    k=k+1
    j=j+12
end do 
end do 
delete([/sta,k,j,ny,year/])

;======================= month to season ==================================================
;========================================================================================
wcy_tmin_MAM=new((/57,5/), typeof(lc),getFillValue(tmin))
wcy_tmin_JJA=new((/57,5/), typeof(lc),getFillValue(tmin))
wcy_tmin_SON=new((/57,5/), typeof(lc),getFillValue(tmin))
wcy_tmin_DJF=new((/57,5/), typeof(lc),getFillValue(tmin))
wcy_tmax_MAM=new((/57,5/), typeof(lc),getFillValue(tmin))
wcy_tmax_JJA=new((/57,5/), typeof(lc),getFillValue(tmin))
wcy_tmax_SON=new((/57,5/), typeof(lc),getFillValue(tmin))
wcy_tmax_DJF=new((/57,5/), typeof(lc),getFillValue(tmin))
ccs_tmin_MAM=new((/57,5/), typeof(lc),getFillValue(tmin))
ccs_tmin_JJA=new((/57,5/), typeof(lc),getFillValue(tmin))
ccs_tmin_SON=new((/57,5/), typeof(lc),getFillValue(tmin))
ccs_tmin_DJF=new((/57,5/), typeof(lc),getFillValue(tmin))
ccs_tmax_MAM=new((/57,5/), typeof(lc),getFillValue(tmin))
ccs_tmax_JJA=new((/57,5/), typeof(lc),getFillValue(tmin))
ccs_tmax_SON=new((/57,5/), typeof(lc),getFillValue(tmin))
ccs_tmax_DJF=new((/57,5/), typeof(lc),getFillValue(tmin))
do sta = 0,4
    wcy_tmin_MAM(:,sta)=month_to_season(wcy_tmin_mon(:,sta), "MAM")
    wcy_tmin_JJA(:,sta)=month_to_season(wcy_tmin_mon(:,sta), "JJA")
    wcy_tmin_SON(:,sta)=month_to_season(wcy_tmin_mon(:,sta), "SON")
    wcy_tmax_MAM(:,sta)=month_to_season(wcy_tmax_mon(:,sta), "MAM")
    wcy_tmax_JJA(:,sta)=month_to_season(wcy_tmax_mon(:,sta), "JJA")
    wcy_tmax_SON(:,sta)=month_to_season(wcy_tmax_mon(:,sta), "SON")
    ccs_tmin_MAM(:,sta)=month_to_season(ccs_tmin_mon(:,sta), "MAM")
    ccs_tmin_JJA(:,sta)=month_to_season(ccs_tmin_mon(:,sta), "JJA")
    ccs_tmin_SON(:,sta)=month_to_season(ccs_tmin_mon(:,sta), "SON")
    ccs_tmax_MAM(:,sta)=month_to_season(ccs_tmax_mon(:,sta), "MAM")
    ccs_tmax_JJA(:,sta)=month_to_season(ccs_tmax_mon(:,sta), "JJA")
    ccs_tmax_SON(:,sta)=month_to_season(ccs_tmax_mon(:,sta), "SON")

    

    t=12
    i=0
    do ny=0,55
        wcy_tmin_DJF(i,sta)=dim_avg_n_Wrap(wcy_tmin_mon(t-1:t+1,sta), 0)
        wcy_tmax_DJF(i,sta)=dim_avg_n_Wrap(wcy_tmax_mon(t-1:t+1,sta), 0)
        ccs_tmax_DJF(i,sta)=dim_avg_n_Wrap(ccs_tmax_mon(t-1:t+1,sta), 0)
        ccs_tmin_DJF(i,sta)=dim_avg_n_Wrap(ccs_tmin_mon(t-1:t+1,sta), 0)
        t =t +12
        i=i+1
    end do

end do 
copy_VarCoords(wcy_tmin_MAM, wcy_tmin_DJF)
copy_VarCoords(wcy_tmin_MAM, wcy_tmax_DJF)
copy_VarCoords(wcy_tmin_MAM, ccs_tmin_DJF)
copy_VarCoords(wcy_tmin_MAM, ccs_tmax_DJF)
copy_VarCoords(wcy_tmin_MAM, wcy_tmin_ann)
copy_VarCoords(wcy_tmin_MAM, wcy_tmax_ann)
copy_VarCoords(wcy_tmin_MAM, ccs_tmin_ann)
copy_VarCoords(wcy_tmin_MAM, ccs_tmax_ann)
;=======================================================================================
;============================= mean to anomaly =========================================
;=======================================================================================
    wcy_tmin_ano=dim_rmvmean_n_Wrap(wcy_tmin_ann(0:51,:), 0)                    ;=======
    wcy_tmax_ano=dim_rmvmean_n_Wrap(wcy_tmax_ann(0:51,:), 0)                    ;=======
    ccs_tmin_ano=dim_rmvmean_n_Wrap(ccs_tmin_ann(0:51,:), 0)                    ;=======
    ccs_tmax_ano=dim_rmvmean_n_Wrap(ccs_tmax_ann(0:51,:), 0)                    ;=======
    wcy_tmin_MAM_ano=dim_rmvmean_n_Wrap(wcy_tmin_MAM(0:51,:), 0)                ;=======
    wcy_tmax_MAM_ano=dim_rmvmean_n_Wrap(wcy_tmax_MAM(0:51,:), 0)                ;=======
    ccs_tmin_MAM_ano=dim_rmvmean_n_Wrap(ccs_tmin_MAM(0:51,:), 0)                ;=======
    ccs_tmax_MAM_ano=dim_rmvmean_n_Wrap(ccs_tmax_MAM(0:51,:), 0)                ;=======
    wcy_tmin_JJA_ano=dim_rmvmean_n_Wrap(wcy_tmin_JJA(0:51,:), 0)                ;=======
    wcy_tmax_JJA_ano=dim_rmvmean_n_Wrap(wcy_tmax_JJA(0:51,:), 0)                ;=======
    ccs_tmin_JJA_ano=dim_rmvmean_n_Wrap(ccs_tmin_JJA(0:51,:), 0)                ;=======
    ccs_tmax_JJA_ano=dim_rmvmean_n_Wrap(ccs_tmax_JJA(0:51,:), 0)                ;=======
    wcy_tmin_SON_ano=dim_rmvmean_n_Wrap(wcy_tmin_SON(0:51,:), 0)                ;=======
    wcy_tmax_SON_ano=dim_rmvmean_n_Wrap(wcy_tmax_SON(0:51,:), 0)                ;=======
    ccs_tmin_SON_ano=dim_rmvmean_n_Wrap(ccs_tmin_SON(0:51,:), 0)                ;=======
    ccs_tmax_SON_ano=dim_rmvmean_n_Wrap(ccs_tmax_SON(0:51,:), 0)                ;=======
    wcy_tmin_DJF_ano=dim_rmvmean_n_Wrap(wcy_tmin_DJF(0:51,:), 0)                ;=======
    wcy_tmax_DJF_ano=dim_rmvmean_n_Wrap(wcy_tmax_DJF(0:51,:), 0)                ;=======
    ccs_tmin_DJF_ano=dim_rmvmean_n_Wrap(ccs_tmin_DJF(0:51,:), 0)                ;=======
    ccs_tmax_DJF_ano=dim_rmvmean_n_Wrap(ccs_tmax_DJF(0:51,:), 0)                ;=======
;=======================================================================================

ccs_tmin=dim_avg_n_Wrap(wcy_tmin_ano, 1)

tmie=ispan(1961, 2012, 1)
rc_ccs_tmin=regline(tmie,ccs_tmin)
;============================= plot ==============================================
;=======================================================================================


;  ----------------------------------------------------------------------
; station_2.ncl
;----------------------------------------------------------------------
;
; Concepts illustrated:
;   - Drawing markers on a map indicating the locations of station data
;   - Generating dummy data using "random_uniform"
;   - Drawing markers of different sizes and colors on a map
;   - Drawing a custom legend outside of a map plot
;   - Attaching a custom labelbar to a plot
;
; This example creates some dummy station data, and then plots each
; value by coloring and sizing it depending on which range of values 
; it falls in.
;
; It creates two plots: one with a legend with markers and text,
; and one with a labelbar.
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;----------------------------------------------------------------------
; This procedure draws a legend with markers and text at the bottom
; of the screen
;----------------------------------------------------------------------
procedure draw_legend(wks,lat[*][*]:numeric,lon[*][*]:numeric,\
                      arr[*]:numeric,colors)
local gsres, txres, xleg, xtxt, yleg, ytxt, i, labels, nitems
begin
  narr   = dimsizes(arr)
  nmarkers = narr+1
  labels = new(nmarkers,string)

;---Generate the labels for each marker.
  do i = 0, nmarkers-1
    if (i.eq.0) then
      labels(i) = "x < " + arr(0)
    end if
    if (i.eq.nmarkers-1) then
      labels(i) = "x >= " + max(arr)
    end if
    if (i.gt.0.and.i.lt.nmarkers-1) then       
      labels(i) = arr(i-1) + " <= x < " + arr(i)
    end if
  end do
;
;  Create logical variables to hold the marker and text resources.
;  These markers are different than the XY markers, because they are not
;  associated with an XY plot. You can put these markers on any plot.
;
  gsres               = True
  gsres@gsMarkerIndex = 16          ; Use filled dots for markers.

  txres               = True
  txres@txFontHeightF = 0.015

;
; Loop through each grouping of markers, and draw them one set at
; a time, assigning the proper color and size with gsn_marker.
;
; At the same time, draw a legend showing the meaning of the markers.
;

  xleg = (/0.07,0.07,0.32,0.32,0.57,0.57,0.82,0.82/)   ; Location of
  xtxt = (/0.16,0.16,0.41,0.41,0.66,0.66,0.91,0.91/)   ; legend markers
  yleg = (/0.22,0.17,0.22,0.17,0.22,0.17,0.22,0.17/)   ; and text
  ytxt = (/0.22,0.17,0.22,0.17,0.22,0.17,0.22,0.17/)   ; strings.

  do i = 0, dimsizes(lat(:,0))-1
    if (.not.ismissing(lat(i,0)))
      gsres@gsMarkerColor      = colors(i)
      gsres@gsMarkerThicknessF = 0.7*(i+1)
;---Add marker and text for the legend.
      gsn_polymarker_ndc(wks,          xleg(i),yleg(i),gsres)
      gsn_text_ndc      (wks,labels(i),xtxt(i),ytxt(i),txres)
    end if
  end do

end

;----------------------------------------------------------------------
; This function attaches a labelbar to the given plot.
;----------------------------------------------------------------------
function attach_labelbar(wks,map,arr[*]:numeric,colors[*])
local lbres, vph, vpw, nboxes
begin
  getvalues map
    "vpHeightF" : vph
    "vpWidthF"  : vpw
  end getvalues

  nboxes = dimsizes(colors)
   
  lbres                    = True          ; labelbar only resources
  lbres@lbAutoManage       = False          ; Necessary to control sizes
  lbres@lbFillColors       = colors
  lbres@vpWidthF           = 0.7 * vpw     ; labelbar width
  lbres@vpHeightF          = 0.2 * vph     ; labelbar height
  lbres@lbMonoFillPattern  = True          ; Solid fill pattern
  lbres@lbLabelFontHeightF = 0.01          ; font height. default is small
  lbres@lbOrientation      = "horizontal"
  lbres@lbPerimOn          = False
  lbres@lbLabelAlignment   = "InteriorEdges"
  lbid = gsn_create_labelbar(wks,nboxes,""+toint(arr),lbres)

  amres                  = True
  amres@amJust           = "TopCenter"
  amres@amParallelPosF   =  0.0    ; Center
  amres@amOrthogonalPosF =  0.6    ; Bottom
  annoid = gsn_add_annotation(map,lbid,amres)
  return(annoid)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------

;---Set some needed arrays
  arr = (/0,1,2,3,4/)    ; bin settings (bin0 = < 0., 

                                         ; bin1 = 0.:4.999, etc.)
  narr = dimsizes(arr)
  labels = new(narr+1,string)   ; Labels for legend.

  npts = 5                                    ; Number of points.
  lat  = (/23.42,23.569,23.21,23.335,22.938/)        ; Create some dummy latitude
  lon  = (/113.237,113.616,113.482,113.828,113.319/)    ; and longitude data that
                                                ; will contain the position of
                                                ; our markers.

  R   = rc_ccs_tmin*1000   ; This is dummy data for determining
                                        ; how to color the markers.

;
; Create X and Y arrays to hold the points for each range and initialize
; them to missing values.  We want to use num_distinct_markers
; different colors, so we need num_distinct_markers sets of X and
; Y points.
;
  num_distinct_markers = dimsizes(arr)+1        ; number of distinct markers
  lat_new = new((/num_distinct_markers,dimsizes(R)/),float,-999)
  lon_new = new((/num_distinct_markers,dimsizes(R)/),float,-999)

;---Group the points according to which range they fall in.
  do i = 0, num_distinct_markers-1
    if (i.eq.0) then
      indexes = ind(R.lt.arr(0))
    end if
    if (i.eq.num_distinct_markers-1) then
      indexes = ind(R.ge.max(arr))
    end if
    if (i.gt.0.and.i.lt.num_distinct_markers-1) then       
      indexes = ind(R.ge.arr(i-1).and.R.lt.arr(i))
    end if
;
; Now that we have the set of indexes whose values fall within 
; the given range, take the corresponding lat/lon values and store
; them, so later we can color this set of markers with the appropriate
; color.
;
    if (.not.any(ismissing(indexes))) then 
      npts_range = dimsizes(indexes)   ; # of points in this range.
      lat_new(i,0:npts_range-1) = lat(indexes)
      lon_new(i,0:npts_range-1) = lon(indexes)
    end if
    delete(indexes)            ; Necessary b/c "indexes" may be a different
                               ; size next time.
  end do

;----------------------------------------------------------------------
; Begin plotting section.
;----------------------------------------------------------------------
  wks = gsn_open_wks("x11","station")   ; send graphics to PNG file
gsn_define_colormap(wks, "MPL_autumn")
;---Set up some map resources.
  mpres              = True
  mpres@gsnMaximize  = True             ; Maximize plot in frame.
  mpres@gsnFrame     = False            ; Don't advance the frame
  mpres@gsnDraw      = False            ; Don't advance the frame

;---Zoom in on United States.
  mpres@mpMinLatF    = 20.
  mpres@mpMaxLatF    = 26.
  mpres@mpMinLonF    = 109.
  mpres@mpMaxLonF    = 118.
  ;mpres@mpCenterLonF = 110
  mpres@tmXBOn=False
  mpres@tmXTOn=False
  mpres@tmYLOn=False
  mpres@tmYROn=False



;================================================================================
;================================================================================
  mpres@mpDataBaseVersion="Ncarg4_1"
  mpres@mpDataSetName     ="Earth..4"
  mpres@mpAreaMaskingOn=True
  mpres@mpOceanFillColor=0
  mpres@mpInlandWaterFillColor=0
  mpres@mpLandFillColor=0

  ;mpres@mpMaskAreaSpecifiers   =(/"China : Guandong"/)
  mpres@mpMaskAreaSpecifiers    =(/"China"/)  
  mpres@mpOutlineOn =True
  ;mpres@mpOutlineSpecifiers=(/"China : Guandong . Donghai Dao","China : Guandong . Donghai Dao",\
  ;      "China : Guandong . Gaolan Dao","China : Guandong . Hailing Dao","Guandong . Nansan Dao",\
  ;      "China : Guandong . Naozhou Dao","China : Guandong . Shangchuan Dao",\
  ;      "China : Guandong . Xiachuan Dao","China : Guandong . Xinliao Dao","China : Guandong"/)
  mpres@mpOutlineSpecifiers=(/"Guandong","China:Provinces"/)
  mpres@mpOutlineBoundarySets="NoBoundaries"
;================================================================================
;================================================================================


  mpres@mpFillColors = (/"transparent","transparent","gray","transparent"/)

  mpres@tiMainString = "Dummy station data colored according to range of values"
  map = gsn_csm_map(wks,mpres)

  gsres               = True
  gsres@gsMarkerIndex = 16          ; Use filled dots for markers.
  gsres@tmXBOn=False
  gsres@tmXTOn=False
  gsres@tmYLOn=False
  gsres@tmYROn=False
;---Get nice spacing through color map for marker colors
  getvalues wks
    "wkColorMapLen" : clen     ; number of colors in color map
  end getvalues

  nstep = (clen-2)/narr
  colors = ispan(2,clen-1,nstep)

;---Loop through each "bin" and attach the markers to the map.
  do i = 0, num_distinct_markers-1
    if (.not.ismissing(lat_new(i,0)))
      gsres@gsMarkerColor      = colors(i)
      dumstr = unique_string("marker")
      map@$dumstr$ = gsn_add_polymarker(wks,map,lon_new(i,:),lat_new(i,:),gsres)
    end if
  end do

;----------------------------------------------------------------------
; First version of this plot has a legend at the bottom
;----------------------------------------------------------------------
  draw(map)                  ; Drawing the map will draw the markers
  draw_legend(wks,lat_new,lon_new,arr,colors) ; Draw a legend at the bottom

  frame(wks)    ; Advance the frame 

;----------------------------------------------------------------------
; Second version of this plot has a labelbar added.
;----------------------------------------------------------------------
  lbid = attach_labelbar(wks,map,arr,colors)   ; Attach a labelbar
    ;map=gsn_add_shapefile_polylines(wks, map, "/mnt/f/data/shp/china/guangdong/Guangdong_city.shp", lnres)
  draw(map)     ; Drawing the map will draw everything
  frame(wks)    ; Advance the frame.
end     

