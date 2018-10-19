;*************************************************
; bar_horz_6.ncl
;
; Concepts illustrated:
;   - Drawing bars instead of curves in an XY plot
;   - Changing the fill colors in a bar plot
;   - Drawing filled bars left or right based on an X reference value
;   - Changing the aspect ratio of a bar plot
;   - Setting the minimum/maximum value of the X axis in a bar plot
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
  wks   = gsn_open_wks ("png", "bar_horz" ) ; send graphics to PNG file
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
  res@tiMainString  = "colors chosen for above and below"
  res@tiMainFontHeightF  = 0.025
  
  
; this resource changes a regular line plot to a bar chart
  res@gsnXYBarChart         = True ; create bar chart 
; this resource is required to get bars above and below a reference line
  res@gsnXRefLine           = 0. ; reference line  
  
; these two resources control the colors of the bars above and below
; the reference line.   
  res@gsnRightXRefLineBarColors = (/"orange","red","black"/) 
  res@gsnLeftXRefLineBarColors  = (/"blue","brown","green"/) 
  
  plot = gsn_csm_xy (wks,dsoik(::8),dateF(::8),res)

; this resource will assign the sequentially regardless of whether the
; bar goes up or down.
  delete(res@gsnRightXRefLineBarColors)
  delete(res@gsnLeftXRefLineBarColors)
  res@tiMainString        = "colors sequential regardless of orientation" 
  res@gsnXYBarChartColors2 = (/"orange","red","black","blue","green"/)
  plot = gsn_csm_xy (wks,dsoik(::8),dateF(::8),res)
end


