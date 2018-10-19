;--------------------------------------------------
; mapgrid_2.ncl
;--------------------------------------------------
; Concepts illustrated:
;   - Drawing a lat/lon grid
;   - Setting the spacing for latitude/longitude grid lines
;   - Changing the map grid lines to dashed lines
;   - Using draw order resources to draw map grid lines under land
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

  res@mpGridAndLimbOn        = True
  res@pmTickMarkDisplayMode  = "Always"           ; turn on tickmarks
  
  res@mpGridLineDashPattern  = 5                  ; lat/lon lines dashed
  res@mpGridLatSpacingF      = 7.5
  res@mpGridLonSpacingF      = 45
  res@mpGridAndLimbDrawOrder = "PreDraw"          ; Draw grid first

  res@tiMainString           = "Lat spacing = " + res@mpGridLatSpacingF + \
                               ", Lon spacing = " + res@mpGridLonSpacingF
  
;---Create and draw map
  plot = gsn_csm_map(wks,res)
  
end
