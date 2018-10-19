;----------------------------------------------------------------------
; shapefiles_14_mask.ncl
;
; Concepts illustrated:
;   - Reading shapefiles
;   - Adding shapefile outlines to an existing WRF contour/map plot
;   - Masking a data array based on a geographical area obtained from a shapefile
;   - Drawing a WRF lat/lon grid using gsn_coordinates
;   - Zooming in on a WRF map
;----------------------------------------------------------------------
; This example shows how to use a shapefile of the United States
; to mask out all data except for over Ohio and Pennsylvania. 
;
; The "USA_adm.shp" shapefiles were downloaded from 
; http://www.gadm.org/country/
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;
; This file still has to be loaded manually
load "./shapefile_utils.ncl"

begin
  wrf_filename  = "wrfout_d01_2002-01.nc"
  shp_filename1 = "USA_adm/USA_adm1.shp"    ; State outlines
  shp_filename2 = "USA_adm/USA_adm2.shp"    ; County outlines
  a = addfile(wrf_filename,"r")
 
;---Area to zoom in on
  lats = (/ 38.0, 43.0/)
  lons = (/-85.0,-78.0/)
  loc  = wrf_user_ll_to_ij(a, lons, lats, True)

; 
; loc(0,:) is west-east (x)
; loc(1,:) is south-north (y)
;
; Use "loc" values to set special resources for zooming in on map.
;
  loc    = loc-1       ; Subtract one since we want to use it 
                       ; as an index in NCL.
  xstart = loc(0,0)   ; Set the zoom in coordinates
  xend   = loc(0,1)
  ystart = loc(1,0)
  yend   = loc(1,1)


;---Read "height" variable and lat/lon coordinates off WRF output file.
  nt        = 0                 ; First time step
  hgt       = a->HGT(nt,:,:)
  hgt@lat2d = a->XLAT(nt,:,:)
  hgt@lon2d = a->XLONG(nt,:,:)

;---Set all hgt values to missing except for those over Ohio.
  opt             = True
  opt@debug       = True
  opt@shape_var   = "NAME_1"
  opt@shape_names = "Ohio"
  hgt_mask  = shapefile_mask_data(hgt,shp_filename1,opt)

;---Zoom in on Ohio, roughly.
  hgt_mask_zoom = hgt_mask(ystart:yend,xstart:xend)
  
;---Start the graphics
  wks = gsn_open_wks("png","shapefiles_mask") ; send graphics to PNG file

  res                   = True               ; Use basic options for this field
  res@cnFillOn          = True               ; Create a color fill plot
  res@cnFillPalette     = "OceanLakeLandSnow"; set color map
  res@ContourParameters = (/1,1100,20/)      ; Special WRF resource

;---Create contours of masked and zoomed in masked "hgt" arrays
  contour_mask      = wrf_contour(a,wks,hgt_mask,res)
  contour_mask_zoom = wrf_contour(a,wks,hgt_mask_zoom,res)

  pltres            = True   ; Set plot options
  pltres@PanelPlot  = True   ; Tells wrf_map_overlays not to remove contours

  mpres             = True   ; Set map options
  mpres@mpOutlineOn = False
  mpres@mpFillOn    = False

  plot_mask      = wrf_map_overlays(a,wks,contour_mask,pltres,mpres) 

;---Create a zoomed version
  mpres@ZoomIn = True        ; Tell wrf_map_resources we want to zoom in.
  mpres@Xstart = xstart
  mpres@Xend   = xend
  mpres@Ystart = ystart
  mpres@Yend   = yend

  plot_mask_zoom = wrf_map_overlays(a,wks,contour_mask_zoom,pltres,mpres) 

;---Attach the shapefile outlines
  lnres                  = True
  lnres@gsLineColor      = "gray25"
  lnres@gsLineThicknessF = 0.5   

;---Using USA_adm2.shp here to get county outlines
  id_mask      = gsn_add_shapefile_polylines(wks,plot_mask,     shp_filename2,lnres)
  id_mask_zoom = gsn_add_shapefile_polylines(wks,plot_mask_zoom,shp_filename2,lnres)

  draw(plot_mask)
  frame(wks)

;---Mask the lat/lon values over Ohio area
  lat2d_mask = hgt_mask@lat2d
  lon2d_mask = hgt_mask@lon2d
  lat2d_mask@_FillValue = default_fillvalue(typeof(lat2d_mask))
  lon2d_mask@_FillValue = default_fillvalue(typeof(lon2d_mask))
  lat2d_mask = where(.not.ismissing(hgt_mask),lat2d_mask@_FillValue,lat2d_mask)
  lon2d_mask = where(.not.ismissing(hgt_mask),lon2d_mask@_FillValue,lon2d_mask)

  mkres                 = True
  mkres@gsMarkerSizeF   = 0.003
  mkres@gsMarkerColor   = "coral1"
  mkres@gsnCoordsAttach = True
  mkres@gsnCoordsLat    = lat2d_mask
  mkres@gsnCoordsLon    = lon2d_mask

;---Attach coordinates
  gsn_coordinates(wks,plot_mask_zoom,hgt_mask_zoom,mkres)

  draw(plot_mask_zoom)
  frame(wks)
end
