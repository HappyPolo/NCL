
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
      ;gsn_text_ndc      (wks,labels(i),xtxt(i),ytxt(i),txres)
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
  lbres@lbLabelBarOn       = False
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
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
f1=addfile("/home/ys-ug/data/Station/t.mon.05_17.nc", "r")
f2=addfile("/home/ys-ug/data/Station/tmin.mon.05_17.nc", "r")
f3=addfile("/home/ys-ug/data/Station/tmax.mon.05_17.nc", "r")
tm   = f1->t
tmin = f2->tmin
tmax = f3->t
lat = f1->lat
lon = f1->lon

t_jja=new((/80,11/), float)
tmin_jja=new((/80,11/), float)
tmax_jja=new((/80,11/), float)

do i=0,10
t_jja(:,i)=avg(tm(:,12*i+5:12*i+7))
tmax_jja(:,i)=avg(tmax(:,12*i+5:12*i+7))
tmin_jja(:,i)=avg(tmin(:,12*i+5:12*i+7))
end do 
; tm_jja=new((/3,11/), float)
; tt = new((/3,11/), float)
; tm_jja(0,0:10)=dim_avg_n_Wrap(t_jja, 0)
; tm_jja(1,0:10)=dim_avg_n_Wrap(tmin_jja, 0)
; tm_jja(2,0:10)=dim_avg_n_Wrap(tmax_jja, 0)
; tm_jja_d=dim_rmvmean_n(tm_jja, 1)
; ; trend = trend_manken(tm_jja_d, False, 1)
yr=ispan(2007, 2017, 1)
trend=new((/80,3/), float)
prob=new((/80,3/), float)
do ns =0 ,79
    trend(ns,0) = regline(yr, t_jja(ns,:))
    trend(ns,1) = regline(yr, tmax_jja(ns,:))
    trend(ns,2) = regline(yr, tmin_jja(ns,:))
    print(trend(ns,0))
    ; df   = trend(ns,0)@nptxy-2
    ; prob(ns,0) = (1 - betainc(df/(df+trend(ns,0)@tval^2), df/2.0, 0.5) )
    ; delete(df)
    ; df   = trend(ns,1)@nptxy-2
    ; prob(ns,1) = (1 - betainc(df/(df+trend(ns,1)@tval^2), df/2.0, 0.5) )
    ; delete(df)
    ; df   = trend(ns,2)@nptxy-2
    ; prob(ns,2) = (1 - betainc(df/(df+trend(ns,2)@tval^2), df/2.0, 0.5) )
    ; delete(df)
end do 
wks = gsn_open_wks("x11", "~/kt/Urbanization/plot/circle")
ww=new(3, typeof(wks))
ww(0) = gsn_open_wks("x11", "~/kt/Urbanization/plot/reg_t")
ww(1) = gsn_open_wks("x11", "~/kt/Urbanization/plot/reg_max")
ww(2) = gsn_open_wks("x11", "~/kt/Urbanization/plot/reg_min")
;---Set some needed arrays
do ni =0,2
  arr = (/0.4,0.5,0.6,0.7,0.8,0.9,1.0/)    ; bin settings (bin0 = < 0., 

                                         ; bin1 = 0.:4.999, etc.)
  narr = dimsizes(arr)
  labels = new(narr+1,string)   ; Labels for legend.

  npts = 80                                   ; Number of points.
  ;lat  = (/23.42,23.569,23.21,23.335,22.938/)        ; Create some dummy latitude
  ;lon  = (/113.237,113.616,113.482,113.828,113.319/)    ; and longitude data that
                                                ; will contain the position of
                                                ; our markers.

  R   = trend(:,ni)   ; This is dummy data for determining
                                        ; how to color the marker
    ;R = 0

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

;---Set up some map resources.
  mpres              = True
  mpres@gsnMaximize  = False             ; Maximize plot in frame.
  mpres@gsnFrame     = False            ; Don't advance the frame
  mpres@gsnDraw      = False            ; Don't advance the frame

;---Zoom in on United States.
  mpres@mpMinLatF    = 22.5
  mpres@mpMaxLatF    = 24.
  mpres@mpMinLonF    = 112.9
  mpres@mpMaxLonF    = 114.1
  ;mpres@mpCenterLonF = 110
  mpres@tmXBOn=True
  mpres@tmXTOn=True
  mpres@tmYLOn=True
  mpres@tmYROn=True



