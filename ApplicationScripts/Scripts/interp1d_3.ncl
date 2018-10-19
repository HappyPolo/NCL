;----------------------------------------------------------------------
; interp1d_3.ncl
;
; Concepts illustrated:
;   - Using "lspoly" to approximate a line through a set of points
;   - Overlaying XY plots on each other
;   - Changing line colors and thicknesses in an XY plot
;   - Changing marker types, sizes, colors, and thicknesses in an XY plot
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

;--Open NetCDF file and read data to be interpolated
  f  = addfile ("TestData.xy3.nc" , "r")
  ni = 36             ; # of input points
  yi = f->T(0,0:ni-1)   ; Input Y array
  xi = ispan(1,ni,1)  ; Input X array

;
; Calculate a set of coefficients for a lesat-squares 
; polynomial fit. All weights are set to 1.
;
  c  = lspoly(xi, yi, 1, 4)
  yo = c(0) + c(1)*yi + c(2)*(yi^2) + c(3)*(yi^3)

;---Start the graphics
  wks = gsn_open_wks("png","interp1d") ; send graphics to PNG file

  res                        = True
  res@gsnMaximize            = True
  res@gsnDraw                = False
  res@gsnFrame               = False
  res@trXMinF                = floor(min(xi))-1
  res@trXMaxF                =  ceil(max(xi))+1
  res@trYMinF                = floor(min((/min(yi),min(yo)/)))-1
  res@trYMaxF                =  ceil(max((/max(yi),max(yo)/)))+1 
  res@xyMarkLineMode         = "MarkLines" 
  res@xyLineThicknessF       = 4.

  res@xyMarkerSizeF      = 7.
  res@xyMarkerThicknessF = 2.
  res@xyMarker           = 4
  res@xyLineColor        = "black"
  plot_base  = gsn_csm_xy(wks,xi,yi,res)

  res@xyMarkerSizeF      = 7.
  res@xyMarkerThicknessF = 1.
  res@xyLineColor        = "red"
  res@xyMarker           = 16
  plot_ovrly = gsn_csm_xy(wks,xi,yo,res)
  overlay(plot_base,plot_ovrly)
  draw(plot_base)
  frame(wks)

end
