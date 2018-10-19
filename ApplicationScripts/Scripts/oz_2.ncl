;----------------------------------------------------------------------
; oz_2.ncl
;
; Concepts illustrated:
;   - Using data from shapefiles to draw areas of interest in Australia
;   - Reading shapefiles
;   - Plotting data from shapefiles
;   - Zooming in on Australia on a cylindrical equidistant map
;   - Creating a color map using named colors
;   - Attaching lots of text strings to a map
;----------------------------------------------------------------------
; This example shows how to read geographic data from a shapefile
; and plot it on a map of Australia created by NCL.
;
; Shapefiles usually have three types of data:
;     line    - rivers, streams, roads
;     polygon - enclosed areas, like provinces, states, countries
;     point   - locations of cities, population counts
;
; This script has three different procedures for drawing these
; three types:
;
;    line:    attach_shapefile_polyline
;    polygon: attach_shapefile_polygon
;    point:   attach_shapefile_point
;----------------------------------------------------------------------
; You can find many free shapefiles on the web. An excellent
; place to start looking is at www.gadm.org.
; 
; For this particular example, here's where we got the various 
; shapefiles:
;
;    "australia.shp" (geographical outline of Australia)
;  http://www.vdstech.com/map_data.htm
;
;    "IARE06aAUST_region.shp"  (indigenous areas of Australia)
;  http://www.abs.gov.au/AUSSTATS/abs@.nsf/DetailsPage/2923.0.30.0012006
;
;    "places.shp" (places of interest)
;  http://www.mapcruzin.com/free-australia-oceania-arcgis-maps-shapefiles.htm
;
;    "rbasin_chain.shp" (river basins)
;  http://e-atlas.org.au/content/au-ga-river-basins-1997
;
;    "STE_2011_AUST.shp" (states and territories borders, not included
;                         in this example)
; http://www.abs.gov.au/AUSSTATS/abs@.nsf/DetailsPage/1270.0.55.001July%202011?OpenDocument
;----------------------------------------------------------------------

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;----------------------------------------------------------------------
; This procedure attaches polyline data from a shapefile
;----------------------------------------------------------------------
undef("attach_shapefile_polyline")
function attach_shapefile_polyline(f:file,wks,plot,line_color)
local lnres
begin
  gsn_define_colormap(wks,(/"white","black","tan","LightBlue",\
                            "brown","yellow","navyblue","green"/))

  lnres                  = True      ; resources for polylines
  lnres@gsLineThicknessF = 2.0       ; 2x as thick
  lnres@gsLineColor      = line_color
;
; Loop through files that we want to read geographic information from.
;
; If this loop is extremely slow, consider using gsn_polyline instead
; of gsn_add_polyline. This can have a significant effect. Remember
; that gsn_polyline is a procedure, not a function, and it draws the
; lines right when you call it, so you need to make sure your plot is
; already drawn to the frame.
;
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

;---Section to draw polylines on plot.
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
        plot@$dumstr$ = gsn_add_polyline(wks, plot, lon(startPT:endPT),  \
                                        lat(startPT:endPT), lnres)
     end do
  end do

;---Clean up before we read in same variables again.
  delete(lat)
  delete(lon)
  delete(segments)
  delete(geometry)

;---We have to return plot so that attached lines are not lost.
  return(plot)
end


;----------------------------------------------------------------------
; This procedure attaches polygon data from a shapefile
;----------------------------------------------------------------------
undef("attach_shapefile_polygon")
function attach_shapefile_polygon(f:file,wks,plot)
local gnres
begin
  gsn_define_colormap(wks,"psgcap")
  gnres                  = True      ; resources for polygons
