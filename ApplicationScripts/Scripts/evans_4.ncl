; ***********************************************
; evans_4.ncl
; ***********************************************
;
; Created by Jason Evans
; senior research fellow
; Climate Change Research Center,
; University of New South Wales, Sydney, Australia.
;				
; Here he plots an evans_plot of the change in precip by amount (hue)
; and significance (sat)
;
; The data are taken from the predictions of 34 realizations
; (by 16 GCMs) of the future precipitation under the SRESA2 scenario
; of the IPCC report.
;
; The probability (significance) of the change is calculated as a 
; t-test between the precipitation now and the precipitation
; simulated in mid 21st century.
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "evans_plot.ncl"

begin
 f = addfile("gcm_co2_pre.nc","r")

;load the change in absolute amount
 anpre48_00 = f->anpre48_00

;load the probability of no change
 prob48_00 = f->prob48_00

;convert to probability of change
 prob48_00 = (/1. - prob48_00/)

;create evans plot
 wks = gsn_open_wks("png","evans")        ; send graphics to PNG file

 res = True

 res@gsnAddCyclic = False

 res@mpLimitMode = "LatLon"
 res@mpMinLonF = min(anpre48_00&lon)
 res@mpMinLatF = min(anpre48_00&lat)
 res@mpMaxLonF = max(anpre48_00&lon)
 res@mpMaxLatF = max(anpre48_00&lat)

 res@mpOutlineDrawOrder     = "PostDraw"  ; force map tp be drawn 1st 
 res@mpGridLineDashPattern  = 2           ; lat/lon lines as dashed
 res@mpPerimOn              = True
 res@mpPerimDrawOrder       = "PostDraw"
 res@mpOutlineOn            = True
 res@mpOutlineBoundarySets = "National"
 res@mpGeophysicalLineThicknessF = 1.5

;*** Evans plot resources

 res@epCyclic = False
 res@epLabelBarOn = True
 res@epMinSatLevel = 0.7
 res@epMaxSatLevel = 0.95
 res@epSatLevelSpacing = 0.05
 res@epSatLabel = "Prob."

 plot = evans_plot_map(wks,anpre48_00,prob48_00,res)

;*** second plot - overlay the 0.9,0.95 and 0.99 significance levels

 res@gsnFrame = False

 plot = evans_plot_map(wks,anpre48_00,prob48_00,res)

 res2 = True
 res2@cnFillOn = False
 res2@gsnDraw = False
 res2@gsnFrame = False
 res2@cnInfoLabelOn = False
 res2@cnLineLabelsOn = False
 res2@gsnLeftString = ""
 res2@cnLineDashPattern = 1
 res2@cnMonoLineThickness = False
 res2@cnLineThicknesses = (/1.0,1.5,3.0/)
 res2@cnLevelSelectionMode = "ExplicitLevels"
 res2@cnLevels = (/0.9,0.95,0.99/)

 plot2 = gsn_csm_contour(wks,prob48_00,res2)

 overlay(plot,plot2)

 draw(plot)
 frame(wks)
 

;*** 3rd plot
; This is a standard plot for change in precip showing signficance levels.
;
; Note that your eye is drawn to the white and red "hotspots", all of which
; fall outside the significant zone .
;
; The Evans plot draws your eye to the significant zones which do not 
; correspond to these "hotspots".


 res@gsnDraw = False
 res@gsnFrame = False
 res@cnFillOn = True
 res@cnFillPalette = "WhViBlGrYeOrRe"
 res@cnLinesOn = False

 plot = gsn_csm_contour_map(wks,anpre48_00,res)
 plot2 = gsn_csm_contour(wks,prob48_00,res2)

 overlay(plot,plot2)

 draw(plot)
 frame(wks)
end
