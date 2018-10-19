;----------------------------------------------------------------------
; scatter_9.ncl
;
; Concepts illustrated:
;   - Drawing a scatter plot with a line through it
;   - Generating dummy data using "random_uniform"
;   - Using "lspoly" to approximate a line through a random set of points
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;----------------------------------------------------------------------
begin
;---Generate some random data
  nx     = 20
  x      = ispan(1,nx,1)
  y      = new((/2,nx/),float)
  y(0,:) = random_uniform(1.,10.,nx)

;
; Calculate a set of coefficients for a least-squares 
; polynomial fit. All weights are set to 1.
;
  c      = lspoly(x, y(0,:), 1, 4)
  y(1,:) = c(0) + c(1)*y(0,:) + c(2)*(y(0,:)^2) + c(3)*(y(0,:)^3)

;---Start the graphics.
  wks = gsn_open_wks ("png","scatter")             ; send graphics to PNG file

  res                   = True                     ; plot mods desired
  res@gsnMaximize       = True

  res@tiMainString      = "least-squares polynomial fit (lspoly)"
  res@xyMarkLineModes   = (/"Markers","Lines"/)

  res@xyMarker          =  16                  ; Change type, size, and
  res@xyMarkerSizeF     = 0.008                ; color of marker
  res@xyMarkerColor     = "purple4"

  res@xyDashPattern     = 0                    ; Change type, thickness, 
  res@xyLineThicknessF  = 3.0                  ; and color of line
  res@xyLineColor       = "purple"

  plot = gsn_csm_xy (wks, x, y, res)

end
