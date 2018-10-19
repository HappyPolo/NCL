; ***********************************************
; evans_2.ncl
; ***********************************************
;
; Created by Jason Evans
; senior research fellow
; Climate Change Research Center,
; University of New South Wales, Sydney, Australia.
;				
; Here he plots an evans_plot of the change in precip by amount (hue)
; and percent of present day (sat).
;
; The data are taken from the predictions of 34 realizations
; (by 16 GCMs) of the future precipitation under the SRESA2 scenario
; of the IPCC report.
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
 f = addfile("gcm_co2_pre.nc","r")


;load the change in absolute amount
 anpre48_00 = f->anpre48_00

;load the change in percent of current amount
 per_anpre48_00 = f->per_anpre48_00

;change to the absolute change in percent
 per_anpre48_00 = (/fabs(per_anpre48_00)/)

;create evans plot
 wks = gsn_open_wks("png","evans")      ; send graphics to PNG file

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

;**** Evans plot resources
 res@epLabelBarOn = True
 res@epCyclic = False

 plot = evans_plot_map(wks,anpre48_00,per_anpre48_00,res)
 
 


end
