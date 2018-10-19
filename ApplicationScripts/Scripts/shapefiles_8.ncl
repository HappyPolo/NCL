;----------------------------------------------------------------------
; shapefiles_8ncl
;
; Concepts illustrated:
;   - Reading shapefiles
;   - Plotting data from shapefiles
;   - Using data from shapefiles to draw areas of interest in India
;   - Zooming in on India on a cylindrical equidistant map
;----------------------------------------------------------------------
; See shapefiles_8_panel.ncl for a panel version of these plots.
;----------------------------------------------------------------------
; This example will only work with NCL V6.1.0 or later, because it
; uses a new function "gsn_add_shapefile_polylines".
;
; This example shows how to read geographic data from a shapefile
; and plot it on a map created by NCL.
;
; This particular example plots data for India
;----------------------------------------------------------------------
; The shapefiles for this example were obtained from the
; "Global Administratie Areas" website:
;
;      http://www.gadm.org/country
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  dir       = "./"
  filenames = "IND_adm" + ispan(0,3,1) + ".shp"
  nfiles    = dimsizes(filenames)

;--- Open workstation.
  wks = gsn_open_wks("png","shapefiles")  ; send graphics to PNG file

  res               = True
  res@gsnMaximize   = True
  res@gsnDraw       = False
  res@gsnFrame      = False

  res@mpOutlineOn   = False   ; Use outlines from shapefile
  res@mpFillOn      = False  

;---Turn on fancier tickmark labels.
  res@pmTickMarkDisplayMode = "Always"

;---Zoom in on area of interest
  res@mpLimitMode           = "LatLon"
  res@mpMinLatF             =  5
  res@mpMaxLatF             = 37
  res@mpMinLonF             = 65
  res@mpMaxLonF             = 99

;
; Loop through the four given shapefiles, and draw the data from
; the first two on one map, and the other two on their own maps.
;

  res@tiMainString = filenames(0) + "/" + filenames(1)

;---Create a map with a title.
  map = gsn_csm_map(wks,res)

;---Attach two sets of polylines to the same map.
  lnres             = True
  lnres@gsLineColor = "gray"
  poly1 = gsn_add_shapefile_polylines(wks,map,dir+filenames(1),lnres)

  lnres@gsLineColor = "black"
  poly0 = gsn_add_shapefile_polylines(wks,map,dir+filenames(0),lnres)

  draw(map)
  frame(wks)

;---Create a new map with a different title.
  res@tiMainString = filenames(2)
  map = gsn_csm_map(wks,res)

;---Attach polylines to map.
  lnres@gsLineColor = "blue"
  poly2 = gsn_add_shapefile_polylines(wks,map,dir+filenames(2),lnres)

  draw(map)
  frame(wks)

;---Create a new map with a different title.
  res@tiMainString = filenames(3)
  map = gsn_csm_map(wks,res)

;---Attach polylines to map.
  lnres@gsLineColor = "ForestGreen"
  poly3 = gsn_add_shapefile_polylines(wks,map,dir+filenames(3),lnres)

  draw(map)
  frame(wks)

end
