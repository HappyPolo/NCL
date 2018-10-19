;----------------------------------------------------------------------
; interp1d_2.ncl
;
; Concepts illustrated:
;   - Calculating an interpolatory spline through a 1D set of values.
;   - Setting different tension values for ftcurvd
;   - Overlaying XY plots on each other
;   - Paneling multiple XY plots on a page
;   - Adding figure strings to paneled plots
;----------------------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  ni = 36             ; # of input points
  npts = 60             ; # of output points
  xi = fspan(0,ni-1,ni)  ; Input X array
  xo = fspan(0,ni-1,npts) ; Output X array, same range as input X array

;--Open NetCDF file and read data to be interpolated
  f  = addfile ("TestData.xy3.nc" , "r")
  yi = f->T(0,0:ni-1)   ; Input Y array

;---Require the derivatives at the endpoints to be zero.
;  ftsetp("sf1",0)
;  ftsetp("sl1", 0.0)
;  ftsetp("sln", 0.0)

;---Find the integrals starting from x=0.
  xl = 0.
  xr = max(xi)
  yint = new(npts, float)
  xinc = xr/(npts-1)
  yo = new(npts,float)
  xo = xinc*ispan(0,npts-1,1)
  do i = 0, npts-1
print("i = " + i + " xinc*i = " + (xinc*i))
    yint(i) = ftcurvi(xl, xo(i), xi, yi)
  end do
print(yint)

;---Start the graphics
  wks = gsn_open_wks("x11","interp1d")

  res                        = True
  res@gsnMaximize            = True
  res@gsnDraw                = False
  res@gsnFrame               = False
  res@trXMinF                = floor(min((/min(xi),min(xo)/)))-1
  res@trXMaxF                =  ceil(max((/max(xi),max(xo)/)))+1
  res@trYMinF                = floor(min((/min(yi),min(yo)/)))-1
  res@trYMaxF                =  ceil(max((/max(yi),max(yo)/)))+1

  res@xyLineThicknessF = 10.
  res@xyLineColor      = "black"
  plot_base  = gsn_csm_xy(wks,xi,yi,res)

  res@xyLineThicknessF  = 4.
  res@xyLineColor       = "red"
  plot_ovrly = gsn_csm_xy(wks,xo,yint,res)
  overlay(plot_base,plot_ovrly)
  draw(plot_base)
  frame(wks)
end
