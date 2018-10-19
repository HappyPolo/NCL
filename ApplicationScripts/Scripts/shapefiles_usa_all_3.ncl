;----------------------------------------------------------------------
; shapefiles_usa_3.ncl
;
; Concepts illustrated:
;   - Reading shapefiles
;   - Plotting data from shapefiles
;   - Drawing selected data based upon a database query of the shapefile
;   - Decreasing the font size of the main title
;   - Using shapefile data to draw the streams of South America
;   - Zooming in on South America on a cylindrical equidistant map
;   - Drawing a map using the medium resolution map outlines
;
;----------------------------------------------------------------------
;  Simple example of how to draw polylines read from a shapefile.
;----------------------------------------------------------------------
; You must download the "hydrogm020_nt00015.tar.gz" gzipped tar file
; (34 MB) from:
;
;  https://catalog.data.gov/dataset/usgs-small-scale-dataset-streams-and-waterbodies-of-the-united-states-200512-shapefile
;
; Gunzip and untar the file:
;
;   tar -zxf hydrogm020_nt00015.tar.gz 
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;----------------------------------------------------------------------
; This function creates a basic NCL map of mainland USA.
;----------------------------------------------------------------------
undef("mainland_map")
function mainland_map(wks,title)
local res
begin
  res                        = True
  res@gsnMaximize            = True
  res@gsnDraw                = False
  res@gsnFrame               = False
  res@mpFillOn               = True 

  res@mpOutlineDrawOrder     = "Draw"
  LC = True            ; This generates a nicer looking map of the U.S.
  if(LC) then
    res@mpProjection           = "LambertConformal"  ; choose projection
    res@mpLambertParallel1F    = 29.5  ; 33.0                ; two parallels
    res@mpLambertParallel2F    = 45.5  ; 45.0
    res@mpLambertMeridianF     = -95.0               ; central meridian
    res@mpLimitMode            = "LatLon"
    res@mpMinLatF           = 20.5         ; map area
    res@mpMaxLatF           = 51.0         ; latitudes
    res@mpMinLonF           = -120.0       ; and
    res@mpMaxLonF           = -71.0        ; longitudes
  else
    res@mpMinLatF           =  18.5
    res@mpMaxLatF           =  50
    res@mpMinLonF           = -128
    res@mpMaxLonF           =  -62
  end if
  res@mpPerimOn              = False
  res@mpLandFillColor        = "white"
  res@mpOceanFillColor       = "white"
  res@mpInlandWaterFillColor = "white"
  res@tiMainString           = title
  map = gsn_csm_map(wks,res)

  map@minlat = res@mpMinLatF
  map@maxlat = res@mpMaxLatF
  map@minlon = res@mpMinLonF
  map@maxlon = res@mpMaxLonF
  return(map)
end

;----------------------------------------------------------------------
; Create a simple NCL map of Hawaii and resize it to be a fraction
; of the size of the mainland USA map.
;----------------------------------------------------------------------
undef("hawaii_map")
function hawaii_map(wks,main_map)
local res, main_height
begin
  getvalues main_map
    "vpHeightF" : main_height
  end getvalues
  res                        = True
  res@vpHeightF              = 0.20*main_height
  res@gsnDraw                = False
  res@gsnFrame               = False
  res@mpFillOn               = True 
  res@mpOutlineOn            = False
  res@mpPerimOn              = False
  LC = True
  if(LC) then
    res@mpProjection           = "LambertConformal"  ; choose projection
    res@mpLambertParallel1F    =  8.   ; 33.0                ; two parallels
    res@mpLambertParallel2F    = 18.   ; 45.0
    res@mpLambertMeridianF     = -165.               ; central meridian
    res@mpLimitMode            = "LatLon"
  else
    res@gsnTickMarksOn         = False
  end if
  res@mpMinLatF              = 18.5
  res@mpMaxLatF              = 22.5
  res@mpMinLonF              = -161
  res@mpMaxLonF              = -154
  res@mpLandFillColor        = "transparent"
  res@mpOceanFillColor       = "transparent"
  res@mpInlandWaterFillColor = "transparent"
  map = gsn_csm_map(wks,res)
