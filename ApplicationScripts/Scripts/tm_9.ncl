;============================================================
; tm_9.ncl
;============================================================
; Concepts illustrated:
;   - Setting "nice" axis labels
;   - Using a function code to display a degree symbol
;   - Explicitly setting tickmarks
;   - Using two Y axes for different units
;============================================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  ntim = 9
  time = ispan(1,9,1)
  T    = (/0.,0.71,1.,0.7,0.002,-0.71,-1.,-0.71,-0.003/)*50

  time@long_name = "time"
  T@long_name    = "Temperature"
  T@units        = "F"
;=============================================================
  wks = gsn_open_wks("png","tm")   ; send graphics to PNG file
  res = True
  res@gsnDraw = False              ; do not draw (So we can add YR labels)
  res@gsnFrame = False             ; do not advance the frame
  res@trYMinF = -60                ; in degrees F
  res@trYMaxF = 55.                ; in degrees F
  res@xyLineColor = "Blue"         ; color the line blue
  res@xyLineThicknessF = 2.0       ; double the thickness of the line
  res@tiYAxisString = "Temperature (~S~o~N~F)"   ; Y-axis title
  res@tiYAxisFontHeightF = 0.020                 ; Y-axis title font height
  plot   = gsn_csm_xy(wks,time,T,res)            ; Draw an XY plot

  getvalues plot                         ; retrieve some of the plot resources
     "tmYLValues"  : tmYLValues          ; values used by NCL at major tick marks
  end getvalues
  degC  = 0.55555555*(tmYLValues -32)    ; convert F to C

  degC2 = round(degC*(10^2),0)/10^2      ; round to 2 decimal places
  
  setvalues plot
    "tmYUseLeft" : False                 ; disassociate  YR tick marks with YL tick marks
    "tmYRLabelsOn" : True                ; turn on the YR tick mark labels
    "tmYRMode"   : "Explicit"            ; explicitly set YR tick marks
    "tmYRValues" : tmYLValues            ; YRValues = YLValues
    "tmYRLabels" : degC2                 ; use degC2 array to label tick marks
  end setvalues
  draw(plot)                             ; draw the plot
  
  txres = True                                   ; draw YR-axis title
  txres@txFontHeightF = res@tiYAxisFontHeightF   ; set the font height to the YL Axis Font Height
  txres@txAngleF = -90                           ; rotate the title -90 degrees
  gsn_text_ndc(wks,"(~S~o~N~C)",0.97,.5,txres)   ; draw the YR-axis title
  frame(wks)                                     ; advance the frame
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  res@gsnDraw = True                     ; draw plot #2 with nice Celsius labels
  res@tmYUseLeft = False                 ; disassociate  YR tick marks with YL tick marks
  res@tmYRLabelsOn = True                ; turn on the YR tick mark labels
  yr = ispan(-50,10,10)                  ; desired major YR-axis labels
  yrdegF = (yr/0.555555)+32.             ; convert yr -> Fahrenheit for tmYRValues
  yrminor = ispan(-50,20,5)              ; desired minor YR-axis tick marks
  yrmdegF = (yrminor/0.555555)+32.       ; convert yrminor -> Fahrenheit for tmYRMinorValues
  res@tmYRMode = "Explicit"              ; explicitly set YR tick marks
  res@tmYRValues = yrdegF                ; set the YR values (in F) where the major tick marks will be
  res@tmYRLabels = yr                    ; label the major YR tick marks with the yr array
  res@tmYRMinorValues = yrmdegF          ; set the YR minor tick mark locations (in F)

  plot2   = gsn_csm_xy(wks,time,T,res)   ; Draw an XY plot
  gsn_text_ndc(wks,"(~S~o~N~C)",0.9,.5,txres)
  frame(wks)
end 
