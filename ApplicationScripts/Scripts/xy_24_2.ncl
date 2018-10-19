;----------------------------------------------------------------------
; xy_24.ncl
;
; Concepts illustrated:
;   - Filling the area between multiple curves in an XY plot
;   - Making all curves in an XY plot solid
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;----------------------------------------------------------------------
;  This example illustrates the creation of a set of 4
;  horizontally-oriented curves, with various filling 
;  between the curves.
;----------------------------------------------------------------------

begin
;---Define the number of points in each curve.
  NPTS  = 500
  PI100 = 0.031415926535898
;
; Create data for the four XY plots.
;
  y      = ispan(0,NPTS-1,1)
  x      = new((/4,NPTS/),float)
  theta  = PI100*y
  x(0,:) = sin(theta)
  x(1,:) = 2+sin(2*sqrt(fabs(theta)))   ; Make sure they
  x(2,:) = 4+sin(3*sqrt(fabs(theta)))   ; don't intersect.
  x(3,:) = 6+sin(10*sqrt(fabs(theta)))

  wks = gsn_open_wks("x11","xy")

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
  res@gsnXYFillColors  = (/"red","blue","orange"/)
  res@tiMainString     = "gsnXYFillColors = red,blue,orange"

  xy = gsn_csm_xy(wks,x,y,res)    ; Create the four plots with fill.

;
; The second plot will fill two curves differently, depending on
; where they intersect.
;
  delete(res@gsnXYFillColors)   ; Make sure this isn't set.

;---Create 6 curves.
  x := new((/6,NPTS/),float)
  do i=0,5
    x(i,:) = sin((i+1)*sqrt(fabs(theta)))
  end do

;---Space the curves out a little.
  x(2,:) = 2 + x(2,:)
  x(3,:) = 2 + x(3,:)
  x(4,:) = 4 + x(4,:)
  x(5,:) = 4 + x(5,:)

;
; Specify the colors to use between adjacent curves, depending
; on where they intersect.
;
; "purple" will be used to fill all areas where curve x(1,:) > x(0,:)
; "orange" will be used to fill all areas where curve x(1,:) < x(0,:)
;
; "brown" will be used to fill all areas where curve x(3,:) > x(2,:)
; "coral" will be used to fill all areas where curve x(3,:) < x(2,:)
;
; "gray85" will be used to fill all areas where curve x(5,:) > x(4,:)
; "gray25" will be used to fill all areas where curve x(5,:) < x(4,:)
;
; Nothing will be done between curves x(1,:) & x(2,:) or
;     curves x(3,:) & x(4,:)  (hence the "transparent" setting)
;
;
  res@tiMainString      = "Using gsnXYRightFillColors/gsnXYLeftFillColors"
  res@tiMainFontHeightF = 0.02

  right_colors = (/"purple","transparent","brown","transparent","Gray85"/)
  left_colors = (/"orange","transparent","coral","transparent","Gray25"/)

  res@gsnXYRightFillColors = right_colors
  res@gsnXYLeftFillColors  = left_colors
  res@xyLabelMode          = "Custom"           ; label a line
  res@xyExplicitLabels     = "X" + ispan(1,6,1)

  xy = gsn_csm_xy(wks,x,y,res)    ; Create the four plots.
end
