;----------------------------------------------------------------------
; shapefiles_7_new.ncl
;
; Concepts illustrated:
;   - Reading shapefiles
;   - Plotting data from shapefiles
;   - Using data from shapefiles to draw areas of interest in Australia
;   - Zooming in on Australia on a cylindrical equidistant map
;   - Creating a color map using named colors
;   - Attaching lots of text strings to a map
;----------------------------------------------------------------------
; This example will only work with NCL V6.1.0 or later, because it
; uses new functions:
;   gsn_add_shapefile_polygons
;   gsn_add_shapefile_polylines
;   gsn_add_shapefile_polymarkers
;
; This example shows how to read Austrlia geographic data from a
; shapefile and plot it on a map created by NCL.
;----------------------------------------------------------------------
; Here's where we got the various shapefiles:
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
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;----------------------------------------------------------------------
; This function creates a cylindrical equidistant map of Australia
; so you you can add polylines, polygons, or point data to it later.
;
; The default map outline provided by NCL is turned off, and instead
; one from a shapefile is used.
;----------------------------------------------------------------------
function create_map(wks,title)
local a, res2
begin
  res2               = True
  res2@gsnMaximize   = True
  res2@gsnDraw       = False
  res2@gsnFrame      = False

  res2@mpOutlineOn   = True
  res2@mpFillOn      = False  
  res2@mpDataBaseVersion = "MediumRes"

;---Turn on fancier tickmark labels.
  res2@pmTickMarkDisplayMode = "Always"

;---Zoom in on area of interest
  res2@mpLimitMode           = "LatLon"
  res2@mpMinLatF             = -45
  res2@mpMaxLatF             =  -6
  res2@mpMinLonF             = 110
  res2@mpMaxLonF             = 155

  res2@tiMainString          = title

;---Create map.
  map = gsn_csm_map(wks,res2)

  return(map)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
  dir       = "Australia/"
  filenames = (/"IARE06aAUST_region","places","rbasin_chain.shp"/)
                
  titles    = (/"Indigenous Areas","Places of interest","River Basins"/)
  nfiles    = dimsizes(filenames)
  filenames = dir + filenames + ".shp"

;--- Open workstation.
  wks = gsn_open_wks("png","shapefiles")  ; send graphics to PNG file

  map = new(nfiles,graphic)

  do i=0,nfiles-1
    map(i) = create_map(wks,titles(i))
  end do

  pres               = True
  pres@gsLineColor   = "blue"
  pres@gsMarkerIndex = 16
  pres@gsMarkerColor = "green"

  print("Adding polygons...")
  poly0 = gsn_add_shapefile_polygons(wks,map(0),filenames(0),pres)

  print("Adding polymarkers...")
  poly1 = gsn_add_shapefile_polymarkers(wks,map(1),filenames(1),pres)

  print("Adding polylines...")
  poly2 = gsn_add_shapefile_polylines(wks,map(2),filenames(2),pres)

;---Draw each map with the newly attached primitives.
  do i=0,nfiles-1
    draw(map(i))
    frame(wks)
  end do

end
