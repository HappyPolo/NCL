;----------------------------------------------------------------------
; shapefiles_16.ncl
;
; Concepts illustrated:
;   - Drawing the Mississippi River Basin using data from a shapefile
;   - Comparing shapefile masking with a coarse and fine grid
;   - Masking a data array based on a geographical area obtained from a shapefile
;   - Drawing a lat/lon grid using gsn_coordinates
;   - Subsetting a color map
;   - Using functions for cleaner code
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "./shapefile_utils.ncl"

;----------------------------------------------------------------------
; Procedure to add shapefile outlines to the given plot.
;----------------------------------------------------------------------
procedure add_shp_outlines(wks,plot,shp_filename)
local lnres
begin
;---Resources for polyline
  lnres                  = True
  lnres@gsLineColor      = "Red"
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

;---Create both a "coarse" and "fine" grid.
  nlat_coarse = 32
  nlon_coarse = 64
  nlat_dense  = 64
  nlon_dense  = 128

  data_coarse = create_dummy_array(minlat,maxlat,minlon,maxlon, \
                                   nlat_coarse,nlon_coarse)
  data_dense  = create_dummy_array(minlat,maxlat,minlon,maxlon, \
                                   nlat_dense,nlon_dense)

;---Start the graphics
  wks  = gsn_open_wks("png","shapefiles")  ; send graphics to PNG file

  res                     = True

  res@gsnMaximize         = True           ; maximize plot in frame
  res@gsnDraw             = False          ; don't draw plot yet
  res@gsnFrame            = False          ; don't advance frame yet

  cmap = read_colormap_file("MPL_terrain")

  res@cnFillOn            = True
  res@cnFillPalette       = cmap(:104,:)   ; Subset the color map
  res@cnLinesOn           = False
  res@cnLineLabelsOn      = False

  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = ispan(6,96,4)
  res@lbLabelBarOn         = False

  res@gsnAddCyclic        = False

  res@mpDataBaseVersion   = "MediumRes"    ; slightly better resolution
  res@mpFillOn            = False

;---Zoom in on area of interest
  res@mpMinLatF           = minlat
  res@mpMaxLatF           = maxlat
  res@mpMinLonF           = minlon
  res@mpMaxLonF           = maxlon

;---Create contours of original data
  res@tiMainString        = "Original coarse data"
  plot_orig_coarse = gsn_csm_contour_map(wks,data_coarse,res)

  res@tiMainString        = "Original dense data"
  plot_orig_dense = gsn_csm_contour_map(wks,data_dense,res)

;---Use shapefile to mask these dummy arrays based on shapefile outline
  dir          = ncargpath("data") + "/shp/"
  shp_filename = dir + "mrb.shp"

  data_mask_coarse = shapefile_mask_data(data_coarse,shp_filename,True)
  data_mask_dense  = shapefile_mask_data(data_dense,shp_filename,True)

;---Create contours of masked data
  res@tiMainString = "Coarse data with mask applied"
  plot_mask_coarse = gsn_csm_contour_map(wks,data_mask_coarse,res)

  res@tiMainString = "Dense data with mask applied"
  plot_mask_dense = gsn_csm_contour_map(wks,data_mask_dense,res)

;---Add shapefile outlines to all four plots
  add_shp_outlines(wks,plot_orig_coarse,shp_filename)
  add_shp_outlines(wks,plot_mask_coarse,shp_filename)

  add_shp_outlines(wks,plot_orig_dense,shp_filename)
  add_shp_outlines(wks,plot_mask_dense,shp_filename)

;---Add dots at the lat/lon grid locations
  mkres                 = True
  mkres@gsMarkerIndex   = 16         ; Filled dots
  mkres@gsMarkerSizeF   = 0.001      ; Make them small
  mkres@gsMarkerColor   = "darkorchid4"
  mkres@gsnCoordsAttach = True

  gsn_coordinates(wks,plot_orig_coarse,data_coarse,mkres)
  gsn_coordinates(wks,plot_mask_coarse,data_mask_coarse,mkres)

  gsn_coordinates(wks,plot_orig_dense,data_dense,mkres)
  gsn_coordinates(wks,plot_mask_dense,data_mask_dense,mkres)

;---Panel all four plots
  pres                  = True
  pres@gsnMaximize      = True
  pres@gsnPanelLabelBar = True
  gsn_panel(wks,(/plot_orig_coarse,plot_orig_dense,\
                  plot_mask_coarse,plot_mask_dense/),\
                  (/2,2/),pres)
end

