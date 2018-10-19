;*************************************************
; avhrr_1.ncl           
;
; Concepts illustrated:
;   - Reading HDF4 data
;   - Contouring AVHRR data
;   - Drawing raster contours
;   - Manually creating lat/lon coordinate arrays
;   - Converting "byte" data to "float"
;
;======================================================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;********************************************
; NOTE: usually when netCDF or HDF files are 
;       used, coordinate information and missing value
;       information is provided.  This file has none. 
;       Must do manually.
;********************************************
begin
;*********************************************
; aread in data 
;*********************************************
  f    = addfile("./avhrr.hdf","r")
  ;print(f)

  NDVI = f->$"Data_Set_2"$      ; byte: all 0 or 1
  NDVI@_FillValue = default_fillvalue(typeof(NDVI))

;*********************************************
; data is in byte format, so we must convert
;*********************************************
  ndvi = NDVI*NDVI@scale_factor + NDVI@add_offset

;*********************************************
; no coordinate information is available so create on our own
;*********************************************
  dim_ndvi = dimsizes(ndvi)

  nlat = dim_ndvi(0)
  lat  = latGlobeFo (nlat, "lat", "latitude", "degrees_north")
  lat  = lat(::-1)              ; grid goes from North->South

  mlon = dim_ndvi(1)
  lon  = lonGlobeFo (mlon, "lon", "longitude", "degrees_east")
  lon  = (/ lon-180. /)         ; grid goes DateLine eastward
;*********************************************
; data does not have named dimensions, coordinate variables or attributes,
; so we must assign
;*********************************************
  ndvi!0   = "lat"              ; name dimensions
  ndvi!1   = "lon"
  ndvi&lat =  lat               ; assign coord variables
  ndvi&lon =  lon               ; that were created above
 
  ndvi@long_name = "NDVI"       ; assign long_name
;*********************************************************
; create plot
;*********************************************************
  wks = gsn_open_wks("png","avhrr")                ; send graphics to PNG file
  cmap = read_colormap_file("BlAqGrYeOrReVi200")
   
  res                  = True                      ; plot mods desired
  res@cnFillOn         = True                      ; turn on color
  res@cnFillPalette    = cmap(0:170,:)             ; subset color map

  res@cnLinesOn        = False                     ; Turn off contour lines
  res@cnFillMode       = "RasterFill"              ; Raster Mode
  res@cnLevelSpacingF  = 0.2

  res@mpOceanFillColor = "White"
  res@mpLandFillColor  = "transparent"
  res@mpInlandWaterFillColor = "white"
  res@mpFillDrawOrder  = "PostDraw"

  res@tiMainString     = "AVHRR data"              ; title

  plot = gsn_csm_contour_map_ce(wks,ndvi, res)     ; create plot
end
