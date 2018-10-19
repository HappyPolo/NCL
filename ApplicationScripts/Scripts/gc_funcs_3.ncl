
begin
  base_lat = 41.6
  base_lon = -76.84

;---Select first two points to get great circle for  
  lat1 = 52.9921
  lat2 = 55.3543
  lon1 = -168.693
  lon2 = -160.346

;---Calculate other points on the same line using basic equation for a line
  slope = (lat2-lat1)/(lon2-lon1)
  lon3 = -180.
  lat4 = 90.
  lat3 = ((lon3-lon1)*slope) + lat1
  lon4 = ((lat4-lat2)/slope) + lon2

;---antipodal points (I hope)
  lat5 = lat1
  lon5 = lon1+180
  lat6 = lat2
  lon6 = lon2+180

;---Debug prints
  print("==================================================")
  print("lat1/lon1 = " + lat1 + "/" + lon1)
  print("lat2/lon2 = " + lat2 + "/" + lon2)
  print("lat3/lon3 = " + lat3 + "/" + lon3)
  print("lat4/lon4 = " + lat4 + "/" + lon4)
  print("lat5/lon5 = " + lat5 + "/" + lon5)
  print("lat6/lon6 = " + lat6 + "/" + lon6)

;
; Incrementally march up to the north pole and calculate more points
; along the way. Doing it this way instead of just a single point at
; the pole, because there's something funny about gc_latlon at the pole.
;
  lats  = ispan(60,90,5)
  nlats = dimsizes(lats)
  lons  = new(dimsizes(lats),float)
  
;---Debug prints
  print("==================================================")
  do n=0,nlats-1
    lons(n) = ((lats(n)-lat2)/slope) + lon2
  end do
  print("lats/lons = " + lats + "/" + lons)

;---Create arrays to hold great circles to calculate later
  ncirc  = 20
  circ_lat1 = new(ncirc,float)               ; Create arrays to hold circle.
  circ_lon1 = new(ncirc,float)
  circ_lat2 = new(ncirc,float)               ; Create arrays to hold circle.
  circ_lon2 = new(ncirc,float)
  circ_lat3 = new(ncirc,float)               ; Create arrays to hold circle. 
  circ_lon3 = new(ncirc,float)
  circ_lat4 = new(ncirc,float)               ; Create arrays to hold circle.
  circ_lon4 = new(ncirc,float)
  circ_lat5 = new(ncirc,float)               ; Create arrays to hold circle.
  circ_lon5 = new(ncirc,float)
  circ_lat6 = new(ncirc,float)               ; Create arrays to hold circle.
  circ_lon6 = new(ncirc,float)
  circ_lats = new((/nlats,ncirc/),float)               ; Create arrays to hold circle.
  circ_lons = new((/nlats,ncirc/),float)
  
  wks = gsn_open_wks("x11","gc_funcs")

; Set up some map resources.
  mpres              = True
  mpres@gsnMaximize  = True     ; Maximize size of plot in frame.
  mpres@gsnDraw      = False
  mpres@gsnFrame     = False    ; Don't advance the frame.
;  mpres@mpCenterLatF = lat1
;  mpres@mpCenterLonF = lon1
  mpres@mpCenterLatF = base_lat ; lat1
  mpres@mpCenterLonF = base_lon ; lon1

  map = gsn_map(wks,"Orthographic", mpres)

;  map = gsn_map(wks,"Mercator", mpres)

;  map = gsn_map(wks,"CylindricalEquidistant", mpres)

  gsres                  = True
  gsres@gsLineThicknessF = 5.0
  gsres@gsMarkerIndex    = 16   ; filled dot

  gcdist1 = gc_latlon(lat1, lon1, lat2, lon2, ncirc, 2)
  gcdist2 = gc_latlon(lat2, lon2, lat1, lon1, ncirc, 2)
  gcdist3 = gc_latlon(lat1, lon1, lat3, lon3, ncirc, 2)
  gcdist4 = gc_latlon(lat2, lon2, lat4, lon4, ncirc, 2)

