;----------------------------------------------------------------------
; xy_24.ncl
;
; Concepts illustrated:
;   - Filling the area between multiple curves in an XY plot
;   - Making all curves in an XY plot solid
;   - Adding custom labels to XY curves
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;----------------------------------------------------------------------
;  This example illustrates the creation of a set of 4
;  vertically-curves, with various filling 
;  curves, with various filling between the curves.
;----------------------------------------------------------------------

begin
;---Define the number of points in each curve.
  NPTS  = 500
  PI100 = 0.031415926535898

;---Create data for the four XY plots.
  x      = ispan(0,NPTS-1,1)
  y      = new((/4,NPTS/),float)
  theta  = PI100*x
  y(0,:) = sin(theta)
  y(1,:) = 2+sin(2*sqrt(fabs(theta)))   ; Make sure they
  y(2,:) = 4+sin(3*sqrt(fabs(theta)))   ; don't intersect.
  y(3,:) = 6+sin(10*sqrt(fabs(theta)))

  wks = gsn_open_wks("png","xy")   ; send graphics to PNG file

  res                   = True     ; Plot options desired
  res@gsnMaximize       = True     ; Maximize plot in frame
  res@xyMonoDashPattern = True     ; Solid lines for all curves

;
; Specify the colors to use between adjacent curves.
;
; The area b/w curves y(0,:) and y(1,:) will be filled in with red
; The area b/w curves y(1,:) and y(2,:) will be filled in with blue
; The area b/w curves y(2,:) and y(3,:) will be filled in with orange
;
  res@gsnXYFillColors = (/"red","blue","orange"/)
  res@tiMainString    = "gsnXYFillColors = red,blue,orange"

  xy = gsn_csm_xy(wks,x,y,res)    ; Draw the four curves

;
; The second plot will fill two curves differently, depending on
; where they intersect.
;
  delete(res@gsnXYFillColors)   ; Make sure this isn't set.

;---Create 6 curves.
  NPLOTS = 6
  y := new((/NPLOTS,NPTS/),float)
  do i=0,NPLOTS-1
    y(i,:) = sin((i+1)*sqrt(fabs(theta)))
  end do

;---Space the curves out a little.
  y(2,:) = 2 + y(2,:)
  y(3,:) = 2 + y(3,:)
  y(4,:) = 4 + y(4,:)
  y(5,:) = 4 + y(5,:)

;
; Specify the colors to use between adjacent curves, depending
; on where they intersect.
;
; "purple" will be used to fill all areas where curve y(1,:) > y(0,:)
; "orange" will be used to fill all areas where curve y(1,:) < y(0,:)
;
; "brown" will be used to fill all areas where curve y(3,:) > y(2,:)
; "coral" will be used to fill all areas where curve y(3,:) < y(2,:)
;
; "gray85" will be used to fill all areas where curve y(5,:) > y(4,:)
; "gray25" will be used to fill all areas where curve y(5,:) < y(4,:)
;
; Nothing will be done between curves y(1,:) & y(2,:) or
;     curves y(3,:) & y(4,:)  (hence the "transparent" setting)
;
;
  res@tiMainString      = "Using gsnXYAboveFillColors/gsnXYBelowFillColors"
  res@tiMainFontHeightF = 0.02

  above_colors = (/"purple","transparent","brown","transparent","Gray85"/)
  below_colors = (/"orange","transparent","coral","transparent","Gray25"/)

  res@gsnXYAboveFillColors = above_colors
  res@gsnXYBelowFillColors = below_colors
  res@xyLabelMode          = "Custom"           ; label a line
  res@xyExplicitLabels     = "Y" + ispan(1,NPLOTS,1)

  xy = gsn_csm_y(wks,y,res)    ; Draw the six curves

end