;---This is for later, when we add the shapefile outlines
  map@minlat = res@mpMinLatF
  map@maxlat = res@mpMaxLatF
  map@minlon = res@mpMinLonF
  map@maxlon = res@mpMaxLonF
  return(map)
end

;----------------------------------------------------------------------
; Create a simple NCL map of Puerto Rico and resize it to be a
; fraction of the size of the mainland USA map.
;----------------------------------------------------------------------
undef("puerto_rico_map")
function puerto_rico_map(wks,main_map)
local res, main_height
begin
  getvalues main_map
    "vpHeightF" : main_height
  end getvalues

  res                        = True
  res@vpHeightF              = 0.10*main_height
  res@gsnDraw                = False
  res@gsnFrame               = False
  res@mpFillOn               = True 
  res@mpOutlineOn            = False
  res@mpPerimOn              = False
  LC = True
  if(LC) then
    res@mpProjection           = "LambertConformal"  ; choose projection
    res@mpLambertParallel1F    = 18.03
    res@mpLambertParallel2F    = 18.43
    res@mpLambertMeridianF     = -66.43
    res@mpLimitMode            = "LatLon"
  else
    res@gsnTickMarksOn         = False
  end if
  res@mpMinLatF              = 17.85
  res@mpMaxLatF              = 18.6
  res@mpMinLonF              = -68
  res@mpMaxLonF              = -65
  res@mpLandFillColor        = "transparent"
  res@mpOceanFillColor       = "transparent"
  res@mpInlandWaterFillColor = "transparent"
  map = gsn_csm_map(wks,res)

;---This is for later, when we add the shapefile outlines
  map@minlat = res@mpMinLatF
  map@maxlat = res@mpMaxLatF
  map@minlon = res@mpMinLonF
  map@maxlon = res@mpMaxLonF
  return(map)
end

;----------------------------------------------------------------------
; Create a simple NCL map of Alaska and resize it to be a fraction of 
; the size of the mainland USA map.
;----------------------------------------------------------------------
undef("alaksa_map")
function alaska_map(wks,main_map)
local res, main_height
begin
  getvalues main_map
    "vpHeightF" : main_height
  end getvalues
  res                        = True
  res@vpHeightF              = 0.3*main_height
  res@gsnDraw                = False
  res@gsnFrame               = False
  res@mpFillOn               = True 
  res@mpOutlineOn            = False
  res@mpPerimOn              = False
  LC = True
  if(LC) then
    res@mpProjection           = "LambertConformal"  ; choose projection
    res@mpLambertParallel1F    = 55.0                ; two parallels
    res@mpLambertParallel2F    = 65.0
    res@mpLambertMeridianF     = -150.
    res@mpLimitMode            = "LatLon"
  else
    res@gsnTickMarksOn         = False
  end if
  res@mpMinLatF              = 53.
  res@mpMaxLatF              = 71.5
  res@mpMinLonF              = -172
  res@mpMaxLonF              = -129
  res@mpLandFillColor        = "transparent"
  res@mpOceanFillColor       = "transparent"
  res@mpInlandWaterFillColor = "transparent"
  map = gsn_csm_map(wks,res)

;---This is for later, when we add the shapefile outlines
  map@minlat = res@mpMinLatF
  map@maxlat = res@mpMaxLatF
  map@minlon = res@mpMinLonF
  map@maxlon = res@mpMaxLonF
  return(map)
end

;----------------------------------------------------------------------
; Add three smaller maps to larger map as annotations.
;----------------------------------------------------------------------
undef("add_small_maps_to_big_map")
procedure add_small_maps_to_big_map(main_map,ak_map,hi_map,pr_map)
local amres
begin
  amres                  = True
  amres@amJust           = "BottomLeft"
  amres@amOrthogonalPosF = 0.50   ; 0.5 is the bottom edge of the plot.

  amres@amParallelPosF   = -0.5   ; -0.5 is the left edge of the plot.
  main_map@$unique_string("ak")$  = gsn_add_annotation(main_map, ak_map, amres)

  amres@amParallelPosF   = -0.2   ; -0.5 is the left edge of the plot
  main_map@$unique_string("h")$ = gsn_add_annotation(main_map, hi_map, amres)

  amres@amJust           = "BottomRight"
  amres@amParallelPosF   = 0.4   ; 0.5 is the right edge of the plot
  main_map@$unique_string("h")$ = gsn_add_annotation(main_map, pr_map, amres)
