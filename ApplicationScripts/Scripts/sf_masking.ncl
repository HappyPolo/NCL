;----------------------------------------------------------------------
; This script is a more complex one for opening a shapefile and using
; variables in the file to mask data or not draw certain other
; features.
;----------------------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;----------------------------------------------------------------------
; Function to add shapefile data to a NCL map object.
;----------------------------------------------------------------------
procedure add_shapefile_data(wks,map,sname)
begin
;---Open shapefile
  f = addfile(sname,"r")

;---Read data off shapefilefile
  geomDims    = getfilevardimsizes(f,"geometry")
  numFeatures = geomDims(0)

  segments = f->segments
  geometry = f->geometry
  segsDims = dimsizes(segments)

;---Read global attributes  
  geom_segIndex = f@geom_segIndex
  geom_numSegs  = f@geom_numSegs
  segs_xyzIndex = f@segs_xyzIndex
  segs_numPnts  = f@segs_numPnts

;---Read lat/lon arrays
  lon           = f->x
  lat           = f->y

;---Set desired line resources
  mkres               = True
  mkres@gsMarkerIndex = 16      ; filled dot

  draw(map)

  do i=0, numFeatures-1  
     startSegment = geometry(i, geom_segIndex)
     numSegments  = geometry(i, geom_numSegs)
     do seg=startSegment, startSegment+numSegments-1
        startPT = segments(seg, segs_xyzIndex)
        endPT   = startPT + segments(seg, segs_numPnts) - 1
        gsn_polymarker(wks, map, lon(startPT:endPT),  \
                               lat(startPT:endPT), mkres)
     end do
  end do
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
  shapefile_name = "placept.shp"

;---Open file and read lat/lon
  f   = addfile(shapefile_name,"r")
  lat = f->y
  lon = f->x

  wks = gsn_open_wks("x11","map")

  res                       = True

  res@gsnMaximize           = True     ; maximize plot in frame
  res@gsnDraw               = False
  res@gsnFrame              = False

  res@mpMinLatF             = min(lat)
  res@mpMaxLatF             = max(lat)
  res@mpMinLonF             = min(lon)
  res@mpMaxLonF             = max(lon)

  res@mpDataBaseVersion     = "MediumRes"   ; "LowRes"

  map = gsn_csm_map(wks,res)
  
  add_shapefile_data(wks,map,shapefile_name)

  frame(wks)
end
