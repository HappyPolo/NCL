;----------------------------------------------------------------------
; dataonmap_5.ncl
;
; Concepts illustrated:
;   - Contouring one-dimensional X, Y, Z data
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;
; Data is stored in four columns:  station_name  lat  lon  pwv
; Read in each line as a string, use "str_get_field" to 
; read in the fields of interest and "tofloat" to convert
; to float.
;
  lines = asciiread("pw.dat",-1,"string")
  pwv   = tofloat(str_get_field(lines(1:),4," "))  ; 32 points
  lat   = tofloat(str_get_field(lines(1:),2," "))  ; 32 points
  lon   = tofloat(str_get_field(lines(1:),3," "))  ; 32 points

  wks = gsn_open_wks("png","dataonmap")  ; send graphics to PNG file

  res                             = True

  res@gsnMaximize                 = True

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

end 
