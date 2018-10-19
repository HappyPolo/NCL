;*************************************************
; shapefiles_2_old.ncl
;
; Concepts illustrated:
;   - Reading shapefiles
;   - Plotting data from shapefiles
;   - Drawing selected data based upon a database query of the shapefile
;   - Using shapefile data to plot history of F5 tornadoes in the U.S.
;
;*************************************************
; 
; Simple example of how to draw selected geometry from a shapefile,
; based upon properties of an associated non-spatial variable.
;
; This example draws the historical incidents of F5-class tornadoes in 
; the United States.
; 
;   The "states.shp" and "tornadx020.shp" shapefiles are from the 
;   National Atlas (http://www.nationalatlas.gov/)
;  
; You must also have the associated ".dbf" and ".shx" files for this
; example to run.
;*************************************************
; This script shows the "old" way (pre NCL V6.1.0) of adding shapefile
; outlines to an existing NCL map. See shapefiles_2.ncl for the new 
; and easier way using gsn_add_shapefile_polylines.
;*************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
  if (.not.isvar("dev")) then
    dev = "X11"
  end if

  wks  = gsn_open_wks(dev,"tornados_f5")

  mres                     = True
  mres@mpLimitMode         = "Corners"     ; corner method of zoom
  mres@mpLeftCornerLatF    = 22            ; left corner
  mres@mpLeftCornerLonF    = -125          ; left corner
  mres@mpRightCornerLatF   = 50            ; right corner
  mres@mpRightCornerLonF   = -64           ; right corner
  mres@mpProjection        = "LambertConformal"    ; choose projection
  mres@mpLambertParallel1F = 33            ; first parallel
  mres@mpLambertParallel2F = 45            ; second parallel
  mres@mpLambertMeridianF  = -98           ; meridian
  mres@tfDoNDCOverlay      = True          ; native grid, no transform
  mres@gsnDraw             = False         ; don't draw yet
  mres@gsnFrame            = False         ; don't advance frame yet
  mres@gsnMaximize = False
  mres@pmTickMarkDisplayMode = "Always"    ; turn on tickmarks
  mres@tiMainString = "Historical record of F5-tornadoes in the USA"

  plot = gsn_csm_map(wks,mres)

  ; Open the states shapefile and draw the state boundaries...
  f        = addfile("states.shp", "r")

  geometry = f->geometry
  segments = f->segments
  segsDims = dimsizes(segments)
  dims     = dimsizes(geometry)
  
;
; We need to reference these inside a nested do loop, so it's
; better to read them off the file here once, and use the
; local variables inside the do loops.
;
  geom_segIndex = f@geom_segIndex
  geom_numSegs  = f@geom_numSegs
  segs_xyzIndex = f@segs_xyzIndex
  segs_numPnts  = f@segs_numPnts

  plres = True
  plres@gsLineColor = "white"
  lines = new(segsDims(0),graphic)

  numFeatures = dims(0)

  segNum = 0
  lat      = f->y
  lon      = f->x
  do i=0, numFeatures-1
     startSegment = geometry(i, geom_segIndex)
     numSegments  = geometry(i, geom_numSegs)
     do seg=startSegment, startSegment+numSegments-1
        startPT = segments(seg, segs_xyzIndex)
        endPT = startPT + segments(seg, segs_numPnts) - 1
        lines(segNum) = gsn_add_polyline(wks, plot, lon(startPT:endPT), \
                                                    lat(startPT:endPT), plres)
        segNum = segNum + 1
     end do
  end do

  ; Open the tornadoes shapefile and query for all tornadoes of F5 classification
  ; on the Fujita Scale...
  t = addfile("tornadx020.shp", "r")
  f5s = ind(t->F_SCALE.ge.5)
  
  ; Draw only the selected points...
  plres = True
  plres@gsMarkerColor = "red"
  plres@gsMarkerIndex = 14  
  p = gsn_add_polymarker(wks, plot, t->x(f5s), t->y(f5s), plres)

  draw(plot)
  frame(wks)

end
