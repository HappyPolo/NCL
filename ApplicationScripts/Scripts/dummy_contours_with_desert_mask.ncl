load "./extra_funcs.ncl"

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
;---Create dummy data over a subset of the globe
  minlat = 0
  maxlat = 50
  minlon = 10
  maxlon = 60
  nlat   = 64
  nlon   = 128
  data   = create_dummy_array(minlat,maxlat,minlon,maxlon,nlat,nlon)

;----------------------------------------------------------------------
; Given a shapefile, a variable name on the shapefile, and list
; of region names, mask the data based on these regions.
;
; Downloaded shapefile from:
;
; http://www.naturalearthdata.com/downloads/10m-physical-vectors/
;----------------------------------------------------------------------
  shp_name     = "ne_10m_geography_regions_polys"
  shp_file     = shp_name + "/" + shp_name + ".shp"
  a = addfile(shp_file,"r")
  
;---Get list of desert names
  desert_names = str_match_ic(a->name,"desert")  

  opt             = True
  opt@shape_var   = "name"   ; var name that contains region names
  opt@keep        = False    ; throw away points inside desert regions
  opt@shape_names = desert_names
  data_mask       = shapefile_mask_data(data,shp_file,opt)

;---Start the graphics
  wks = gsn_open_wks("png","dummy_contours_with_desert_mask")

  res                   = True
  res@gsnMaximize       = True        ; Maximize plot in frame

  res@gsnDraw           = False       ; Will draw later in panel
  res@gsnFrame          = False

  res@cnFillOn          = True        ; Turn on contour fill
  res@cnLinesOn         = False       ; Turn off contour lines
  res@cnLineLabelsOn    = False       ; Turn off line labels

  res@gsnAddCyclic      = False        ; Don't add longitude cyclic point

;---Zoom in on a region
  res@mpMinLatF         = minlat
  res@mpMaxLatF         = maxlat
  res@mpMinLonF         = minlon
  res@mpMaxLonF         = maxlon

  res@mpFillOn          = False
  res@mpOutlineOn       = False

;--Set the contour levels using "nice_mnmxintvl" function.
  mnmxint = nice_mnmxintvl( min(data), max(data), 18, False)
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       = mnmxint(0)
  res@cnMaxLevelValF       = mnmxint(1)
  res@cnLevelSpacingF      = mnmxint(2)/4.  ; Decrease spacing for more levels
  res@lbLabelBarOn         = False          ; Will add labelbar in panel

;---Create plots of original data and masked data
  res@tiMainString = "Original data"
  plot_orig = gsn_csm_contour_map(wks,data,res)

  res@tiMainString = "Masked data"
  plot_mask = gsn_csm_contour_map(wks,data_mask,res)

;---Attach the shapefile outlines
  ADD_SHAPEFILE_OUTLINES = True
  if(ADD_SHAPEFILE_OUTLINES) then
    add_shapefile_outlines(wks,plot_orig,shp_file)
    add_shapefile_outlines(wks,plot_mask,shp_file)
  end if

;---Attach coordinates of data's lat/lon points if desired.
  ADD_LATLON_POINTS = False
  if(ADD_LATLON_POINTS) then
    add_latlon_points(wks,plot_orig,data)
    add_latlon_points(wks,plot_mask,data_mask)
  end if
  
;---Panel both plots
  pres                    = True
  pres@gsnPanelLabelBar   = True
  pres@pmLabelBarWidthF   = 0.7
  pres@lbLabelFontHeightF = 0.01
  gsn_panel(wks,(/plot_orig,plot_mask/),(/1,2/),pres)
end
