;----------------------------------------------------------------------
; shapefiles_21.ncl
;
; Concepts illustrated:
;   - Reading shapefiles
;   - Adding shapefile outlines to an existing WRF contour/map plot
;   - Masking a data array based on a geographical area obtained from a shapefile
;   - Masking a data array by filling undesired areas in white
;   - Drawing a WRF lat/lon grid using gsn_coordinates
;----------------------------------------------------------------------
; This example shows how to use a shapefile of the United States
; to mask data based on given shapefile areas. This shows
; two methods: 
;
;  - one using shapefile_mask_data to set the data to missing outside 
;    the undesired areas.
;
;  - one by drawing the full contours, and then drawing the undesired 
;    areas filled in white.
;
; This example was updated Oct 2017 to show how the "shape_names" 
; attribute can work with either array of strings or integers. 
; You just have to use the correct type for whatever type the 
; "shape_var_name" variable is on your shapefile.
;
; The "USA_admx.shp" shapefiles were downloaded from 
; http://www.gadm.org/country/
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;----------------------------------------------------------------------
load "./shapefile_utils.ncl"

;----------------------------------------------------------------------
; Given a variable name on a shapefile, this function returns all the 
; shapefile areas of interest.  Optionally, you can include a list
; of areas to exclude (which is the real purpose of this function).
;----------------------------------------------------------------------
function get_areas_of_interest(shp_file_name,shp_var_name,opt[1]:logical)
begin
;---Open the shapefile
  f = addfile(shp_file_name,"r")
  features = f->$shp_var_name$

  if(opt.and.isatt(opt,"areas_to_exclude")) then
    features@_FillValue = default_fillvalue(typeof(features))
    do na=0,dimsizes(opt@areas_to_exclude)-1
      ii := ind(features.eq.opt@areas_to_exclude(na))
      if(.not.any(ismissing(ii))) then
        features(ii) = features@_FillValue
      end if
    end do
    return(features(ind(.not.ismissing(features))))
  else
    return(features)
  end if
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
  polytype         = get_res_value_keep(opt,"polytype","polyline")    ; "marker", "polygon"
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
;
  ptres                  = True
  ptres@gsLineColor      = get_res_value_keep(opt,"gsLineColor","darkorchid4")
  ptres@gsLineThicknessF = get_res_value_keep(opt,"gsLineThicknessF",3.0)
  ptres@gsMarkerIndex    = get_res_value_keep(opt,"gsMarkerIndex",16)
  ptres@gsFillColor      = get_res_value_keep(opt,"gsFillColor","white")

  do i=0,numFeatures-1  
    if(.not.any(features(i).eq.requested_features)) then
      continue
    end if
    startSegment = geometry(i, geom_segIndex)
    numSegments  = geometry(i, geom_numSegs)
    do seg=startSegment, startSegment+numSegments-1
      startPT = segments(seg, segs_xyzIndex)
      endPT   = startPT + segments(seg, segs_numPnts) - 1
      plot@$unique_string("primitive")$ = gsn_add_primitive(wks,plot,lon(startPT:endPT),lat(startPT:endPT),False,polytype,ptres)
    end do
  end do
end


;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
  wrf_filename  = "wrfout_d01_2005-12-14_13:00:00.nc"
  a = addfile(wrf_filename,"r")
 
;---Read "height" variable and lat/lon coordinates off WRF output file.
  nt        = 0                 ; First time step
  hgt       = a->HGT(nt,:,:)
  printMinMax(hgt,0)

  hgt@lat2d = a->XLAT(nt,:,:)      ; necessary for plotting over a 
  hgt@lon2d = a->XLONG(nt,:,:)     ; different map projection than
  minlat    = min(hgt@lat2d)       ; what's defined on the WRF file
  maxlat    = max(hgt@lat2d) 
  minlon    = min(hgt@lon2d) 
  maxlon    = max(hgt@lon2d) 

;
; Using a shapefile, set all hgt values to missing except for those 
; over the areas of interest.
; 
  shp_filename1  = "USA_adm/USA_adm1.shp"    ; State outlines

  shape_var_name = "NAME_1"     ; string based names
; shape_var_name = "ID_1"       ; integer based names

  if(shape_var_name.eq."NAME_1") then
    areas_of_interest = (/"Kentucky","West Virginia","Virginia","Mississippi",\
                          "Georgia","North Carolina","Alabama","Tennessee",\
                          "South Carolina"/)
  else
    areas_of_interest = (/18,49,47,25,11,34,1,43,41/)
  end if

  opt             = True
  opt@minlat      = minlat    ; Setting these four resources makes
  opt@maxlat      = maxlat    ; the function run slightly faster,
  opt@minlon      = minlon    ; b/c it won't check the whole 
  opt@maxlon      = maxlon    ; shapefile.
  opt@debug       = True
  opt@shape_var   = shape_var_name
  opt@shape_names = areas_of_interest

  hgt_mask        = shapefile_mask_data(hgt,shp_filename1,opt)

