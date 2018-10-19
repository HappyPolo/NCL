;----------------------------------------------------------------------
; This script masks data over part of Greenland, using outlines from 
; a shapefile downloaded from a gadm.org.
;
; It can be slow to run, maybe 30 seconds or more.
;
; The GRL_adm0.shp shapefile has the following lat/lon min/max values.
;
;    lat min =  59.74450683593795   max = 83.65833282470737
;    lon min = -73.24323272705044   max = -0.0130208618937786
;
; We use these to help speed up the masking, since the original data is 
; global and can take a long time to mask it based on an outline 
; like Greenland, which takes a LOT of lat/lon points to define its
; outline.
;----------------------------------------------------------------------
load "shapefile_utils.ncl"     ; script that contains the masking function

begin
;----------------------------------------------------------------------
; Rough area of interest for plotting and masking. This will make 
; masking routine go faster. You can use different values for 
; plotting and masking, if desired.
;----------------------------------------------------------------------
  minlat    =  58
  maxlat    =  85
  minlon    = -75
  maxlon    =   0

;---Open the file and read first timestep of "ts".
  fname = "ts_Amon_CESM1-CAM5_historical_r1i1p1_185001-200512.nc"
  f = addfile(fname,"r")
  t = f->ts(0,:,:)
  t = lonFlip(t)              ; 0 to 360 ---> -180 to 180


;---Using a subset of t will also help the masking go faster.
  tsub = t({30:90},{-90:10})

  wks = gsn_open_wks("png","greenland_masking")

  res  = True
  res@gsnMaximize = True    ; make plot as large as possible
  res@cnFillOn      = True
  res@cnLinesOn     = False

  res@tiMainString   = fname   ; use the file name as the main title

  res@mpDataBaseVersion = "MediumRes"
  res@mpMinLatF    = minlat
  res@mpMaxLatF    = maxlat
  res@mpMinLonF    = minlon
  res@mpMaxLonF    = maxlon
  res@mpFillOn     = False

  res@gsnAddCyclic = False   ; set to False if using subset of data

;  plot = gsn_csm_contour_map(wks,tsub,res)
  plot = gsn_csm_contour_map(wks,t,res)

;---Draw markers at grid locations
  mkres                          = True
  mkres@gsMarkerSizeF            = 5
;  gsn_coordinates(wks,plot,tsub,mkres)
  gsn_coordinates(wks,plot,t,mkres)

;
; Mask the data based on Greenland outline. This is slow.
; Using a subset of the shapefile is faster, like "Kitaa".
;
  shp_filename = "GRL_adm/GRL_adm1.shp"
  opt             = True
  opt@shape_var   = "NAME_1"
  opt@shape_names = "Tunu"        ; Avannaa, Kitaa, Tunu
  opt@minlat      = minlat
  opt@maxlat      = maxlat
  opt@minlon      = minlon
  opt@maxlon      = maxlon
  
;  tmask = shapefile_mask_data(tsub,shp_filename,opt)
  tmask = shapefile_mask_data(t,shp_filename,opt)
  printVarSummary(tmask)
  printMinMax(tmask,0)

;---Create plot of masked data (it won't be drawn yet)
  res@mpOutlineOn = False
  res@gsnDraw     = False
  res@gsnFrame    = False
  plot_mask = gsn_csm_contour_map(wks,tmask,res)

;---Add the shapefile outlines
  lnres                  = True
  lnres@gsLineThicknessF = 2.0
  id1 = gsn_add_shapefile_polylines(wks,plot_mask,"GRL_adm/GRL_adm1.shp",lnres)

  draw(plot_mask)
  frame(wks)

;---Add grid points again, but this time color the missing points in red.
  mkres@gsnCoordsNonMissingColor = "black"     ; the default
  mkres@gsnCoordsMissingColor    = "red"
  gsn_coordinates(wks,plot_mask,tmask,mkres)
end
