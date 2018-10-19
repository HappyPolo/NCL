;*************************************************
; shapefiles_2.ncl
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
; This script is the "new" way (post NCL V6.0.0) of adding shapefile
; outlines to an existing NCL map. It uses gsn_add_shapefile_polylines.
; It adds the polymarkers using gsn_add_polymarker.
;*************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
  wks  = gsn_open_wks("png","shapefiles")  ; send graphics to PNG file

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

  plres = True
  plres@gsLineColor = "white"
  lines_id = gsn_add_shapefile_polylines(wks,plot,"states.shp",plres)

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
