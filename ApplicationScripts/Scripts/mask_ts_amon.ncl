;----------------------------------------------------------------------
; mask_12.ncl
;
; Concepts illustrated:
;   - Using a worldwide shapefile to create a land/ocean mask
;   - Masking a data array based on a geographical area
;   - Attaching shapefile polylines to a map plot
;   - Attaching lat/lon points to a map using gsn_coordinates
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
  start_time = get_cpu_time()
  DEBUG      = False

;---Read data to plot and mask
  dir        = "./"
  cdf_file   = dir + "ts_Amon_CESM1-CAM5_historical_r1i1p1_185001-200512.nc"
  f          = addfile(cdf_file,"r")
  t          = f->ts(0,:,:)
  t          = lonFlip(t)              ; 0 to 360 ---> -180 to 180
  printVarSummary(t)

;
; Create a mask array the same size as "u", using
; lat/lon data read off a shapefile.
;
  shpfile   = "GSHHS_shp/c/GSHHS_c_L1.shp"
  opt             = True
  opt@return_mask = True

  land_mask = shapefile_mask_data(t,shpfile,opt)

;---Mask "u" against land and ocean.
  t_land_mask  = where(land_mask.eq.1,t,t@_FillValue)
  t_ocean_mask = where(land_mask.eq.0,t,t@_FillValue)
  copy_VarMeta(t,t_land_mask)
  copy_VarMeta(t,t_ocean_mask)

;---Start the graphics
  wks = gsn_open_wks("png","land_ocean_masks")

  res                       = True

  res@gsnMaximize           = True           ; maximize plot in frame
  res@gsnDraw               = False          ; don't draw plot yet
  res@gsnFrame              = False          ; don't advance frame yet

  res@cnFillOn              = True
  res@cnLineLabelsOn        = False
  res@cnLinesOn             = False

;---Make sure both plots have same contour levels
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
  dum1     = gsn_add_shapefile_polylines(wks,map_data,shpfile,False)

;---Create plots of masked data
  res@tiMainString         = "Original data masked against land"
  map_land_mask  = gsn_csm_contour_map(wks,t_land_mask,res)
  res@tiMainString         = "Original data masked against ocean"
  map_ocean_mask = gsn_csm_contour_map(wks,t_ocean_mask,res)

  if(DEBUG) then
    mkres                 = True
;    mkres@gsMarkerSizeF   = 0.007
    mkres@gsnCoordsAttach = True
    gsn_coordinates(wks,map_data,t,mkres)
    mkres@gsnCoordsNonMissingColor = "yellow"
    mkres@gsnCoordsMissingColor    = "black"
    gsn_coordinates(wks,map_land_mask,t_land_mask,mkres)
    gsn_coordinates(wks,map_ocean_mask,t_ocean_mask,mkres)
  end if

;---Add shapefile outlines
  dum2 = gsn_add_shapefile_polylines(wks,map_land_mask,shpfile,False)
  dum3 = gsn_add_shapefile_polylines(wks,map_ocean_mask,shpfile,False)

;---Draw all three plots on one page
  pres                  = True
  pres@gsnMaximize      = True
  pres@gsnPanelLabelBar = True
  gsn_panel(wks,(/map_data,map_land_mask,map_ocean_mask/),(/3,1/),pres)

  end_time = get_cpu_time()
  print("Elapsed time = " + (end_time-start_time) + " CPU seconds.")
end

