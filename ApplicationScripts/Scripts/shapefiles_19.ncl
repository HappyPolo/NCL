;----------------------------------------------------------------------
; shapefiles_19.ncl
;
; Concepts illustrated:
;   - Removing or retaining data based on a geographical area obtained from a shapefile
;   - Drawing a lat/lon grid using gsn_coordinates
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
; Function to generate some dummy data.
;----------------------------------------------------------------------
function dummy_data(nlat,nlon,minlat,maxlat,minlon,maxlon)
local nlat, nlon, lat, lon
begin
;---Generate some dummy lat/lon data over area that covers Georgia
  lat       = fspan(minlat,maxlat,nlat)
  lon       = fspan(minlon,maxlon,nlon)
  lat@units = "degrees_north"
  lon@units = "degrees_east"

  data     = generate_2d_array(10, 25, -20, 15, 0, (/nlat,nlon/))
  data!0   = "lat"
  data!1   = "lon"
  data&lat = lat
  data&lon = lon
  
  return(data)
end


;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
;---Name of shapefile that contains U.S. state outlines
  shp_filename = "./USA_adm1.shp"    ; downloaded from http://www.gadm.org/country/

;---Generate some dummy data with lat/lon coordinates.
  minlat = 17
  maxlat = 72
  minlon = -180
  maxlon = -50
  nlat   = 64
  nlon   = 128
  data   = dummy_data(nlat,nlon,minlat,maxlat,minlon,maxlon)

;---Set masking options for shapefile_mask_data function
  opt             = True
  opt@shape_var   = "NAME_1"
  opt@shape_names = "Alaska"
  opt@debug       = True

;---Mask the data to exclude points over Alaska.
  opt@keep        = False
  data_mask  = shapefile_mask_data(data,shp_filename,opt)
  printMinMax(data_mask,0)

;---Mask the data to keep points over Alaska.
  opt@keep        = True
  data_keep  = shapefile_mask_data(data,shp_filename,opt)
  printMinMax(data_keep,0)

;---Start the graphics
  wks = gsn_open_wks("png","shapefiles")  ; send graphics to PNG file

  res                   = True

  res@gsnMaximize       = True     ; maximize plot in frame
  res@gsnDraw           = False    ; don't draw plot
  res@gsnFrame          = False    ; don't advance frame

  res@mpFillOn          = False    ; Turn these off because we're
  res@mpOutlineOn       = False    ; adding our own outlines

;---Zoom in on map if desired
  res@mpMinLatF         = minlat
  res@mpMaxLatF         = maxlat
  res@mpMinLonF         = minlon
  res@mpMaxLonF         = maxlon
  res@mpCenterLonF      = (res@mpMinLonF + res@mpMaxLonF) / 2.

  res@gsnAddCyclic      = False

  res@cnFillOn          =  True
  res@cnLinesOn         = False
  res@cnLineLabelsOn    = False
  res@lbLabelBarOn      = False

;---Generate nice contour levels
  mnmxint = nice_mnmxintvl( min(data), max(data), 18, False)
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       = mnmxint(0)
  res@cnMaxLevelValF       = mnmxint(1)
  res@cnLevelSpacingF      = mnmxint(2)

;---Create contour plot over map
  res@tiMainString = "Original data"
  plot_orig = gsn_csm_contour_map(wks,data,res)

;---Create a map with the same map limits as previous plot
  res@tiMainString = "Data over Alaska discarded"
  plot_mask = gsn_csm_contour_map(wks,data_mask,res)

;---Create a map with the same map limits as previous plot
  res@tiMainString = "Data over Alaska retained"
  plot_keep = gsn_csm_contour_map(wks,data_keep,res)

;---Add the outlines to both plots.
  lnres                  =  True
  lnres@gsLineColor      = "Grey25"

  dum1 = gsn_add_shapefile_polylines(wks,plot_orig,shp_filename,lnres)

  dum2 = gsn_add_shapefile_polylines(wks,plot_mask,shp_filename,lnres)
  dum3 = gsn_add_shapefile_polylines(wks,plot_keep,shp_filename,lnres)

;---Panel three plots for comparison.
  pres                  = True
  pres@gsnMaximize      = True
  pres@gsnPanelLabelBar = True
  pres@pmLabelBarWidthF = 0.8
  pres@lbLabelFontHeightF = 0.015
  pres@gsnPanelRowSpec    = True
  gsn_panel(wks,(/plot_orig,plot_mask,plot_keep/),(/1,2/),pres)

end
