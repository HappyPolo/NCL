;================================================;
;  maponly_5.ncl
;================================================;
;
; Concepts illustrated:
;   - Drawing a satellite map
;   - Changing the view of a satellite map
;
;=================================================;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
;=================================================;
begin

  wks  = gsn_open_wks("png","maponly")         ; send graphics to PNG file

  res                            = True
  res@mpProjection               = "Satellite" ; choose map projection
  res@mpCenterLonF               = 270.0       ; choose center lon
  res@mpCenterLatF               = 45.         ; choose center lat
  res@mpSatelliteDistF           = 3.0         ; choose satellite view

  plot = gsn_csm_map(wks,res)                  ; draw satellite proj map

  end