;
; If this loop is extremely slow, consider using gsn_polyline instead
; of gsn_add_polyline. This can have a significant effect. Remember
; that gsn_polyline is a procedure, not a function, and it draws the
; lines right when you call it, so you need to make sure your map is
; already drawn to the frame.
;

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

  lon = f->x
  lat = f->y
  do i=0, numFeatures-1  
     gnres@gsFillColor = (i%254)+2
     startSegment = geometry(i, geom_segIndex)
     numSegments  = geometry(i, geom_numSegs)
     do seg=startSegment, startSegment+numSegments-1
        startPT = segments(seg, segs_xyzIndex)
        endPT   = startPT + segments(seg, segs_numPnts) - 1
;
; This call adds the filled polygon
; Can use gsn_polygon here to make it faster.
        dumstr = unique_string("primitive")
        plot@$dumstr$ = gsn_add_polygon(wks, plot, lon(startPT:endPT),  \
                                        lat(startPT:endPT), gnres)
      end do
    end do

;---Clean up before we read in same variables again.
  delete(lat)
  delete(lon)
  delete(segments)
  delete(geometry)

;---We have to return plot so that attached lines are not lost.
  return(plot)
end

;----------------------------------------------------------------------
; This procedure attaches point data from a shapefile, using markers
; and text.
;----------------------------------------------------------------------
undef("attach_shapefile_point")
function attach_shapefile_point(f:file,wks,plot)
local names, lat, lon, num_points
begin
  names = f->name
  lon   = f->x
  lat   = f->y
  npts  = dimsizes(names)
  ;print(names)

;
; Areas we want to put a label and a marker. If you plot
; everything in "names", you will have a giant mess!
;
  points_of_interest = (/"Canberra","Melbourne","Sydney","Perth",\
                         "Mooball","Kookaburra","Adelaide", \
                         "Alice Springs","Cairns","Denniston", \
                         "Maryboroug","Darwin","Geraldton",\
                         "Mary Kathleen","Hobart","Broome","Dubbo", \
                         "Boulder","Albany","Phillips Island","Brisbane", \
                         "Townsville","Torres Strait","Karratha","Bourke",\
                         "Cue","Esperance"/)
  npts = dimsizes(points_of_interest)
;
; Loop through each of the "name" places in the shapefile, and see if
; it's on our list of ones we want to put a label and marker for.
;
; Some places appear in the shapefile multiple times with the same
; name. You may have to add extra checks (like lat/lon location)
; to weed out the ones you don't want.
;
; If you find this looping code too slow, you can use 
; gsn_polymarker and gsn_text instead.
;

;---Set up text resources to label random areas of interest.
  txres               = True
  txres@txFontHeightF = 0.008
  txres@txJust        = "CenterLeft"

;---Set up marker resources to mark random areas of interest.
  mkres               = True
  mkres@gsMarkerSizeF = 10.

  do i=0,npts-1
    ii = ind(points_of_interest(i).eq.names)
    if(.not.any(ismissing(ii))) then

;---Attach a filled marker to the plot.
      dumstr = unique_string("primitive")

      mkres@gsMarkerColor = "Green"
      mkres@gsMarkerIndex = 16
      plot@$dumstr$ = gsn_add_polymarker(wks, plot, lon(ii), lat(ii), mkres)
      dumstr = unique_string("primitive")

;---Attach a hollow marker to the plot.
      dumstr = unique_string("primitive")

      mkres@gsMarkerColor      = "Black"
      mkres@gsMarkerThicknessF = 1.5
      mkres@gsMarkerIndex      = 4
      plot@$dumstr$ = gsn_add_polymarker(wks, plot, lon(ii), lat(ii), mkres)

;---Attach the text string to the plot. 
      dumstr = unique_string("primitive")
      plot@$dumstr$ = gsn_add_text(wks, plot, "   " + points_of_interest(i), \
                                   lon(ii), lat(ii), txres)
    end if
    delete(ii)
  end do

  setvalues plot
    "pmTickMarkDisplayMode" : "Never"
  end setvalues

;---We have to return plot so that attached polygons are not lost.
  return(plot)
end

