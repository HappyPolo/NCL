;*******************************************************
; leg_15.ncl
;
; Concepts illustrated:
;   - Drawing a legend inside an XY plot
;   - Masking the XY curves behind a legend
;   - Drawing a legend on top of everything in an XY plot
;   - Changing the width and height of a legend
;   - Changing the legend box fill color
;   - Changing the line color for multiple curves in an XY plot
;   - Adding labels to curves in an XY plot
;   - Attaching a plot as an annotation of another plot
;   - Paneling two plots vertically on a page
;   - Using "getvalues" to retrieve the size of a plot
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

  wks = gsn_open_wks("png","leg")               ; send graphics to PNG file

  res                        = True             ; plot mods desired
; res@gsnMaximize            = True             ; Not necessary
  res@gsnDraw                = False
  res@gsnFrame               = False

  res@pmLegendDisplayMode    = "Always"         ; Turn on a legend

  res@pmLegendOrthogonalPosF = -0.22            ; Move legend inside plot
  res@pmLegendParallelPosF   = 0.95             ; Move legend to right
  res@pmLegendWidthF         = 0.13             ; Change width and height
  res@pmLegendHeightF        = 0.1

  res@xyLabelMode            = "Custom"
  res@xyLineThicknessF       = 3.0
  res@xyExplicitLabels       = (/"w","x","y","z"/)  ; explicit labels
  res@xyLineLabelFontHeightF = 0.015                ; font height

  res@lgPerimFill            = "SolidFill"      ; Fill legend box w/white
  res@lgPerimFillColor       = "white"          ; so it masks XY curves
  res@lgPerimFillColor       = "yellow"
;
; To get the legend to draw on top of tickmarks, we have to draw the 
; plot first with the tickmarks and no legend, and then draw
; the plot again with no tickmarks but the legend turned on.
;
  res@pmLegendDisplayMode    = "Never"     ; Turn off legend for first plot

;---Create plots with tickmarks, but no legend
  res@xyLineColors = (/"DodgerBlue","ForestGreen","Violet","Firebrick"/)
  plot1 = gsn_csm_y(wks,y(:3,:),res)

  plot3 = gsn_csm_y(wks,y(4:,:),res)

;---Make sure both plots are in same location in viewport
  getvalues plot1
    "vpXF"      : vpx
    "vpYF"      : vpy
    "vpWidthF"  : vpw
    "vpHeightF" : vph
  end getvalues
  
  res@vpXF                   =  vpx
  res@vpYF                   =  vpy
  res@vpWidthF               =  vpw
  res@vpHeightF              =  vph

;---Turn off tickmarks so they don't cover legend.
  res@tmXBOn                 = False
  res@tmYROn                 = False
  res@tmXBBorderOn           = False
  res@tmYRBorderOn           = False

  res@pmLegendDisplayMode    = "Always"    ; Turn legend back on for 2nd plot

  res@xyLineColors = (/"NavyBlue","ForestGreen","Violet","Firebrick"/)
  plot2 = gsn_csm_y(wks,y(:3,:),res)    ; Create plot again without tickmarks

  res@xyLineColors = (/"Green","SkyBlue","Red","Orange"/)
  plot4 = gsn_csm_y(wks,y(4:,:),res)
;
; Add plot2/plot4 on top of plot1/plot4. This is so we can panel
; them later.
;
  annoid1 = gsn_add_annotation(plot1,plot2,True)
  annoid2 = gsn_add_annotation(plot3,plot4,True)

;---Paneling
  pres             = True
  pres@gsnMaximize = True
  pres@txString    = "Legend drawn on top of tickmarks"
  gsn_panel(wks,(/plot1,plot3/),(/1,2/),pres)
end
