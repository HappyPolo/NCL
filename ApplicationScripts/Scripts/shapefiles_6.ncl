;----------------------------------------------------------------------
; shapefiles_6.ncl
;
; Concepts illustrated:
;   - Reading shapefiles
;   - Plotting data from shapefiles
;   - Using shapefile data to draw the cantons of Switzerland
;   - Zooming in on Switzerland on a cylindrical equidistant map
;   - Creating a color map using named colors
;   - Attaching lots of text strings to a map
;   - Using functions for cleaner code
;----------------------------------------------------------------------
; This example shows how to read Switzerland geographic data from a 
; shapefile and plot it on a map created by NCL.

; This script shows a mix of the "old" and "new" ways (post NCL V6.0.0)
; of adding shapefile information to an existing NCL map.
;----------------------------------------------------------------------
; To get the gis.osm_waterways_free* shapefile, go to:
;
; http://download.geofabrik.de/europe/switzerland.html
;
; and download and unzip the switzerland-latest-free.shp.zip file. This
; file provides you with many other Switzerland shapefiles as well.
;
; Got the "CHE_adm" shapefiles directory from:
; 
;    http://www.gadm.org/country
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;----------------------------------------------------------------------
; Add outlines from two shapefiles to given map plot.
;----------------------------------------------------------------------
undef("add_outlines_to_map")
procedure add_outlines_to_map(wks,plot)
local fnames, colors, lnres, n
begin
;
; These two shapefiles contain waterways and administrative 
; geographic info. We will add them to the existing map using
; polylines.
;
  fnames = (/"gis.osm_waterways_free_1","CHE_adm/CHE_adm1"/) + ".shp"

  colors = (/"LightBlue", "Tan"/)    ; water, administrative

  lnres                  = True      ; resources for polylines
  lnres@gsLineThicknessF = 2.0       ; 2x as thick

  do n=0,dimsizes(fnames)-1
    dumstr = unique_string("primitive")
    lnres@gsLineColor = colors(n)
    plot@$dumstr$ = gsn_add_shapefile_polylines(wks, plot, fnames(n), lnres)
  end do
end

;----------------------------------------------------------------------
; Add markers for cities to given map plot.
;----------------------------------------------------------------------
undef("add_places_to_map")
procedure add_places_to_map(wks,plot)
local f, names, lat, lon, txres, mkres 
begin
;---Read shapefile with "places" information.
  f = addfile("gis.osm_places_free_1.shp","r")

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
; If you find this looping code to be too slow, you can use 
; gsn_polymarker and gsn_text instead.
;
  names_of_interest@_FillValue = "missing"
  do i=0,num_places-1
    if(any(names(i).eq.names_of_interest)) then
      ii = ind(names_of_interest.eq.names(i))
      names_of_interest(ii) = "missing"
      dumstr = unique_string("primitive")

;---Attach the marker to the map.
      plot@$dumstr$ = gsn_add_polymarker(wks, plot, lon(i), lat(i), mkres)
      dumstr = unique_string("primitive")
;
; NCL doesn't deal with "ü" unfortunately! This code should be done 
; outside this loop.
;
      if(names(i).eq."Zürich") then
        names(i) = "Zurich"
      end if

;---Attach the text string to the map. 
      plot@$dumstr$ = gsn_add_text(wks, plot, "  " + names(i), \
                                    lon(i), lat(i), txres)
      delete(ii)
    end if
  end do
end

;----------------------------------------------------------------------
; Add some legend information at the bottom of the frame
;----------------------------------------------------------------------
undef("add_legend")
procedure add_legend(wks)
local txres, mkres, lnres
begin
;---Set up text resources to label random areas of interest.
  txres               = True
  txres@txFontHeightF = 0.015
  txres@txJust        = "CenterLeft"

  txres@txFontHeightF = 0.015
  txres@txFont        = "Helvetica-bold"

  gsn_text_ndc(wks,"Places of interest",0.10,0.25,txres)

  mkres               = True
  mkres@gsMarkerIndex = 16
  mkres@gsMarkerColor = "brown"
  mkres@gsMarkerSizeF = 40.
  gsn_polymarker_ndc(wks,0.09,0.25,mkres)

  gsn_text_ndc(wks,"Waterways",0.4,0.25,txres)

  lnres                  = True      ; resources for polylines
  lnres@gsLineColor      = "LightBlue"
  lnres@gsLineThicknessF = 5.0
  gsn_polyline_ndc(wks,(/0.35,0.39/),(/0.25,0.25/),lnres)

  gsn_text_ndc(wks,"Administrative areas",0.7,0.25,txres)
  lnres@gsLineColor = "Tan"
  gsn_polyline_ndc(wks,(/0.65,0.69/),(/0.25,0.25/),lnres)

end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin

;---Open workstation and define colormap.
  wks = gsn_open_wks("png","shapefiles")

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

  add_outlines_to_map(wks,map)
  add_places_to_map(wks,map)

  draw(map)   ; This will draw the outlines and places

  add_legend(wks)


  frame(wks)
end
