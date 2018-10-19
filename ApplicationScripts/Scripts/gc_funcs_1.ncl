
begin
  npts         = (/10,50/)
  circ_colors  = (/"aquamarine4","purple4"/)
  pnt_colors   = (/"red1","red4"/)
  cen_lat  = (/  45.,  35.,   0.,  20.,  25.,  90. /)
  cen_lon  = (/-105., -60, -120., -50., -90., -90. /)
  radii    = (/   3., 5.5,   7.0,  8.0,  9.0,  20. /)

  wks = gsn_open_wks("x11","nggcog")   ; Open X11 workstation.

; Set up some map resources.
  mpres              = True
  mpres@gsnMaximize  = True     ; Maximize size of plot in frame.
  mpres@gsnFrame     = False    ; Don't advance the frame.
  mpres@mpLandFillColor = "tan"
  mpres@mpCenterLonF = -95.     ; Center map at this lat,lon point
  mpres@mpCenterLatF =  35.
  mpres@mpGridLineDashPattern  = 8
  mpres@mpFillOn    = True
  mpres@mpLandFillColor = "beige"
  mpres@mpOceanFillColor = "lightsteelblue1"
  mpres@mpInlandWaterFillColor = "transparent"
  map = gsn_map(wks,"Orthographic", mpres)

  gsres                  = True
  gsres@gsLineThicknessF = 5.0
  gsres@gsMarkerIndex    = 16   ; filled dot

  do np=0,dimsizes(npts)-1
    circ_lat := new(npts(np),float)               ; Create arrays to hold circle.
    circ_lon := new(npts(np),float)
    gsres@gsLineColor      = circ_colors(np)
    gsres@gsMarkerColor    = pnt_colors(np)
    do n=0,dimsizes(radii)-1
      nggcog(cen_lat(n),cen_lon(n),radii(n),circ_lat,circ_lon)
      gsn_polyline(wks, map, circ_lon, circ_lat, gsres)
      gsn_polymarker(wks, map, cen_lon(n), cen_lat(n), gsres)
    end do
    cen_lon = cen_lon - 2*radii
    radii   = where(cen_lat.eq.90,radii-2,radii)  ; Make circle at equator smaller
  end do

  frame(wks)
end
