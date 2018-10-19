load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"

;------------------------------------------------------------
;-- Description
;------------------------------------------------------------
; The following script tracks a cyclone, defined as minimum of 
; Mean Sea Level Pressure over an unstructured grid. 
; The methodology employs a minimum search forced by a first-guess
; which is obtained by linearly interpolating the previous 2 
; positions of the cyclones. At the first 2 timestep a simple 
; minimum search in a subset of the domain prescribed by the user 
; is performed.
; Subsequently, the coordinates of the MSLP minimum are used 
; to obtain centroid plots following the cyclones and a 
; time series plot of the MSLP minimum and the wind gust.
;------------------------------------------------------------
;-- This script was written by Guido Cioni
;------------------------------------------------------------
;-- set global constants
;------------------------------------------------------------
pi       =  get_pi("float")   ; 4.0*atan(1.)
deg2rad  =  get_d2r("float")  ; pi/180.
rad2deg  =  get_r2d("float")  ; 45./atan(1.)
fillval  = -99999.9

export_text           = False
plot_map              = True
plot_centroid         = True
plot_timeseries       = False

begin

; Open model level output file
   fin = addfile( "./merge.nc","r")  

  print("DATA READ in "+get_cpu_time()+"s")

  time     = fin->time
  gust     = fin->sp_10m
  mslp     = fin->pres_msl * 0.01
  topo     = fin->topography_c
  temp     = fin->temp
  lon      = fin->clon * rad2deg ; cell center, lon (ncells)
  lat      = fin->clat * rad2deg ; cell center, lat (ncells)

;---Convert time to other formats for later use.
  utc_date = cd_calendar(time, 0)
  date     = cd_calendar(time, -3)

  print("VARIABLES ASSIGNED in "+get_cpu_time()+"s")

;------------------------------------------------------------
;-- SECTION 0: Common resources for the first map plot
;------------------------------------------------------------
;

; mask variables to avoid points over orography
; important in order to track the cyclone !
;
  mslp = mask(mslp, topo.ge.5 , False) 
  temp = mask(temp, topo.ge.5, False)

  print("MASKING DONE in "+get_cpu_time()+"s")

;---Set resources for the map plot
  ResC                       = True
  ResC@gsnDraw               = False
  ResC@gsnFrame              = False
  ResC@gsnMaximize           = True         ; Maximize plot in frame. 
  ResC@mpLimitMode           = "LatLon"
  ResC@mpMaxLonF             = 17               ; specify the plot domain
  ResC@mpMinLonF             = 11
  ResC@mpMinLatF             = 34
  ResC@mpMaxLatF             = 39
  ResC@mpDataBaseVersion     = "HighRes"
  ResC@pmTickMarkDisplayMode = "Always"   ; nicer tickmarks

;---Set resources for the mslp label 
  cmap = read_colormap_file("amwg_blueyellowred")
  res_lb                    = True
  res_lb@vpWidthF           = 0.50
  res_lb@vpHeightF          = 0.10
  res_lb@lbPerimOn          = False            ; Turn off perimeter.
  res_lb@lbOrientation      = "Horizontal"     ; Default is vertical.
  res_lb@lbLabelAlignment   = "InteriorEdges"  ; Default is "BoxCenters".
  res_lb@lbFillColors       = cmap(2:,:)      ; Colors for boxes.
  res_lb@lbMonoFillPattern  = True             ; Fill them all solid.
  res_lb@lbLabelFontHeightF = 0.015 
  
;---Set resources for lines, markers, and text
  mres  = True
  lres  = True
  txres = True
  lres@gsLineThicknessF = 3.0
  mres@gsMarkerIndex    = 16
  mres@gsMarkerSizeF    = 0.005
  txres@txFontHeightF   = 0.01

;------------------------------------------------------------
;-- SECTION 1: MSLP Minimum Search
;------------------------------------------------------------
; begin and end of the tracking algorithm
; adjust if needed
  start  = 0
  limit  = 48
  lstart = limit-start+1

