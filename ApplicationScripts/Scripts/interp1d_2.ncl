;----------------------------------------------------------------------
; interp1d_2.ncl
;
; Concepts illustrated:
;   - Calculating an interpolatory spline through a 1D set of values.
;   - Setting different tension values for ftcurv
;   - Overlaying XY plots on each other
;   - Paneling multiple XY plots on a page
;   - Adding figure strings to paneled plots
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  ni = 36             ; # of input points
  no = 60             ; # of output points
  xi = ispan(1,ni,1)  ; Input X array
  xo = fspan(1,ni,no) ; Output X array, same range as input X array

;--Open NetCDF file and read data to be interpolated
  f  = addfile ("TestData.xy3.nc" , "r")
  yi = f->T(0,0:ni-1)   ; Input Y array

;---Create smoothed array using different smoothing factors
  sigs = (/1.,5.,10.,20.,30.,40./)
  nsigs = dimsizes(sigs)

;---Apply different tension factors
  yo = new((/nsigs,no/),float)
  do i=0,nsigs-1
    ftsetp("sig",sigs(i))
    yo(i,:) = ftcurv(xi, yi, xo)
  end do


;---Start the graphics
  wks = gsn_open_wks("png","interp1d")   ; send graphics to PNG file

  res                        = True
  res@gsnMaximize            = True
  res@gsnDraw                = False
  res@gsnFrame               = False
  res@trXMinF                = floor(min((/min(xi),min(xo)/)))-1
  res@trXMaxF                =  ceil(max((/max(xi),max(xo)/)))+1
  res@trYMinF                = floor(min((/min(yi),min(yo)/)))-1
  res@trYMaxF                =  ceil(max((/max(yi),max(yo)/)))+1

  plot_base  = new(nsigs,graphic)
  plot_ovrly = new(nsigs,graphic)

  do i=0,nsigs-1
    res@xyLineThicknessF = 10.
    res@xyLineColor      = "black"
    plot_base(i)  = gsn_csm_xy(wks,xi,yi,res)

    res@xyLineThicknessF  = 4.
    res@xyLineColor       = "red"
    plot_ovrly(i) = gsn_csm_xy(wks,xo,yo(i,:),res)
    overlay(plot_base(i),plot_ovrly(i))
  end do   

  pres                                  = True
  pres@txString                         = "black line is original curve, red line is interpolated curve" 
  pres@gsnMaximize                      = True
  pres@gsnPanelFigureStrings            = "sig = " + sigs
  pres@gsnPanelFigureStringsFontHeightF = 0.01

  gsn_panel(wks,plot_base,(/3,2/),pres)
end
