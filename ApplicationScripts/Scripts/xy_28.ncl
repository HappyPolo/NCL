;****************************************************
; xy_28.ncl
;
; Concepts illustrated:
;   - Drawing a hodograph plot
;   - Reading data from an ASCII file
;   - Drawing XY plot curves with both lines and markers
;   - Putting labels on an XY plot
;
;****************************************************
;
; This script was contributed by Haoming Chen from
; LASG/IAP in Beijing, China.
;
; A hodograph plot is a suitable approach in
; describing diurnal variations in the wind vector
; at a given point.
;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
; Read data of an ASCII file
  fin  = "wind_hourly.txt"
  dat  = asciiread(fin,-1,"float")
  nhr  = 25
  badv = -999.0

  u    = dat(0:24)
  v    = dat(25:49)

;====================================================

; wks  = gen_open_wks("eps","hodograph_test")
  wks = gsn_open_wks ("png","xy")    ; send graphics to PNG file

  res                      = True 

  res@gsnMaximize          = True    ; Maximize plot in window.

  res@gsnDraw              = False   ; Don't draw plot
  res@gsnFrame             = False   ; Don't advance frame

;  res@gsnPaperOrientation  = "portrait"

  res@gsnLeftString        = ""
  res@gsnRightString       = ""

  res@xyMarkLineMode       = "MarkLines"  ; markers and lines
  res@xyMarkers            = 16           ; filled dot
  res@xyMarkerSizeF        = 0.0135
  res@xyMarkerThicknessF   = 0.6

  res@tiMainString         = "Hodograph plot"
  res@tiYAxisString        = "V-Wind"
  res@tiXAxisString        = "U-Wind"

  plot = gsn_csm_xy (wks,u,v,res)    ; Create plot, but don't draw it yet

; Attach some text strings next to the markers.
  txres               = True
  txres@txFontHeightF = 0.0275
  txres@txJust        = "TopLeft"

  labels            = "  " + ispan(0,24,1)
  labels(24) 	    = ""   ; Don't do the last one.

  txid = gsn_add_text(wks,plot,labels,u,v,txres)

  draw(plot)    ; Drawing the plot will also cause text strings to appear
  frame(wks)    ; Advance the frame.
end 