;----------------------------------------------------------------------
; This function creates a cylindrical equidistant map of Australia
; so you you can add polylines, polygons, or point data to it later.
;
; The medium resolution map data base is used so we can get the
; territories and states of Australia.
;----------------------------------------------------------------------
function create_map(wks,title)
local a, res2
begin
  res2                      = True
  res2@gsnMaximize          = False     ; We'll do this later.
  res2@gsnDraw              = False
  res2@gsnFrame             = False

  res2@mpOutlineOn          = True
  res2@mpFillOn             = False  

  res2@mpDataBaseVersion    = "MediumRes"  ; Medium resolution database

  res2@mpDataSetName        = "Earth..4"   ; This database contains
                                           ; divisions for countries
                                           ; like Australia, China.

  res@mpOutlineBoundarySets = "AllBoundaries"

;---Turn on fancier tickmark labels.
  res2@pmTickMarkDisplayMode = "Always"

;---Zoom in on area of interest
  res2@mpLimitMode           = "LatLon"
  res2@mpMinLatF             = -45
  res2@mpMaxLatF             =  -6
  res2@mpMinLonF             = 110
  res2@mpMaxLonF             = 155

  res2@tiMainString          = title

;---Create and return it.
  map = gsn_csm_map(wks,res2)
  return(map)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
;---List the various shapefiles we want to plot from.
  dir       = "Australia/"
  filenames = (/"IARE06aAUST_region","places",            "rbasin_chain.shp"/)
  types     = (/"polygon",           "point",             "polyline"/)
  titles    = (/"Indigenous Areas",  "Places of interest","River Basins"/)
  nfiles    = dimsizes(filenames)
  filenames = dir + filenames + ".shp"

;--- Open workstation.
  wks = gsn_open_wks("ps","oz")
;
; Loop through the given shapefiles, create a map of Australia, 
; and then attach the requested primitives (polygons, polylines,
; or markers/text).
;
  do n=0,nfiles-1

;---Open shapefile.
    print("----------------------------------------")
    f = addfile(filenames(n),"r")

;---Create a map with a title.
    map = create_map(wks,titles(n))
;
; Create plot based on three geometry types:
;   1. polyline  2. polygon   3. point
;

;---Attach POLYLINE data
    if(types(n).eq."polyline") then
;
; Check that this file is the correct type. To draw a polyline,
; it can be polyline *or* polygon.
;
      if(any(f@geometry_type.eq.(/"polyline","polygon"/))) then
        print("Attaching polyline data from file '" + filenames(n) + "'")

;---Attach polylines to map.
        map = attach_shapefile_polyline(f,wks,map,"blue")

;---Draw map (with attached polylines) and advance frame.
        maximize_output(wks,True)  ; This maximizes the plot in the frame
      else
        print("Error: don't have polygon or polyline data.")
        print("       No plot created.")
      end if
    end if      ; Attach POLYLINE data

;---Attach POLYGON data
    if(types(n).eq."polygon") then

;---Check that this file is the correct type.
      if(f@geometry_type.eq."polygon") then
        print("Attaching polygon data from file '" + filenames(n) + "'")

;---Attach polygon to map.
        map = attach_shapefile_polygon(f,wks,map)

;---Draw map and advance frame.
        maximize_output(wks,True)  ; This maximizes the plot in the frame
      else
        print("Error: don't have polygon data.")
        print("       No plot created.")
      end if
    end if   ; Attach POLYGON data

;---Attach POINT data
    if(types(n).eq."point") then

;---Check that this file is the correct type.
      if(f@geometry_type.eq."point") then
        print("Attaching point data from file '" + filenames(n) + "'")

;---Attach markers/text to map.
        map = attach_shapefile_point(f,wks,map)

;---Draw map and advance frame.
        maximize_output(wks,True)  ; This maximizes the plot in the frame
      else
        print("Error: don't have point data.")
        print("       No plot created.")
      end if

;---Clean up
      if(isvar("map")) then
        delete(map)
      end if
    end if   ; Attach POINT data
  end do     ; file loop

end
