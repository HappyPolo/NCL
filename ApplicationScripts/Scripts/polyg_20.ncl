;----------------------------------------------------------------------
; polyg_20.ncl
;
; Concepts illustrated:
;   - Adding a map to another map as an annotation
;   - Adding markers to a map
;   - Adding shapefile features to a map
;   - Using functions for cleaner code
;-----------------------------------------------------------------
;----------------------------------------------------------------------
; This script generates a map of the Western United States and the
; Boulder/Denver/Golden area, and then adds markers at lat/lon
; location of RMACC institutions.  The Boulder/Denver/Golden map is
; draw as a subset map of the Western U.S. one.
;----------------------------------------------------------------------
; The USA_adm and PRI_adm shapefiles can be downloaded from
; gadm.org/country. The "states" shapefile can be downloaded
; from the NCL examples page, http://www.ncl.ucar.edu/Applications/Data
;----------------------------------------------------------------------

;----------------------------------------------------------------------
; Read a CSV file with three fields: Location, Lat, Lon
;----------------------------------------------------------------------
function read_csv(csv_name)
local data, names, lat, lon, ncols
begin
  data  = str_split_csv(asciiread(csv_name,-1,"string"),",",0)
  ncols = dimsizes(data(0,:))

  names = data(1:,0)
  lat   = tofloat(data(1:,1))
  lon   = tofloat(data(1:,2))
  if(ncols.eq.4) then
    extra_field = data(1:,3)
    return([/names,lat,lon,extra_field/])
  else
    return([/names,lat,lon/])
  end if
end


;----------------------------------------------------------------------
; Create a simple NCL map of the USA region
;----------------------------------------------------------------------
undef("simple_map")
function simple_map(wks,lat,lon,title,opt)
local res
begin
  tickmarks = get_res_value_keep(opt,"tickmarks",True)
  perim     = get_res_value_keep(opt,"perim",True)

  res                        = True
  res@mpProjection           = "Mercator"
  res@gsnMaximize            = True
  res@gsnDraw                = False
  res@gsnFrame               = False
  res@mpFillOn               = True 
  res@mpLimitMode            = "LatLon"

  if(tickmarks)
    res@pmTickMarkDisplayMode  = "Always"
  else  
    res@pmTickMarkDisplayMode  = "Never"
  end if

  res@mpMinLatF              = get_res_value_keep(opt,"minlat",min(lat)-2)
  res@mpMaxLatF              = get_res_value_keep(opt,"maxlat",max(lat)+2)
  res@mpMinLonF              = get_res_value_keep(opt,"minlon",min(lon)-2)
  res@mpMaxLonF              = get_res_value_keep(opt,"maxlon",max(lon)+2)

  res@mpPerimOn              = perim
  res@mpPerimLineThicknessF  = 5.0
  res@mpOutlineOn            = False
  res@mpLandFillColor        = get_res_value_keep(opt,"background","transparent")
  res@mpOceanFillColor       = get_res_value_keep(opt,"background","transparent")
  res@mpInlandWaterFillColor = get_res_value_keep(opt,"background","transparent")

  res@tmXBMajorLengthF        = 0.0
  res@tmXBMajorOutwardLengthF = 0.0
  res@tmYLMajorLengthF        = 0.0
  res@tmYLMajorOutwardLengthF = 0.0
  res@tmXBLabelFontHeightF    = 0.008
  res@tmYLLabelFontHeightF    = 0.008
  if(title.ne."")
   res@tiMainString           = title
   res@tiMainOffsetYF         = -0.07
   res@tiMainFontHeightF      = 0.015
  end if
  map = gsn_csm_map(wks,res)
  return(map)
end

;----------------------------------------------------------------------
; This adds all outlines in a shapefile to a given map. A couple
; of line resources are also set.
;----------------------------------------------------------------------
procedure add_shapefile_outlines(wks,map,shp_name)
local lnres
begin
  lnres                  = True
  lnres@gsFillColor      = "White"
  lnres@gsLineThicknessF = 5.0
  lnres@gsLineColor      = "Gray50"
  map@mapoutlines = gsn_add_shapefile_polylines(wks,map,shp_name,lnres)
end

