;================================================;
;  mptick_2.ncl
;================================================;
;
; Concepts illustrated:
;   - Drawing a default cylindrical equidistant map
;   - Changing the style of the map tickmarks labels
;   - Turning on map tickmark labels with degree symbols
;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; ================================================;
begin
  wks  = gsn_open_wks("png","mptick")             ; send graphics to PNG file

  res                       = True                ; plot mods desired
  res@pmTickMarkDisplayMode = "Always"            ; turn on built-in tickmarks
  plot = gsn_csm_map_ce(wks,res)                  ; draw global map
end
