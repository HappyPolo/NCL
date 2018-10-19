; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "./shapefile_utils.ncl"

;----------------------------------------------------------------------
; Function to generate some dummy data over part of the United States.
; This area is being used because we want to be sure to have data
; over the state of Georgia.
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
;---Rough area that covers Georgia
  minlat = 17
  maxlat = 72
  minlon = -180
  maxlon = -50

;---Name of shapefile that contains U.S county outlines
  shp_filename = "USA_adm/USA_adm1.shp"

;---Generate some dummy data with lat/lon coordinates.
  data = dummy_data(64,128,minlat,maxlat,minlon,maxlon)

  opt             = True
  opt@debug       = True
  opt@shape_var   = "NAME_1"
  opt@shape_names = "Alaska"
  opt@keep        = False

;--To help masking go faster, indicate rough box for Alaska.
;  opt@minlat      = 40
;  opt@maxlat      = 73
;  opt@minlon      = -180
;  opt@maxlon      = -130

;---Mask the data to exclude points over Alaska.
  start_time = get_cpu_time()
  data_mask  = shapefile_mask_data(data,shp_filename,opt)
  end_time   = get_cpu_time()
  print("elapsed time for masking data = " + (end_time-start_time))
  printMinMax(data_mask,0)

  wks = gsn_open_wks("png","shapefiles")

;---Set some common resources
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

  res@tiMainFontHeightF = 0.018

  res@pmTickMarkDisplayMode = "Always"    ; better tickmark labels

;---Set additional contour resources
  cnres                   = res
  cnres@gsnAddCyclic      = False

  cnres@cnFillOn          =  True
  cnres@cnLinesOn         = False
  cnres@cnLineLabelsOn    = False
  cnres@lbLabelBarOn      = False

;---Generate nice contour levels
  mnmxint = nice_mnmxintvl( min(data), max(data), 18, False)
  cnres@cnLevelSelectionMode = "ManualLevels"
  cnres@cnMinLevelValF       = mnmxint(0)
  cnres@cnMaxLevelValF       = mnmxint(1)
  cnres@cnLevelSpacingF      = mnmxint(2)

;---Create contour plot over map
  cnres@tiMainString = "Original data"
  plot_orig = gsn_csm_contour_map(wks,data,cnres)

;---Create a map with the same map limits as previous plot
  cnres@tiMainString = "Data masked by shapefile"
  plot_mask = gsn_csm_contour_map(wks,data_mask,cnres)

  lnres                  =  True
  lnres@gsLineColor      = "NavyBlue"
  lnres@gsLineThicknessF = 3.0

  dum1 = gsn_add_shapefile_polylines(wks,plot_orig,shp_filename,lnres)
  dum2 = gsn_add_shapefile_polylines(wks,plot_mask,shp_filename,lnres)

;---Panel both plots for comparison.
  pres                  = True
  pres@gsnMaximize      = True
  pres@gsnPanelLabelBar = True
  pres@pmLabelBarWidthF = 0.8
  pres@lbLabelFontHeightF = 0.015
  gsn_panel(wks,(/plot_orig,plot_mask/),(/2,1/),pres)

end
