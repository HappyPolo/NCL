;****************************************************
; xy_25.ncl
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
  t0   = f->T(0,0:35)                 ; read in left variable
  t1   = f->T(2,0:35)
  p0   = f->P(0,0:35)                 ; read in right variable
  p1   = f->P(1,0:35)                 ; read in data for extra curve

  pmin = min((/p0,p1/))             ; Get min/max so we can set limits
  pmax = max((/p0,p1/))             ; of axes in advance.
  tmin = min((/t0,t1/))
  tmax = max((/t0,t1/))

  time = f->time(0:35)              ; this is our x

  wks = gsn_open_wks("png","xy")    ; send graphics to PNG file

; resources for "left" variable
  resL                  = True 

  resL@gsnMaximize      = True
  resL@vpWidthF         = 0.8            ; Change the aspect ratio, but 
  resL@vpHeightF        = 0.4            ; make plot as large as possible.

  resL@trYMinF          = tmin           ; Set min/max of left Y axis
  resL@trYMaxF          = tmax

  resL@xyLineColor      = "Brown"
  resL@xyLineThicknessF = 2.5

  resL@tiYAxisFontColor = resL@xyLineColor

; resources for "right" variable
  resR                  = True                      

  resR@trYMinF          = pmin           ; Set min/max of right Y axis
  resR@trYMaxF          = pmax

  resR@xyLineColor      = "NavyBlue"
  resR@xyDashPattern    = 2              ; Dashed line for 2nd curve
  resR@xyLineThicknessF = 2.5

  resR@tiYAxisFontColor = resR@xyLineColor

  resR@tmYRFormat       = "f"            ; Remove trailing zeros from labels

  plot = gsn_csm_xy2(wks,time,t0,p0,resL,resR)

;
; Create data object to add new curve to right axis.
;
  dataid = create "xyData" coordArraysClass defaultapp
    "caYArray": p1
    "caXArray": time
  end create
;
; Add new data object plot represented by right axis.
;
; Use the attribute "xy2" returned from gsn_csm_xy2.
;
  dataspec = NhlAddData(plot@xy2,"xyCoordData",dataid)

; Set some resources for new curve.
  setvalues dataspec
    "xyLineColor"      : resR@xyLineColor
    "xyLineThicknessF" : resR@xyLineThicknessF
    "xyDashPattern"    : 7         ; use different dashed line
  end setvalues
 
;
; The maximize_output call draws everything on the workstation,
; so the XY plot with the new line added to it will get drawn
; here.
;
  psres = True
  maximize_output(wks,psres)      ; Maximize new plots in frame.

end
