;======================================================================
; geo_2.ncl
;
; Concepts illustrated:
;   - Plotting geodesic data
;   - Plotting unstructured data
;   - Drawing contours over a polar stereographic map
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

  wks = gsn_open_wks("png","geo")            ; send graphics to PNG file

  res                      = True            ; plot mods desired
;  res@gsnMaximize          = True           ; largest plot possible

  res@cnFillOn             = True            ; turn on color
  res@cnFillPalette        = "gui_default"   ; set color map
  res@cnLinesOn            = False           ; turn off contour lines
  res@cnLineLabelsOn       = False           ; turn off line labels

  res@tiMainString         = "Geodesic grid contoured using~C~triangular mesh under the hood"

  res@gsnPolar             = "NH"
  res@mpMinLatF            = 45

;---These resources define the cell centers and cell vertices
  res@sfXArray             = x
  res@sfYArray             = y
  res@sfXCellBounds        = cx
  res@sfYCellBounds        = cy

  map = gsn_csm_contour_map_polar(wks,ke,res)
end
