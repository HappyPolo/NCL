;----------------------------------------------------------------------
; dataonmap_7.ncl
;
; Concepts illustrated:
;   - Plotting data on a rectilinear grid
;   - Fixing the "units" of lat/lon coordinate arrays
;   - Turning off the addition of a longitude cyclic point
;   - Zooming in on a particular area on a map
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;----------------------------------------------------------------------

begin
  f = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/Tstorm.cdf","r") 
  t = f->t    ; 64 x 33 x 36

  printVarSummary(t)
  printVarSummary(t&lat)
  printVarSummary(t&lon)

  wks = gsn_open_wks("png","dataonmap")

  res              = True
  res@gsnMaximize  = True
  res@cnFillOn     = True
  res@cnLinesOn    = False

  res@tiMainString = "This plot is INCORRECT!"

;---Note the errors when you try to plot this data
  plot = gsn_csm_contour_map(wks,t(0,:,:),res)

;---Fix the lat/lon units, turn off cyclic point, plot again
  t&lat@units = "degrees_north"
  t&lon@units = "degrees_east"

  res@gsnAddCyclic = False
  res@tiMainString = "This plot is correct, but not zoomed in"

  plot = gsn_csm_contour_map(wks,t(0,:,:),res)

;---Zoom in on map and  plot again
  res@mpMinLatF    = min(t&lat) - 1
  res@mpMaxLatF    = max(t&lat) + 1
  res@mpMinLonF    = min(t&lon) - 1
  res@mpMaxLonF    = max(t&lon) + 1
  res@tiMainString = "Zoom in on map"

  plot = gsn_csm_contour_map(wks,t(0,:,:),res)
end
