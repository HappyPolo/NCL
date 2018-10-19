;--------------------------------------------------
; mapgrid_4.ncl
;--------------------------------------------------
; Concepts illustrated:
;   - Drawing a lat/lon grid
;   - Drawing an orthographic map
;   - Drawing a map using the medium resolution map outlines
;   - Masking map grid lines so they only go over ocean
;   - Explicitly setting the fill colors for land, ocean, and inland water
;   - Changing the center latitude and longitude for an orthographic projection
;--------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  

begin
  wks  = gsn_open_wks ("png", "mapgrid")          ; send graphics to PNG file
  
  res                        = True               ; plot mods desired
  res@gsnMaximize            = True

  res@mpDataBaseVersion      = "MediumRes"        ; Default is LowRes

  res@mpProjection           = "Orthographic"
  res@mpCenterLonF           = 50
  res@mpCenterLatF           = 20

  res@mpGridAndLimbOn        = True               ; turn on lat/lon grid lines
  res@mpGridMaskMode         = "MaskNotOcean"     ; don't draw over land or
                                                  ; inland water bodies
  
  res@mpLandFillColor        = "tan"
  res@mpOceanFillColor       = "LightBlue"
  res@mpInlandWaterFillColor = "LightBlue"

  res@tiMainString           = "Lat/lon grid lines over ocean only"
  
;---Create and draw map
  plot = gsn_csm_map(wks,res)
  
end
