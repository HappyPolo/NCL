;----------------------------------------------------------------------
;  lb_21.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Drawing a labelbar on the left side of a polar map plot.
;   - Changing the land fill color
;   - Taking an average of values across January months
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

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

  wks = gsn_open_wks("png","lb")  ; send graphics to PNG file


  res                          = True
  res@gsnMaximize              = True

  res@cnFillOn                 = True
  res@cnFillPalette            = "WhiteBlue"
  res@cnLinesOn                = False

  res@lbOrientation            = "Vertical"
  res@pmLabelBarOrthogonalPosF = -1.25     ; Move labelbar to the left side of plot
  res@lbLabelPosition          = "left"    ; Move labels to left side of labelbar

  res@mpDataBaseVersion        = "MediumRes"  ; better resolution
  res@gsnPolar                 = "SH"
  res@mpMaxLatF                = -50
  res@mpLandFillColor          = "moccasin"

  res@tiMainString             = "Move labelbar to the left"
  res@tiMainFontHeightF        = 0.025

  nsub = maxind(ind(icemon&hlat.le.0))  ; Subscript location of northernmost hlat to be plotted.
  map = gsn_csm_contour_map(wks,icemon(0:nsub,:),res)
end
