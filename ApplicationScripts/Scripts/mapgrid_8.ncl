;--------------------------------------------------
; mapgrid_8.ncl
;--------------------------------------------------
; Concepts illustrated:
;   - Drawing a lat/lon grid using gsn_coordinates
;--------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  tf    = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/Tstorm.cdf","r")
  t     = tf->t
  time  = tf->timestep

  t&lat@units = "degrees_north"
  t&lon@units = "degrees_east"

;---Convert to different units
  t       = ((/t/) - 273.15) * 9.0/5.0 +32.0
  t@units = "F"

  wks = gsn_open_wks("png","mapgrid") ; send graphics to PNG file

;---Set up some contour resources.
  res                       = True
  res@gsnMaximize           = True
  res@gsnDraw               = False   ; Don't draw plot
  res@gsnFrame              = False   ; Don't advance frame.

  res@gsnAddCyclic          = False
  res@gsnLeftString         = "temperature"
  res@cnFillOn              = True
  res@cnFillPalette         = "temp1" ; set color map
  res@cnLinesOn             = False
  res@cnInfoLabelOn         = False
  res@mpFillOn              = False 
  res@mpProjection          = "LambertEqualArea"
  res@mpGridAndLimbOn       = False

  res@mpDataBaseVersion     = "MediumRes"
  res@mpOutlineBoundarySets = "GeophysicalAndUSStates"   ; "AllBoundaries"
 
  res@cnLevelSpacingF       = 5
  res@lbOrientation         = "Vertical"
 
;---Zoom in on North America
  res@mpLimitMode           = "LatLon"
  res@mpMinLatF             = min(t&lat)-1
  res@mpMaxLatF             = max(t&lat)-1
  res@mpMinLonF             = min(t&lon)-1
  res@mpMaxLonF             = max(t&lon)+1
  res@mpCenterLonF          = -100.0
  res@mpCenterLatF          = 40.0

  res@mpGridAndLimbDrawOrder = "Predraw"
  res@tiMainString           = "Lat/lon grid"

;---Plot will just be created, and not drawn yet.
  plot = gsn_csm_contour_map(wks,t(0,:,:),res)

;----------------------------------------------------------------------
; Draw the lat/lon grid with markers, using black for grid locations
; where the data is not missing, and yellow for grid locations
; where the data is missing.
;---------------------------------------------------------------------
  pres                          = True
  pres@gsnCoordsNonMissingColor = "yellow"
  pres@gsnCoordsMissingColor    = "black"
  pres@gsMarkerSizeF            = 5.0
  gsn_coordinates(wks,plot,t(0,:,:),pres)

;----------------------------------------------------------------------
; Draw lines at the lon/lon coordinate array values.
; Marker resources set above will be ignored.
;----------------------------------------------------------------------
  pres@gsnCoordsAsLines  = True
  pres@gsLineThicknessF  = 2
  gsn_coordinates(wks,plot,t(0,:,:),pres)
end