;================================================================================
;================================================================================
  mpres@mpDataBaseVersion="Ncarg4_1"
  mpres@mpDataSetName     ="Earth..4"
  mpres@mpAreaMaskingOn=False
  mpres@mpOceanFillColor=0
  mpres@mpInlandWaterFillColor=0
  mpres@mpLandFillColor=0

  mpres@mpMaskAreaSpecifiers   =(/"Guandong"/)
  mpres@mpOutlineOn =False
;  mpres@mpOutlineSpecifiers=(/"China : Guandong . Donghai Dao","China : Guandong . Donghai Dao",\
;        "China : Guandong . Gaolan Dao","China : Guandong . Hailing Dao","Guandong . Nansan Dao",\
;        "China : Guandong . Naozhou Dao","China : Guandong . Shangchuan Dao",\
;        "China : Guandong . Xiachuan Dao","China : Guandong . Xinliao Dao","China : Guandong"/)

  mpres@mpOutlineBoundarySets="NoBoundaries"
;================================================================================
;================================================================================


  mpres@mpFillColors = (/"transparent","transparent","gray","transparent"/)
nhres                          = mpres
    mpres@mpOutlineSpecifiers=(/"Guandong","China:Provinces"/)

  mpres@tiMainString = ""

  ;mpres@
  map = gsn_csm_map(wks,mpres)

  gsres               = True
  gsres@gsMarkerIndex = 16          ; Use filled dots for markers.
  gsres@tmXBOn=False
  gsres@tmXTOn=False
  gsres@tmYLOn=False
  gsres@tmYROn=False

;---Get nice spacing through color map for marker colors
  getvalues ww(ni)
    "wkColorMapLen" : clen     ; number of colors in color map
  end getvalues

  nstep = (clen-2)/narr
  colors = ispan(2,clen-1,nstep)

;---Loop through each "bin" and attach the markers to the map.
  do i = 0, num_distinct_markers-1
    if (.not.ismissing(lat_new(i,0)))
      gsres@gsMarkerColor      = colors(i)
      dumstr = unique_string("marker")
      map@$dumstr$ = gsn_add_polymarker(ww(ni),map,lon_new(i,:),lat_new(i,:),gsres)
    end if
  end do


nhres@mpOutlineSpecifiers=(/"Guandong","China:Provinces"/)
  nhres@gsnMaximize              = False

  nhres@vpHeightF                = 0.18    
  nhres@vpWidthF                 = 0.18
    
  nhres@mpMinLatF                =   20.0    
  nhres@mpMaxLatF                =  25.0
  nhres@mpMinLonF                = 111.0
  nhres@mpMaxLonF                = 115.0

  nhres@lbLabelBarOn             = False
  nhres@tmXBOn                   = False 
  nhres@tmXTOn                   = False
  nhres@tmYLOn                   = False
  nhres@tmYROn                   = False
  nhres@gsnLeftString            = ""
  nhres@gsnRightString           = ""

  map_nanhai = gsn_csm_map(ww(ni),nhres)

  adres                          = False
  adres@amParallelPosF           = 0.495 ; -0.5 is the left edge of the plot.
  adres@amOrthogonalPosF         = 0.49  ; -0.5 is the top edge of the plot.
  adres@amJust                   = "BottomRight"

  lnres             =True
lnres@gsFillColor ="grey"
lnres@gsLineThicknessF=1.5
lnres@gsLineDashPattern=0

  ;plotnh = gsn_add_annotation(map,map_nanhai,adres)
;----------------------------------------------------------------------
; First version of this plot has a legend at the bottom
;----------------------------------------------------------------------
  ;draw(map)                  ; Drawing the map will draw the markers
  draw_legend(ww(ni),lat_new,lon_new,arr,colors) ; Draw a legend at the bottom

  ;frame(wks0)    ; Advance the frame 

;----------------------------------------------------------------------
; Second version of this plot has a labelbar added.
;----------------------------------------------------------------------
  lbid = attach_labelbar(ww(ni),map,arr,colors)   ; Attach a labelbar
    ;map=gsn_add_shapefile_polylines(wks, map, "/mnt/f/data/shp/china/guangdong/Guangdong_city.shp", lnres)
    ma = gsn_add_shapefile_polylines(ww(ni), map, "/home/ys-ug/kt/shapefile/guangzhou_city.shp", lnres)
    ;ma = gsn_add_shapefile_polylines(wks, map, "/home/ys-ug/kt/g.shp", lnres)
  draw(map)     ; Drawing the map will draw everything
  frame(ww(ni))    ; Advance the frame.
  

    



end 