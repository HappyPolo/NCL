;================================================;
;  mptick_4.ncl
;================================================;
;
; Concepts illustrated:
;   - Setting the latitude/longitude spacing for map tickmarks
;   - Turning off minor tickmarks
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; ================================================;
begin
  wks  = gsn_open_wks("png","mptick")      ; send graphics to PNG file

  res                    = True            ; plot mods desired
  res@gsnMajorLatSpacing = 20              ; change maj lat tm spacing
  res@gsnMajorLonSpacing = 50              ; change maj lon tm spacing
  res@tmXBMinorOn        = False           ; no lon minor tickmarks

  plot = gsn_csm_map_ce(wks,res)           ; draw global map
end
