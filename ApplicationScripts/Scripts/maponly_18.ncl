;================================================;
;  maponly_18.ncl
;================================================;
;
; Concepts illustrated:
;   - Comparing the old Mollweide projection with the new one
;   - Changing the color of the map grid lines
;   - Changing the map grid lines to dashed lines
;================================================;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;
;================================================;
;
; As of version 5.1.0 of NCL, the Mollweide projection has
; been replaced with a true Mollweide. The old one uses simpler
; math and is not considered correct. To get the old one, use
; a projection of "PseudoMollweide".
;
begin
  wks  = gsn_open_wks("png","maponly")    ; send graphics to PNG file

  res                = True               ; plot mods desired
  res@gsnMaximize    = True               ; maximize plot in frame
  res@gsnDraw        = False              ; we are going to panel later
  res@gsnFrame       = False
  
  res@mpGridAndLimbOn        = True        ; turn on lat/lon lines
  res@mpGridLineColor        = "Gray21"    ; line color
  res@mpGridAndLimbDrawOrder = "PreDraw"   ; draw lines first, so
                                           ; filled land is on top
  res@mpPerimOn              = False       ; turn off map perimeter
  res@mpOutlineOn            = True        ; turn on map outlines
  res@mpGeophysicalLineColor = "Gray21"    ; map outline color

  res@mpGridLineDashPattern = 2
  res@mpLandFillColor       = "orange"

  res@mpProjection          = "Mollweide"
  res@tiMainString          = "New Mollweide projection"

  map_new = gsn_csm_map(wks,res)

  res@mpProjection          = "PseudoMollweide"
  res@tiMainString          = "Old Mollweide projection"

  map_old = gsn_csm_map(wks,res)

  pres = True
  pres@gsnMaximize = True
  gsn_panel(wks,(/map_old,map_new/),(/2,1/),pres)

end 
  
