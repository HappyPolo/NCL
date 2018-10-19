;----------------------------------------------------------------------
; shapefiles_20.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Masking data based on a geographical area obtained from a shapefile
;   - Using "cd_string" to produce a nice time label for a title
;   - Paneling four plots on a page
;----------------------------------------------------------------------
; The NetCDF data file for this example can be downloaded from
; http://www.ncl.ucar.edu/Applications/Data/#cdf
;
; The shapefile data can be downloaded from
; http://gadm.org/country
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;
; These files still have to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
load "./shapefile_utils.ncl"

begin
;---Read in netCDF file.
  a  = addfile("ts_Amon_CESM1-CAM5_historical_r1i1p1_185001-200512.nc","r")

  ntime    = 4                       ; How many time steps
  ts       = a->ts(0:ntime-1,:,:)    ; Read the first "ntime" time steps
  ts       = lonFlip(ts)             ; Convert from 0:360 to -180:180
  ts       = ts-273.15               ; Convert from Kelvin -> Celsius.
  ts@units = "degC"

;---Convert "time" array to "DD MMM YYYY"
  date = cd_string(ts&time, "%D %c %Y")

;
; Mask the data based on first timestep, using a shapefile outline of the U.S.
; We'll use this to mask the rest of the data across other timesteps.
; Note: this only works if the lat/lon grid is the same for every time step.
;
  shp_filename    = "./USA_adm0.shp"
  opt             = True
  opt@return_mask = True

  start_time = get_cpu_time()
  usa_mask   = shapefile_mask_data(ts(0,:,:),shp_filename,opt)
  end_time   = get_cpu_time()
  print("Elapsed CPU time for creating the mask array is " + (end_time-start_time) + " seconds.")

  printMinMax(usa_mask,0)

;---Convert this mask to an nD array of the same size as "ts"
  usa_mask_nd = conform_dims(dimsizes(ts),usa_mask,(/1,2/))

;---Mask the "ts" variable across all time steps and copy metadata.
 ts_mask = mask(ts,usa_mask_nd,1)
 copy_VarMeta(ts,ts_mask)

;---Print information about ts and ts_mask
  printVarSummary(ts)            ; ntime x 192 x 288
  printVarSummary(ts_mask)       ; ditto

  printMinMax(ts,0)              ; These two should
  printMinMax(ts_mask,0)         ; be different!


  wks = gsn_open_wks("png","shapefiles")  ; send graphics to PNG file

;---Set some resources
  res                       = True

  res@gsnDraw               = False    ; will draw later in panel 
  res@gsnFrame              = False

  res@cnFillOn              = True     ; turn on contour fill
  res@cnLinesOn             = False    ; turn off contour lines
  res@cnLineLabelsOn        = False    ; turn off contour line labels
  res@lbLabelBarOn          = False    ; will add in panel later
  res@cnInfoLabelOn         = False
;
; For a contour animation, it's important to set all the contour
; levels to the same levels for each timestep. The "nice_mnmxintvl"
; function will give you equally-spaced levels, based on the min/max
; of your whole data array.
;
  mnmxint = nice_mnmxintvl( min(ts), max(ts), 18, False)
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       = mnmxint(0)
  res@cnMaxLevelValF       = mnmxint(1)
  res@cnLevelSpacingF      = mnmxint(2)/4.  ; Decrease spacing for more levels

  plot      = new(ntime,graphic)
  plot_mask = new(ntime,graphic)

;
; Create plots of both original data and masked data.
; We aren't zooming in on masked data because we want
; to see it compared it against the global map.
;
  do nt=0,ntime-1
    res@tiMainString = date(nt)
    plot(nt)         = gsn_csm_contour_map(wks,ts(nt,:,:),res)
    plot_mask(nt)    = gsn_csm_contour_map(wks,ts_mask(nt,:,:),res)
  end do

;---Panel both sets of plots.
  pres                  = True
  pres@txString         = "Full dataset"
  pres@gsnMaximize      = True
  pres@gsnPanelLabelBar = True
  gsn_panel(wks,plot,(/2,2/),pres)

  pres@txString         = "Masked dataset"
  gsn_panel(wks,plot_mask,(/2,2/),pres)
end
