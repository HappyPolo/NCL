;****************************************************
; xy_26.ncl
;
; Concepts illustrated:
;   - Drawing an XY plot with two different Y axes
;   - Adding curves to an existing XY plot that contains two different Y axes
;   - Removing trailing zeros from tickmark labels
;   - Maximizing plots after they've been created
;
;****************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
;****************************************************
begin
;***************************
; read in data
;***************************
  f    = addfile ("TestData.xy3.nc" , "r")
  d0   = f->D(0,0:35)                 ; read in left variable
  d1   = f->D(1,0:35)

  p0   = f->P(0,0:35)                 ; read in right variable
  p1   = f->P(1,0:35)                 ; read in data for extra curve

  pmin = min((/p0,p1/))             ; Get min/max so we can set limits
  pmax = max((/p0,p1/))             ; of axes in advance.
  tmin = min((/d0,d1/))
  tmax = max((/d0,d1/))

  time = f->time(0:35)              ; this will be our X values

  wks = gsn_open_wks("png","xy")    ; send graphics to PNG file

; resources for "left" variable
  resL                  = True 

  resL@gsnMaximize      = True
  resL@vpWidthF         = 0.8            ; Change the aspect ratio, but 
  resL@vpHeightF        = 0.4            ; make plot as large as possible.

  resL@trYMinF          = tmin           ; Set min/max of left Y axis
  resL@trYMaxF          = tmax

  resL@xyLineColor      = "ForestGreen"
  resL@xyLineThicknessF = 1.5

  resL@tiYAxisFontColor = resL@xyLineColor

; resources for "right" variable
  resR                  = True                      

  resR@trYMinF          = pmin           ; Set min/max of right Y axis
  resR@trYMaxF          = pmax

  resR@xyLineColor      = "NavyBlue"
  resR@xyDashPattern    = 2              ; Dashed line for 2nd curve
  resR@xyLineThicknessF = 2.0

  resR@tiYAxisFontColor = resR@xyLineColor

  resR@tmYRFormat       = "f"            ; Remove trailing zeros from labels

  plot = gsn_csm_xy2(wks,time,d0,p0,resL,resR)

;
; Add two new lines to the XY plot, one associated with the left
; Y axis, and one with the right Y axis. Use the special attribute
; "xy2" returned from gsn_csm_xy2 for the right Y axis.
;

; New line for left axis.

  lnres                   = True
  lnres@gsLineColor       = resL@xyLineColor
  lnres@gsLineThicknessF  = resL@xyLineThicknessF

  dum0 = gsn_add_polyline(wks,plot,time,d1,lnres)

; New line for right axis, note "plot@xy2".

  lnres@gsLineColor       = resR@xyLineColor
  lnres@gsLineDashPattern = resR@xyDashPattern
  lnres@gsLineThicknessF  = resR@xyLineThicknessF

  dum1 = gsn_add_polyline(wks,plot@xy2,time,p1,lnres)

;
; Calling maximize_output is necessary, because the plot gets
; set back to the regular small size after the gsn_csm_xy2 call.
;
  psres = True
  maximize_output(wks,psres)      ; Maximize new plots in frame.

end
