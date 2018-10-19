;----------------------------------------------------------------------
; dataonmap_10.ncl
;
; Concepts illustrated:
;   - Plotting WRF data on native grid
;   - Plotting WRF data on non-native grid
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
;----------------------------------------------------------------------

begin
  f  = addfile("wrfout_d01_2003-07-15_00_00_00.nc","r")
  q2 = f->Q2                     ; (Time, south_north, west_east )

  printVarSummary(q2)

  wks = gsn_open_wks("png" ,"dataonmap")           ; ps,pdf,x11,ncgm,eps

  res1                 = True
  res1@gsnMaximize     = True                ; maximize size

  res1@cnFillOn        = True                ; color plot desired
  res1@cnFillPalette   = "BlGrYeOrReVi200"
  res1@cnLinesOn       = False               ; turn off contour lines
  res1@cnLineLabelsOn  = False               ; turn off contour labels
  res1@cnLevelSpacingF = 0.00125

  res1@gsnAddCyclic    = False               ; turn off longitude cyclic point

  res1@lbOrientation   = "Vertical"
  res1@lbLabelFontHeightF = 0.015

  res1@tiMainString    = "WRF data on native grid"

  res1@mpDataBaseVersion = "MediumRes"

;---Set map projection based on global attributes on file
  res1 = wrf_map_resources(f, res1)

  res1@tfDoNDCOverlay  = True

  plot = gsn_csm_contour_map(wks,q2(0,:,:),res1)

  q2@lat2d = f->XLAT(0,:,:)                 ; need for map limits        
  q2@lon2d = f->XLONG(0,:,:)      

  res2                 = True
  res2@gsnMaximize     = True                ; maximize size

  res2@cnFillOn        = True                ; color plot desired
  res2@cnFillPalette   = "BlGrYeOrReVi200"
  res2@cnLinesOn       = False               ; turn off contour lines
  res2@cnLineLabelsOn  = False               ; turn off contour labels
  res2@cnLevelSpacingF = 0.00125

  res2@gsnAddCyclic    = False               ; turn off longitude cyclic point

  res2@lbOrientation   = "Vertical"
  res2@lbLabelFontHeightF = 0.015

  res2@mpMinLatF       = min(q2@lat2d)-1
  res2@mpMaxLatF       = max(q2@lat2d)+1
  res2@mpMinLonF       = min(q2@lon2d)-1
  res2@mpMaxLonF       = max(q2@lon2d)+1

  res2@tiMainString    = "WRF data on C.E. grid with margins"
  res2@pmTitleZone     = 4

  res2@mpDataBaseVersion = "MediumRes"
  res2@pmTickMarkDisplayMode = "Always"       ; nicer tickmarks

  plot = gsn_csm_contour_map(wks,q2(0,:,:),res2)

end

