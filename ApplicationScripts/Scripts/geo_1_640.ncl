;======================================================================
; geo_1.ncl
;
; Concepts illustrated:
;   - Plotting geodesic data
;   - Drawing the geodesic grid and cell centers with lines and markers
;   - Plotting unstructured data
;   - Turning off the subtitles at the top of a plot
;======================================================================
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;
; This grid came to us via Dave Randall, Todd Ringler, and Ross Heikes
; of CSU. The data for this mesh were originally downloaded from:
; http://kiwi.atmos.colostate.edu/BUGS/geodesic/interpolate.html
;

;---Open file and read in data
  r2d = 57.2957795             ; radians to degrees
  f = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/hswm_d000000p000.g2.nc","r")

  ke       = f->kinetic_energy(2,:)      ; 3 x 2452  (time x cells)
  ke@lon1d = f->grid_center_lon * r2d    ; 2462 cells
  ke@lat1d = f->grid_center_lat * r2d    ;   "
  cx = f->grid_corner_lon * r2d    ; 2462 cells x 6 vertices
  cy = f->grid_corner_lat * r2d    ;   "
  printVarSummary(ke)      

  dims  = dimsizes(cx)
  ncell = dims(0)          ; 2462
  nvert = dims(1)          ; 6

  wks = gsn_open_wks("x11","geo")            ; send graphics to PNG file

  res                      = True            ; plot mods desired
  res@gsnMaximize          = True           ; largest plot possible

  res@cnFillOn             = True            ; turn on color
  res@cnFillPalette        = "gui_default"   ; set color map
  res@cnLinesOn            = False           ; turn off contour lines
  res@cnLineLabelsOn       = False           ; turn off line labels

  res@tiMainString         = "Geodesic grid contoured using~C~triangular mesh under the hood"
  res@gsnLeftString        = ""
  res@gsnRightString       = ""

  res@mpProjection         = "Orthographic"     ; choose projection
  res@mpDataBaseVersion    = "MediumRes"        ; change outline database
  res@mpCenterLatF         =  40                ; rotate globe
  res@mpCenterLonF         = -100
  res@mpPerimOn            = False              ; turn off map perimeter

;---These resources define the cell vertices
  res@sfXCellBounds        = cx
  res@sfYCellBounds        = cy

  res@lbTitleString = ke@long_name + " (" + ke@units + ")"

  map = gsn_csm_contour_map(wks,ke,res)

;
; Draw the contours again, but mostly opaque so we can
; add grid lines and markers on top of the plot.
;
  res@cnFillOpacityF       = 0.25         ; Draw contours mostly transparent
  res@gsnFrame             = False        ; Don't advance frame because we want to
  res@mpGridAndLimbOn      = False        ; Less clutter
  map = gsn_csm_contour_map(wks,ke,res)

;---Draw cell centers in brown.
  gsres                 = True
  gsres@gsMarkerColor   = "Brown"
  gsres@gsMarkerIndex   = 16     ; filled dot
  gsres@gsMarkerSizeF   = 3      ; a little smaller
  gsres@gsnCoordsAttach = True   ; attach dots, but don't draw map just yet
  gsn_coordinates(wks,map,ke,gsres)

;---Draw the hexagonal mesh that surrounds each cell center in gray.
  gsres@gsLineColor      = "Gray25"
  gsres@gsLineThicknessF = 3.0
  gsres@gsnCoordsLat = cy
  gsres@gsnCoordsLon = cx
;  do nc=0,ncell-1
;    gsn_polyline(wks,map,cx(nc,:),cy(nc,:),gsres)
;  end do
  gsn_coordinates(wks,map,(/ke/),gsres)
  draw(map)
  frame(wks)
end
