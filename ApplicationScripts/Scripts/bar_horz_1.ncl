;*************************************************
; bar_horz_1.ncl
;
; Concepts illustrated:
;   - Drawing bars instead of curves in an XY plot
;   - Changing the aspect ratio of a bar plot
;   - Drawing bars left or right based on an X reference value
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
 wks   = gsn_open_wks ("png", "bar_horz" )  ; send graphics to PNG file
 res   = True
 res@gsnScale = True               

; these four resources allow the user to stretch the plot size, and
; decide exactly where on the page to draw it.

 res@gsnMaximize = True
 res@vpHeightF = 0.85        ; Changes the aspect ratio
 res@vpWidthF  = 0.43

 res@tiYAxisString = ""
 res@tiXAxisString = ""

;---------- First plot --------------------

 res@tiMainString  = "Bar plot"
 res@tiMainFontHeightF = 0.025
 res@gsnXYBarChart = True            ; Create bar plot
 res@gsnXRefLine   = min(dsoik(::8))

 plot = gsn_csm_xy (wks,dsoik(::8),dateF(::8),res)

;---------- Second plot --------------------

; This is like drawing a regular curve, except with
; flat bars for each point.

 res@tiMainString             = "Bar plot with outlines"
 res@gsnXYBarChartOutlineOnly = True
 res@gsnXRefLineColor = "transparent"

 plot = gsn_csm_xy (wks,dsoik(::8),dateF(::8),res)

;---------- Third plot --------------------

 delete(res@gsnXYBarChartOutlineOnly)

; When you include a reference line, then the bars
; will be drawn pointing left or right, depending on
; if they are to the left or right of the ref line.

 res@tiMainString = "Bar plot with a reference line"
 res@gsnXRefLine  = 0.              ; reference line   
 res@gsnXRefLineColor = "black"

 plot = gsn_csm_xy (wks,dsoik(::8),dateF(::8),res)

end


