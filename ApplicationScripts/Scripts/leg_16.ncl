;*********************************************
; leg_16.ncl
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
  gres@YPosPercent = 95.    ; expressed as %, 0->100, sets position of top border of legend 
                            ;  when gres@Position is set to its default setting of "Top" (Default = 95.)
  gres@XPosPercent = 5      ; expressed as %, 0->100, sets position of left border of legend(Default = 5.)

  lineres = True
  lineres@lgLineColors = (/"red","orange","dodgerblue"/) ; line colors
  lineres@lgLineThicknesses = 2.5                        ; line thicknesses
  lineres@LineLengthPercent = 9.                         ; expressed as %, 0->100, length of line

  textres = True
  textres@lgLabels = (/"CESM1 50","CESM1 52","CESM1 55"/)  ; legend labels (required)

  plot = simple_legend(wks,plot,gres,lineres,textres)
  draw(plot)
  frame(wks)
end
	
