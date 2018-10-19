;--------------------------------------------------
; lcnative_latlon_1.ncl
;   - Drawing contours over a different projection than the native one
;   - Subsetting a color map
;--------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
begin
;--------------------------------------------------
; Open file and read in data. The arrays
; are dimensioned (time x xcoord x ycoord)
; (time x lon x lon), so we must reorder
; to (time x ycoord x xcoord).
;--------------------------------------------------
  f       = addfile ("pre.8912.mon.nc", "r")
  p       = f->pre(time|:,ycoord|:,xcoord|:)
  p@lat2d = f->lat(ycoord|:,xcoord|:)
  p@lon2d = f->lon(ycoord|:,xcoord|:)

;--------------------------------------------------
; create plot
;--------------------------------------------------
  wks  = gsn_open_wks ("png", "lcnative_latlon")  ; open workstation
  
  cmap = read_colormap_file("gui_default")        ; so we can subset later

  res                        = True               ; plot mods desired
  res@cnFillOn               = True               ; color fill  
  res@cnFillPalette          = cmap(2:,:)         ; subset the color map
  res@cnLinesOn              = False              ; no contour lines
  res@cnLineLabelsOn         = False              ; no contour labels
  res@cnInfoLabelOn          = False              ; no contour info label
  
  res@mpDataBaseVersion      = "MediumRes"        ; better map outlines
  res@pmTickMarkDisplayMode  = "Always"           ; turn on tickmarks
  
  res@tiMainString           = "Native Lambert Conformal Data Plotted on~C~" +\
                               "    a Cylindrical Equidistant projection"
  res@tiMainFontHeightF      = 0.020              ; smaller title
  res@tiMainOffsetYF         = -0.03              ; move title down
  
  ;res@gsnAddCyclic           = False              ; regional data
  res@mpLimitMode            = "LatLon"           ; choose region of map
  res@mpMinLatF              = min(p@lat2d)-1     ; Add a little bit of
  res@mpMinLonF              = min(p@lon2d)-1     ; a margin around
  res@mpMaxLatF              = max(p@lat2d)+1     ; the plot.
  res@mpMaxLonF              = max(p@lon2d)+1
  
  plot = gsn_csm_contour_map(wks,p(0,:,:),res)     ; Draw contours over a map.
  
end
