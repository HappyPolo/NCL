;--------------------------------------------------
; lcnative_1.ncl
;
; Concepts illustrated:
;   - Drawing contours over a map using a native lat,lon grid
;   - Drawing filled contours over a Lambert Conformal map
;   - Zooming in on a particular area on a Lambert Conformal map
;   - Subsetting a color map
;--------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
begin
;--------------------------------------------------
; Open file and read in data. The arrays
; are dimensioned (time x xcoord x ycoord)
; (time x lon x lon), so we must reorder
; to (time x ycoord x xcoord).
;--------------------------------------------------
  f     = addfile ("pre.8912.mon.nc", "r")
  p     = f->pre(time|:,ycoord|:,xcoord|:)
  lat2d = f->lat(ycoord|:,xcoord|:)
  lon2d = f->lon(ycoord|:,xcoord|:)

;--------------------------------------------------
; get some parameters
;--------------------------------------------------
  nlat = dimsizes(lat2d(:,0))
  nlon = dimsizes(lat2d(0,:))
;--------------------------------------------------
; create plot
;--------------------------------------------------
  wks  = gsn_open_wks ("png", "lcnative")         ; open workstation
  cmap = read_colormap_file("gui_default")        ; so we can subset later

  res                        = True               ; plot mods desired
  res@cnFillOn               = True               ; color fill  
  res@cnFillPalette          = cmap(2:,:)         ; subset the color map
  res@cnLinesOn              = False              ; no contour lines
  res@cnLineLabelsOn         = False              ; no contour labels
  res@cnInfoLabelOn          = False              ; no contour info label
  
  res@mpDataBaseVersion      = "MediumRes"        ; better map outlines
  res@pmTickMarkDisplayMode  = "Always"           ; turn on tickmarks
  
  res@tiMainString           = "Native Lambert Conformal Grid"
  res@tiMainFontHeightF      = 0.020              ; smaller title
  res@tiMainOffsetYF         = -0.005             ; move title down
  
  res@gsnAddCyclic           = False              ; regional data
  res@gsnMaximize            = True               ; enlarge image  

  res@mpLimitMode            = "Corners"          ; choose region of map
  res@mpLeftCornerLatF       = lat2d(0,0)
  res@mpLeftCornerLonF       = lon2d(0,0)
  res@mpRightCornerLatF      = lat2d(nlat-1,nlon-1)
  res@mpRightCornerLonF      = lon2d(nlat-1,nlon-1)
  
; The following 4 pieces of information are REQUIRED to properly display
; data on a native lambert conformal grid.  This data should be specified
; somewhere in the model itself, but in this case, it was not.
  
  res@mpProjection           = "LambertConformal"
  res@mpLambertParallel1F    = 36.
  res@mpLambertParallel2F    = 55.
  res@mpLambertMeridianF     = 45.

; Usually, when data is placed onto a map, it is TRANSFORMED to the specified
; projection. Since this model is already on a native lambert conformal grid,
; we want to turn OFF the tranformation.
  
  res@tfDoNDCOverlay = True
  
  plot = gsn_csm_contour_map(wks,p(0,:,:),res)     ; Draw contours over a map.
  
end
