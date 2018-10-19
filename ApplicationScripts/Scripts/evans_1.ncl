; ***********************************************
; evans_1.ncl
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
; Here the hue tells us what month the maximum NDVI 
; (a satelite based measure of vegetation greeness)
; occurs and the saturation tells us just how green the
; vegetation gets I.e. grey areas indicate arid (desert) regions.
;
; This default case picks "nice" hues and saturarions for you
; in this case it plots the data 2 months at a time. 
; I.e red is jan/feb, yellow is mar/apr etc
;
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

 gsn_define_colormap(wks,"WhViBlGrYeOrRe")

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

 res@epCyclic = True

 plot = evans_plot_map(wks,timing,maxndvi,res)
end
