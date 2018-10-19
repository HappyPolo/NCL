;*************************************************
; bar_8.ncl
;
; Concepts illustrated:
;   - Drawing filled bars using solid colors and patterns
;   - Changing the aspect ratio of a bar plot
;   - Setting the minimum/maximum value of the X and Y axis in a bar plot
;
;************************************************
;
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
  wks   = gsn_open_wks ("png", "bar" )  ; send graphics to PNG file
  res          = True             ; plot mods desired
  res@gsnScale = True               
  
; these four resources allow the user to stretch the plot size, and
; decide exactly where on the page to draw it.
  
;  res@vpXF      = 0.10            ; In page coordinates, where to start
;  res@vpYF      = 0.75            ; the plot
  res@vpHeightF = 0.43            ; Changes the aspect ratio
  res@vpWidthF  = 0.85
  res@gsnMaximize = True
  
  res@trYMinF   = -3.0            ; min value on y-axis
  res@trYMaxF   =  3.0            ; max value on y-axis
  
  res@tiYAxisString = "Anomalies" ; y-axis label      
  res@tiXAxisString = ""
  res@tiMainString  = "Darwin Southern Oscillation Index" ; title
  
  
; this resource changes a regular line plot to a bar chart
  res@gsnXYBarChart         = True ; create bar chart 
; this resource is required to get bars above and below a reference line
  res@gsnYRefLine           = 0. ; reference line  
  
; these resources control the patterns of the bars above and below
; the reference line. 
  res@gsnAboveYRefLineColor       = "red"    ; default is black    
  res@gsnBelowYRefLineColor       = "blue"   ; default is black
  res@gsnAboveYRefLineBarPatterns = (/1,3,4/) 
  res@gsnBelowYRefLineBarPatterns = (/13,14,15/) 
  plot = gsn_csm_xy (wks,dateF(::8),dsoik(::8),res)


; these resources control the patterns regardless of bar orientation. They
; are distributed sequentially.
  delete(res@gsnAboveYRefLineColor)
  delete(res@gsnBelowYRefLineColor)
  delete(res@gsnAboveYRefLineBarPatterns)
  delete(res@gsnBelowYRefLineBarPatterns)

  res@gsnXYBarChartPatterns2 = (/1,3,4,13,14,15/)
  plot = gsn_csm_xy (wks,dateF(::8),dsoik(::8),res)

end


