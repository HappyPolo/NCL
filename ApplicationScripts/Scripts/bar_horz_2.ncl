;*************************************************
; bar_horz_2.ncl
;
; Concepts illustrated:
;   - Drawing bars instead of curves in an XY plot
;   - Changing the aspect ratio of a bar plot
;   - Drawing filled bars left or right based on an X reference value
;   - Setting the minimum/maximum value of the X axis in a bar plot
;
;************************************************
; This example is not included in the main bar page,
; but is being included here for reference purposes.
;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
;************************************************
begin
 f = addfile ("soi.nc", "r")      ; add file

 date  = f->date                  ; YYYYMM
 dsoik = f->DSOI_KET              ; Darwin SOI Index via KET 11pt Smth
 dsoid = f->DSOI_DEC              ; Darwin Decadal SOI Index

 dimDate = dimsizes(date)         ; number of dates

; convert integer YYYYMM to float

dateF = yyyymm_to_yyyyfrac(date,0)

;*********************************
; create plot
;K********************************
 wks   = gsn_open_wks ("png", "bar_horz" )  ; send graphics to PNG file
 res   = True
 res@gsnScale = True               

; these four resources allow the user to stretch the plot size, and
; decide exactly where on the page to draw it.

; res@vpXF      = 0.3         ; In page coordinates, where to start
; res@vpYF      = 0.92        ; the plot
 res@vpHeightF = 0.85         ; Changes the aspect ratio
 res@vpWidthF  = 0.43
 res@gsnMaximize = True       ; make sure plot fits in frame

 res@trXMinF   = -3.0        ; min value on x-axis
 res@trXMaxF   =  3.0        ; max value on x-axis

 res@tiXAxisString = "Anomalies" ; x-axis label      
 res@tiXAxisFontHeightF = 0.02
 res@tiYAxisString = ""
 res@tiMainString  = "Darwin Southern Oscillation Index" ; title
 res@tiMainFontHeightF = 0.025

 res@gsnXRefLine           = 0.              ; reference line   
 res@gsnXYBarChart         = True            ; create bar chart 
 res@gsnRightXRefLineColor = "red"           ; greater than ref line fill red
 res@gsnLeftXRefLineColor  = "blue"          ; less than ref line fill blue

 res@tmXBLabelFontHeightF  = 0.02
 res@tmYLLabelFontHeightF  = 0.02

 plot = gsn_csm_xy (wks,dsoik(::8),dateF(::8),res)
end


