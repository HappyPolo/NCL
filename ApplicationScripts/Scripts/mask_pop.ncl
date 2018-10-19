;----------------------------------------------------------------------
; Downloaded GSHHS shapefiles from:
;
;  http://www.ngdc.noaa.gov/mgg/shorelines/data/gshhg/latest/
;
; Used the "coarsest" one: "GSHHS_shp/c/GSHHS_c_L1.shp".
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file, being a user-created file, is not automatically loaded
load "./shapefile_utils.ncl"

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
  start_script_time = get_cpu_time()

;---Read data to plot and mask
  dir        = "./"
  cdf_file   = dir + "v5_rel04_BC5_ne120_t12_pop62.pop.h.0001-01_partial.nc"
  f          = addfile(cdf_file,"r")
  t          = f->TEMP(0,0,:,:)    ; 2400 x 3600
  t@lat2d    = f->TLAT     ; for plottin
  t@lon2d    = f->TLONG
  printVarSummary(t)

;
; Create a mask array the same size as "u", using
; lat/lon data read off a shapefile.
;
  shpfile   = "GSHHS_shp/c/GSHHS_c_L1.shp"
  opt             = True
  opt@return_mask = True

  print("Masking data against shapefile outlines...")
  start_mask_time = get_cpu_time()

  land_mask = shapefile_mask_data(t,shpfile,opt)

  end_mask_time = get_cpu_time()
  print("Elapsed mask time = " + (end_mask_time-start_mask_time) + " CPU seconds.")

;---Mask "u" against land and ocean.
  t_land_mask  = where(land_mask.eq.1,t,t@_FillValue)
  t_ocean_mask = where(land_mask.eq.0,t,t@_FillValue)
  copy_VarMeta(t,t_land_mask)
  copy_VarMeta(t,t_ocean_mask)

;---Start the graphics
  start_graphics_time = get_cpu_time()

  wks = gsn_open_wks("x11","land_ocean_masks")

  res                       = True

  res@gsnMaximize           = True           ; maximize plot in frame
  res@gsnDraw               = False          ; don't draw plot yet
  res@gsnFrame              = False          ; don't advance frame yet

  res@cnFillOn              = True
  res@cnLineLabelsOn        = False
  res@cnLinesOn             = False
  res@cnFillMode            = "RasterFill"
  res@trGridType            = "TriangularMesh"

;---Make sure all plots have same contour levels
  mnmxint                   = nice_mnmxintvl(min(t),max(t),25,False)
  res@cnLevelSelectionMode  = "ManualLevels"
  res@cnMinLevelValF        = mnmxint(0)
  res@cnMaxLevelValF        = mnmxint(1)
  res@cnLevelSpacingF       = mnmxint(2) / 2.

  res@lbLabelBarOn          = False
  res@gsnAddCyclic          = False

  res@mpFillOn              = False
  res@mpOutlineOn           = False

  res@gsnRightString        = ""
  res@gsnLeftString         = ""

;---Create plot of original data and attach shapefile outlines
  res@tiMainString         = "Original data with shapefile outlines"
  map_data = gsn_csm_contour_map(wks,t,res)

;---Create plots of masked data
  res@tiMainString         = "Original data masked against land"
  map_land_mask  = gsn_csm_contour_map(wks,t_land_mask,res)

  res@tiMainString         = "Original data masked against ocean"
  map_ocean_mask = gsn_csm_contour_map(wks,t_ocean_mask,res)

;---Add shapefile outlines
  dum1 = gsn_add_shapefile_polylines(wks,map_data,shpfile,False)
  dum2 = gsn_add_shapefile_polylines(wks,map_land_mask,shpfile,False)
  dum3 = gsn_add_shapefile_polylines(wks,map_ocean_mask,shpfile,False)

;---Draw all three plots on one page
  pres                  = True
  pres@gsnMaximize      = True
  pres@gsnPanelLabelBar = True
  gsn_panel(wks,(/map_data,map_land_mask,map_ocean_mask/),(/3,1/),pres)
  end_graphics_time = get_cpu_time()

  print("Elapsed graphics time = " + (end_graphics_time-start_graphics_time) + " CPU seconds.")

  end_script_time = get_cpu_time()
  print("Elapsed script time = " + (end_script_time-start_script_time) + " CPU seconds.")
end

