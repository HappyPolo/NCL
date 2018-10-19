;================================================;
;  maponly_4.ncl
;================================================;
;
; Concepts illustrated:
;   - Drawing a default polar stereographic map
;
;================================================;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
;================================================;
begin

  wks  = gsn_open_wks("png","maponly")       ; send graphics to PNG file
  plot = gsn_csm_map_polar(wks,False)        ; draw global map

  end
