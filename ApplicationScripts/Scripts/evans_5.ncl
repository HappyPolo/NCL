; ***********************************************
; evans_5.ncl
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
; simulated in the 21st century.
;
;This is done for each season
;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; These files still have to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "evans_plot.ncl"

begin
 f = addfile("pr_mme_change_sresa2.nc","r")


;load the seasonal amounts
seas1980 = f->seas1980
seas2020 = f->seas2020
seas2060 = f->seas2060


;calculate the changes
seas20_80 = seas2020
seas20_80 = seas2020 - seas1980
seas60_80 = seas2060 
seas60_80 = seas2060 - seas1980

;in percent of current
perseas20_80 = seas20_80
perseas60_80 = seas60_80
perseas20_80 = fabs(100.*seas20_80/seas1980)
perseas60_80 = fabs(100.*seas60_80/seas1980)


;load the probability of no change
probseas20 = f->prob_seas2020_1980
probseas60 = f->prob_seas2060_1980

;convert to probability of change
probseas20 = (/1. - probseas20/)
probseas60 = (/1. - probseas60/)



;convert the change from kbm-2s-1 to mm/season
seas20_80 = (/seas20_80*86400*91/)
seas60_80 = (/seas60_80*86400*91/)



;create evans plot
 wks = gsn_open_wks("png","evans")        ; send graphics to PNG file
 


 res = True
 
 res@gsnDraw = False
 res@gsnFrame = False

 res@gsnAddCyclic = False

 res@mpLimitMode = "LatLon"
 res@mpMinLonF = min(seas1980&lon)
 res@mpMinLatF = min(seas1980&lat)
 res@mpMaxLonF = max(seas1980&lon)
 res@mpMaxLatF = max(seas1980&lat)

 res@mpOutlineDrawOrder     = "PostDraw"  ; force map tp be drawn 1st 
 res@mpGridLineDashPattern  = 2           ; lat/lon lines as dashed
 res@mpPerimOn              = True
 res@mpPerimDrawOrder       = "PostDraw"
 res@mpOutlineOn            = True
 res@mpOutlineBoundarySets = "National"
 res@mpGeophysicalLineThicknessF = 1.5

;*** Evans plot resources

 res@epCyclic = False
 res@epLabelBarOn = False

 res@epMinSatLevel = 5
 res@epMaxSatLevel = 25
 res@epSatLevelSpacing = 5
 res@epSatLabel = "%"
 
 res@epMinHueLevel = -20
 res@epMaxHueLevel = 60
 res@epHueLevelSpacing = 10
 res@epHueLabel = "mm"
 



;*** second plot - overlay the 0.9,0.95 and 0.99 significance levels
res2 = True
 res2@cnFillOn = False
 res2@gsnDraw = False
 res2@gsnFrame = False
 res2@cnInfoLabelOn = False
 res2@cnLineLabelBackgroundColor = -1
 res2@cnLineLabelPlacementMode = "Constant"
 res2@gsnLeftString = ""
 res2@cnLineDashPattern = 1
 res2@cnMonoLineThickness = False
 res2@cnLineThicknesses = (/1.0,1.5,3.0/)
 res2@cnLevelSelectionMode = "ExplicitLevels"
 res2@cnLevels = (/0.9,0.95,0.99/)

 res2@tfDoNDCOverlay = True



;cycle through seasons
plot = new(4,graphic)
plot2 = new(4,graphic)

season = (/"DJF","MAM","JJA","SON"/)
res@gsnLeftString = seas1980@long_name

do mm = 0,3

 res@gsnRightString = "2060-1980 : sresA2"
 res@gsnCenterString = season(mm)
 


 
 plot(mm) = evans_plot_map(wks,seas60_80(mm,:,:),perseas60_80(mm,:,:),res)

 plot2(mm) = gsn_csm_contour(wks,(/probseas60(mm,:,:)/),res2)

 overlay(plot(mm),plot2(mm))
 


end do




 
 
 
 ;panel resources
 pres = True
  pres@gsnFrame = False
   
  pres@lbAutoManage = "False"
  pres@lbTitleString = "mm"
  pres@lbTitlePosition = "Left"
  pres@lbTitleDirection = "Across"
  pres@lbTitleFontHeightF = 0.015
  pres@lbLabelStride = 2



  gsn_panel(wks,plot,(/2,2/),pres)
  
  
  
  
  ;add ep label bar
 ep_res = True
 
 ;position Label bar
 ep_res@epLabelBarYMin = 0.2
 
;show every month
 ep_res@epHueLabel = "mm"
 ep_res@epMinHueLevel = -20
 ep_res@epMaxHueLevel = 60
 ep_res@epHueLevelSpacing = 10.   

 ep_res@epSatLabel = "%"
 ep_res@epMinSatLevel = 5
 ep_res@epMaxSatLevel = 25
 ep_res@epSatLevelSpacing = 5
 
 
 add_ep_label_bar_ndc(wks,ep_res)


frame(wks)

end
