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

  x  = f->grid_center_lon * r2d    ; 2462 cells
  y  = f->grid_center_lat * r2d    ;   "
  cx = f->grid_corner_lon * r2d    ; 2462 cells x 6 vertices
  cy = f->grid_corner_lat * r2d    ;   "
  ke = f->kinetic_energy(2,:)      ; 3 x 2452  (time x cells)
  printVarSummary(ke)      

  dims  = dimsizes(cx)
  ncell = dims(0)          ; 2462
  nvert = dims(1)          ; 6

  wks = gsn_open_wks("png","geo")            ; send graphics to PNG file

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

;---These resources define the cell centers and cell vertices
  res@sfXArray             = x
  res@sfYArray             = y
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

;---Draw the hexagonal mesh that surrounds each cell center in gray.
  gsres                  = True
  gsres@gsLineColor      = "Gray25"
  gsres@gsLineThicknessF = 3.0
  do nc=0,ncell-1
    gsn_polyline(wks,map,cx(nc,:),cy(nc,:),gsres)
  end do

;---Draw cell centers in brown.
  gsres@gsMarkerColor = "Brown"
  gsres@gsMarkerIndex = 16        ; filled dot
  gsres@gsMarkerSizeF = 3         ; a little smaller
  gsn_polymarker(wks,map,x,y,gsres)

  frame(wks)
end
