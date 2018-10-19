;----------------------------------------------------------------------
; dataonmap_1.ncl
;
; Concepts illustrated:
;   - Plotting contours on a rectilinear grid
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
  wks = gsn_open_wks("png","dataonmap")

  res              = True
  res@gsnMaximize  = True     ; maximize plot in frame
  res@cnFillOn     = True     ; turn on contour fill
  res@cnLinesOn    = False    ; turn off contour fill
  res@tiMainString = "Plotting rectilinear data"

  plot = gsn_csm_contour_map(wks,u,res)

  res@mpProjection = "Robinson"
  plot = gsn_csm_contour_map(wks,u,res)

end
