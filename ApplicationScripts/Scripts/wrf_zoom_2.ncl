;--------------------------------------------------
; wrf_zoom_2.ncl
;--------------------------------------------------
; Concepts illustrated:
;   - Plotting WRF data on native grid
;   - Zooming in on a WRF map using special WRF resources
;   - Plotting data using wrf_xxxx and gsn_csm_xxxx_map functions
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
  res = True
  res@cnFillOn      = True
  res@lbOrientation = "Vertical"
  res = wrf_map_resources(a,res)

  res@mpGeophysicalLineColor = "Black"
  res@mpUSStateLineColor     = "Black"
  res@mpGeophysicalLineThicknessF = 2.0
  res@mpUSStateLineThicknessF     = 2.0

  res@tfDoNDCOverlay              = True    ; very important for "native" overlay
  res@gsnAddCyclic                = False   ; data is regional

;---Draw full domain over map
  res@tiMainString = "Full plot"
  plot_full = gsn_csm_contour_map(wks,td2,res)

;---Draw subsetted domain over zoomed in map
  res@ZoomIn = True        ; Tell wrf_map_resources we want to zoom in.
  res@Xstart = x_start     ; Set these four special WRF resources
  res@Xend   = x_end       ; required for zooming.
  res@Ystart = y_start
  res@Yend   = y_end
  res = wrf_map_resources(a,res)   ; must call this again after setting ZoomIn/X/Ystart/end

  res@tiMainString = "Zoomed in plot"
  plot_zoom = gsn_csm_contour_map(wks,td2_zoom,res)


end
