;----------------------------------------------------------------------
; dataonmap_native_grid_3.ncl
;
; Concepts illustrated:
;   - Drawing contours over a map using a native lat,lon grid
;   - Zooming in on a particular area on a map
;   - Drawing a variable's lat/lon grid using gsn_coordinates
;----------------------------------------------------------------------
; The data file for this example can be downloaded from
;    http://www.ncl.ucar.edu/Applications/Data/#grb
;
; wget http://www.ncl.ucar.edu/Applications/Data/ruc.grb
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;---Read data
  a    = addfile("ruc.grb","r")
  temp = a->TMP_236_SPDY     ; 6 x 113 x 151
  lat  = a->gridlat_236      ; Needed only for projection information
  lon  = a->gridlon_236

  wks = gsn_open_wks("png","dataonmap_native_grid")

;---Set some resources
  res                = True

  res@gsnMaximize    = True     ; maximize plot in frame

  res@gsnDraw        = False    ; Don't draw plot or 
  res@gsnFrame       = False    ; advance frame

  res@cnFillOn       = True     ; turn on contour fill
  res@cnLinesOn      = False    ; turn off contour lines
  res@cnLineLabelsOn = False    ; turn off contour line labels


  res@tfDoNDCOverlay    = True        ; REQUIRED for plotting on native grid
  res@mpLimitMode       = "Corners"         ; choose range of map
  res@mpLeftCornerLatF  = lat@corners(0)
  res@mpLeftCornerLonF  = lon@corners(0)
  res@mpRightCornerLatF = lat@corners(2)
  res@mpRightCornerLonF = lon@corners(2)

  res@mpProjection        = lat@mpProjection
  res@mpLambertMeridianF  = lat@mpLambertMeridianF
  res@mpLambertParallel1F = lat@mpLambertParallel1F
  res@mpLambertParallel2F = lat@mpLambertParallel2F

  res@pmTickMarkDisplayMode = "Always"    ; better map tickmarks

  res@tiMainString   = "Lat/lon grid for curvilinear variable"

  plot = gsn_csm_contour_map(wks,temp(0,:,:),res)

;
; Draw the lat/lon locations as grid lines. Since the
; lat/lon arrays are not associated with "temp", we
; have to pass them explicitly via the gsnCoordsLat/Lon
; attributes.
;
  lnres = True
  lnres@gsnCoordsLat = lat
  lnres@gsnCoordsLon = lon
  lnres@gsnCoordsAsLines = True
  gsn_coordinates(wks,plot,temp,lnres)

end