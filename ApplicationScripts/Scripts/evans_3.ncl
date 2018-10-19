; ***********************************************
; evans_3.ncl
; ***********************************************
;
; Created by Jason Evans
; senior research fellow
; Climate Change Research Center,
; University of New South Wales, Sydney, Australia.
;				
; Here he plots an evans_plot of the maximum ndvi (hue)
; and timing (sat).
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "evans_plot.ncl"

begin

 f = addfile("ndvi_time.nc","r")

 maxndvi = f->ndvi_max
 timing = f->ndvi_timing

;create evans plot
 wks = gsn_open_wks("png","evans")        ; send graphics to PNG file

 res = True

 res@gsnAddCyclic = False

 res@mpLimitMode = "LatLon"
 res@mpMinLonF = min(maxndvi&lon)
 res@mpMinLatF = min(maxndvi&lat)
 res@mpMaxLonF = max(maxndvi&lon)
 res@mpMaxLatF = max(maxndvi&lat)

 res@mpOutlineDrawOrder     = "PostDraw"  ; force map tp be drawn 1st 
 res@mpGridLineDashPattern  = 2           ; lat/lon lines as dashed
 res@mpPerimOn              = True
 res@mpPerimDrawOrder       = "PostDraw"
 res@mpOutlineOn            = True
 res@mpOutlineBoundarySets = "National"
 res@mpGeophysicalLineThicknessF = 1.5

;**** Evans plot resources

; Put a border around, resize, and move the color wheel
 res@epColorWheelPerimOn = True
 res@epColorWheelScale = 0.45
 res@epColorWheelCenterX = 0.822
 res@epColorWheelCenterY = 0.33

;show every month
 res@epMinHueLevel = 1.
 res@epMaxHueLevel = 12.
 res@epHueLevelSpacing = 1.   

 res@epHueOffset = 180.   ; rotate teh color wheel

 plot2 = evans_plot_map(wks,timing,maxndvi,res)
end
