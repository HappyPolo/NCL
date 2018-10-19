;*************************************************
; tdpack_1.ncl
;************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"

begin

;
;  Create the input arrays.
;
  nxi = 11
  nyi = 17

  xi = fspan(0.,1.,nxi)
  yi = fspan(0.,1.,nyi)
  zi = new((/nxi,nyi/),float)
  zi = 0.5 + 0.25 * (sin(-7.*conform(zi,xi,0)) + cos(5.*conform(zi,yi,1)))

;
;  Set up the output grid.
;
  nxo = 31
  nyo = 21
  xo = fspan(0.,1.,nxo)
  yo = fspan(0.,1.,nyo)

;
;  Interpolate.
;
  zo = ftsurf(xi,yi,zi,xo,yo)

  wks = gsn_open_wks("png","tdpack")   ; send graphics to PNG file
;
;  Draw plot.
;
  rho   = 3.
  theta = 36.
  phi   = 67.

  tdez2d(wks, xo, yo, zo, rho, theta, phi, -6)
  frame(wks)
end
