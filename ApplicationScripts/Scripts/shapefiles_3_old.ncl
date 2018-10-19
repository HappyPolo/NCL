;----------------------------------------------------------------------
; shapefiles_3_old.ncl
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
;  Simple example of how to draw selected geometry from a shapefile.
;
; You must download the "HYDRO1k Streams data set for South America
; as a tar file in shapefile format (2.4 MB)" from:
;
; http://eros.usgs.gov/#/Find_Data/Products_and_Data_Available/gtopo30/hydro/samerica
;  
; Gunzip and untar the file:
;
;   gunzip sa_str.tar.gz
;   tar -xf sa_str.tar
;
; You then can use NCL V5.1.1 to plot the shapefile data.
;
;----------------------------------------------------------------------
; This script shows the "old" way (pre NCL V6.1.0) of adding shapefile
; outlines to an existing NCL map. See shapefiles_3.ncl for the new 
; and easier way using gsn_add_shapefile_polylines.
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  wks  = gsn_open_wks("png","shapefiles")

  res                     = True

; For faster code, don't set res@gsnDraw = False, and see below.
  res@gsnDraw             = False          ; don't draw plot yet

  res@gsnFrame            = False          ; don't advance frame yet
  res@gsnMaximize         = True           ; maximize plot in frame
  res@mpDataBaseVersion   = "MediumRes"    ; slightly better resolution

; Zoom in on South America.
  res@mpMinLatF           = -60
  res@mpMaxLatF           =  15
  res@mpMinLonF           = -90
  res@mpMaxLonF           = -30

  res@tiMainString        = "Stream network data for South America"
  res@tiMainFontHeightF   = 0.015   ; Make font slightly smaller.

  plot = gsn_csm_map(wks,res)   ; Draw map, but don't advance frame.

;---Section to read shapefile data
  f = addfile("sa_str.shp", "r")   ; Open shapefile

;---Read data off shapefile
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

; print(segsDims(0))         ; Number of lines we'll end up drawing.

;---Section to add polylines to map.
  lines = new(segsDims(0),graphic)   ; array to hold polylines

  plres             = True           ; resources for polylines
  plres@gsLineColor = "blue"

  lon    = f->x
  lat    = f->y
  segNum = 0       ; Counter for adding polylines
  do i=0, numFeatures-1  
     startSegment = geometry(i, geom_segIndex)
     numSegments  = geometry(i, geom_numSegs)
     do seg=startSegment, startSegment+numSegments-1
        startPT = segments(seg, segs_xyzIndex)
        endPT   = startPT + segments(seg, segs_numPnts) - 1
        lines(segNum) = gsn_add_polyline(wks, plot, lon(startPT:endPT),  \
                                                    lat(startPT:endPT), plres)
;
; For faster code, use these two lines instead of the above two lines.
;        gsn_polyline(wks, plot, lon(startPT:endPT),  \
;                                lat(startPT:endPT), plres)

        segNum = segNum + 1
     end do
  end do
;
; For faster code, don't set res@gsnDraw above. This assumes you are 
; calling "gsn_polyline" and not "gsn_add_polyline".
;
  if(isatt(res,"gsnDraw").and..not.res@gsnDraw) then
    draw(plot)
  end if

  frame(wks)   ; Advanced frame.

end

