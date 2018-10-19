;----------------------------------------------------------------------
; shapefiles_usa_3.ncl
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
;  Simple example of how to draw polylines read from a shapefile.
;----------------------------------------------------------------------
; You must download the "hydrogm020_nt00015.tar.gz" gzipped tar file
; (34 MB) from:
;
;  https://catalog.data.gov/dataset/usgs-small-scale-dataset-streams-and-waterbodies-of-the-united-states-200512-shapefile
;
; Gunzip and untar the file:
;
;   tar -zxf hydrogm020_nt00015.tar.gz 
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  wks  = gsn_open_wks("x11","shapefiles")  ; send graphics to PNG file

  res                       = True

  res@gsnMaximize           = True                 ; maximize plot
  res@gsnDraw               = False                ; don't draw plot yet
  res@gsnFrame              = False                ; don't advance frame yet

  res@mpFillOn              = False                ; turn off map fill
  res@mpOutlineOn           = False                ; turn off map outlines
  res@mpPerimOn             = False                ; turn off box around map
  res@mpGridAndLimbOn       = False                ; turn off grid lat/lon lines.
  
;---Zoom in on the U.S.
  res@mpProjection          = "LambertConformal"  ; choose projection
  res@mpLambertParallel1F   = 33.0                ; two parallels
  res@mpLambertParallel2F   = 45.0
  res@mpLambertMeridianF    = -95.0               ; central meridian
  res@mpLimitMode           = "LatLon"
  res@mpMinLatF             = 24.0                ; map area
  res@mpMaxLatF             = 50.0                ; latitudes
  res@mpMinLonF             = -125.0              ; and
  res@mpMaxLonF             = -65.0               ; longitudes

  plot = gsn_csm_map(wks,res)   ; Draw map, but don't advance frame.

;---Section to add polylines to map.
  plres             = True           ; resource list for polylines
  plres@gsLineColor = "navyblue"
  id = gsn_add_shapefile_polylines(wks,plot,"hydrogl020.shp",plres)

  draw(plot)   ; This will draw attached polylines and map
  frame(wks)   ; Advanced frame.

end

