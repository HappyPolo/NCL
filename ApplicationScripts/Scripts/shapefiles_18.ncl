;----------------------------------------------------------------------
; shapefiles_18.ncl
;
; Concepts illustrated:
;   - Reading shapefiles
;   - Adding shapefile outlines to an existing plot
;   - Masking a data array based on the distance from a geographical outline in a shapefile
;   - Generating dummy data
;----------------------------------------------------------------------
;
; This file still has to be loaded manually
load "./shapefile_mask_data_mod.ncl"

;----------------------------------------------------------------------
; Procedure to add shapefile outlines to the given plot.
;----------------------------------------------------------------------
procedure add_shp_outlines(wks,plot,shp_filename)
local lnres
begin
;---Resources for polyline
  lnres                  = True
  lnres@gsLineColor      = "ForestGreen"
  lnres@gsLineThicknessF = 3.0            ; 3x thickness

  plot@lines = gsn_add_shapefile_polylines(wks, plot, shp_filename, lnres)
end

;----------------------------------------------------------------------
; Function to create dummy rectilinear data over a map area of 
; interest, given nlat and nlon.
;----------------------------------------------------------------------
function create_dummy_array(minlat,maxlat,minlon,maxlon,nlon,nlat)
local lat1d, lon1d
begin
;---Generate some dummy data over map
  data            = generate_2d_array(10, 10, 0., 100., 0, (/nlat,nlon/))
  data@_FillValue = -9999

;---Add lat/lon coordinate array information.
  lat1d       = fspan(minlat,maxlat,nlat)
  lon1d       = fspan(minlon,maxlon,nlon)
  lat1d@units = "degrees_north"
  lon1d@units = "degrees_east"
  data!0      = "lat"
  data!1      = "lon"
  data&lat    = lat1d
  data&lon    = lon1d

  return(data)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------

begin
  minlat = 20
  maxlat = 60
  minlon = -125
  maxlon = -60
  delta_kilometers = 300

;---Create dummy array
  nlat = 16
  nlon = 32
  data = create_dummy_array(minlat,maxlat,minlon,maxlon,nlat,nlon)

;---Start the graphics
  wks  = gsn_open_wks("png","shapefiles")  ; send graphics to PNG file

  res                     = True

  res@gsnMaximize         = True           ; maximize plot in frame
  res@gsnDraw             = False          ; don't draw plot yet
  res@gsnFrame            = False          ; don't advance frame yet

  res@cnFillOn            = True
  res@cnFillPalette       = "nrl_sirkes_nowhite"
  res@cnLinesOn           = False
  res@cnLineLabelsOn      = False
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = ispan(6,96,4)
  res@lbLabelBarOn         = False       ; Will add in panel later

  res@gsnAddCyclic        = False

  res@mpDataBaseVersion   = "MediumRes"    ; slightly better resolution
  res@mpFillOn            = False

;---Zoom in on area of interest
  res@mpMinLatF           = minlat
  res@mpMaxLatF           = maxlat
  res@mpMinLonF           = minlon
  res@mpMaxLonF           = maxlon

;---Create contours of original data
  res@tiMainString        = "Original data"
  plot_orig               = gsn_csm_contour_map(wks,data,res)

;---Use shapefile to mask these dummy arrays based on shapefile outline
  dir          = ncargpath("data") + "/shp/"
  shp_filename = dir + "mrb.shp"

  shp_res = True
  shp_res@delta_kilometers = delta_kilometers
  data_mask = shapefile_mask_data_mod(data,shp_filename,shp_res)

;---Create contours of masked data
  res@tiMainString = "delta_kilometers = " + delta_kilometers
  plot_mask = gsn_csm_contour_map(wks,data_mask,res)

;---Add shapefile outlines to all four plots
  add_shp_outlines(wks,plot_orig,shp_filename)
  add_shp_outlines(wks,plot_mask,shp_filename)

;---Add dots at the lat/lon grid locations
  mkres                 = True
  mkres@gsMarkerIndex   = 16         ; Filled dots
  mkres@gsMarkerSizeF   = 0.001      ; Make them small
  mkres@gsMarkerColor   = "darkorchid4"
  mkres@gsnCoordsAttach = True

  gsn_coordinates(wks,plot_orig,data,mkres)
  gsn_coordinates(wks,plot_mask,data_mask,mkres)

;---Panel the two plots
  pres                  = True
  pres@gsnMaximize      = True
  pres@gsnPanelLabelBar = True
  gsn_panel(wks,(/plot_orig,plot_mask/),(/2,1/),pres)
end

