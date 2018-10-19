;================================================;
;  maponly_3.ncl
;================================================;
;
; Concepts illustrated:
;   - Changing the color of the oceans, land, and inland water areas
;
;=================================================;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
;=================================================;
begin

  wks  = gsn_open_wks("png","maponly")      ; send graphics to PNG file

  res                        = True         ; mods desired
  res@mpOceanFillColor       = "cyan"            ; array index in color map
  res@mpLandFillColor        = "sienna"          ; for land, ocean, and inland h20
  res@mpInlandWaterFillColor = "cyan"
 
  res@mpMinLonF              =   0
  res@mpMaxLonF              = 360
  res@mpCenterLonF           = 180     ; This is necessary to get the correct map
 
  plot = gsn_csm_map(wks,res)        ; draw global map

  end
