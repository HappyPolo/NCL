;----------------------------------------------------------------------
; xy_21.ncl
;
; Concepts illustrated:
;   - Drawing three Y reference lines in an XY plot
;   - Filling the areas of an XY curve above and below a reference line
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

  wks = gsn_open_wks("png","xy")  ; send graphics to PNG file

  res             = True
  res@gsnMaximize = True
  res@trXMinF     = min(x)
  res@trXMaxF     = max(x)
  res@trYMaxF     = 53.

  res@gsnYRefLineColor      = "transparent"
;  res@gsnYRefLineColor      = (/"black","transparent","black"/)

  res@gsnBelowYRefLineColor = (/ "orange", "transparent", "transparent"/)
  res@gsnAboveYRefLineColor = (/ "transparent", "transparent", "blue"/)

  res@gsnYRefLine           = (/ 20,  30, 40 /)

  res@tiMainString = "Filling above and below multiple ref lines"
  plot = gsn_csm_xy(wks,x,y,res)

end
