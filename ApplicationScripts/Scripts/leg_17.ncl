;*********************************************
; leg_17.ncl
;
; Concepts illustrated:
;   - Manually creating a legend using simple_legend
;*********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;*********************************************
begin
  wks = gsn_open_wks("png","leg")

  res = True
  res@gsnDraw = False
  res@gsnFrame = False
  plot = gsn_csm_xy(wks,ispan(1,10,1),fspan(1,5,10),res)  ; create xy-plot

  gres = True
  gres@YPosPercent = 5.               ; expressed as %, 0->100, sets position of bottom border of legend 
                                      ;  when gres@Position="Bottom" (Default = 95.)
  gres@XPosPercent = 30.               ; expressed as %, 0->100, sets position of left border of legend 
                                      ;  (Default = 05.)
  gres@Position = "Bottom"            ; YPosPercent setting reflects the "Top" or "Bottom" of legend 
                                      ;  (Default="Top")
  gres@ItemSpacePercent = 5.          ; expressed as %, 0->100, space between legend items (Default = 5.)
  gres@LineLabelWhiteSpacePercent = 2 ; expressed as %, 0->100, space between line and label (Default = 3.) 

  lineres = True
  lineres@lgLineColors = (/"red","blue","dodgerblue"/) ; line colors
  lineres@lgLineOpacity = (/0.3,0.5,0.5/)              ; line opacities
  lineres@lgLineThicknesses = (/1.0,4.0,12.0/)         ; line thicknesses
  lineres@lgDashIndexes = (/0,1,14/)                   ; line types
  lineres@LineLengthPercent = 5                        ; expressed as %, 0->100, length of line

  textres = True
  textres@lgLabels = (/"CCSM4 Control","b.e11.B1850C5CN.f09_g16.005","Ensemble Member #15"/) ; labels (req)
  textres@lgLabelFontHeights = (/0.015,0.018,0.025/)                           ; label font heights
  textres@lgLabelColors = (/"green","black","orange"/)                        ; label font colors
  textres@lgLabelOpacity = (/0.8,0.5,1.0/)                                     ; 0->1, label opacities

  plot = simple_legend(wks,plot,gres,lineres,textres)
  draw(plot)
  frame(wks)
end
	
