; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "./shapefile_utils.ncl"

function bullseye(nlat,nlon)
begin
;---Generate a bullseye pattern
  ispn  = conform_dims((/nlat,nlon/),ispan(-nlon/2,nlon/2,1)^2,1)
  jspn  = conform_dims((/nlat,nlon/),ispan(-nlat/2,nlat/2,1)^2,0)
  data  = 100. - sqrt(64*(jspn + ispn))
  dims  = dimsizes(data)

  lat = fspan( -90, 90,nlat)
  lon = fspan(-180,180,nlon)
  lat@units = "degrees_north"
  lon@units = "degrees_east"
  data!0 = "lat"
  data!1 = "lon"
  data&lat = lat
  data&lon= lon
  return(data)
end

begin
;---Read in netCDF file.
  a  = addfile("ts_Amon_CESM1-CAM5_historical_r1i1p1_185001-200512.nc","r")
  ts = a->ts(0,:,:)    ; Read the first time step
  ts = lonFlip(ts)             ; Convert from 0:360 to -180:180
  printVarSummary(ts)
  printMinMax(ts,0)

;---Start the graphics
  wks = gsn_open_wks("png","shapefiles_mask_data_ex")

;---Default contour plot
  res                     = True
  res@cnFillOn             = True
  res@cnFillPalette        = "BlueYellowRed"
  res@cnLinesOn            = False
  res@cnLineLabelsOn       = False
  res@gsnAddCyclic         = False
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = ispan(230,315,5)

;---Plot original data
  res@tiMainString         = "Original data"
  plot_orig = gsn_csm_contour_map(wks,ts,res)

;---Mask the data against shapefile containing the desired shapefile outlines
  shp_filename = "AUS_adm/AUS_adm0.shp"
  opt        = True
  opt@debug  = True
  opt@minlat =  -56
  opt@maxlat =  -9
  opt@minlon =  112
  opt@maxlon =  160

  start_time = get_cpu_time()
  ts_mask    = shapefile_mask_data(ts,shp_filename,opt)
  end_time   = get_cpu_time()

  print("Elapsed time for masking data = " + (end_time-start_time))

  printMinMax(ts_mask,0)

;---Plot masked data
  res@tiMainString = "Masked data"
  plot_mask = gsn_csm_contour_map(wks,ts_mask,res)
end

