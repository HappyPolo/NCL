;*****************************************************
; xy_22.ncl
;
; Concepts illustrated:
;   - Moving the left Y axis in an XY plot
;
;*****************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;*****************************************************
begin
; Create variables to contain data.
;
  ncurve = 3
  npts = 129

;
; Read ASCII file xy.asc
;
  x1_y3 = asciiread(ncargpath("data")+"/asc/xy.asc",4*129,"float")
;
;  xy.asc has 4 vars of length 129 longitudes, lon, u, v, t
;
;     The data is taken at 43N latitude.  Longitude is an index
;     1-129 standing for 0 deg - 360 deg in steps of 360/128?
;     u and v are in m/s, and t is in deg K.
;

  lon = (x1_y3(0:512:4) -1.) * 360./128.
;  t   = (x1_y3(3:515:4) - 273.15) * 9./5. * 32.
  v   = x1_y3(2:514:4)

  wks = gsn_open_wks("png","xy") ; send graphics to PNG file

  res             = True

  res@gsnFrame    = False        ; Don't advance frame.

;
; Turn off all axes except for the bottom one.
;
  res@tmYLOn       = False
  res@tmYLBorderOn = False
  res@tmYLLabelsOn = False

  res@tmXTOn       = False
  res@tmXTBorderOn = False
  res@tmXTLabelsOn = False

  res@tmYROn       = False
  res@tmYRBorderOn = False
  res@tmYRLabelsOn = False

  res@trXMaxF     = max(lon)    ; Control end of X axis

  res@tiMainString  = "Left axis shifted"
  res@tiXAxisString = "x"       ; Put label on X axis

  res@vpXF     = 0.18               ; Control X position of first plot.
  res@vpYF     = 0.85
  res@vpWidthF = 0.75

  plot = gsn_csm_xy(wks,lon,v,res)   ; Draw plot.

  delete(res@tiMainString)      ; Make sure main string and X label
  delete(res@tiXAxisString)     ; get drawn again

  res@vpXF = 0.15               ; X position of second plot is to the
                                ; left of first plot.

  res@xyLineColor = "white"     ; Make sure you can't see the curve on
                                ; the second plot.
  
  res@tiYAxisString = "v"       ; Add a Y label.

  res@tmXBOn       = False      ; Turn off X axis since it has already
  res@tmXBBorderOn = False      ; been drawn.
  res@tmXBLabelsOn = False

  res@tmYLOn       = True       ; Turn on left Y axis.
  res@tmYLBorderOn = True
  res@tmYLLabelsOn = True

  plot = gsn_csm_xy(wks,lon,v,res)   ; Draw plot. The only thing that
                                     ; will get drawn is the Y axis.

  frame(wks)
end
