;*******************************************************
; leg_19.ncl
;
; Concepts illustrated:
;   - Manually creating a legend using simple_legend
;   - Reversing the order of legend items
;   - Drawing grid lines on an XY plot
;   - Paneling two plots vertically on a page
;*******************************************************
; This example is similar to leg_18.ncl, except it uses
; simple_legend (added in NCLV 6.4.0) to create the
; legend.
;*******************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;--Define the number of points in each curve.
  NPTS  = 500
  PI100 = 0.031415926535898

;---Create data for the 8 XY plots.
  y      = new((/8,NPTS/),float)
  theta  = PI100*ispan(0,NPTS-1,1)
  y(0,:) = sin(theta)
  y(1,:) = 2+sin(2*sqrt(fabs(theta)))   ; Make sure they
  y(2,:) = 4+sin(3*sqrt(fabs(theta)))   ; don't intersect.
  y(3,:) = 6+sin(10*sqrt(fabs(theta)))

  y(4,:) = cos(theta)
  y(5,:) = 3+cos(4*sqrt(fabs(theta)))
  y(6,:) = 5+cos(5*sqrt(fabs(theta)))
  y(7,:) = 7+cos(8*sqrt(fabs(theta)))

  wks = gsn_open_wks("png","leg")            ; send graphics to PNG file

  res                        = True 
  res@gsnDraw                = False         ; turn off so we can 
  res@gsnFrame               = False         ; add a legend later

  res@trYMinF                = min(y)-2      ; leave space at bottom for legend
  res@trYMaxF                = max(y)+1

  res@xyLineThicknessF       = 5.0
  res@xyDashPattern          = 0             ; make all curves solid
  res@tmXMajorGrid           = True          ; turn on vertical grid lines
  res@tmYMajorGrid           = True          ; turn on horizontal grid lines
  res@tmXMajorGridLineColor  = "Gray"
  res@tmYMajorGridLineColor  = "Gray"
  res@tmGridDrawOrder        = "PreDraw"     ; XY curves will be drawn on top of grid lines

;---Create two XY plots each with a unique set of colors for their curves
  res1 = res
  res2 = res
  res1@xyLineColors = (/"DodgerBlue",     "ForestGreen","Violet","Firebrick"/)
  res2@xyLineColors = (/"LightGoldenRod4","NavyBlue",   "Red",   "Orange"/)
  plot1 = gsn_csm_y(wks,y(:3,:),res1)
  plot2 = gsn_csm_y(wks,y(4:,:),res2)

;----------------------------------------------------------------------
; Code for customizing a legend via simple_legend.
;----------------------------------------------------------------------

;---Create three resource lists required for simple_legend
  gres     = True     ; legend position
  lineres  = True     ; legend lines
  textres  = True     ; legend labels

  gres@Position             = "Bottom"
  gres@YPosPercent          =  5.      ; from the bottom
  gres@XPosPercent          = 78.      ; move to the right side
  lineres@lgLineThicknesses = 5.0      ; line thicknesses
  lineres@LineLengthPercent = 9.       ; expressed as %, 0->100, length of line

;---Attach legend to first plot
  textres@lgLabels     = (/"a","b","c","d"/)
  lineres@lgLineColors = res1@xyLineColors
  plot1 = simple_legend(wks,plot1,gres,lineres,textres)

;---Attach legend to second plot, reversing them
  textres@lgLabels     = (/"z","y","x","w"/)
  lineres@lgLineColors = res2@xyLineColors(::-1)
  plot2 = simple_legend(wks,plot2,gres,lineres,textres)

;---Panel both plots
  pres             = True
  pres@gsnMaximize = True
  pres@gsnPanelMainString  = "Legends added with simple_legend; right legend is reversed"
  gsn_panel(wks,(/plot1,plot2/),(/1,2/),pres)
end
