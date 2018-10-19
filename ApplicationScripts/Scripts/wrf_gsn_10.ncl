;--------------------------------------------------
; wrf_gsn_10.ncl
;--------------------------------------------------
; Concepts illustrated:
;   - Subsetting a WRF grid three different ways to take an average of points in a lat/lon box
;   - Using opacity to emphasize or subdue overlain features
;   - Setting the correct WRF map projection using wrf_map_resources
;   - Illustrating the use of "where" to subset data
;   - Illustrating the use of "getind_latlon2d" to subset data
;   - Illustrating the use of "wrf_user_ll_to_ij" to subset data
;--------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;---Open WRF output file and read off the lat/lon grid
  a     = addfile("wrfout_sample.nc","r")
  nt    = 0                                ; 0 = first time step
  t2    = wrf_user_getvar(a, "T2",  nt)
  lat2d = wrf_user_getvar(a,"XLAT", nt)
  lon2d = wrf_user_getvar(a,"XLONG",nt)

;---Lat/lon box of interest where we want to average the data
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
  t2@_FillValue    = default_fillvalue(typeof(t2))
  lon2d@_FillValue = default_fillvalue(typeof(lon2d))
  lat2d@_FillValue = default_fillvalue(typeof(lat2d))

  lat_sub1 = where(lat2d.lt.min_lat.or.lat2d.gt.max_lat .or. \
                   lon2d.lt.min_lon.or.lon2d.gt.max_lon, \
                   lat2d@_FillValue, lat2d)
  lon_sub1 = where(lat2d.lt.min_lat.or.lat2d.gt.max_lat .or. \
                   lon2d.lt.min_lon.or.lon2d.gt.max_lon, \
                   lon2d@_FillValue, lon2d)

  t2_sub1 = where(lat2d.lt.min_lat.or.lat2d.gt.max_lat .or. \
                  lon2d.lt.min_lon.or.lon2d.gt.max_lon, \
                  t2@_FillValue, t2)


;---Use "wrf_user_ll_to_ij" to get subset of lat/lon range
  lats = (/ min_lat, max_lat /)
  lons = (/ min_lon, max_lon /)
  loc  = wrf_user_ll_to_ij(a, lons, lats, True)
  loc  = loc-1    ; wrf function returns 1 to n, NCL needs 0 to n-1

  ilt1 = loc(1,0)  
  ilt2 = loc(1,1)
  iln1 = loc(0,0)
  iln2 = loc(0,1)

  lat_sub2 = lat2d(ilt1:ilt2 , iln1:iln2)
  lon_sub2 = lon2d(ilt1:ilt2 , iln1:iln2)
  t2_sub2  = t2                     ; make a copy
  t2_sub2  = t2_sub2@_FillValue     ; set to all missing
  t2_sub2(ilt1:ilt2,iln1:iln2) = t2(ilt1:ilt2, iln1:iln2)   ; fill in subset

;
; Use "getind_latlon2d"; should produce same results as wrf_user_ll_to_ij.
;
; This function can be used on any curvilinear data, whereas
; wrf_user_ll_to_ij is tailored for WRF data.
;
  nm   = getind_latlon2d (lat2d,lon2d, lats, lons)
  ilt1 = nm(0,0)  
  ilt2 = nm(1,0)
  iln1 = nm(0,1)
  iln2 = nm(1,1)

  lat_sub3 = lat2d(ilt1:ilt2 , iln1:iln2)
  lon_sub3 = lon2d(ilt1:ilt2 , iln1:iln2)
  t2_sub3  = t2                     ; make a copy
  t2_sub3  = t2_sub3@_FillValue     ; set to all missing
  t2_sub3(ilt1:ilt2,iln1:iln2) = t2(ilt1:ilt2, iln1:iln2)   ; fill in subset

;---Take an average of all the points, and of the two subsetted sets of points
  t2_avg      = avg(t2)
  t2_sub1_avg = avg(t2_sub1)
  t2_sub2_avg = avg(t2_sub2)
  t2_sub3_avg = avg(t2_sub3)

;---Print this information
;  printVarSummary(t2)
;  printVarSummary(t2_sub1)
;  printVarSummary(t2_sub2)
;  printVarSummary(t2_sub3)

  print("--------------------------------------------------")
  print("  # non-msg points in t2      = " + num(.not.ismissing(t2)))
  print("  Average of t2               = " + t2_avg)
  print("--------------------------------------------------")
  print("  Using 'where' function")
  print("  # non-msg points in t2_sub1 = " + num(.not.ismissing(t2_sub1)))
  print("  Average of t2_sub1          = " + t2_sub1_avg)
  print("--------------------------------------------------")
  print("  Using 'wrf_user_ll_to_ij' function")
  print("  # non-msg points in t2_sub2 = " + num(.not.ismissing(t2_sub2)))
  print("  Average of t2_sub2          = " + t2_sub2_avg)
  print("--------------------------------------------------")
  print("  Using 'getind_latlon2d' function")
  print("  # non-msg points in t2_sub3 = " + num(.not.ismissing(t2_sub3)))
  print("  Average of t2_sub3          = " + t2_sub3_avg)

