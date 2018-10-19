;--------------------------------------------------
; wrf_zoom_1.ncl
;--------------------------------------------------
; Concepts illustrated:
;   - Plotting WRF data on native grid
;   - Zooming in on a WRF map using special WRF resources
;   - Plotting data using wrf_xxxx functions
;--------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
  filename = "wrfout_d03_2012-04-22_23_00_00"
  a = addfile(filename + ".nc", "r")

  td2  = wrf_user_getvar(a,"td2",0)

  wks = gsn_open_wks("png","wrf_zoom")

;---Get index values for for upper left of domain
  dims    = dimsizes(td2)
  y_start = dims(0)/2
  y_end   = dims(0)-1
  x_start = 0
  x_end   = dims(1)/2

;---Subset the original array with these new indexes
  td2_zoom = td2(y_start:y_end,x_start:x_end)

;---Create filled contour plot of original domain (td2)
  cnres = True
  cnres@cnFillOn                 = True
  cnres@MainTitle                = "Full plot"
  cnres@pmLabelBarOrthogonalPosF = 0.001  ; move labelbar down a smidge
  contour_full = wrf_contour(a,wks,td2,cnres)

;---Create filled contour plot of zoomed in domain (td2_zoom)
  cnres@MainTitle = "Zoomed in plot"
  contour_zoom = wrf_contour(a,wks,td2_zoom,cnres)

;---Draw full domain over map
  pltres = True
  mpres  = True
  mpres@mpGeophysicalLineColor = "Black"
  mpres@mpUSStateLineColor     = "Black"
  mpres@mpGeophysicalLineThicknessF = 2.0
  mpres@mpUSStateLineThicknessF     = 2.0

  plot_full = wrf_map_overlays(a,wks,contour_full,pltres,mpres)

;---Draw subsetted domain over zoomed in map

  mpres@ZoomIn = True        ; Tell wrf_map_resources we want to zoom in.
  mpres@Xstart = x_start     ; Set these four special WRF resources
  mpres@Xend   = x_end       ; required for zooming.
  mpres@Ystart = y_start
  mpres@Yend   = y_end
  plot_zoom = wrf_map_overlays(a,wks,contour_zoom,pltres,mpres)


end
