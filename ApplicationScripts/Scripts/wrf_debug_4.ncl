;--------------------------------------------------
; wrf_debug_4.ncl
;--------------------------------------------------
; Concepts illustrated:
;   - Drawing subsets of WRF lat/lon grids using lines and markers
;   - Setting the correct WRF map projection using wrf_map_resources
;   - Illustrating the use of "where" to subset data
;   - Illustrating the use of "wrf_user_ll_to_ij" to subset data
;--------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;---Open WRF output file and read off the lat/lon grid
  a     = addfile("wrfout_sample.nc","r")
  lat2d = wrf_user_getvar(a,"XLAT",0)   ; 0 = first time step
  lon2d = wrf_user_getvar(a,"XLONG",0)

;---Lat/lon values to zoom in on
  min_lat = 30
  max_lat = 40
  min_lon = -80
  max_lon = -75
;
; The purpose of the code below is to show two ways of subsetting
; a WRF lat/lon grid: one using the "where" statement, and one
; using "wrf_user_ll_to ij". The important thing to note is that
; you get very different results using these two methods.
;

;---Use "where" statement to get subset of lat/lon range
  lon2d@_FillValue = default_fillvalue(typeof(lon2d))
  lat2d@_FillValue = default_fillvalue(typeof(lat2d))

  lat_sub1 = where(lat2d.lt.min_lat.or.lat2d.gt.max_lat .or. \
                   lon2d.lt.min_lon.or.lon2d.gt.max_lon, \
                   lat2d@_FillValue, lat2d)
  lon_sub1 = where(lat2d.lt.min_lat.or.lat2d.gt.max_lat .or. \
                   lon2d.lt.min_lon.or.lon2d.gt.max_lon, \
                   lon2d@_FillValue, lon2d)


;---Use "wrf_user_ll_to_ij" to get subset of lat/lon range
  lats = (/ min_lat, max_lat /)
  lons = (/ min_lon, max_lon /)
  loc  = wrf_user_ll_to_ij(a, lons, lats, True)
  loc = loc-1

  lat_sub2 = lat2d(loc(1,0):loc(1,1) , loc(0,0):loc(0,1))
  lon_sub2 = lon2d(loc(1,0):loc(1,1) , loc(0,0):loc(0,1))

;---Start the graphics
  wtype = "png"
  wtype@wkWidth = 2000
  wtype@wkHeight = 2000
  wks = gsn_open_wks(wtype,"wrf_debug")

;---Set some resources for a WRF map
  res                         = True
  res@gsnMaximize             = True
  res@gsnDraw                 = False
  res@gsnFrame                = False
  res@gsnLeftString           = "min lat/lon = ("+min_lat+","+min_lon+")"
  res@gsnRightString          = "max lat/lon = ("+max_lat+","+max_lon+")"
  res@mpGridAndLimbOn         = True
  res@mpGridLineColor         = "gray50"
  res = wrf_map_resources(a,res)

;---Create a map to hold all lat/lon points
  res@tiMainString = "All lat/lon points"
  plot_all = gsn_csm_map(wks,res)
 
;---Create a map to hold subset of points using "where"
  res@tiMainString = "Using 'where' statement"
  plot1 = gsn_csm_map(wks,res)

;---Create a map to hold subset of points using "wrf_user_ll_to_i"
  res@tiMainString = "Using wrf_user_ll_to_ij"
  plot2 = gsn_csm_map(wks,res)

;---Add the lat/lon points to each plot
  mkres                  = True
  mkres@gsMarkerColor    = "Brown"
  mkres@gsMarkerIndex    = 16
  mkres@gsMarkerSizeF    = 0.002
  dum0 = gsn_add_polymarker(wks,plot_all,lon2d,   lat2d,mkres)
  dum1 = gsn_add_polymarker(wks,plot1,   lon_sub1,lat_sub1,mkres)
  dum2 = gsn_add_polymarker(wks,plot2,   lon_sub2,lat_sub2,mkres)

;---Add a box showing the area of interest
  lnres                  = True
  lnres@gsLineColor      = "ForestGreen"
  lnres@gsLineThicknessF = 2.0
  dum3 = gsn_add_polyline(wks,plot_all,(/min_lon,max_lon,max_lon,\
                                         min_lon,min_lon/),\
                                       (/min_lat,min_lat,max_lat,\
                                         max_lat,min_lat/),lnres)
  dum4 = gsn_add_polyline(wks,plot1,(/min_lon,max_lon,\
                                      max_lon,min_lon,min_lon/),\
                                    (/min_lat,min_lat,max_lat,\
                                      max_lat,min_lat/),lnres)
  dum5 = gsn_add_polyline(wks,plot2,(/min_lon,max_lon,max_lon,\
                                      min_lon,min_lon/),\
                                    (/min_lat,min_lat,max_lat,\
                                      max_lat,min_lat/),lnres)

;---Add the two points showing min/max lat/lon
  mkres@gsMarkerSizeF = 0.007
  mkres@gsMarkerColor = "NavyBlue"
  dum6 = gsn_add_polymarker(wks,plot_all,(/min_lon,max_lon/),\
                                         (/min_lat,max_lat/),mkres)
  dum7 = gsn_add_polymarker(wks,plot1,(/min_lon,max_lon/), \
                                      (/min_lat,max_lat/),mkres)
  dum8 = gsn_add_polymarker(wks,plot2,(/min_lon,max_lon/), \
                                      (/min_lat,max_lat/),mkres)

;---Panel the three plots
  pres              = True
  pres@gsnMaximize  = True
  pres@gsnPanelRowSpec = True

  gsn_panel(wks,(/plot_all,plot1,plot2/),(/1,2/),pres)
end