;---Start the graphics
  wtype = "png"
  if(wtype.eq."png") then
    wtype@wkWidth  = 2000
    wtype@wkHeight = 2000
  end if
  wks = gsn_open_wks(wtype,"wrf_gsn")

;---Set some resources for a WRF map
  res                         = True
  res@gsnMaximize             = True
  res@gsnDraw                 = False
  res@gsnFrame                = False
  res@gsnLeftString           = "min lat/lon = ("+min_lat+","+min_lon+")"
  res@gsnRightString          = "max lat/lon = ("+max_lat+","+max_lon+")"
  res@mpGridAndLimbOn         = True
  res@mpGridLineColor         = "gray50"

  res@cnFillOn                = True
  res@cnLinesOn               = False
  res@cnLineLabelsOn          = False
  res@cnFillOpacityF          = 0.5      ; Fade the colors so we can see lat/lon box better.
 
  res@cnLevelSelectionMode    = "ManualLevels"
  mnmxint = nice_mnmxintvl( min(t2), max(t2), 18, False)
  res@cnMinLevelValF          = mnmxint(0)
  res@cnMaxLevelValF          = mnmxint(1)
  res@cnLevelSpacingF         = mnmxint(2)

  res@lbLabelBarOn            = False   ; will add in panel

;---Necessary for overlay to work properly in native WRF grid.
  res = wrf_map_resources(a,res)
  res@tfDoNDCOverlay          = True
  res@gsnAddCyclic            = False

;---Create a map to hold all lat/lon points
  res@tiMainString = "All lat/lon points: avg = " + t2_avg
  plot_all = gsn_csm_contour_map(wks,t2,res)
 
;---Create a map to hold subset of points using "where"
  res@tiMainString = "Using 'where' statement: avg = " + t2_sub1_avg
  plot1 = gsn_csm_contour_map(wks,t2_sub1,res)

;---Create a map to hold subset of points using "wrf_user_ll_to_i"
  res@tiMainString = "Using wrf_user_ll_to_ij: avg = " + t2_sub2_avg
  plot2 = gsn_csm_contour_map(wks,t2_sub2,res)

;---Create a map to hold subset of points using "getind_latlon2d"
  res@tiMainString = "Using getind_latlon2d: avg = " + t2_sub3_avg
  plot3 = gsn_csm_contour_map(wks,t2_sub3,res)

;---Add the lat/lon points to each plot
  mkres                  = True
  mkres@gsMarkerColor    = "black"
  mkres@gsMarkerIndex    = 16
  mkres@gsMarkerSizeF    = 0.002
  dum0 = gsn_add_polymarker(wks,plot_all,lon2d,   lat2d,   mkres)
  dum1 = gsn_add_polymarker(wks,plot1,   lon_sub1,lat_sub1,mkres)
  dum2 = gsn_add_polymarker(wks,plot2,   lon_sub2,lat_sub2,mkres)
  dum3 = gsn_add_polymarker(wks,plot3,   lon_sub3,lat_sub3,mkres)

;---Add a box showing the area of interest
  lnres                  = True
  lnres@gsLineColor      = "ForestGreen"
  lnres@gsLineThicknessF = 5.0
  dum4 = gsn_add_polyline(wks,plot_all,(/min_lon,max_lon,max_lon,\
                                         min_lon,min_lon/),\
                                       (/min_lat,min_lat,max_lat,\
                                         max_lat,min_lat/),lnres)
  dum5 = gsn_add_polyline(wks,plot1,(/min_lon,max_lon,\
                                      max_lon,min_lon,min_lon/),\
                                    (/min_lat,min_lat,max_lat,\
                                      max_lat,min_lat/),lnres)
  dum6 = gsn_add_polyline(wks,plot2,(/min_lon,max_lon,max_lon,\
                                      min_lon,min_lon/),\
                                    (/min_lat,min_lat,max_lat,\
                                      max_lat,min_lat/),lnres)
  dum7 = gsn_add_polyline(wks,plot3,(/min_lon,max_lon,max_lon,\
                                      min_lon,min_lon/),\
                                    (/min_lat,min_lat,max_lat,\
                                      max_lat,min_lat/),lnres)

;---Add the two points showing min/max lat/lon box corners
  mkres@gsMarkerSizeF = 0.007
  mkres@gsMarkerColor = "NavyBlue"
  dum8 = gsn_add_polymarker(wks,plot_all,(/min_lon,max_lon/),\
                                         (/min_lat,max_lat/),mkres)
  dum9 = gsn_add_polymarker(wks,plot1,(/min_lon,max_lon/), \
                                      (/min_lat,max_lat/),mkres)
  dum10= gsn_add_polymarker(wks,plot2,(/min_lon,max_lon/), \
                                      (/min_lat,max_lat/),mkres)
  dum11= gsn_add_polymarker(wks,plot3,(/min_lon,max_lon/), \
                                      (/min_lat,max_lat/),mkres)

;---Panel the three plots
  pres                    = True
  pres@gsnMaximize        = True
  pres@gsnPanelLabelBar   = True
  pres@pmLabelBarWidthF   = 0.8
  pres@lbLabelFontHeightF = 0.015

  gsn_panel(wks,(/plot_all,plot1,plot2,plot3/),(/2,2/),pres)
end
