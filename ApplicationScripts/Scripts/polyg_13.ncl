;**********************************************************************
; polyg_13.ncl
;
; Concepts illustrated:
;   - Drawing filled boxes on a map plot using different methods
;   - Attaching filled boxes to a map plot
;   - Zooming in on a particular area on a Lambert Conformal map
;   - Turning on edges for polygons
;   - Attaching filled polygons to a map
;   - Changing the color of a filled polygon
;   - Using gc_latlon to create a straight box on a map
;   - Turning off the map lat/lon grid lines
;
;**********************************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;
;**********************************************************************
; This function attaches a filled box to a map.
;
; It gets the edges of the box using gc_latlon to calculate the
; great circle between two lat/lon points.
;
; This ensures that your box edges will be straight when you attach
; them to the map.
;
;**********************************************************************

function add_filled_box(wks,map,lftlat,lftlon,rgtlat,rgtlon)
local gnres, npts, i, lat_begend, lon_begend, dist
begin
  gnres             = True
  gnres@gsFillColor = "red"
  gnres@gsEdgesOn   = True

  npts   =  5     ; Number of points along each box edge.
                  ; You could make this different for each
                  ; edge, if you want.  
;
; Define the coordinates for the start, end of the four sides
; of each box. Put them in a big array so it's easier to
; loop across the points later.
;
                         ; bottom            right
                         ; top               left
  lat_begend = (/ (/lftlat,lftlat/), (/lftlat,rgtlat/),  \
                  (/rgtlat,rgtlat/), (/rgtlat,lftlat/)/)
  lon_begend = (/ (/lftlon,rgtlon/), (/rgtlon,rgtlon/),  \
                  (/rgtlon,lftlon/), (/lftlon,lftlon/)/)
  
;---Define array to hold box.
  latbox = new(4*npts,float)
  lonbox = new(4*npts,float)

;---Loop across the four edges and calculate the points along each edge
  do i=0,3
    ibeg = i*npts
    iend = ibeg+npts-1
    dist = gc_latlon(lat_begend(i,0),lon_begend(i,0), \
                     lat_begend(i,1),lon_begend(i,1),npts,2)
    latbox(ibeg:iend) = dist@gclat
    lonbox(ibeg:iend) = dist@gclon
  end do

;---Attach filled box to map and return
  dum = gsn_add_polygon(wks, map, lonbox, latbox, gnres)

  return(dum)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
  wks = gsn_open_wks("png", "polyg")  ; send graphics to PNG file

  res = True

  res@gsnDraw               = False
  res@gsnFrame              = False
  res@gsnMaximize           = True

; Add map resources
  res@mpProjection          = "LambertConformal"  
  res@mpOutlineDrawOrder    = "PostDraw"           ; Draw map outlines last
  res@mpGridAndLimbOn       = False                ; Turn off lat/lon lines
  res@pmTickMarkDisplayMode = "Always"             ; Turn on map tickmarks
 
  res@mpLimitMode        = "Corners"            ; Portion of map to zoom
  res@mpLeftCornerLatF   = 35.
  res@mpLeftCornerLonF   = 25.
  res@mpRightCornerLatF  = 45.
  res@mpRightCornerLonF  = 45.

  res@mpLambertParallel1F = 30.
  res@mpLambertParallel2F = 60.
  res@mpLambertMeridianF  = 30.

  res@tiMainString        = "Box with curved edges, gsn_add_polygon"

  map1 = gsn_csm_map(wks, res)
  
;---Draw a box using gsn_add_polygon. See how the edges are curved.
  gnres             = True
  gnres@gsFillColor = "yellow"
  gnres@gsEdgesOn   = True

  lonbox = (/28.,41.,41.,28.,28./)
  latbox = (/37.,37.,44.,44.,37./)

  dum1 = gsn_add_polygon(wks, map1, lonbox, latbox, gnres)

  draw(map1)
  frame(wks)

;---Create new map plot with a new title.

  res@tiMainString  = "Box with straight edges, gsn_polygon_ndc"

  map2 = gsn_csm_map(wks, res)
  draw(map2)

;
; Draw a box using gsn_polygon_ndc. The edges are now straight, but
; you can't attach them to the map because they are in NDC space.
;
  xndc = new(dimsizes(lonbox),float)
  yndc = new(dimsizes(latbox),float)

;---Convert lat/lon points to NDC values.
  datatondc(map2, lonbox, latbox, xndc, yndc)

;---Draw box in NDC space.

  gnres@gsFillColor = "green"
  gsn_polygon_ndc(wks, xndc, yndc, gnres)

; Now advance the frame.
  frame(wks)

;---Create new map plot with a new title.

  res@tiMainString = "Box defined using gc_latlon"
  map3 = gsn_csm_map(wks, res)

;
; Calculate box edges using gc_latlon. Now we can attach box to
; the map, and the edges will be straight.
;
  lftlat = min(latbox)
  rgtlat = max(latbox)
  lftlon = min(lonbox)
  rgtlon = max(lonbox)

  dum2 = add_filled_box(wks,map3,lftlat,lftlon,rgtlat,rgtlon)

  draw(map3)
  frame(wks)

end
