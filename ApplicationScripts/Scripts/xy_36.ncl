;----------------------------------------------------------------------
; xy_36.ncl
;
; Concepts illustrated:
;   - Drawing multiple X reference lines in an XY plot
;   - Setting the colors, thicknesses, and dash patterns of X reference lines
;----------------------------------------------------------------------
; Note: you can swap the x and y arrays, and use gsnYRefLineXXXX
; resources for horizontal reference lines.
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  NPTS = 101
  y = fspan(0.,100.,NPTS)
  x = new((/4,NPTS/),float)

  x(0,:) = sin(3.14159*(y+.5)/50.)
  x(1,:) = 3+cos(3.14159*y/50.)
  x(2,:) = 6+sin(3.14159*y/50.)
  x(3,:) = 9+cos(3.14159*(y-.5)/50.)

  wks = gsn_open_wks("png","xy")

  res                   = True
  res@gsnMaximize       = True
  res@xyMonoDashPattern = True                 ; make all curves solid
  res@xyLineThicknessF  = 5.0
  res@gsnXRefLine       = (/0.,3.,6.,9./)      ; four X reference lines

; res@gsnXYBarChart = True    ; uncomment this for bars instead of curves

;---Multiple thicknesses
  res@gsnXRefLineThicknesses = (/3.,5.,7.,10/)
  res@tiMainString = "multiple ref line thicknesses"
  plot = gsn_csm_xy(wks,x,y,res)

;---Multiple colors
  res@gsnXRefLineColors = (/"blue","sienna","forestgreen","hotpink"/)
  res@tiMainString = "multiple ref line colors"
  plot = gsn_csm_xy(wks,x,y,res)

;---Multiple dash patterns
  res@gsnXRefLineDashPatterns = (/2,8,12,14/)
  res@tiMainString = "multiple ref line dash patterns"
  plot = gsn_csm_xy(wks,x,y,res)

end
