;*******************************************************
; leg_11.ncl
;
; Concepts illustrated:
;   - Manually creating a legend based on XY plot settings
;   - Changing the width and height of a legend
;   - Drawing the legend on a separate page
;   - Generating dummy data for an XY plot
;   - Adding a title to a legend
;   - Changing the dash patterns of lines inside a legend
;   - Changing the markers inside a legend
;   - Changing the marker colors inside a legend
;   - Changing the font size of a legend title
;   - Turning off labels inside a legend
;
;*******************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;
; Define the number of points in each curve.
;
  NPTS  = 50
  PI100 = 0.031415926535898
;
; Create data for the four XY plots.
;
  y      = new((/4,NPTS/),float)
  theta  = PI100*ispan(0,NPTS-1,1)
  y(0,:) = sin(theta)
  y(1,:) = 2+sin(2*sqrt(fabs(theta)))   ; Make sure they
  y(2,:) = 4+sin(3*sqrt(fabs(theta)))   ; don't intersect.
  y(3,:) = 6+sin(10*sqrt(fabs(theta)))


  wks = gsn_open_wks("png","leg")       ; send graphics to PNG file

  res                        = True             ; plot mods desired
  res@gsnMaximize            = True

  res@xyMarkLineModes        = (/"MarkLines","Lines","Markers","Lines"/)
  res@xyMarkers              = (/14,-1,16,-1/)
  res@xyMarkerColors         = (/"red","white","blue","white"/)
  res@xyDashPatterns         = (/0,2,4,6/)
  res@tiMainString           = "Legend drawn on next page"

  plot = gsn_csm_y(wks,y,res)    ; Draw plot with grid, no legend yet


;***********************************************
; legend resources
;***********************************************
 labels = (/"","","",""/)                         ; don't want labels

 lgres                    = True

 lgres@vpWidthF           = 0.7                   ; width of legend (NDC)
 lgres@vpHeightF          = 0.4                   ; height of legend (NDC)

 lgres@lgTitleString      = "Legend with four items"
 lgres@lgTitleFontHeightF = 0.03
 lgres@lgAutoManage       = False                 ; Necessary to set font hgt

 lgres@lgMonoLineColor    = True
 lgres@lgLineColor        = "black"
 lgres@lgMonoItemType     = False                 ; more than one type
 lgres@lgItemTypes        = res@xyMarkLineModes   ; line/marker
 lgres@lgDashIndexes      = res@xyDashPatterns    ; dash indexes
 lgres@lgMarkerIndexes    = res@xyMarkers         ; marker indexes
 lgres@lgMarkerColors     = res@xyMarkerColors    ; marker colors
 lgres@lgLineLabelStrings = labels                ; blank labels

;
; Draw the legend, indicating the number of items, a label for each
; item, and the X, Y position of the legend in NDC coordinates.
;
 gsn_legend_ndc(wks,4,labels,0.1,0.95,lgres)

 frame(wks)                                        ; finally advance frame


end