;---Start the graphics
  wks = gsn_open_wks("png","shapefiles")  ; send graphics to PNG file

  res                   = True
  res@gsnMaximize       = True
  res@gsnDraw           = False
  res@gsnFrame          = False

  res@cnFillOn          = True
  res@cnLinesOn         = False
  res@cnFillPalette     = "OceanLakeLandSnow"

  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels = (/0.5,5,10,25,50,100,200,300,400,500,600,700,800,900,1000,1100/)

  res@mpOutlineOn           = False
  res@mpOutlineBoundarySets = "AllBoundaries"   ; this is for ocean fill

  res@pmTickMarkDisplayMode = "Always"    ; nicer map tickmarks

  res@tiMainFont        = "helvetica"     ; default is helvetica-bold
  res@tiMainFontHeightF = 0.015           ; default is a bit large
  res@pmTitleZone       = 4               ; moves title down a bit

  res@gsnLeftString     = ""              ; don't want the substrings at the top
  res@gsnRightString    = ""

;
; Create three plots: 
;    1) Original data that is not zoomed in
;    2) Original data that is zoomed in
;    3) Original data masked by shapefile outlines
;
; Note: the plots are only created here and not drawn. They will be
; drawn later after we add the desired outlines, markers, and filled areas.
;
  res@mpMinLatF    = min(hgt@lat2d)    ; Zoom in on lat/lon area of height
  res@mpMaxLatF    = max(hgt@lat2d) 
  res@mpMinLonF    = min(hgt@lon2d) 
  res@mpMaxLonF    = max(hgt@lon2d) 
  res@tiMainString = "Original data, no masking or zooming"

;---First plot
  plot_orig = gsn_csm_contour_map(wks,hgt,res)

;---Further zoom in on map
  res@mpMinLatF    =  28.
  res@mpMaxLatF    =  41.
  res@mpMinLonF    = -92.
  res@mpMaxLonF    = -75.
  res@tiMainString = "Mask data by keeping points inside shapefile outline"

;---Second plot
  plot_mask = gsn_csm_contour_map(wks,hgt_mask,res)

;---Set some options for filling ocean and land in white
  res@mpLandFillColor        = "transparent"
  res@mpOceanFillColor       = "white"
  res@mpInlandWaterFillColor = "white"

  res@cnFillDrawOrder        = "PreDraw"   ; draw filled contours first
  res@mpFillDrawOrder        = "Draw"      ; draw filled map areas second
  res@tfPolyDrawOrder        = "PostDraw"  ; draw filled shapefile last
  res@tiMainString           = "Mask data by filling undesired areas in white"

;---Third plot
  plot_fill = gsn_csm_contour_map(wks,hgt,res)

;---In the "fill" plot, fill in undesired areas in white.
  opt                  = True
  opt@areas_to_exclude = areas_of_interest
  areas_to_fill        = get_areas_of_interest(shp_filename1,shape_var_name,opt)

  popt          = True
  popt@polytype = "polygon"
  add_shapefile_primitives_by_name(wks,plot_fill,shp_filename1,shape_var_name,areas_to_fill,popt)

;---Add coordinate points at lat/lon locations to two of the plots
  mkres                          = True
  mkres@gsMarkerSizeF            = 0.003
  mkres@gsnCoordsAttach          = True
  mkres@gsnCoordsMissingColor    = "red"
  mkres@gsnCoordsNonMissingColor = "black"
  gsn_coordinates(wks,plot_mask,hgt_mask,mkres)
  gsn_coordinates(wks,plot_fill,hgt,mkres)

;---Add US state shapefile outlines to all plots.
  lnres                  = True
  lnres@gsLineColor      = "gray25"
  lnres@gsLineThicknessF = 2.0
  id_orig = gsn_add_shapefile_polylines(wks,plot_orig,shp_filename1,lnres)
  id_mask = gsn_add_shapefile_polylines(wks,plot_mask,shp_filename1,lnres)
  id_fill = gsn_add_shapefile_polylines(wks,plot_fill,shp_filename1,lnres)

;---Add highlighted outlines indicating the area of interest.
  popt@polytype = "polyline"
  add_shapefile_primitives_by_name(wks,plot_orig,shp_filename1,shape_var_name,\
                                   areas_of_interest,popt)
  add_shapefile_primitives_by_name(wks,plot_mask,shp_filename1,shape_var_name,\
                                   areas_of_interest,popt)
  add_shapefile_primitives_by_name(wks,plot_fill,shp_filename1,shape_var_name,\
                                   areas_of_interest,popt)

;---Draw all three plots, which will draw the various attached lines, polygons, and markers
  draw(plot_orig)
  frame(wks)

  draw(plot_mask)
  frame(wks)

  draw(plot_fill)
  frame(wks)
end
