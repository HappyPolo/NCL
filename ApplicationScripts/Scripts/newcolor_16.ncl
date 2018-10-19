;----------------------------------------------------------------------
; newcolor_16.ncl
;
; Concepts illustrated:
;   - Filling the area between three curves in an XY plot
;   - Using opacity to emphasize or subdue overlain features
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;----------------------------------------------------------------------
; If you have NCL V6.1.2 or earlier, then you need to download the 
; "fill_opacities_fix.ncl" script from:
;
;   http://www.ncl.ucar.edu/Applications/Scripts/fill_opacities_fix.ncl
;
; and uncomment the next line:
;
; load "./fill_opacities_fix.ncl"
;----------------------------------------------------------------------

begin
  NPTS  = 500
  PI100 = 0.031415926535898
;
; Create data for the four XY plots.
;
  x     = ispan(0,NPTS-1,1)
  y     = new((/4,NPTS/),float)
  theta = PI100*x
  y(0,:) = sin(theta)
  y(1,:) = cos(theta)-1
  y(2,:) = sin(theta)-2
  y(3,:) = cos(theta)-3

;---Move the curves up or down in order to get them to intersect.

  wks = gsn_open_wks("png","newcolor") ; send graphics to PNG file

  res                   = True     ; Plot options desired

  res@vpWidthF          = 0.8 
  res@vpHeightF         = 0.4
  res@gsnMaximize       = True     ; Maximize plot in frame
  res@xyMonoDashPattern = True     ; Solid lines for all curves

  res@gsnXYFillColors = (/"red","blue","purple"/)

  res@tiMainString      = "Full opacity: purple on top of blue on top of red"
  res@tiMainFontHeightF = 0.025
  res@gsnXYFillOpacities = (/1.0,1.0,1.0/)

  xy = gsn_csm_xy(wks,x,y,res)    ; Create the four plots with fill.

  res@tiMainString       = "res@gsnXYFillOpacities = (/0.5,0.5,0.5/)"
  res@gsnXYFillOpacities = (/0.5,0.5,0.5/)
  xy = gsn_csm_xy(wks,x,y,res)    ; Create the four plots with fill.

end
