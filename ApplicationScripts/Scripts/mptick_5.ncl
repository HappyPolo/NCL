;================================================;
;  mptick_5.ncl
;================================================;
;
; Concepts illustrated:
;   - Setting the latitude/longitude spacing for map tickmarks
;   - Increasing the size of tickmark labels
;   - Changing the length of tickmarks
;   - Turning on map grid lies
;
;================================================;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; ================================================;
begin
  wks  = gsn_open_wks("png","mptick")      ; send graphics to PNG file

  res                      = True          ; plot mods desired
  res@tmXBLabelFontHeightF = 0.019         ; change maj lat tm spacing
  res@tmXBMajorLengthF     = 0.02          ; change the tickmark length
  res@mpGridAndLimbOn      = True          ; default is every 15 deg
  res@mpGridSpacingF       = 30            ; change to match labels
  plot = gsn_csm_map_ce(wks,res)           ; draw global map
end
