;*************************************************
; bar_1.ncl
;
; Concepts illustrated:
;   - Drawing bars instead of curves in an XY plot
;   - Changing the aspect ratio of a bar plot
;   - Drawing bars up or down based on a Y reference value
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
;K********************************
 wks   = gsn_open_wks ("png", "bar" )  ; send graphics to PNG file
 res   = True
 res@gsnScale = True               

; these four resources allow the user to stretch the plot size, and
; decide exactly where on the page to draw it.

 res@gsnMaximize = True
 res@vpHeightF = 0.43        ; Changes the aspect ratio
 res@vpWidthF  = 0.85

 res@tiYAxisString = ""
 res@tiXAxisString = ""

;---------- First plot --------------------

 res@tiMainString  = "Bar plot"
 res@gsnXYBarChart = True            ; Create bar plot

 plot = gsn_csm_xy (wks,dateF(::8),dsoik(::8),res)

;---------- Second plot --------------------

; This is like drawing a regular curve, except with
; flat bars for each point.

 res@tiMainString             = "Bar plot with outlines"
 res@gsnXYBarChartOutlineOnly = True

 plot = gsn_csm_xy (wks,dateF(::8),dsoik(::8),res)

;---------- Third plot --------------------

 delete(res@gsnXYBarChartOutlineOnly)

; When you include a reference line, then the bars
; will be drawn pointing up or down, depending on
; if they are above or below the ref line.

 res@tiMainString = "Bar plot with a reference line"
 res@gsnYRefLine  = 0.              ; reference line   

 plot = gsn_csm_xy (wks,dateF(::8),dsoik(::8),res)

end


