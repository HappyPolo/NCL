;----------------------------------------------------------------------
; dataonmap_grid_1.ncl
;
; Concepts illustrated:
;   - Plotting contours on a rectilinear grid
;   - Drawing a variable's lat/lon grid using gsn_coordinates
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;----------------------------------------------------------------------

begin
  filename = "$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc"
  a = addfile(filename,"r")    ; open file
  u = a->U(0,:,:)              ; read data (64 x 128)
  printVarSummary(u)           ; print info about variable

;---Plot data
  wks = gsn_open_wks("png","dataonmap_grid")

  res              = True
  res@gsnDraw      = False    ; Don't draw plot or 
  res@gsnFrame     = False    ; advance frame
  res@gsnMaximize  = True     ; maximize plot in frame
  res@cnFillOn     = True     ; turn on contour fill
  res@cnLinesOn    = False    ; turn off contour fill
  res@tiMainString = "Lat/lon grid for rectilinear variable"

  plot = gsn_csm_contour_map(wks,u,res)

;---Draw the lat/lon locations as grid lines
  lnres = True
  lnres@gsnCoordsAsLines = True
  gsn_coordinates(wks,plot,u,lnres)

end
