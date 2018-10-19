;*************************************************
; shapefiles_1.ncl
;
; Concepts illustrated:
;   - Reading shapefiles
;   - Plotting data from shapefiles
;   - Using shapefile data to plot unemployment percentages in the U.S.
;   - Drawing a custom labelbar on a map
;   - Drawing filled polygons over a Lambert Conformal plot
;   - Drawing the US with a Lambert Conformal projection
;   - Zooming in on a particular area on a Lambert Conformal map
;   - Centering the labels under the labelbar boxes
;
;*************************************************
; 
; Simple example of how to draw selected geometry from a shapefile,
; based upon properties of an associated non-spatial variable.
;
; This example color-fills the states based upon "percent unemployment",
; which is calculated from several of the non-spatial variables in the
; file.
; 
;   "states.shp" is from the National Atlas (http://www.nationalatlas.gov/)
;  
; You must also have the files "states.dbf" and "states.shx" for this
; example to run.
;*************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  wks  = gsn_open_wks("png","shapefiles") ; send graphics to PNG file

  res                     = True

  res@gsnDraw             = False       ; don't draw yet
  res@gsnFrame            = False       ; don't advance frame yet
  res@gsnMaximize         = True        ; maximize plot in frame

  res@mpProjection        = "LambertConformal"    ; choose projection
  res@mpLambertParallel1F = 33          ; first parallel
  res@mpLambertParallel2F = 45          ; second parallel
  res@mpLambertMeridianF  = -98         ; meridian

  res@mpLimitMode         = "Corners"   ; corner method of zoom
  res@mpLeftCornerLatF    = 22          ; left corner
  res@mpLeftCornerLonF    = -125        ; left corner
  res@mpRightCornerLatF   = 50          ; right corner
  res@mpRightCornerLonF   = -64         ; right corner

  res@pmTickMarkDisplayMode = "Always"  ; turn on tickmarks

  res@tiMainString          = "Percentage unemployment, by state"

  plot = gsn_csm_map(wks,res)   ; Create map, but don't draw it yet.

;*************************************************
; Section to add polygons to map.
;*************************************************

  dir = ncargpath("data") + "/shp/"
  f = addfile(dir + "states.shp", "r")   ; Open shapefile
  
;
; Read data off shapefile
;
  segments = f->segments
  geometry = f->geometry
  segsDims = dimsizes(segments)
  geomDims = dimsizes(geometry)
;
; Read global attributes  
;
  geom_segIndex = f@geom_segIndex
  geom_numSegs  = f@geom_numSegs
  segs_xyzIndex = f@segs_xyzIndex
  segs_numPnts  = f@segs_numPnts

  lines       = new(segsDims(0),graphic)   ; Array to hold polygons
  numFeatures = geomDims(0)

  unemp = f->UNEMPLOY / f->PERSONS
  lon   = f->x
  lat   = f->y

  plres             = True       ; resources for polylines
  plres@gsEdgesOn   = True       ; draw border around polygons
  plres@gsEdgeColor = "black"    

  colors = (/"blue","green","yellow","red"/)

  segNum = 0
  do i=0, numFeatures-1  

     ; color assignment (probably a better way to do this?)
     if (unemp(i).ge.0.01 .and. unemp(i).lt.0.02) then
         plres@gsFillColor = colors(0)
     end if
     if (unemp(i).ge.0.02 .and. unemp(i).lt.0.03) then
         plres@gsFillColor = colors(1)
     end if
     if (unemp(i).ge.0.03 .and. unemp(i).lt.0.04) then
         plres@gsFillColor = colors(2)
     end if
     if (unemp(i).ge.0.04) then 
         plres@gsFillColor = colors(3)
     end if

     startSegment = geometry(i, geom_segIndex)
     numSegments  = geometry(i, geom_numSegs)
     do seg=startSegment, startSegment+numSegments-1
        startPT = segments(seg, segs_xyzIndex)
        endPT = startPT + segments(seg, segs_numPnts) - 1
        lines(segNum) = gsn_add_polygon(wks, plot, lon(startPT:endPT),  \
                                                   lat(startPT:endPT), plres)
        segNum = segNum + 1
     end do
  end do

; Make a legend...
  labels = (/ "1", "2", "3", "4" /)

  lres                    = True
  lres@vpWidthF           = 0.50             ; location
  lres@vpHeightF          = 0.05             ; " " 
  lres@lbPerimOn          = False            ; Turn off perimeter.
  lres@lbOrientation      = "Horizontal"     ; Default is vertical.
  lres@lbLabelAlignment   = "BoxCenters"     ; Default is "BoxCenters".
  lres@lbFillColors       = colors
  lres@lbMonoFillPattern  = True             ; Fill them all solid.
  lres@lbLabelFontHeightF = 0.012            ; label font height
  lres@lbTitleString      = "percent"        ; title
  lres@lbTitlePosition    = "Bottom"         ; location of title
  lres@lbTitleFontHeightF = 0.01             ; title font height
  gsn_labelbar_ndc (wks,4,labels,0.23,0.15,lres)  
  
;
; Maximize output in frame. This will draw everything and advance
; the frame.
;
  maximize_output(wks,False)

end