;----------------------------------------------------------------------
; This adds markers at the given lat/lon locations to the given map,
; using the color and size input. A star marker is drawn both as
; a filled marker and a hollow marker for a cleaner look.
;----------------------------------------------------------------------
procedure  add_latlon_markers(wks,map,lat,lon,marker_color,marker_size)
local fcirc,hcirc, mkres
begin
  fstar = NhlNewMarker(wks, "z",  35, 0.0, 0.0, 1.0, 1.0, 0.)
  hstar = NhlNewMarker(wks, "z", 135, 0.0, 0.0, 1.0, 1.0, 0.)

  mkres                    = True
  mkres@gsMarkerSizeF      = marker_size*1.1
  mkres@gsMarkerColor      := "Black"
  mkres@gsMarkerIndex      = fstar ; 16 ; fstar
  tmpstr = unique_string("markers")
  map@$tmpstr$ = gsn_add_polymarker(wks,map,lon,lat,mkres)

  mkres@gsMarkerColor      := marker_color
  mkres@gsMarkerSizeF      = marker_size
  tmpstr = unique_string("markers")
  map@$tmpstr$ = gsn_add_polymarker(wks,map,lon,lat,mkres)
end

;--------------------------------------------------------------------------------
; This procedure adds Golden, Denver, and Boulder to the given map
; using text strings.
;--------------------------------------------------------------------------------
procedure add_co_cities(wks,map)
local cities, city_lats, city_lons, mkres, txres
begin
  cities    = (/"Golden","Denver","Boulder"/)
  city_lats = (/39.7555,39.7392,40.015/)
  city_lons = (/-105.2211,-104.9903,-105.2705/)
  mkres               = True
  txres               = True
  mkres@gsMarkerSizeF = 10
  mkres@gsMarkerIndex = 16
  txres@txFontHeightF = 0.02   ; 0.02 if part of smaller map
  txres@txFont = "helvetica"
  txres@txJust = "BottomRight"
  map@cities_tx = gsn_add_text(wks,map,cities,city_lons,city_lats+0.01,txres)
end


;----------------------------------------------------------------------
; Given an NCL map, a shapefile, and a list of requested features
; in the shapefile, this procedure adds the outlines of the
; requested shapefile features to the NCL map.
;----------------------------------------------------------------------
procedure add_shapefile_outlines_by_name(wks,plot,shp_file_name,shp_var_name,requested_features)
begin
;---Open the shapefile
  f = addfile(shp_file_name,"r")

;---Read data off the shapefile
  geomDims    = getfilevardimsizes(f,"geometry")
  numFeatures = geomDims(0)

  features = f->$shp_var_name$
  segments = f->segments
  geometry = f->geometry
  segsDims = dimsizes(segments)

;---Read global attributes  
  geom_segIndex = f@geom_segIndex
  geom_numSegs  = f@geom_numSegs
  segs_xyzIndex = f@segs_xyzIndex
  segs_numPnts  = f@segs_numPnts

;---Section to attach polygons to plot.
  lon = f->x
  lat = f->y

  npl = 0     ; polyline counter

  lnres                  = True
  lnres@gsLineThicknessF = 5.0
  lnres@gsLineColor      = "Gray"
  lnres@gsFillColor      = "White"
  do i=0,numFeatures-1  
    if(.not.any(features(i).eq.requested_features)) then
      continue
    end if
    startSegment = geometry(i, geom_segIndex)
    numSegments  = geometry(i, geom_numSegs)
    do seg=startSegment, startSegment+numSegments-1
      startPT = segments(seg, segs_xyzIndex)
      endPT   = startPT + segments(seg, segs_numPnts) - 1
      plot@$unique_string("lines")$ = gsn_add_polyline(wks,plot,lon(startPT:endPT),lat(startPT:endPT),lnres)
    end do
  end do
end


;----------------------------------------------------------------------
; Given a list of lat/lon values, this procedure uses a rough
; lat/lon box to determine which points are close to the 
; Boulder / Denver / Golden area in Colorado, and which aren't.
;
; The lat/lon points are split up into two separate lists and returned.
;----------------------------------------------------------------------
function get_latlon_bld_den_gld(lat,lon)
local msg, ii, lat2, lon2, lat_bd, lon_bd, lat_no_bd, lon_no_bd
begin
  lat2 = lat
  lon2 = lon
  if(.not.isatt(lat2,"_FillValue")) then
    lat2@_FillValue = default_fillvalue(typeof(lat2))
  end if
  if(.not.isatt(lon2,"_FillValue")) then
    lon2@_FillValue = default_fillvalue(typeof(lon2))
  end if

