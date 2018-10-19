;----------------------------------------------------------------------
; pie_chart_1.ncl
;
; Concepts illustrated:
;   - Drawing a pie chart
;----------------------------------------------------------------------
; These files are loaded by default in NCL 6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

 percent = (/30.0, 12,0.5, 4,16, 8, 11.5,18.0/)
 color   = (/ "red", "green", "orange", "yellow", "brown","magenta","blue","gray" /)
 name    = (/ "Deciduous", "Savanna", "Wetland", "Tundra", "Evergreen", "Desert", "Cropland", "Grassland" /)

 pcRes   = True
 pcRes@gsnMaximize     = True

 wks     = gsn_open_wks("png","pie_chart")               ; send graphics to PNG file

 pcRes@tiMainString    = "Surface Type: Sector Labels"   ; Sector Label is default
 plot    = pie_chart(wks, percent, name, color, pcRes)

 pcRes@pcLabelType     = "block"
 pcRes@tiMainString    = "Surface Type: Block Labels"
 plot    = pie_chart(wks, percent, name, color, pcRes)

