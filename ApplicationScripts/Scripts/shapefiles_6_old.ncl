;----------------------------------------------------------------------
; shapefiles_6_old.ncl
;
; Concepts illustrated:
;   - Reading shapefiles
;   - Plotting data from shapefiles
;   - Using shapefile data to draw the cantons of Switzerland
;   - Zooming in on Switzerland on a cylindrical equidistant map
;   - Creating a color map using named colors
;   - Attaching lots of text strings to a map
;----------------------------------------------------------------------
; This example shows how to read Switzerland geographic data from a 
; shapefile and plot it on a map created by NCL.

; It shows the "old" way (pre NCL V6.1.0) of adding shapefile outlines
; to an existing NCL map.  See shapefiles_6.ncl for a mix of the "old"
; and "new" ways of adding shapefile information.
;----------------------------------------------------------------------
; Got the "switzerland" shapefiles directory from:
;
;    http://download.geofabrik.de/osm/europe/
;
; Got the "CHE_adm" shapefiles directory from:
; 
;    http://www.gadm.org/country
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

;--- Open workstation and define colormap.
  wks = gsn_open_wks("png","shapefiles")
  gsn_define_colormap(wks,(/"white","black","tan","LightBlue","brown","yellow"/))

;---Set some resources for the map.
  res                       = True
  res@gsnMaximize           = True

  res@mpFillOn              = False
  res@mpOutlineBoundarySets = "AllBoundaries"

  res@gsnTickMarksOn        = False

;---Zoom in on Swizterland
  res@mpLimitMode           = "LatLon"
  res@mpMinLatF             = 45.7
  res@mpMaxLatF             = 48.
  res@mpMinLonF             = 5.9
  res@mpMaxLonF             = 10.7

  res@tiMainString         = "Crude outline of Switzerland"
  res@tiMainFontHeightF    = 0.015

;---Draw the crude map of Switzerland.
  map = gsn_csm_map(wks,res)

;---Change a few resources and create map again. This time don't draw it.
  res@gsnDraw      = False
  res@gsnFrame     = False
  res@mpOutlineOn  = False    ; No outlines or fill will be done.
  res@tiMainString = "Switzerland data from shapefiles"

  map = gsn_csm_map(wks,res)

;
; These two shapefiles contain waterways and administrative 
; geographic info. We will add them to the existing map using
; polylines.
;
  fnames = (/"switzerland/waterways","CHE_adm/CHE_adm1"/) + ".shp"

  colors = (/"LightBlue", "Tan"/)    ; water, administrative

  lnres                  = True      ; resources for polylines
  lnres@gsLineThicknessF = 2.0       ; 2x as thick

;
; Loop through files that we want to read geographic information from.
;
; If this loop is extremely slow, consider using gsn_polyline instead
; of gsn_add_polyline. This can have a significant effect. Remember
; that gsn_polyline is a procedure, not a function, and it draws the
; lines right when you call it, so you need to make sure your map is
; already drawn to the frame.
;
  prims = True
  do n=0,dimsizes(fnames)-1

;---Open the shapefile.
    print("Reading '" + fnames(n) + "'")
    f = addfile(fnames(n),"r")

;---Read data off the shapefile
    segments = f->segments
    geometry = f->geometry
    segsDims = dimsizes(segments)
    geomDims = dimsizes(geometry)

;---Read global attributes  
    geom_segIndex = f@geom_segIndex
    geom_numSegs  = f@geom_numSegs
    segs_xyzIndex = f@segs_xyzIndex
    segs_numPnts  = f@segs_numPnts
    numFeatures   = geomDims(0)

;---Section to draw polylines on map.
    lnres@gsLineColor = colors(n)

    lon = f->x
    lat = f->y
    do i=0, numFeatures-1  
       startSegment = geometry(i, geom_segIndex)
       numSegments  = geometry(i, geom_numSegs)
       do seg=startSegment, startSegment+numSegments-1
          startPT = segments(seg, segs_xyzIndex)
          endPT   = startPT + segments(seg, segs_numPnts) - 1
;
; This call adds the line segment.
;
; Can use gsn_polyline here to make it faster.
;
          dumstr = unique_string("primitive")
          prims@$dumstr$ = gsn_add_polyline(wks, map, lon(startPT:endPT),  \
                                            lat(startPT:endPT), lnres)
       end do
    end do

;---Clean up before we read in same variables again.
    delete(lat)
    delete(lon)
    delete(segments)
    delete(geometry)
  end do

;---Read shapefile with "places" information.
  f = addfile("switzerland/places.shp","r")
  print("Reading 'switzerland/places.shp'")

  names      = f->name
  lon        = f->x
  lat        = f->y
  num_places = dimsizes(names)

;---Set up text resources to label random areas of interest.
  txres               = True
  txres@txFontHeightF = 0.015
  txres@txJust        = "CenterLeft"

;---Set up marker resources to mark random areas of interest.
  mkres               = True
  mkres@gsMarkerIndex = 16
  mkres@gsMarkerColor = "brown"
  mkres@gsMarkerSizeF = 30.

;---Areas we want to put a label and a marker.
  names_of_interest = (/"Bern","Lausanne","Basel","Montreux","Interlaken",\
                        "Olten","Winterthur","Zermatt","Thun","Davos",\
                        "Chur","Lugano","Verbier","Zürich","Luzern",\
                        "Andermatt","Ascona","Sankt Moritz","Poschiavo"/)

;
; Loop through each of the "name" places in the shapefile, and see if
; it's on our list of ones we want to put a label and marker for.
;
; Also, make sure we haven't already encountered this place. The
; shapefile seems to contain duplicate entries (Zurich has two entries,
; for example).
;
; Just like with gsn_add_polyline above, if you find this looping
; code to be too slow, you can use gsn_polymarker and gsn_text instead.
;
  names_of_interest@_FillValue = "missing"
  do i=0,num_places-1
    if(any(names(i).eq.names_of_interest)) then
      ii = ind(names_of_interest.eq.names(i))
      names_of_interest(ii) = "missing"
      dumstr = unique_string("primitive")

;---Attach the marker to the map.
      prims@$dumstr$ = gsn_add_polymarker(wks, map, lon(i), lat(i), mkres)
      dumstr = unique_string("primitive")
;
; NCL doesn't deal with "ü" unfortunately! This code should be done 
; outside this loop.
;
      if(names(i).eq."Zürich") then
        names(i) = "Zurich"
      end if

;---Attach the text string to the map. 
     prims@$dumstr$ = gsn_add_text(wks, map, "  " + names(i), \
                                    lon(i), lat(i), txres)
      delete(ii)
    end if
  end do


;---We're done adding primitives, draw everything and advance frame.
  draw(map)

;---Add some legend information at the bottom of the map.
  txres@txFontHeightF = 0.015
  txres@txFont        = "Helvetica-bold"

  gsn_text_ndc(wks,"Places of interest",0.10,0.25,txres)
  mkres@gsMarkerSizeF = 40.
  gsn_polymarker_ndc(wks,0.09,0.25,mkres)

  gsn_text_ndc(wks,"Waterways",0.4,0.25,txres)

  lnres@gsLineColor      = "LightBlue"
  lnres@gsLineThicknessF = 5.0
  gsn_polyline_ndc(wks,(/0.35,0.39/),(/0.25,0.25/),lnres)

  gsn_text_ndc(wks,"Administrative areas",0.7,0.25,txres)
  lnres@gsLineColor = "Tan"
  gsn_polyline_ndc(wks,(/0.65,0.69/),(/0.25,0.25/),lnres)

  frame(wks)
end
