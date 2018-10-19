;**********************************************************
; conOncon_4.ncl
;
; Concepts illustrated:
;   - Overlaying stippled contours on solid line contours
;   - Filling contours with stippling (solid dots)
;   - Adding shading below a specified contour level
;   - Drawing the zero contour line thicker
;   - Drawing negative contour lines as dashed lines
;   - Changing the density of a contour fill pattern
;   - Reading differences and probabilities
;   - Drawing a base plot of differences
;   - Overlaying a stippling pattern for the 5% significance level
;
;***************************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
                            
begin
  fili    = "slpDiffProb"
                                      
  f    = addfile (fili+".nc", "r")            ; open the netCDF file
  diff = f->DIFF
  prob = f->PROB
; ========================= PLOT 1 ==============================
  wks   = gsn_open_wks ("png", "conOncon" )  ; send graphics to PNG file 

  res = True                                 ; plot mods desired

  res@cnLevelSelectionMode = "ManualLevels"  ; set manual contour levels
  res@cnMinLevelValF       = -6.             ; set min contour level
  res@cnMaxLevelValF       =  6.             ; set max contour level
  res@cnLevelSpacingF      =   2.            ; set contour spacing

  res@gsnDraw              = False           ; Do not draw plot
  res@gsnFrame             = False           ; Do not advance frome

  res@tiMainString         = "SLP Difference: 9099-7079"
  res@gsnCenterString      = "5% stippled"
  res@gsnLeftString        = "DJF"

  plot = gsn_csm_contour_map_ce(wks,diff(:,:,0), res)  
  plot = ZeroNegDashLineContour (plot)

; ========================= PLOT 2 ==============================
  res2 = True                            ; res2 probability plots

  res2@gsnDraw             = False       ; Do not draw plot
  res2@gsnFrame            = False       ; Do not advance frome

  res2@cnLevelSelectionMode = "ManualLevels" ; set manual contour levels
  res2@cnMinLevelValF      = 0.00        ; set min contour level
  res2@cnMaxLevelValF      = 1.05        ; set max contour level
  res2@cnLevelSpacingF     = 0.05        ; set contour spacing

  res2@cnInfoLabelOn       = False       ; turn off info label

  res2@cnLinesOn           = False       ; do not draw contour lines
  res2@cnLineLabelsOn      = False       ; do not draw contour labels

  res2@cnFillScaleF        = 0.6         ; add extra density
  delete(prob@long_name)

  plot2   = gsn_csm_contour(wks,gsn_add_cyclic_point(prob(:,:,0)), res2)
  opt     = True
  opt@gsnShadeFillType = "pattern"
  opt@gsnShadeLow = 17 
  plot2   = gsn_contour_shade(plot2, 0.05, 30, opt)  ; shade all areas less than the
                                             ; 0.05 contour level
  overlay (plot, plot2)

  draw (plot)
  frame(wks)

end
