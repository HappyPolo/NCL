;================================================
;  lb_12.ncl
;================================================
; Concepts illustrated:
;   - Adding gray to an existing color map
;   - Reordering an array
;   - Setting all zero values in an array to missing
;   - Zooming in on a particular area on a polar stereographic map
;   - Drawing color-filled contours over a polar stereographic map
;   - Making the labelbar be vertical
;   - Changing the color of map outlines
;   - Turning on end labels in labelbar for a contour plot
;   - Removing the end boxes in a labelbar
;   - Turning off map fill
;================================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  filen = ncargpath("data") + "/cdf/fice.nc"
  f     = addfile(filen,"r")

  fice = f->fice       ; Read fice -- ice concentration
                       ; Calculate the January (nmo=0) average.
  nmo    = 0
  icemon = dim_avg_n_Wrap(fice(nmo::12,:,:),0)
  icemon = where(icemon.eq.0., icemon@_FillValue,icemon)      ; Set 0.0 to _FillValue.

  nsub = maxind(ind(icemon&hlat.le.0))  ; Subscript location of northernmost hlat to be plotted.

  wks = gsn_open_wks("png","lb") ; send graphics to PNG file

  res                   = True
  res@gsnMaximize       = True
  res@cnFillOn          = True
  res@cnFillPalette     = "cosam12"
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

  res@tiMainFontHeightF           = 0.025

; Labels on inner box lines only.
  res@cnLabelBarEndStyle = "IncludeOuterBoxes"    ; The default
  res@tiMainString = "cnLabelBarEndStyle='" + res@cnLabelBarEndStyle + "'"
  map = gsn_csm_contour_map(wks,icemon(0:nsub,:),res)
                            
; Label outer edges with min/max values.
  res@cnLabelBarEndStyle = "IncludeMinMaxLabels"
  res@tiMainString = "cnLabelBarEndStyle='" + res@cnLabelBarEndStyle + "'"
  map = gsn_csm_contour_map(wks,icemon(0:nsub,:),res)

; Remove outer boxes.
  res@cnLabelBarEndStyle = "ExcludeOuterBoxes"
  res@tiMainString = "cnLabelBarEndStyle='" + res@cnLabelBarEndStyle + "'"
  map = gsn_csm_contour_map(wks,icemon(0:nsub,:),res)

end
