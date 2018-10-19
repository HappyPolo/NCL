;----------------------------------------------------------------------
; xy_vert_21.ncl
;
; Concepts illustrated:
;   - Drawing three X reference lines in an XY plot
;   - Filling the areas of an XY curve to the right and left of a reference line
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;----------------------------------------------------------------------
begin
;
; Read ASCII file xy.asc. It has four variables of length 129. 
; We're only interested in two of them.
;
  xy = asciiread(ncargpath("data")+"/asc/xy.asc",4*129,"float")
  x  = (xy(0:512:4) -1.) * 360./128.
  y  = xy(1:513:4)

  wks = gsn_open_wks("png","xy_vert")  ; send graphics to PNG file

  res             = True
  res@gsnMaximize = True
  res@trYMinF     = min(x)
  res@trYMaxF     = max(x)
  res@trXMaxF     = 53.

  res@gsnXRefLineColor      = "transparent"
; res@gsnXRefLineColor      = (/"black","transparent","black"/)

  res@gsnLeftXRefLineColor  = (/ "orange", "transparent", "transparent"/)
  res@gsnRightXRefLineColor = (/ "transparent", "transparent", "blue"/)
  res@gsnXRefLine           = (/ 20,  30, 40 /)

  res@tiMainString = "Filling to the right and left of multiple ref lines"
  plot = gsn_csm_xy(wks,y,x,res)

end
