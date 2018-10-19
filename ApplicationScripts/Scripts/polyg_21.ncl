;----------------------------------------------------------------------
; polyg_21.ncl
;
; Concepts illustrated:
;   - Adding smooth hollow circles to a plot using polylines
;   - Adding a blocky hollow circle using polymarkers
;   - Using nggcog to create a great circle
;----------------------------------------------------------------------
; This script shows how to use special procedures nggcog and circle_ll
; to draw large circles on a plot that are not blocky. If you try to 
; draw large circles using markers, they will start to look blocky the 
; larger they get.
;
; The circle_ll code was contributed by Arindam Chakraborty.
;----------------------------------------------------------------------
; See also polyg_22.ncl which shows how to use characters in NCL's 
; font tables to get other types of hollow circles.
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; This file is loaded by default in NCL V6.4.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
  wks = gsn_open_wks("png","polyg")

;----------------------------------------------------------------------
; Draw a large circle on a map.
;----------------------------------------------------------------------
  ncirc    = 100
  circ_lat = new(ncirc,float)               ; Create arrays to hold circle.
  circ_lon = new(ncirc,float)
  cen_lat  = 40.
  cen_lon  = -105.3

  nggcog(cen_lat,cen_lon,7.0,circ_lat,circ_lon)

;---Create an orthographic map
  mpres              = True
  mpres@gsnMaximize  = True     ; Maximize size of plot in frame.
  mpres@gsnDraw      = False    ; Don't draw plot
  mpres@gsnFrame     = False    ; Don't advance the frame.

  mpres@tiMainString = "Smooth and blocky circles"

  mpres@mpCenterLonF = -95.
  mpres@mpCenterLatF =  35.

  map = gsn_map(wks, "Orthographic", mpres)

;---Attach a single brown circle to the map
  lnres                  = True
  lnres@gsLineColor      = "Brown"
  lnres@gsLineThicknessF = 3.0
  line_id = gsn_add_polyline(wks, map, circ_lon, circ_lat, lnres)

;---Attach a single blue hollow circle marker to the map
  mkres                    = True
  mkres@gsMarkerIndex      = 4
  mkres@gsMarkerSizeF      = 115
  mkres@gsMarkerColor      = "blue4"
  mkres@gsMarkerThicknessF = 3.0
  mk_id = gsn_add_polymarker(wks, map, cen_lon+30, cen_lat, mkres)

  draw(map)   ; This will draw map and the circle.
  frame(wks)

;----------------------------------------------------------------------
; Draw large circles/ellipses on a contour plot
;----------------------------------------------------------------------

;---Generate some dummy data.
  arr = generate_2d_array(10, 10, -19.,16., 0, (/100,100/))

  res              = True
  res@gsnMaximize  = True     ; Maximize size of plot in frame.
  res@gsnDraw      = False
  res@gsnFrame     = False
  res@tiMainString = "Circles and ellipses"
  res@cnLineColor  = "gray65"

  plot = gsn_csm_contour(wks,arr,res)

;---Add 50 circles to the plot at random locations
  ncirc = 50
  x = random_uniform(1,99,ncirc)
  y = random_uniform(1,99,ncirc)
  r = random_uniform(1,10,ncirc)

  resc                  = True
  resc@gsLineColor      = "Purple"
  resc@gsLineThicknessF = 1.5

  do i=0,dimsizes(x)-1
    circle_ll(wks,plot,x(i),y(i),r(i),resc)
  end do

;---Add a single green ellipse to the plot
  resc@gsLineColor      = "ForestGreen"
  resc@gsLineThicknessF = 3.5
  resc@Scale            = 2.5
  resc@Rotation         = -45

  circle_ll(wks,plot,40,60,15,resc)

  draw(plot)    ; Draws the contour plot, circles and ellipse
  frame(wks) 

end
