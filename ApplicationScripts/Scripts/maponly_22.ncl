;================================================
;  maponly_22.ncl
;================================================
;
; Concepts illustrated:
;   - Drawing specific country boundaries
;   - Filling specific country boundaries
;   - Changing the view of an orthographic map
;   - Changing the center latitude and longitude for an orthographic projection
;   - Zooming in on Africa on a orthographic map
;
;================================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  wks = gsn_open_wks("png","maponly")        ; send graphics to PNG file
  gsn_define_colormap(wks,"uniform")

;
; Set up arrays to contain names of countries in Africa that we
; want to either outline or fill.
;
  fill_areas =  (/"Mali", "Egypt", "Ethiopia", "Tanzania", "Namibia", \
                  "Zaire", "Morocco", "Water", "Land"/)
  fill_colors = (/46,68,50,138,161,87,83,3,76/)

  outline_areas =  (/"Burundi","Botswana","Congo","Gabon","Ghana","Niger","Rwanda","Sudan","Zaire"/)

  mpres                      = True          ; Plot options desired.

  mpres@gsnMaximize          = True

  mpres@mpProjection         = "Orthographic"
  mpres@mpEllipticalBoundary = True
  mpres@mpCenterLatF         = 20.0
  mpres@mpCenterLonF         = 14.0

  mpres@mpLimitMode          = "LatLon"
  mpres@mpMinLatF            = -40
  mpres@mpMaxLatF            =  42
  mpres@mpMinLonF            = -20
  mpres@mpMaxLonF            =  60

  mpres@mpFillOn              = True
  mpres@mpFillAreaSpecifiers  = fill_areas
  mpres@mpSpecifiedFillColors = fill_colors

  mpres@mpOutlineOn           = True
  mpres@mpOutlineSpecifiers   = outline_areas

  mpres@tiMainString          = "Some countries in Africa"    ; Main title

  map = gsn_csm_map(wks,mpres)              ; Draw plot

end
