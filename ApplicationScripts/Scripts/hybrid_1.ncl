;
; hybrid_1.ncl
;
;********************************************************
; (1) Read NCEP/NCAR Reanalysis SLP 
; (2) Use "runave" to compute seasonal [3-month] means
; (3) Use the "ind" function to select the 70s and 90s decades
; (4) Use clmMonLLT and stdMonLLT to compute the decadal
;     means and standard deviations [contributed.ncl]
; (5) Use "ttest" to compute the probabilities
; (6) Use copy_VarCoords [contributed.ncl] to copy cordinate info
; (7) Calculate the differences between the decades
; (8) plot: ZeroNegDashLineContour and ShadeLtContour
;           are in shea_util.ncl. 
;***********************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
                                  
begin
  fili    = "slpNCEP.nc"
                                      ; open the netCDF file
  f    = addfile (fili, "r")
  date = f->date
  slp  = f->SLP
                                      ; compute SEASONAL means
  slp_ts = slp(lat|:,lon|:,time|:)    ; (lat,lon,time)
  slp_ts = runave (slp_ts, 3, 0)      ; (lat,lon,time) 3-mo run ave

;********************************
; indices for special dates
;*********************************
  ind7001 = ind(date.eq.197001)       ; Jan 1970 
  ind7012 = ind(date.eq.197912)       ; Dec 1979
  ind9001 = ind(date.eq.199001)       ; Jan 1990
  ind9912 = ind(date.eq.199912)       ; Dec 1999
;********************************
; compute [2-mon] climatologies
; over specified periods
;********************************
  slpAve7079 = clmMonLLT ( slp_ts(:,:,ind7001:ind7012) )
  slpStd7079 = stdMonLLT ( slp_ts(:,:,ind7001:ind7012) )

  slpAve9099 = clmMonLLT ( slp_ts(:,:,ind9001:ind9912) )
  slpStd9099 = stdMonLLT ( slp_ts(:,:,ind9001:ind9912) )
;********************************
; compute probabilities for means difference
;******************************** 
  prob = ttest(slpAve9099, slpStd9099^2, 10 \
              ,slpAve7079, slpStd7079^2, 10 ,True, False )

  copy_VarCoords (slpAve9099, prob)
  prob@long_name = "Probability: difference between means"
                                     ; compute differences
  difAve = slpAve9099-slpAve7079 
  copy_VarCoords (slpAve9099, difAve)
  difAve@long_name = "9099-7079" 
  difAve@units     = "mb"
;********************************
; create plot
;********************************    
  nmo = 0                                ; for demo, only plot Dec-Feb
  wks   = gsn_open_wks ("ncgm", "hybrid" ) ; open workstation 
  res = True                             ; plot mods desired

  res@cnLevelSelectionMode = "ManualLevels"  ; set manual contour levels
  res@cnMinLevelValF       = -6.             ; set min contour level
  res@cnMaxLevelValF       =  6.             ; set max contour level
  res@cnLevelSpacingF      =   2.            ; set contour spacing

  res@gsnDraw              = False           ; Do not draw plot
  res@gsnFrame             = False           ; Do not advance frome

  res@tiMainString         = "SLP Difference: 9099-7079"
  res@gsnCenterString      = "5% stippled"
  res@gsnLeftString        = "DJF"

  plot = gsn_csm_contour_map_ce(wks,difAve(:,:,nmo), res)  
  plot = ZeroNegDashLineContour (plot)

  res2 = True                            ; res2 probability plots
  res2@gsnDraw             = False       ; Do not draw plot
  res2@gsnFrame            = False       ; Do not advance frome
  res2@cnLevelSelectionMode = "ManualLevels" ; set manual contour levels
  res2@cnMinLevelValF      = 0.00        ; set min contour level
  res2@cnMaxLevelValF      = 1.05        ; set max contour level
  res2@cnLevelSpacingF     = 0.05        ; set contour spacing
  res2@cnInfoLabelOn       = False
  res2@cnLinesOn           = False       ; do not draw contour lines
  res2@cnLineLabelsOn      = False       ; do not draw contour labels
  res2@cnFillScaleF        = 0.6         ; add extra density
  delete(prob@long_name)
                                         ; add cyclic point
  plot2   = gsn_csm_contour(wks,gsn_add_cyclic_point(prob(:,:,nmo)), res2) 
  plot2   = ShadeLtContour(plot2, 0.07, 17)  ; shade all areas less than the
  overlay (plot, plot2)                  ; 0.05 contour.

  draw (plot)
  frame(wks)

end
