;----------------------------------------------------------------------
; mkZmean.ncl
;
; Concepts illustrated:
;   - Filling the area between two curves in an XY plot
;   - Drawing a custom legend on a panel plot
;----------------------------------------------------------------------
; This script was contributed by Dustin Swales, an associate scientist
; at CIRES /NOAA/PSD.
;----------------------------------------------------------------------
; The purpose of this program is to make plots of the output of 
; mkZmean.pro
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

; START PROGRAM
begin

; ###########################################################
; Plot control items
; ###########################################################
spect   = "LW"                          ; Spectral region (LW or SW)
seas    = "ALL"                         ; Season for plots (DJF, JJA or ALL)
fileOUT = "Zmean."+spect+"."+seas       ; Output file name
wksType = "png"                         ; Output file type

; Colors for area between curves
below_colors = (/"darkslategray1","darkslategray","darkslategray",\
                 "darkslategray1"/)
; Colors for plot lines
line_colors  = (/"darkslategray1","darkslategray","black",\
                 "darkslategray","darkslategray1"/)
; Line thicknesses
line_thick = (/1,1,4,1,1/)

; ###########################################################
; This is for a fix needed in NCL V6.2.0.
; Won't be needed in V6.2.1 or later.
; ###########################################################
above_colors = new(dimsizes(below_colors),string)       
above_colors = "transparent"

; ###########################################################
; Read in data
; ###########################################################
fileIN  = "zMeanStat.nc"
nc_file = addfile(fileIN,"r")

; ALL month data
if (seas .eq. "ALL") then
   lat = nc_file->lat
   if (spect .eq. "SW") then
      var1 = nc_file->SW1_ALL
      var2 = nc_file->SW2_ALL
      var3 = nc_file->SW3_ALL
      var4 = nc_file->SW4_ALL
   end if
   if (spect .eq. "LW") then
      var1 = nc_file->LW1_ALL
      var2 = nc_file->LW2_ALL
      var3 = nc_file->LW3_ALL
      var4 = nc_file->LW4_ALL
   end if
end if
if (seas .eq. "DJF") then
   lat = nc_file->lat
   if (spect .eq. "SW") then
      var1 = nc_file->SW1_DJF
      var2 = nc_file->SW2_DJF
      var3 = nc_file->SW3_DJF
      var4 = nc_file->SW4_DJF
   end if 
   if (spect .eq. "LW") then     
      var1 = nc_file->LW1_DJF
      var2 = nc_file->LW2_DJF
      var3 = nc_file->LW3_DJF
      var4 = nc_file->LW4_DJF
   end if
end if
if (seas .eq. "JJA") then
   lat = nc_file->lat
   if (spect .eq. "SW") then
      var1 = nc_file->SW1_JJA
      var2 = nc_file->SW2_JJA
      var3 = nc_file->SW3_JJA
      var4 = nc_file->SW4_JJA
   end if 
   if (spect .eq. "LW") then    
      var1 = nc_file->LW1_JJA
      var2 = nc_file->LW2_JJA
      var3 = nc_file->LW3_JJA
      var4 = nc_file->LW4_JJA
   end if
end if
lat = sin(lat*3.14/180.0)

; ###########################################################
; Plot data
; ###########################################################
; Open file
wks  = gsn_open_wks(wksType,fileOUT)
plot = new(4,graphic)

res                      = True
res@gsnDraw              = False                ; Don't draw plot 
res@gsnFrame             = False                ; Don't advance frame
res@xyMonoDashPattern    = True                 ; Solid lines for all curves
res@xyLineThicknesses    = line_thick           ; Plot line thickness
res@xyLineColors         = line_colors          ; Plot line colors
res@gsnXYBelowFillColors = below_colors         ; Plot line color fill
res@gsnXYAboveFillColors = above_colors         ; A fix for V6.2.0. Set to transparent.
res@tmXBMinorOn          = False                ; Turn off x-axis (bottom) minor ticks
res@tmXTMinorOn          = False                ; Turn off x-axis (bottom)minor ticks
res@tmXTOn               = False                ; Turn off x-axis (top) major ticks
res@tmYRMinorOn          = False                ; Turn off y-axis (right) minor ticks
res@tmYLMinorOn          = False                ; Turn off y-axis (left) minor ticks
res@tmYROn               = False                ; Turn off y-axis (right) major ticks
res@tmXBMode             = "Explicit"
lats                     = (/-60,-30,0,30,60/)
xpos                     = sin(lats*3.14/180.0)
res@tmXBValues           = xpos
res@tmXBLabels           = (/"-60","-30","0","30","60"/)
res@tiYAxisString        = "Flux (W/m2)"        ; Y-axis title
res@tiYAxisFontHeightF   = 0.0175               ; Y-axis string size (X/0.025 for scaling)
res@tiMainFontHeightF    = 0.0175               ; Title string size (X/0.025 for scaling)
res@tmXBLabelFontHeightF = 0.015                ; Label font height (X/0.020 for scaling)
res@tmYLLabelFontHeightF = 0.015                ; Label font height (X/0.020 for scaling)

res@tiMainString = "Default with Vapor - Default"
plot(0) = gsn_csm_xy(wks,lat,var1,res)
res@tiMainString = "ClearSky Weighted - Default"
plot(1) = gsn_csm_xy(wks,lat,var2,res)
res@tiMainString = "ClearSky Weighted with Vapor - Default"
plot(2) = gsn_csm_xy(wks,lat,var3,res)
res@tiMainString = "ClearSky Weighted with Vapor - ClearSky Weighted"
plot(3) = gsn_csm_xy(wks,lat,var4,res)

; Create legend
lgres                    = True
lgres@lgLineColors       = (/"darkslategray1","darkslategray","black"/)
lgres@lgLineThicknessF   = (/10,10,5/) 
lgres@lgLabelFontHeightF = .08            ; set the legend label font thickness
lgres@vpWidthF           = 0.15           ; width of legend (NDC)
lgres@vpHeightF          = 0.1            ; height of legend (NDC)
lgres@lgMonoDashIndex    = True   
lgres@lgPerimOn          = False          ; draw the box perimeter in orange
labels = " " + (/"5-95 Percentile","25-75 Percentile","Mean"/)
lbid = gsn_create_legend(wks,3,labels,lgres)

; Add legend to bottom right corner of last plot
amres                  = True
amres@amJust           = "BottomRight"  ; Corner of plot for positioning
amres@amOrthogonalPosF =  0.48   ;  0.5 is the bottom edge of the plot.
amres@amParallelPosF   =  0.47   ;  0.5 is the right edge of the plot.
annoid = gsn_add_annotation(plot(3), lbid, amres)


; Make panel plot       
resP             = True
resP@gsnMaximize = True
gsn_panel(wks,plot,(/2,2/),resP)

; END PROGRAM
end
