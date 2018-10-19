;***********************************************
; interp1d_1.ncl
;
; Concepts illustrated:
;   - Calculating an interpolatory spline through a 1D set of values.
;   - Overlaying XY plots on each other
;   - Attaching text strings to a plot
;   - Drawing multiple XY plots on a page
;   - Maximizing plots after they've been created
;   - Changing the width and height of a plot
;   - Turning off the top and right borders of an XY plot
;   - Turning off the top and right tickmarks of an XY plot
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;---Specify the input data.
  xi = (/  0.00,   2.00,   5.00,   8.00,  10.00,  13.00,     \
          15.00,  18.00,  21.00,  23.00,  30.00         /)
  yi = (/  1.00,   0.81,   0.00,  -0.81,  -1.00,  -0.84,     \
          -0.56,   0.04,   0.73,   1.18,   2.0          /)

;---Create the output X coordinate array.
  npts = 201
  xr = 30.
  xo = fspan(0.,xr,npts)

;---Require the derivatives at the endpoints to be zero.
  ftsetp("sf1",0)
  ftsetp("sl1", 0.0)
  ftsetp("sln", 0.0)

;---Interpolate.
  yo = ftcurv(xi, yi, xo)

;---Find the derivatives.
  yd = ftcurvd(xi, yi, xo)

;---Find the integrals starting from x=0.
  yint = new(npts, float)
  xinc = xr/(npts-1)
  do i = 0, npts-1
    yint(i) = ftcurvi(0., xinc*i, xi, yi)
  end do

;---Open workstation to draw graphics to.
  wks = gsn_open_wks("png","interp1d")      ; send graphics to PNG file
;
;
; Draw three graphs: 
;   1.)  The function values (with markers for the input points), 
;   2.)  The derivatives,
;   3.)  The integrals (starting from X=0.).
;

;---Specify a point of origin for three graphs.
  ypos_top = 0.88

;
; Create an XyPlot object for drawing a curve with the interpolated
; points.  This is created as a child of the XWorkstation object.  
; 
  xyres                        = True

  xyres@gsnDraw                = False      ; Don't draw anything or
  xyres@gsnFrame               = False      ; advance the frame.

  xyres@gsnYRefLine            = 0.0        ; Draw a line at y = 0.0
  xyres@gsnYRefLineColor       = "red"

  xyres@vpXF                   = 0.13
  xyres@vpYF                   = ypos_top
  xyres@vpWidthF               = 0.8
  xyres@vpHeightF              = 0.2

  xyres@trYMaxF                =  2.0
  xyres@trYMinF                = -1.0
  xyres@trXMaxF                = xr
  xyres@trXMinF                =  0.0

  xyres@tmXTBorderOn           = False    ; Turn off top and right
  xyres@tmYRBorderOn           = False    ; tickmarks and labels.
  xyres@tmXTOn                 = False
  xyres@tmYROn                 = False

  xyres@tmXBMinorPerMajor      = 4
  xyres@tmYLMinorPerMajor      = 0

  xyres@tmXBLabelFontHeightF   = 0.025
  xyres@tmYLLabelFontHeightF   = 0.025

  xyres@tmYLMode               = "Manual"
  xyres@tmYLTickStartF         = -1.0
  xyres@tmYLTickSpacingF       = 1.0
  xyres@tmYLTickEndF           = 2.0

;---Create XY plot with original points.
  xy_orig   = gsn_csm_xy(wks,xo,yo,xyres)

  xyres@xyMarkLineMode         = "Markers"
  xyres@xyMarkerColor          = "blue"
  xyres@xyMarker               = 16         ; Filled dot
  xyres@xyMarkerSizeF          = 0.02

;---Create XY plot with interpolated points.
  xy_interp = gsn_csm_xy(wks,xi,yi,xyres)

;---Overlay interpolated points on original points.
  overlay(xy_orig,xy_interp)

;---Draw a main title.
  txres               = True
  txres@txJust        = "CenterCenter"
  txres@txFontHeightF = 0.04
  gsn_text_ndc(wks,"Demo for ftcurv, ftcurvd, ftcurvi",0.5,0.95,txres)

  delete(xyres@xyMarkLineMode)
  delete(xyres@xyMarkerColor)
  delete(xyres@xyMarkerSizeF)

  txres@txJust        = "CenterLeft"
  txres@txFontHeightF = 0.035

;---Attach a text string
  txid1 = gsn_add_text(wks,xy_orig,"Function",4.,1.5,txres)

;---Draw the graph of the interpolated values with the original points marked.
  draw(xy_orig)

;---Resources for derivative points.
  xyres@vpYF                   = ypos_top - 0.3
  xyres@trYMaxF                =  0.35
  xyres@trYMinF                = -0.35
  xyres@tmYLTickStartF         = -0.3
  xyres@tmYLTickSpacingF       = 0.2
  xyres@tmYLTickEndF           = 0.3

;---Create XY plot with derived points.
  xy_deriv = gsn_csm_xy(wks,xo,yd,xyres)

;---Attach a text string
  txid2 = gsn_add_text(wks,xy_deriv,"Derivative",4.,0.20,txres)

;---Draw the graph of the derivatives.
  draw(xy_deriv)

;---Resources for curve with the integrals
  xyres@vpYF                   = ypos_top - 0.6
  xyres@trYMaxF                = 10.
  xyres@trYMinF                = -6.
  xyres@tmYLTickStartF         = -6.
  xyres@tmYLTickSpacingF       = 4.
  xyres@tmYLTickEndF           = 10.

;---Create XY plot with integrals.
  xy_integ = gsn_csm_xy(wks,xo,yint,xyres)

;---Attach a text string
  txid3 = gsn_add_text(wks,xy_integ,"Integral",4.,7.,txres)

;---Draw the graph of the integrals.
  draw(xy_integ)

;
; Maximize all of this output on the frame. The plot will be
; drawn and the frame advanced.
; 
  psres = True
  maximize_output(wks,psres)

end
