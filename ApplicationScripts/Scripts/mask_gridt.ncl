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
; This function uses shapefile_mask_data to mask the given array
; and then copies metadata before returning.
;----------------------------------------------------------------------
function apply_mask(x,shpname[1]:string,opt[1]:logical)
local start_time, end_time
begin
  start_time = get_cpu_time()
  print("apply_mask: masking data against '" + shpname + "'...")

  x_mask = shapefile_mask_data(x,shpname,opt)
  copy_VarMeta(x,x_mask)

  end_time = get_cpu_time()
  print("apply_mask: elapsed  time : " + (end_time-start_time) + " CPU seconds.")

  return(x_mask)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
  start_script_time = get_cpu_time()

;---Read data to plot and mask
  filename    = "grid.t.20d.nc"
  f           = addfile(filename,"r")
  ht          = f->HT
  lat2d       = f->TLAT
  lon2d       = f->TLONG                              ; 0 to 360
  lon2d_180   = where(lon2d.gt.180,lon2d-360,lon2d)   ; -180 to 180

  ht@lat2d    = lat2d             ; for masking and plotting purposes
  ht@lon2d    = lon2d_180

  printVarSummary(ht)
  printMinMax(ht,0)
  print("# valid values before masking   : " + num(.not.ismissing(ht)))
  print("# missing values before masking : " + num(ismissing(ht)))

;---Create a mask array the same size as "ht", using shapefile data
  shpfile  = "GSHHS_shp/c/GSHHS_c_L1.shp"
  opt      = True
  opt@keep = False  ; throw away values over land
  ht_ocean_mask = apply_mask(ht,shpfile,opt)
  print("# valid values after masking   : " + num(.not.ismissing(ht_ocean_mask)))
  print("# missing values after masking : " + num(ismissing(ht_ocean_mask)))

;---Start the graphics
  start_graphics_time = get_cpu_time()

  wks = gsn_open_wks("png","gridt_ocean_mask")

  res                       = True

  res@gsnMaximize           = True           ; maximize plot in frame
  res@gsnDraw               = False          ; don't draw plot yet
  res@gsnFrame              = False          ; don't advance frame yet

  res@cnFillOn              = True
  res@cnLineLabelsOn        = False
  res@cnLinesOn             = False

  res@cnFillMode            = "RasterFill"       ; These two resources important for
  res@trGridType            = "TriangularMesh"   ; faster and better plotting!

;---Make sure all plots have same contour levels
  mnmxint                   = nice_mnmxintvl(min(ht),max(ht),25,False)
  res@cnLevelSelectionMode  = "ManualLevels"
  res@cnMinLevelValF        = mnmxint(0)
  res@cnMaxLevelValF        = mnmxint(1)
  res@cnLevelSpacingF       = mnmxint(2)

  res@lbLabelBarOn          = False
  res@gsnAddCyclic          = False

  res@mpFillOn              = False
  res@mpOutlineOn           = False

  res@gsnRightString        = ""
  res@gsnLeftString         = ""

;---Create plot of original data and attach shapefile outlines
  res@tiMainString         = "Original data with shapefile outlines"
  map_data = gsn_csm_contour_map(wks,ht,res)

  res@tiMainString         = "Original data masked against ocean"
  map_ocean_mask = gsn_csm_contour_map(wks,ht_ocean_mask,res)

;---Add shapefile outlines
  dum1 = gsn_add_shapefile_polylines(wks,map_data,shpfile,False)
  dum2 = gsn_add_shapefile_polylines(wks,map_ocean_mask,shpfile,False)

;---Draw two plots on one page
  pres                  = True
  pres@gsnMaximize      = True
  pres@gsnPanelLabelBar = True
  gsn_panel(wks,(/map_data,map_ocean_mask/),(/2,1/),pres)
  end_graphics_time = get_cpu_time()

  print("Elapsed graphics time = " + (end_graphics_time-start_graphics_time) + " CPU seconds.")

  end_script_time = get_cpu_time()
  print("Elapsed script time = " + (end_script_time-start_script_time) + " CPU seconds.")
end

