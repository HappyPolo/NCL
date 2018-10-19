;----------------------------------------------------------------------
; shapefiles_12.ncl
;
; Concepts illustrated:
;   - Reading shapefiles
;   - Plotting data from shapefiles
;   - Selecting specific features in a shapefile to draw
;   - Modifying gsn_add_shapefile_polylines to draw a subset of the shapefile
;   - Using shapefile data to plot primary interstate highways in Western U.S.
;   - Zooming in on Western United States
;   - Changing the land fill color
;   - Drawing a custom legend inside a map plot
;----------------------------------------------------------------------
; The shapefile for the Interstate Highways of the US was downloaded
; from: 
;
; http://www.nws.noaa.gov/geodata/catalog/transportation/html/interst.htm
; 
; Click on the "Download Compressed Shapefile" link and then run
; "unzip" on the downloaded file ("in101503.zip") to extract the
; files.
;
; Thanks to Dave Allured of NOAA for his improvement of this script
; to handle more highway segments that the original script missed
; (for example, ""I- 5, US 30").
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

;----------------------------------------------------------------------
; This function is a modified version of "gsn_add_shapefile_polylines" in
; "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl". It was modified
; to indicate which shapefile features we want to draw.
; 
; Three variables were added to the argument list:
;   "vname" - set this to the name of the variable on the shapefile
;             that contains the names of the areas you want to draw.
;   "vlist" - list of areas in "vname" that you want to draw.
;   "colors" - list of colors to use for each "vname"
;----------------------------------------------------------------------
undef("gsn_add_shapefile_polylines_subset")
function gsn_add_shapefile_polylines_subset(wks,plot,fname[1]:string,\
         vname[1]:string,vlist[*]:string,colors[*],lnres)
local f, segments, geometry, segsDims, geomDims, geom_segIndex, \
geom_numSegs, segs_xyzIndex, segs_numPnts, numFeatures, i, lat, lon, \
startSegment, numSegments, seg, startPT, endPT, npoly, npl, feature_names, \
num_vlist, feature_flags, vlist_inds, ii, inds
begin
;---Open the shapefile
  f = addfile(fname,"r")

;---Error checking
  if(ismissing(f)) then
    print("Error: gsn_add_shapefile_polylines_subset: Can't open shapefile '" + \
           fname + "'")
    print("       No shapefile information will be added.")
    return(new(1,graphic))
  end if

;---We can't use this routine to plot point data
  if(.not.any(f@geometry_type.eq.(/"polygon","polyline"/))) then
    print("Error: gsn_add_shapefile_polylines_subset: geometry_type attribute must be 'polygon' or 'polyline'")
    print("       No shapefile information will be added.")
    return(new(1,graphic))
  end if

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

;---Read variable containing names of areas we are interested in
  feature_names = f->$vname$

;---Special handling for comma separated name lists inside feature_names,
;---such as found in the AWIPS interstate highways shape file.
  num_vlist = dimsizes (vlist)
  feature_flags = new (numFeatures, logical)
  vlist_inds    = new (numFeatures, integer)
  feature_flags = False
  do ii = 0, num_vlist-1
     inds = str_match_ind_ic(feature_names+",", vlist(ii)+",")
     if (.not. ismissing (inds(0))) then
       feature_flags(inds) = True    ; vector subscripting
       vlist_inds(inds)    = ii      ; ref. indices for requested names
     end if
     delete (inds)
  end do

;---Create array to hold all polylines
  npoly = sum(geometry(:,geom_numSegs)) 
  poly  = new(npoly,graphic)

;---Section to attach polylines to plot.
  lon = f->x
  lat = f->y
  npl = 0     ; polyline counter
;
; Special check for minlat/maxlat/minlon/maxlon attributes.
;
; If set, then each lat/lon segment will be checked if it's
; in the range.  This can speed up plotting, but I need to
; verify this!
; 
  if(isatt(lnres,"minlon").and.isatt(lnres,"maxlon").and.\
     isatt(lnres,"minlat").and.isatt(lnres,"maxlat")) then
    do i=0, numFeatures-1  
       if(.not.feature_flags(i)) then
         continue
       end if
       lnres@gsLineColor = colors(vlist_inds(i))
       startSegment = geometry(i, geom_segIndex)
       numSegments  = geometry(i, geom_numSegs)
       do seg=startSegment, startSegment+numSegments-1
          startPT = segments(seg, segs_xyzIndex)
          endPT   = startPT + segments(seg, segs_numPnts) - 1
          lat_sub = lat(startPT:endPT)
          lon_sub = lon(startPT:endPT) 
          if(.not.(all(lon_sub.lt.lnres@minlon).or. \
                   all(lon_sub.gt.lnres@maxlon).or. \
                   all(lat_sub.lt.lnres@minlat).or. \
                   all(lat_sub.gt.lnres@maxlat))) then
            poly(npl) = gsn_add_polyline(wks, plot, lon_sub, lat_sub, lnres)
            npl = npl + 1
          end if
          delete([/lat_sub,lon_sub/])
       end do
    end do
  else       ; Don't do any range checking. 
    do i=0, numFeatures-1  
       if(.not.feature_flags(i)) then
         continue
       end if
       lnres@gsLineColor = colors(vlist_inds(i))
       startSegment = geometry(i, geom_segIndex)
       numSegments  = geometry(i, geom_numSegs)
       do seg=startSegment, startSegment+numSegments-1
          startPT = segments(seg, segs_xyzIndex)
          endPT   = startPT + segments(seg, segs_numPnts) - 1
          poly(npl) = gsn_add_polyline(wks, plot, lon(startPT:endPT),  \
                                       lat(startPT:endPT), lnres)
          npl = npl + 1
       end do
    end do
  end if
  return(poly(0:npl-1))
end


;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
  shp_filename = "in101503.shp"

;--- Open workstation.
  wks = gsn_open_wks("png","shapefiles")  ; send graphics to PNG file

  res                   = True
  res@gsnMaximize       = True
  res@gsnFrame          = False
  res@gsnDraw           = False

  res@mpDataBaseVersion = "MediumRes"     ; Better map resolution
  res@mpLandFillColor   = "bisque3"
  res@mpFillOn              = True
  res@mpOutlineOn           = True
  res@mpOutlineBoundarySets = "USStates"
  res@mpUSStateLineColor    = "Gray25"

;---Zoom in on Washington State
  res@mpLimitMode       = "LatLon"
  res@mpMinLatF         = 30
  res@mpMaxLatF         = 50
  res@mpMinLonF         = -130
  res@mpMaxLonF         = -110
  res@mpCenterLonF      = avg((/res@mpMinLonF,res@mpMaxLonF/))

  res@pmTickMarkDisplayMode = "Always"     ; Turn on fancier tickmark labels.
  res@tiMainString          = "Selected interstate highways in Western U.S."
  res@tiMainFontHeightF     = 0.015

  map = gsn_csm_map(wks,res)

;---Attach specified highways as polylines on the map.
  highways = (/"I- 5",    "I- 82","I- 90"/)
  colors   = (/"NavyBlue","Brown","DarkOrchid4"/)
  pres                  = True
  pres@gsLineThicknessF = 3.0       ; default is 1.0
  poly = gsn_add_shapefile_polylines_subset(wks,map,shp_filename,"ROUTE",\
                                            highways,colors,pres)

;---Add a text legend to identify highways by color.
  nh    = dimsizes(highways)
  txid  = new(nh,graphic)

  txres               = True
  txres@txFontHeightF = 0.025
  txres@txJust        = "CenterLeft"

  lat = (/ 47,   46,  45/)
  lon = (/-128,-128,-128/)
  do i=0,nh-1
    txres@txFontColor = colors(i)
    txid(i) = gsn_add_text(wks,map,str_sub_str(highways(i)," ",""),lon(i),lat(i),txres)
  end do

;---Drawing the map will also draw the attached polylines and text legend.
  draw(map)
  frame(wks)
end