;---Define the arrays that will contain the variables related to the minimum
  lat_min  = new(lstart, double)
  lon_min  = new(lstart, double)
  mslp_min = new(lstart, double)
  gust_max = new(lstart, double)
  hour     = new(lstart, string)
  hour_acc = new(lstart, integer)

  hour_acc=ispan(start, limit, 1)

  mslp_min@long_name = "Mean Sea-Level Pressure minimum [hPa]"
  gust_max@long_name = "Maximum wind gust [m/s]"
  hour_acc@long_name = "Simulation lead time [hour]"
  hour_acc@units      = "hours since 2014-11-07 00:00:00"

;---first box to search the minimum, only at the first 2 timesteps
  min_lon=11.
  max_lon=13.
  min_lat=35.
  max_lat=37.
  box_ini=ind(lon.ge.min_lon .and. lon.le.max_lon .and. lat.ge.min_lat .and. lat.le.max_lat)

  radius= 1.0 ; in order to grab the maximum wind gust

;---dimension of the box that will contain the first guess for the minimum position
  box_dim=0.25 ; units latitude/longitude

  print("Quest for the minimum is starting")
;---minimum search
  do i=start,limit
    k=i-start
   ; first 2 instants just perform a minimum search over the initial box
    if(i.eq.start .or. i.eq.(start+1) ) then 
       ;minimum must lies in the box defined by the boundaries
      cell_min=ind(lon.ge.min_lon .and. lon.le.max_lon .and. lat.ge.min_lat .and. lat.le.max_lat \
                   .and. mslp(i,:).eq. min(mslp(i,box_ini)) )
       ; cell_min should be 1-dimensional
      if(dimsizes(cell_min) .ne. 1) then 
        lat_min(k) = lat(min(cell_min))  
        lon_min(k) = lon(min(cell_min))
        mslp_min(k)= mslp(i,min(cell_min))
      else
        lat_min(k) = lat(cell_min)  
        lon_min(k) = lon(cell_min)
        mslp_min(k)= mslp(i,cell_min)
      end if
      circle=ind(lon^2+lat^2-2*lon*lon_min(k)-2*lat*lat_min(k) .le. radius^2-lon_min(k)^2-lat_min(k)^2)
      gust_max(k)=max(gust(i,0,circle))
      delete([/cell_min, circle/])
    else
       ;find new center based on linear-extrapolation from the two previous positions
      lat_new=2*lat_min(k-1)-lat_min(k-2)
      lon_new=2*lon_min(k-1)-lon_min(k-2)
      box_new=ind(lon.ge.(lon_new-box_dim)  .and. lon.le.(lon_new+box_dim)\
                  .and. lat.ge.(lat_new-box_dim) .and. lat.le.(lat_new+box_dim))
      cell_min=ind(lon.ge.(lon_new-box_dim) .and. lon.le.(lon_new+box_dim)\
                   .and. lat.ge.(lat_new-box_dim).and. lat.le.(lat_new+box_dim)\
                   .and. mslp(i,:) .eq. min(mslp(i,box_new)) )
      if(dimsizes(cell_min) .ne. 1) then 
        lat_min(k) = lat(min(cell_min))  
        lon_min(k) = lon(min(cell_min))
        mslp_min(k)= mslp(i,min(cell_min))
      else
        lat_min(k) = lat(cell_min)  
        lon_min(k) = lon(cell_min)
        mslp_min(k)= mslp(i,cell_min)
      end if
      circle=ind(lon^2+lat^2-2*lon*lon_min(k)-2*lat*lat_min(k) .le. radius^2-lon_min(k)^2-lat_min(k)^2)
      gust_max(k)=max(gust(i,0,circle))
      delete([/box_new, lat_new, lon_new, circle, cell_min/])
    end if
    print("iteration n."+(k+0.0))
    hour(k)=utc_date(i,3)
  end do 

  if(plot_map) then
    wks = gsn_open_wks("png","icon_track")
    map = gsn_csm_map(wks,ResC)

    cnLevels = fspan(min(mslp_min),max(mslp_min),10)
    line1 = new(dimsizes(mslp_min)-2,graphic)
    do j=0,dimsizes(mslp_min)-2
      lres@gsLineColor=GetFillColor(cnLevels,cmap,avg( (/mslp_min(j),mslp_min(j+1)/)))
      line1(j) = gsn_add_polyline(wks,map,(/lon_min(j),lon_min(j+1)/),(/lat_min(j),lat_min(j+1)/),lres) 
    end do
    marker1 = gsn_add_polymarker(wks,map,lon_min,lat_min,mres)
    text1   = gsn_add_text(wks, map,hour,lon_min-0.01, lat_min+0.1,txres)
    gsn_labelbar_ndc(wks,dimsizes(cnLevels)+1,floor(cnLevels),0.30,0.30,res_lb)

    draw(map)
    frame(wks)
  end if

