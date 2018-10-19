;*************************************************
; mptick_10.ncl
;
; Concepts illustrated:
;   - Adding degree-minute-second labels to a cylindrical equidistant map
;   - Truncating a floating point number using "toint"
;   - Explicitly setting map tickmarks and labels
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;----------------------------------------------------------------------
; Set map resources to change map tickmark labels to be Deg Min'Sec"
;----------------------------------------------------------------------
procedure degminsec_labs(lat[*],lon[*],res)
local ilat, ilon, dlatmin, dlonmin, ilatmin, ilonmin, dlatsec, dlonsec
begin
  ilat    = toint(lat)
  ilon    = toint(lon)
  dlatmin = 60*(lat-ilat)
  dlonmin = 60*(lon-ilon)
  ilatmin = toint(dlatmin)
  ilonmin = toint(dlonmin)
  dlatsec = abs((dlatmin-ilatmin)*60)
  dlonsec = abs((dlonmin-ilonmin)*60)

  ilatmin = abs(ilatmin)
  ilonmin = abs(ilonmin)

  res@tmXBMode    = "Explicit"
  res@tmYLMode    = "Explicit"
  res@tmXBValues  = lon
  res@tmYLValues  = lat
  res@tmXBLabels  = ilon + "~S~o~N~" + ilonmin + "'" + toint(dlonsec) + \
                    str_get_dq()
  res@tmYLLabels = ilat + "~S~o~N~" + ilatmin + "'" + toint(dlatsec) + \
                    str_get_dq()

  res@tmYLLabelFontHeightF = 0.01
  res@tmXBLabelFontHeightF = 0.01

  res@tmXBMinorOn = False
  res@tmYLMinorOn = False
end

begin
;---Set some locations where we want lat/lon labels.
  nlat = 8
  nlon = 12
  lat  = fspan(-90,90,nlat)
  lon  = fspan(-180,180,nlon)

;---Start graphics
  wks = gsn_open_wks("png","mptick")   ; send graphics to PNG file

;---Map resources
  res                      = True
  res@gsnMaximize          = True
  res@tiMainString         = "Default map labels for a C.E. map"

;---Draw the map with the default labels
  map = gsn_csm_map(wks,res)

;---Set resources for special deg-min-sec labels
  degminsec_labs(lat,lon,res)

  res@tiMainString         = "Degree-minute-second labels for a C.E. map"
;---Draw the map with the new labels.
  map = gsn_csm_map(wks,res)

end

