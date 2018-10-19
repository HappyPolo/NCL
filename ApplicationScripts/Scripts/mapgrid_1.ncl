;--------------------------------------------------
; mapgrid_1.ncl
;--------------------------------------------------
; Concepts illustrated:
;   - Drawing a lat/lon grid on a map
;   - Changing the style of the map tickmarks labels
;--------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  

begin
  wks  = gsn_open_wks ("png", "mapgrid")          ; send graphics to PNG file
  
  res                        = True               ; plot mods desired
  res@gsnMaximize            = True

  res@mpGridAndLimbOn        = True               ; turn on grid lines
  res@pmTickMarkDisplayMode  = "Always"           ; turn on fancy tickmarks
  
  res@tiMainString           = "C.E. map with lat/lon grid lines"
  
;---Create and draw map
  plot = gsn_csm_map(wks,res)
  
end
