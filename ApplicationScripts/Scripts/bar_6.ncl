;*************************************************
; bar_6.ncl
;
; Concepts illustrated:
;   - Drawing bars instead of curves in an XY plot
;   - Changing the fill colors in a bar plot
;   - Drawing filled bars up or down based on a Y reference value
;   - Changing the aspect ratio of a bar plot
;   - Setting the minimum/maximum value of the Y axis in a bar plot
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
  wks   = gsn_open_wks ("png", "bar" ) ; send graphics to PNG file
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
  res@tiMainString  = "colors chosen for above and below"
  
  
; this resource changes a regular line plot to a bar chart
  res@gsnXYBarChart         = True ; create bar chart 
; this resource is required to get bars above and below a reference line
  res@gsnYRefLine           = 0. ; reference line  
  
; these two resources control the colors of the bars above and below
; the reference line.   
  res@gsnAboveYRefLineBarColors = (/"orange","red","black"/) 
  res@gsnBelowYRefLineBarColors = (/"blue","brown","green"/) 
  
  plot = gsn_csm_xy (wks,dateF(::8),dsoik(::8),res)

; this resource will assign the sequentially regardless of whether the
; bar goes up or down.
  delete(res@gsnAboveYRefLineBarColors)
  delete(res@gsnBelowYRefLineBarColors)
  res@tiMainString        = "colors sequential regardless of orientation" 
  res@gsnXYBarChartColors2 = (/"orange","red","black","blue","green"/)
  plot = gsn_csm_xy (wks,dateF(::8),dsoik(::8),res)
end


