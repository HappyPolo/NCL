;**************************************
;  adapt_1.ncl
;
; Concepts illustrated:
;   - Drawing contours of data on an adaptive grid
;   - Drawing contours of data on non-uniform grids
;   - Using triangular meshes to create contours
;   - Explicitly specifying lat/lon locations of data to be contoured
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;********************************************
; read in data
;********************************************
  f = addfile("fvgcm_amr.delp.000240.000.nc","r")
  H = f->H     ; one dimensional
;********************************************
; create plot
;********************************************
  wks = gsn_open_wks("png","adapt")           ; send graphics to PNG file

  res                       = True            ; plot mods desired
  res@gsnMaximize           = True            ; largest plot possible

  res@cnFillOn              = True            ; turn on color
  res@cnLinesOn             = False           ; no contour lines
  res@cnLineLabelsOn        = False           ; no line labels
  res@cnFillPalette         = "BlAqGrYeOrReVi200" ; set color map
;  res@cnVerboseTriangleInfo = True           ; prints out triangular mesh info


  res@tiMainString          = "Adaptive grid using triangular mesh conversion"

; these two resources are required to "enable" the triangular mesh function 
; when the input data is one-demensional
  res@sfXArray              = f->lon          ; assign lat/lon
  res@sfYArray              = f->lat

  map = gsn_csm_contour_map_ce(wks,H,res)
end
