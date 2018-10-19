;*************************************************
; bar_horz_8.ncl
;
; Concepts illustrated:
;   - Drawing filled bars using solid colors and patterns
;   - Changing the aspect ratio of a bar plot
;   - Setting the minimum/maximum value of the X and Y axis in a bar plot
;
;************************************************
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
;********************************
  wks   = gsn_open_wks ("png", "bar_horz" )  ; send graphics to PNG file
  res          = True             ; plot mods desired
  res@gsnScale = True               
  
; these four resources allow the user to stretch the plot size, and
; decide exactly where on the page to draw it.
  
;  res@vpXF      = 0.10            ; In page coordinates, where to start
;  res@vpYF      = 0.75            ; the plot
  res@vpHeightF = 0.85            ; Changes the aspect ratio
  res@vpWidthF  = 0.43
  res@gsnMaximize = True
  
  res@trXMinF   = -3.0            ; min value on x-axis
  res@trXMaxF   =  3.0            ; max value on x-axis
  
  res@tiXAxisString = "Anomalies" ; x-axis label
  res@tiXAxisFontHeightF = 0.02      
  res@tiYAxisString = ""
  res@tiMainString  = "Darwin Southern Oscillation Index" ; title
  res@tiMainFontHeightF  = 0.025
  
  
; this resource changes a regular line plot to a bar chart
  res@gsnXYBarChart         = True ; create bar chart 
; this resource is required to get bars above and below a reference line
  res@gsnXRefLine           = 0. ; reference line  
  
; these resources control the patterns of the bars above and below
; the reference line. 
  res@gsnRightXRefLineColor       = "red"    ; default is black    
  res@gsnLeftXRefLineColor        = "blue"   ; default is black
  res@gsnRightXRefLineBarPatterns = (/2,3,4/) 
  res@gsnLeftXRefLineBarPatterns  = (/13,14,15/) 
  plot = gsn_csm_xy (wks,dsoik(::8),dateF(::8),res)


; these resources control the patterns regardless of bar orientation. They
; are distributed sequentially.
  delete(res@gsnRightXRefLineColor)
  delete(res@gsnLeftXRefLineColor)
  delete(res@gsnRightXRefLineBarPatterns)
  delete(res@gsnLeftXRefLineBarPatterns)

  res@gsnXYBarChartPatterns2 = (/2,3,4,13,14,15/)
  plot = gsn_csm_xy (wks,dsoik(::8),dateF(::8),res)

end


