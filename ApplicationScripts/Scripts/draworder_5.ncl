;*************************************************
; draworder_5.ncl
;
; Concepts illustrated:
;   - Controlling the draw order of markers relative to map fill
;   - Adding a map to another map as an annotation
;   - Changing the land fill color
;   - Changing the ocean fill color
;   - Setting land, ocean, and inland water fill to transparent
;   - Generating dummy data using "generate_2d_array"
;   - Generating dummy coordinate arrays
;   - Using named colors to indicate a fill color
;   - Creating a color map using named colors
;   - Drawing a lat/lon grid using markers
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
;************************************************

begin
; Generate some dummy data with dummy 1D lat/lon coordinate arrays.
  nlat      =  64
  nlon      = 128
  lat       = fspan( -88.75, 88.75,nlat)
  lon       = fspan(-179.50,179.50,nlon)
  lat@units = "degrees_north"
  lon@units = "degrees_east"
  data      = generate_2d_array(10, 10, -19.69, 15.82, 0, (/nlat,nlon/))
  data!0    = "lat"
  data!1    = "lon"
  data&lat  = lat
  data&lon  = lon

;
; Start graphics
;
  wks = gsn_open_wks("png","draworder") ; send graphics to PNG file
  colormap = (/"White","Black","Black","Red","Green","Blue","Brown", \
               "Purple","ForestGreen","Wheat3","SlateGray2"/)

  res                 = True                        ; plot mods desired

  res@gsnMaximize     = True                        ; maximize size of plot

  res@gsnDraw         = False                       ; don't draw yet
  res@gsnFrame        = False                       ; don't advance yet

  res@mpMinLatF       =  -20                        ; zoom in on a subregion
  res@mpMaxLatF       =   40
  res@mpMinLonF       = -130
  res@mpMaxLonF       =    0

  res@cnFillPalette   = colormap                    ; set color map

; 
; We want to draw markers over ocean only, so we need to:
;
; - Create a map plot with filled land and transparent ocean.
; - Create a map plot with filled ocean and transparent land.
; - Attach the land plot to the ocean plot so that the ocean
;    plot will get drawn first.
; - Attach the markers to the ocean plot. This means that the
;   land plot will cover the markers.
;
; Note: we have to use "gsn_add_annotation" to attach one map
; plot to another, because you can't use the "overlay" procedure
; to overlay two map plots.

;
; Create land plot by setting land fill resources and making
; ocean/inland water transparent.
;
  res@mpLandFillColor        = "Wheat3"	; was "GoldenRod1" or "Tan"
  res@mpInlandWaterFillColor = "Transparent"
  res@mpOceanFillColor       = "Transparent"

  land_plot = gsn_csm_contour_map_ce(wks,data,res)
;
; Create ocean plot by setting water fill resources and
; making land transparent.
;
  res@tiMainString           = "Drawing markers over ocean, under land"
  res@mpLandFillColor        = "Transparent"	; was "GoldenRod1" or "Tan"
  res@mpOceanFillColor       = "SlateGray2" ; was "LightBlue1"
  res@mpInlandWaterFillColor = "SlateGray2" ; was "LightBlue1"	; was "PaleTurquoise3"
  ocean_plot = gsn_csm_contour_map_ce(wks,data,res)

;
; Add the land plot as an annotation of the ocean plot.
;
  amres = True
  annoid = gsn_add_annotation(ocean_plot,land_plot,amres)

;
; Create a 2D array of lat/lon values, but make this a 1D array
; so we can pass them to gsn_add_polymarker.
;
  lat2d_1d = ndtooned(conform_dims((/nlat,nlon/),lat,0))
  lon2d_1d = ndtooned(conform_dims((/nlat,nlon/),lon,1))

;
; Set up resources for polymarkers.
;
  resp               = True
  resp@gsMarkerIndex = 16          ; Filled dots
  resp@gsMarkerColor = "purple"

; Attach polymarkers to ocean plot.
  dum = gsn_add_polymarker(wks,ocean_plot,lon2d_1d,lat2d_1d,resp)

  draw(ocean_plot)  ; Note markers get drawn under land.
  frame(wks)
end