end

;----------------------------------------------------------------------
; Given an NCL map, a shapefile, and a list of requested features
; in the shapefile, this procedure adds markers, lines, or polygons
; of the requested shapefile features to the NCL map.
;----------------------------------------------------------------------
procedure add_shapefile_primitives_by_name(wks,plot,shp_file_name, \
                                           shp_var_name,requested_features,\
                                           opt[1]:logical)
local poly_type, ptres, f, geomDims, numFeatures, features, segments, \
      geometry, segsDims, geom_segIndex, geom_numSegs, segs_xyzIndex,\
      segs_numPnts, lat, lon, startSegment, numSegments, startPT, endPT
begin
  polytype         = get_res_value(opt,"polytype","polyline")    ; "marker", "polygon"
  valid_prim_types = (/"polymarker","polyline","polygon"/)
  if(.not.any(polytype.eq.valid_prim_types)) then
    print("add_shapefile_primitives_by_name: invalid polytype.")
    print("    Must be "+str_join(valid_prim_types,","))
    return
  end if

;---Read data off the shapefile
  f = addfile(shp_file_name,"r")
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

;
; Set custom primitive resources. It doesn't hurt to set, say line 
; color, even if you are just drawing markers. They will be ignored.
  ptres                  = True
  ptres@gsLineColor      = get_res_value(opt,"gsLineColor","darkorchid4")
; ptres@gsLineThicknessF = get_res_value(opt,"gsLineThicknessF",10.0)
  ptres@gsMarkerIndex    = get_res_value(opt,"gsMarkerIndex",16)
  ptres@gsFillColor      = get_res_value(opt,"gsFillColor","white")

  do i=0,numFeatures-1  
    if(.not.any(features(i).eq.requested_features)) then
      continue
    end if
    startSegment = geometry(i, geom_segIndex)
    numSegments  = geometry(i, geom_numSegs)
    do seg=startSegment, startSegment+numSegments-1
      startPT = segments(seg, segs_xyzIndex)
      endPT   = startPT + segments(seg, segs_numPnts) - 1
      plot@$unique_string("line")$ = gsn_add_polyline(wks,plot,lon(startPT:endPT),lat(startPT:endPT),ptres)
    end do
  end do
end


;----------------------------------------------------------------------
; Main driver 
;----------------------------------------------------------------------
begin
  shp_filename = "hydrogl020.shp"

  wks  = gsn_open_wks("png","shapefiles")

;---Create the various maps
  main_map = mainland_map(wks,"USGS Streams and Waterbodies of the United States 2005-12")
  ak_map   = alaska_map(wks,main_map)
  hi_map   = hawaii_map(wks,main_map)
  pr_map   = puerto_rico_map(wks,main_map)

  plres             = True           ; resource list for polylines
  plres@gsLineColor = "navyblue"
  plres@polytype    = "polyline"
  shp_main = gsn_add_shapefile_polylines(wks,main_map,"hydrogl020.shp",plres)
  shp_ak   = gsn_add_shapefile_polylines(wks,ak_map,"hydrogl020.shp",plres)
  shp_hi   = gsn_add_shapefile_polylines(wks,hi_map,"hydrogl020.shp",plres)
  shp_pr   = gsn_add_shapefile_polylines(wks,pr_map,"hydrogl020.shp",plres)

;---Add three smaller maps to larger map as annotations.
  add_small_maps_to_big_map(main_map,ak_map,hi_map,pr_map)

;  add_shapefile_primitives_by_name(wks,main_map,shp_filename,"FEATURE","Stream",plres)
;  add_shapefile_primitives_by_name(wks,ak_map,shp_filename,"FEATURE","Stream",plres)
;  add_shapefile_primitives_by_name(wks,hi_map,shp_filename,"FEATURE","Stream",plres)
;  add_shapefile_primitives_by_name(wks,ak_map,shp_filename,"FEATURE","Stream",plres)

;---Draw everything
  draw(main_map)
  frame(wks)

end
