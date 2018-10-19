;----------------------------------------------------------------------
; pie_chart_2.ncl
;
; Concepts illustrated:
;   - Drawing pie charts in a panel
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

 pcRes          = True
 pcRes@gsnDraw  = False           ; for paneling
 pcRes@gsnFrame = False

 name  = (/ "Deciduous", "Savanna", "Wetland", "Tundra" \
          , "Evergreen", "Desert", "Cropland", "Grassland" /)
 color = (/ "red", "green", "orange", "yellow"        \
          , "brown","magenta","blue","gray" /)

 wks   = gsn_open_wks("png","pie_chart")         ; send graphics to PNG file
 panel = new (4, "graphic")
;************************************************
; create panel using "section" labels [default]
;************************************************

 pcRes@tiMainString    = "Model A"
 percent  = (/10.5, 12, 20, 4, 6, 8, 24.5, 15 /)
 panel(0) = pie_chart(wks, percent, name, color, pcRes)

 pcRes@tiMainString    = "Model B"
 percent  = (/15.5, 12, 40, 4, 6, 8, 11.5, 3.0/)
 panel(1) = pie_chart(wks, percent, name, color, pcRes)

 pcRes@tiMainString    = "Model C"
 percent  = (/10.5, 12, 30, 4,16, 8, 11.5, 8.0/)
 panel(2) = pie_chart(wks, percent, name, color, pcRes)

 pcRes@tiMainString    = "Model D"
 percent  = (/30.0, 12,0.5, 4,16, 8, 11.5,18.0/)
 panel(3) = pie_chart(wks, percent, name, color, pcRes)

 resP                  = True                    ; resources for panel plot
 resP@gsnMaximize      = True
 resP@txString         = "Surface Type: Section Labels"
 gsn_panel(wks,panel,(/2,2/),resP)               ; now draw as one plot

;************************************************
; create panel using "block" labels [user specified]
;************************************************

 pcRes@pcLabelType     = "block"

 pcRes@tiMainString    = "Model A"
 percent  = (/10.5, 12, 20, 4, 6, 8, 24.5, 15 /)
 panel(0) = pie_chart(wks, percent, name, color, pcRes)

 pcRes@tiMainString    = "Model B"
 percent  = (/15.5, 12, 40, 4, 6, 8, 11.5, 3.0/)
 panel(1) = pie_chart(wks, percent, name, color, pcRes)

 pcRes@tiMainString    = "Model C"
 percent  = (/10.5, 12, 30, 4,16, 8, 11.5, 8.0/)
 panel(2) = pie_chart(wks, percent, name, color, pcRes)

 pcRes@tiMainString    = "Model D"
 percent  = (/30.0, 12,0.5, 4,16, 8, 11.5,18.0/)
 panel(3) = pie_chart(wks, percent, name, color, pcRes)

 resP@txString            = "Surface Type: Block Labels"
 gsn_panel(wks,panel,(/2,2/),resP)               ; now draw as one plot

