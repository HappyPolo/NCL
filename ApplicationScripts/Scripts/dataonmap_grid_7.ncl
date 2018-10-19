;----------------------------------------------------------------------
; dataonmap_grid_7.ncl
;
; Concepts illustrated:
;   - Plotting data on a rectilinear grid
;   - Fixing the "units" of lat/lon coordinate arrays
;   - Turning off the addition of a longitude cyclic point
;   - Zooming in on a particular area on a map
;   - Drawing a variable's lat/lon grid using gsn_coordinates
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;----------------------------------------------------------------------

begin
  f = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/Tstorm.cdf","r") 
  t = f->t    ; 64 x 33 x 36

;---Fix the lat/lon units
  t&lat@units = "degrees_north"
  t&lon@units = "degrees_east"

  wks = gsn_open_wks("png","dataonmap_grid")

  res              = True
  res@gsnMaximize  = True
  res@gsnDraw      = False    ; Don't draw plot or 
  res@gsnFrame     = False    ; advance frame
  res@cnFillOn     = True
  res@cnLinesOn    = False
  res@gsnAddCyclic = False    ; turn off addition of lon cyclic pt

;---Zoom in on map
  res@mpMinLatF    = min(t&lat) - 1
  res@mpMaxLatF    = max(t&lat) + 1
  res@mpMinLonF    = min(t&lon) - 1
  res@mpMaxLonF    = max(t&lon) + 1
  res@tiMainString = "Lat/lon grid for variable, red = missing value locations"

  plot = gsn_csm_contour_map(wks,t(0,:,:),res)

;---Draw the lat/lon locations as markers
  mkres = True
  mkres@gsMarkerIndex            = 16
  mkres@gsMarkerSizeF            = 3
  mkres@gsnCoordsNonMissingColor = "black"
  mkres@gsnCoordsMissingColor    = "red"
  gsn_coordinates(wks,plot,t(0,:,:),mkres)

end
