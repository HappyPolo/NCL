;************************************************
; native_3.ncl
;
; Concepts illustrated:
;   - Reading GRIB data
;   - Drawing filled contours over a stereographic map
;   - Overlaying contours on a map without having lat,lon coordinates
;   - Creating a color map using named colors
;   - Turning off the addition of a longitude cyclic point
;   - Zooming in on a particular area on a stereographic map
;   - Drawing raster contours
;   - Drawing U.S. states
;   - Explicitly setting contour levels
;   - Using "where" to set all values <= 0 to missing
;
;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
;************************************************
begin
  f = addfile("ST4.2002030112.06h.grb","r")

  prc   = f->A_PCP_GDS5_SFC_acc6h
;
; The lat,lon coordinate points are only used in this 
; script to determine the area of the map to look at.
; You could potentially use them to over this data
; on a different map projection. See end of script.
;
  lat2d = f->g5_lat_0               ;  (g5_x_0, g5_y_1)
  lon2d = f->g5_lon_1               ;  (g5_x_0, g5_y_1)
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","native")                 ; open wk station

; create color map using named colors
  colors = (/"white","green","palegreen","yellowgreen",\
  "greenyellow", "yellow","goldenrod","orange","orangered","red","deeppinK",\
  "violet","darkviolet","blueviolet","blue"/)
  
; plot resources
  res                   = True                   ; plot mods desired
  res@tiMainString      = "native stereographic from GRIB"
  res@gsnAddCyclic      = False                  ; regional data
  res@tfDoNDCOverlay    = True                   ; no map transformation
;************************************************
; stereographic projections are limited using the corners method rather than 
; the latlon method seen for cylindrical equadistant projections this grib \
; file contains attributes that provide the necessary info.
;************************************************
  res@mpProjection          = "Stereographic"
  res@mpLimitMode           = "Corners"        
  res@mpLeftCornerLatF      = lat2d@corners(0)         ; info on GRIB file
  res@mpLeftCornerLonF      = lon2d@corners(0)
  res@mpRightCornerLatF     = lat2d@corners(2)
  res@mpRightCornerLonF     = lon2d@corners(2)
  res@mpCenterLonF          = lat2d@Lov
  res@mpCenterLatF          = 90.                      ; ProjCenter: north
  
  res@mpPerimOn             = False
  res@mpOutlineBoundarySets = "GeophysicalAndUSStates" ; state boundaries
  res@mpFillOn              = False                    ; no map fill
  
  res@cnFillOn              = True                     ; color plot desired
  res@cnLinesOn             = False                    ; turn off cn lines
  res@cnFillMode            = "RasterFill"             ; raster
  res@cnFillPalette         = colors  
  res@cnLevelSelectionMode  = "ExplicitLevels"   ; set explicit contour levels
  res@cnLevels              = (/0,5,10,15,20,25,30,35,50,75,100,125,150,175/)
  

;---Remove all values <= 0.0
  prc = where(prc.le.0,prc@_FillValue,prc)

  plot = gsn_csm_contour_map(wks,prc,res)    ; create the plot

;
; You could use a differnt map projection, since you have 2-dimensional
; lat, lon data. Make sure you set:
; 
; res@tfDoNDCOverlay = False
;
; and add:
;
;  prc@lat2d = lat2d
;  prc@lon2d = lon2d
;
; before calling gsn_csm_xxxx_map with a new projection.
;  
end