;---Calculate GC for each point and the *other point*'s antipodal point
  gcdist5 = gc_latlon(lat1, lon1, lat6, lon6, ncirc, 2)
  gcdist6 = gc_latlon(lat2, lon2, lat5, lon5, ncirc, 2)
  
  gclats = new((/nlats,ncirc/),float)
  gclons  = new((/nlats,ncirc/),float)
  gcdists = new(nlats,float)
  do n=0,nlats-1
    if(n.eq.0) then
      gcdists(n) = gc_latlon(lat2, lon2, lats(n), lons(n), ncirc, 2)
    else
      gcdists(n) = gc_latlon(lats(n-1), lons(n-1), lats(n), lons(n), ncirc, 2)
    end if
    gclats(n,:) = gcdists@gclat
    gclons(n,:) = gcdists@gclon
  end do

  pdists  = new(nlats,float)
  pdist1  = gc_pnt2gc(base_lat,base_lon,(/gcdist1@gclat(0),gcdist1@gclat(ncirc-1)/),\
                                        (/gcdist1@gclon(0),gcdist1@gclon(ncirc-1)/))
  pdist2  = gc_pnt2gc(base_lat,base_lon,(/gcdist2@gclat(0),gcdist2@gclat(ncirc-1)/),\
                                        (/gcdist2@gclon(0),gcdist2@gclon(ncirc-1)/))
  pdist3  = gc_pnt2gc(base_lat,base_lon,(/gcdist3@gclat(0),gcdist3@gclat(ncirc-1)/),\
                                        (/gcdist3@gclon(0),gcdist3@gclon(ncirc-1)/))
  pdist4  = gc_pnt2gc(base_lat,base_lon,(/gcdist4@gclat(0),gcdist4@gclat(ncirc-1)/),\
                                        (/gcdist4@gclon(0),gcdist4@gclon(ncirc-1)/))
  pdist5  = gc_pnt2gc(base_lat,base_lon,(/gcdist5@gclat(0),gcdist5@gclat(ncirc-1)/),\
                                        (/gcdist5@gclon(0),gcdist5@gclon(ncirc-1)/))
  pdist6  = gc_pnt2gc(base_lat,base_lon,(/gcdist6@gclat(0),gcdist6@gclat(ncirc-1)/),\
                                        (/gcdist6@gclon(0),gcdist6@gclon(ncirc-1)/))
  print("==================================================")
  print("pdist1 = " + pdist1)
  print("pdist2 = " + pdist2)
  print("pdist3 = " + pdist3)
  print("pdist4 = " + pdist4)
  print("pdist5 = " + pdist5)
  print("pdist6 = " + pdist6)

  nggcog(base_lat,base_lon,pdist1,circ_lat1,circ_lon1)
  nggcog(base_lat,base_lon,pdist2,circ_lat2,circ_lon2)
  nggcog(base_lat,base_lon,pdist3,circ_lat3,circ_lon3)
  nggcog(base_lat,base_lon,pdist4,circ_lat4,circ_lon4)
  nggcog(base_lat,base_lon,pdist5,circ_lat5,circ_lon5)
  nggcog(base_lat,base_lon,pdist6,circ_lat6,circ_lon6)

  do n=0,nlats-1
    pdists(n) = gc_pnt2gc(base_lat,base_lon,(/gclats(n,0),gclats(n,ncirc-1)/),\
                                            (/gclons(n,0),gclons(n,ncirc-1)/))
    print("pdists(" + n + ") = " + pdists(n))
    nggcog(base_lat,base_lon,pdists(n),circ_lats(n,:),circ_lons(n,:))
  end do

  gsres@gsLineColor = "Navyblue"
  ldum1 = gsn_add_polyline(wks,map,gcdist1@gclon ,gcdist1@gclat,gsres)
  ldum2 = gsn_add_polyline(wks,map,gcdist2@gclon ,gcdist2@gclat,gsres)
;  ldum3 = gsn_add_polyline(wks,map,gcdist3@gclon ,gcdist3@gclat,gsres)
;  ldum4 = gsn_add_polyline(wks,map,gcdist4@gclon ,gcdist4@gclat,gsres)
;  ldum5 = gsn_add_polyline(wks,map,gcdist5@gclon ,gcdist5@gclat,gsres)
;  ldum6 = gsn_add_polyline(wks,map,gcdist6@gclon ,gcdist6@gclat,gsres)

  ldum5 = gsn_add_polyline(wks,map,(/lon2,lon5/),(/lat2,lat5/),gsres)
  ldum6 = gsn_add_polyline(wks,map,(/lon1,lon6/),(/lat1,lat6/),gsres)

  ldums = new(nlats,graphic)
  do n=0,nlats-1
;    ldums(n) = gsn_add_polyline(wks,map,gclons(n,:),gclats(n,:),gsres)
  end do
  gsres@gsMarkerSizeF    = 15
  gsres@gsMarkerColor    = "black"
  bdum = gsn_add_polymarker(wks,map,base_lon,base_lat,gsres)

  gsres@gsMarkerColor    = "purple"
  gsres@gsMarkerSizeF    = 10
;  mdum  = gsn_add_polymarker(wks,map,(/lon1,lon2,lon3,lon4,lon5,lon6/),(/lat1,lat2,lat3,lat4,lat5,lat6/),gsres)
  mdum  = gsn_add_polymarker(wks,map,(/lon1,lon2/),(/lat1,lat2/),gsres)
;  mdums = gsn_add_polymarker(wks,map,lons,lats,gsres)

  draw(map)
  frame(wks)

  xy = gsn_csm_xy(wks,gcdist1@gclon,gcdist1@gclat,False)
end