;---write coordinates and mslp in a text file
  if(export_text) then 
    alist=[/hour_acc,lon_min,lat_min,mslp_min,gust_max/]
    write_table("track.txt","w",alist,"%2i%10.8f%10.8f%8.4f%4.2f")
  end if

;------------------------------------------------------------
;-- SECTION 2: Centroid plot
;------------------------------------------------------------

  if(plot_centroid) then
;---Define variables in a circle around the minimum
    resc           = True
    resc@cnFillOn  = True 
    resc@cnLinesOn = False
    resc@gsnDraw   = False
    resc@gsnFrame  = False

;---Make copy of previous resources and change a couple of them for second plot
    resc2           = resc     
    resc2@cnFillOn  = False 
    resc2@cnLinesOn = True

    resc@cnLevelSelectionMode = "ManualLevels"
    resc@cnMinLevelValF       = -3
    resc@cnMaxLevelValF       = 3
    resc@cnFillPalette        ="GHRSST_anomaly"
    resc@lbOrientation        ="Vertical"

    level  = 0 
    radius = 1.0
    do i=start,limit
      wks2 = gsn_open_wks("png","icon_centroid_"+i)

      centroid := ind(lon^2+lat^2-2*lon*lon_min(i)-2*lat*lat_min(i) .le. radius^2-lon_min(i)^2-lat_min(i)^2)
      mslp_c   := mslp(i,centroid)
      temp_c   := temp(i,level,centroid)

      resc@gsnCenterString      = date(i)+"| Temperature anomaly and MSLP"
      resc@sfXArray             := lon(centroid) 
      resc@sfYArray             := lat(centroid)
      resc2@sfXArray            := lon(centroid) 
      resc2@sfYArray            := lat(centroid)

      plot = gsn_csm_contour(wks2, temp_c-avg(temp_c), resc)
      over = gsn_csm_contour(wks2, mslp_c, resc2)
  
      overlay(plot,over)   ; Overlay line contour plot on filled contour plot
      draw(plot)
      frame(wks2)
    end do
  end if

;------------------------------------------------------------
;-- SECTION 3: Time series plot
;------------------------------------------------------------
  if(plot_timeseries) then 
    wks3 = gsn_open_wks("png","icon_mslp_wind")
    resxy               = True
    resxy@gsnMaximize   = True
    resxy@vpWidthF      = 0.9    ; Make plot wider than it is high
    resxy@vpHeightF     = 0.5
    resxy@trXMinF       = start
    resxy@trXMaxF       = limit
    resxy@xyLineColors  = "black"

    resxy2              = resxy    ; Make a copy of resource list for second Y curve
    resxy2@xyLineColors = "red"    ; and use it to change the line color.

    timeseries = gsn_csm_xy2(wks3, hour_acc, mslp_min, gust_max,resxy,resxy2)
    frame(wks3)
  end if 
end
