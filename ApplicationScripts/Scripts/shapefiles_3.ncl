;----------------------------------------------------------------------
; shapefiles_3.ncl
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
;----------------------------------------------------------------------
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
;----------------------------------------------------------------------
; This script shows the "new" way (post NCL V6.0.0) of adding shapefile
; outlines to an existing NCL map. It uses gsn_add_shapefile_polylines.
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  wks  = gsn_open_wks("png","shapefiles")  ; send graphics to PNG file

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

;---Section to add polylines to map.
  plres             = True           ; resource list for polylines
  plres@gsLineColor = "blue"
  
  id = gsn_add_shapefile_polylines(wks,plot,"sa_str.shp",plres)

  draw(plot)   ; This will draw attached polylines and map
  frame(wks)   ; Advanced frame.

end

