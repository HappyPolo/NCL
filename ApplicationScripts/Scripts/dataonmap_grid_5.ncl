;----------------------------------------------------------------------
; dataonmap_grid_5.ncl
;
; Concepts illustrated:
;   - Contouring one-dimensional X, Y, Z data
;   - Drawing a variable's lat/lon locations using gsn_coordinates
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;
; Data is stored in four columns:  station_name  lat  lon  pwv
; Read in each line as a string, and use "str_get_field" to 
; read in the fields of interest.
;
  fname = "pw.dat"
  lines = asciiread(fname,-1,"string")

;
; Use "str_get_field" to indicate which fields to read in.
; Each field is separated by spaces.
;
  lat = tofloat(str_get_field(lines(1:),2," "))
  lon = tofloat(str_get_field(lines(1:),3," "))
  pwv = tofloat(str_get_field(lines(1:),4," "))

  wks = gsn_open_wks("png","dataonmap_grid")  ; send graphics to PNG file

  res                             = True

  res@gsnMaximize                 = True
  res@gsnDraw                     = False    ; Don't draw plot or 
  res@gsnFrame                    = False    ; advance frame

  res@cnLevelSelectionMode        = "ManualLevels"
  res@cnMinLevelValF              = 15         	; 15.25
  res@cnMaxLevelValF              = 50		; 49.75
  res@cnLevelSpacingF             = 1.125

  res@cnFillOn                    = True
  res@cnLinesOn                   = False
  res@cnFillPalette               = "cmp_flux"
  res@tiMainString                = "GPS PWV (18Z)"

  res@sfXArray                    = lon      ; Associates lat/lon locations
  res@sfYArray                    = lat      ; with data values.

;---Zoom in on map
  res@mpMinLatF                   = min(lat)-1
  res@mpMaxLatF                   = max(lat)+1
  res@mpMinLonF                   = min(lon)-1
  res@mpMaxLonF                   = max(lon)+1

;---Customize the map outlines.
  res@mpDataBaseVersion           = "MediumRes"
  res@mpFillOn                    = False
  res@mpOutlineBoundarySets       = "GeophysicalAndUSStates"
  res@mpUSStateLineColor          = "Gray10"

  res@pmTickMarkDisplayMode       = "Always"

  plot = gsn_csm_contour_map(wks,pwv,res)

;---Draw the lat/lon locations as markers
  mkres = True
  mkres@gsMarkerIndex = 16
  mkres@gsnCoordsLat  = lat
  mkres@gsnCoordsLon  = lon
  gsn_coordinates(wks,plot,pwv,mkres)

end 