;---Get index values where the lat/lon do not fall in Denver/Boulder/Golden area
  ii = ind(lat.ge.39.5.and.lat.le.40.2.and.lon.ge.-105.4.and.lon.le.-104.8)

  lat2(ii) = lat2@_FillValue
  lon2(ii) = lon2@_FillValue

  lat_bd    = lat(ii)
  lon_bd    = lon(ii)
  lat_no_bd = lat2(ind(.not.ismissing(lat2)))
  lon_no_bd = lon2(ind(.not.ismissing(lon2)))

  return([/lat_no_bd,lon_no_bd,lat_bd,lon_bd/])

end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
  shp_name_states = "states.shp"
  shp_name_adm1   = "USA_adm/USA_adm1.shp"
  shp_name_adm2   = "USA_adm/USA_adm2.shp"
  rmacc_csv       = "rmacc.csv"    ; Location,Lat,Lon
  rm_list = read_csv(rmacc_csv)
  loc     = rm_list[0]
  lat     = rm_list[1]
  lon     = rm_list[2]

;---Get lat/lon values minus the Denver/Boulder area
  den_bld_gld_list = get_latlon_bld_den_gld(lat,lon)
  lat_no_bd = den_bld_gld_list[0]
  lon_no_bd = den_bld_gld_list[1]
  lat_bd    = den_bld_gld_list[2]
  lon_bd    = den_bld_gld_list[3]

;---Start the graphics
  wks = gsn_open_wks("png","polyg")

;---Create a map of the west area of the USA
  opt        = True
  opt@minlat = 27.
  opt@maxlat = 51.
  opt@minlon = -125.
  opt@maxlon = -100.
  usa_map    = simple_map(wks,lat,lon,"RMACC Locations in the western USA (2016)",opt)

;---Create a map of the Denver/Boulder area
  den_bld_gld_lat = (/  39.7,  40.1/)
  den_bld_gld_lon = (/-105.4,-104.9/)

  opt            = True
  opt@minlat     = min(den_bld_gld_lat)
  opt@maxlat     = max(den_bld_gld_lat)
  opt@minlon     = min(den_bld_gld_lon)
  opt@maxlon     = max(den_bld_gld_lon)
  opt@perim      = True
  opt@tickmarks  = False
  opt@background = "gray95"
  bd_map = simple_map(wks,lat,lon,"",opt)

;---Add various outlines, markers, and text to the two maps.
  add_shapefile_outlines(wks,usa_map,shp_name_states)
  add_shapefile_outlines_by_name(wks,usa_map,shp_name_adm2,"NAME_1","Colorado")
  add_shapefile_outlines_by_name(wks,bd_map, shp_name_adm2,"NAME_1","Colorado")

  add_latlon_markers(wks,usa_map,lat_no_bd,lon_no_bd,"blue",20.)               ; Non Boulder/Denver
  add_latlon_markers(wks,usa_map,avg(lat_bd),avg(lon_bd),"forestgreen",30.)    ; Boulder/Denver
  add_latlon_markers(wks,bd_map,lat,lon,"forestgreen",20.)

  add_co_cities(wks,bd_map)

;---Add title to the bottom of Bld/Den/Gld map
  txres                       = True
  txres@txFontHeightF         = 0.025
  txres@txFont                = "helvetica-bold"
  txres@txBackgroundFillColor = "transparent"
  txres@txJust                = "TopCenter"
  txid_bd = gsn_add_text(wks,bd_map,"RMACC Locations in the Denver/Boulder area",\
                          (opt@maxlon+opt@minlon)/2.,opt@maxlat-0.01,txres)

;---Make the Boulder/Denver map smaller and attach it as annotation of USA map.
  setvalues bd_map
    "vpWidthF"  : 0.4
    "vpHeightF" : 0.4
  end setvalues

  amres                  = True
  amres@amJust           = "BottomLeft"
  amres@amOrthogonalPosF =  0.49   ; 0.5 is the bottom edge of the plot.
  amres@amParallelPosF   = -0.49   ; -0.5 is the left edge of the plot.
  bd_anno = gsn_add_annotation(usa_map, bd_map, amres)

  draw(usa_map)   ; This draws both maps
  frame(wks)
end
