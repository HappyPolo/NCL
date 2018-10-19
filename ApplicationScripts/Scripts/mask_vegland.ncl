;----------------------------------------------------------------------
; Download GSHHS and Greenland shapefiles from:
;
;  hptt://www.gadm.org/country  
;  http://www.ngdc.noaa.gov/mgg/shorelines/data/gshhg/latest/
;
; Use the "coarsest" one: "GSHHS_shp/c/GSHHS_c_L1.shp".
; 
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
;
; With MASK_GREENLAND = False, this script takes about 262 CPU seconds.
;----------------------------------------------------------------------
begin
  start_script_time = get_cpu_time()

  MASK_GREENLAND = True  ; Whether to further mask data against Greenland shapefile
                         ; This is mostly to make the script run slower for test purposes.

;---Read data to plot and mask
  fili = "IGBPa_1198.map.nc"
  f    = addfile (fili, "r")
  x    = f->CLASS                       ; note: type byte
  x    = lonFlip(x)                     ; 0 to 360 ---> -180 to 180
  x@_FillValue = default_fillvalue(typeof(x))

;---Debug information
  printVarSummary(x)
  print("# missing values before mask = " + num(ismissing(x)))

  world_shpfile = "GSHHS_shp/c/GSHHS_c_L1.shp"
  x_mask_world = apply_mask(x,world_shpfile,True)
  print("# missing values after mask = " + num(ismissing(x_mask_world)))

;---Further mask "x_mask" against Greenland shapefile
  if(MASK_GREENLAND) then
    opt          = True
    opt@keep     =  False  ; Throw away values inside Greenland
    opt@minlat   = 59      ; Specify approximate box that contains
    opt@maxlat   = 84      ; Greenland. This makes the masking go
    opt@minlon   = -74.24  ; faster. Comment this out if you want
    opt@maxlon   = 0       ; the code to run slower!
    grnld_shpfile = "GRL_adm/GRL_adm0.shp"
    x_mask_greenland = apply_mask(x,grnld_shpfile,opt)
    print("# missing values after mask = " + num(ismissing(x_mask_greenland)))
  end if

;---Start the graphics
  start_graphics_time = get_cpu_time()

  wks = gsn_open_wks("png","vegland_masks")

  res                       = True

  res@gsnMaximize           = True           ; maximize plot in frame
  res@gsnDraw               = False          ; don't draw plot yet
  res@gsnFrame              = False          ; don't advance frame yet

  res@cnFillOn              = True
  res@cnLineLabelsOn        = False
  res@cnLinesOn             = False
  res@cnFillMode            = "RasterFill"
;  res@trGridType            = "TriangularMesh"

;---Make sure all plots have same contour levels
  res@cnLevelSelectionMode = "ExplicitLevels"              ; set explict contour levels
  res@cnLevels             = integertobyte(ispan(2,17,1))

  res@lbLabelBarOn          = False
  res@gsnAddCyclic          = False

  res@mpFillOn              = False
  res@mpOutlineOn           = False

  res@gsnRightString        = ""
  res@gsnLeftString         = ""

;---Create plot of original data and attach shapefile outlines
  res@tiMainString = "Original data with shapefile outlines"
  map_data = gsn_csm_contour_map(wks,x,res)

  
;---Create plot of world masked data
  res@tiMainString = "Original data masked against world shapefile"
  map_world_mask  = gsn_csm_contour_map(wks,x_mask_world,res)

;---Add shapefile outlines
  dum1 = gsn_add_shapefile_polylines(wks,map_data,world_shpfile,False)
  dum2 = gsn_add_shapefile_polylines(wks,map_world_mask,world_shpfile,False)

;---Create plot of world + Greenland masked data
  if(MASK_GREENLAND) then
    res@tiMainString = "Masked data masked against Greenland"
    map_greenland_mask  = gsn_csm_contour_map(wks,x_mask_greenland,res)
    dum3 = gsn_add_shapefile_polylines(wks,map_greenland_mask,world_shpfile,False)
  end if

;---Draw plots on one page
  pres                  = True
  pres@gsnMaximize      = True
  pres@gsnPanelLabelBar = True
  gsn_panel(wks,(/map_data,map_world_mask/),(/2,1/),pres)

  if(MASK_GREENLAND) then
    gsn_panel(wks,(/map_data,map_greenland_mask/),(/2,1/),pres)
  end if
  end_graphics_time = get_cpu_time()

  print("Elapsed graphics time = " + (end_graphics_time-start_graphics_time) + " CP seconds.")

  end_script_time = get_cpu_time()
  print("Elapsed script time = " + (end_script_time-start_script_time) + " CPU seconds.")
end

