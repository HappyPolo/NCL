
begin
;  base_lat = -27.
;  base_lon =   0.
  base_lat = 41.6
  base_lon = -76.84

;---Horizontal line at equator
  lat1 = (/  0, -10, -10, 52.9921/)
  lat2 = (/  0,  10,  10, 55.3543/)
  lon1 = (/-10,   0,   0, -168.693/)
  lon2 = (/ 10,   0,  10, -160.346/)

  lat1 = (/  0, -10, -10, 52.9921/)
  lat2 = (/  0,  10,  10, 55.3543/)
  lon1 = (/-10,   0,   0, -168.693/)
  lon2 = (/ 10,   0,  10, -160.346/)

; p_lat = 41.6
; p_lon = -76.84
; lat = (/52.9921,55.3543/)
; lon = (/-168.693,-160.346/)
; dist = gc_pnt2gc(p_lat,p_lon,lat,lon)
  
  cols = (/"maroon4","navyblue","forestgreen","hotpink4"/)
  npts = 20
  nlatlon = dimsizes(lat1)

  ncirc    = 20
  circ_lat = new(ncirc,float)               ; Create arrays to hold circle.
  circ_lon = new(ncirc,float)
  
  wks = gsn_open_wks("x11","gc_funcs")

; Set up some map resources.
  mpres              = True
  mpres@gsnMaximize  = True     ; Maximize size of plot in frame.
  mpres@gsnDraw      = False
  mpres@gsnFrame     = False    ; Don't advance the frame.
  mpres@mpCenterLatF = base_lat
  mpres@mpCenterLonF = base_lon
  map = gsn_map(wks,"Orthographic", mpres)

  gsres                  = True
  gsres@gsLineThicknessF = 5.0
  gsres@gsMarkerIndex    = 16   ; filled dot
  gsres@gsMarkerColor    = "purple"
  gsres@gsMarkerSizeF    = 10

  ldum = new(nlatlon,graphic)
  cdum = new(nlatlon,graphic)
  mdum = gsn_add_polymarker(wks,map,base_lon,base_lat,gsres)
  do n=0,nlatlon-1
    mpres@mpCenterLatF = lat1(n)
    mpres@mpCenterLonF = lon1(n)
    gcdist = gc_latlon(lat1(n), lon1(n), lat2(n), lon2(n), 30, 2)
    pdist  = gc_pnt2gc(base_lat,base_lon,(/gcdist@gclat(0),gcdist@gclat(npts-1)/),\
                                         (/gcdist@gclon(0),gcdist@gclon(npts-1)/))
    print("pdist = " + pdist)
    nggcog(base_lat,base_lon,pdist,circ_lat,circ_lon)

    gsres@gsLineColor = cols(n)
    ldum(n) = gsn_add_polyline(wks,map,gcdist@gclon ,gcdist@gclat,gsres)
    cdum(n) = gsn_add_polyline(wks, map, circ_lon, circ_lat, gsres)
  end do

  draw(map)
  frame(wks)
end
