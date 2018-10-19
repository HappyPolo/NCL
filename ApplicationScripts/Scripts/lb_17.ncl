;----------------------------------------------------------------------
;  lb_17.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Using lbBoxEndCapStyle to draw triangles at the end of a labelbar
;   - Recreating a labelbar from scratch
;   - Using "setvalues" to set resource values
;   - Using "getvalues" to retrieve resource values
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;----------------------------------------------------------------------
; This shows how to use the new lbBoxEndCapStyle resource introduced
; in NCL V6.4.0 for drawing triangles at one or both ends of a 
; labebar.

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------

begin
  filen = ncargpath("data") + "/cdf/fice.nc"
  f     = addfile(filen,"r")

  fice = f->fice       ; Read fice -- ice concentration
                       ; Calculate the January (nmo=0) average.
  nmo    = 0
  icemon = dim_avg_n_Wrap(fice(nmo::12,:,:),0)
  icemon = where(icemon.eq.0., icemon@_FillValue,icemon)      ; Set 0.0 to _FillValue.
  wks = gsn_open_wks("png","lb") ; send graphics to PNG file

  res                   = True
  res@gsnMaximize       = True
  res@cnFillOn          = True
  res@cnFillPalette     = "cosam12"
  res@tiMainFontHeightF = 0.025
;
; Create a stereographic map with an elliptical boundary and change
; the center of the projection.
;
  res@mpProjection                = "Stereographic"
  res@mpEllipticalBoundary        = True
  res@mpCenterLatF                = -90.
  res@mpLimitMode                 = "Angles"
  res@mpBottomAngleF              = 40.
  res@mpLeftAngleF                = 40.
  res@mpRightAngleF               = 40.
  res@mpTopAngleF                 = 40.
  res@mpFillOn                    = False
  res@mpGeophysicalLineColor      = "gray"
  res@mpLandFillColor             = "gray"

  res@lbOrientation               = "Vertical"
  res@tiMainString                = "Default labelbar"

  nsub = maxind(ind(icemon&hlat.le.0))  ; Subscript location of northernmost hlat to be plotted.
  map = gsn_csm_contour_map(wks,icemon(0:nsub,:),res)

;---Redraw plot with labelbar w/triangular ends
  res@lbBoxEndCapStyle     = "TriangleBothEnds"
  res@tiMainString         = "Labelbar with triangular ends"
  map = gsn_csm_contour_map(wks,icemon(0:nsub,:),res)

end
