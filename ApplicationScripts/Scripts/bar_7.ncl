;********************************************************
; bar_7.ncl
;
; Concepts illustrated:
;   - Drawing filled bars
;   - Changing the width of the bars in a bar plot
;   - Filling the bars in a bar plot with different colors
;   - Setting the minimum/maximum value of the X and Y axis in a bar plot
;   - Adding text to a plot
;   - Rotating text 45 degrees
;   - Drawing a custom labelbar
;   - Using "getvalues" to retrieve the size of a plot
;
;********************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  
;********************************************************
; create the data
;********************************************************  
  x = (/1,2,3,4,5,6,7,8/)
  y = (/154900,56600,40000,30200,29700,24400,21700,13900/)
  labels = (/"Lung","Colon/rectum","Breast","Prostate","Pancreas",\
  "Non-Hodgkin's Lymphoma","Leukemias","Ovary"/)
;********************************************************
; create the plot
;********************************************************   
  wks = gsn_open_wks("png","bar")                  ; send graphics to PNG file
  res                       = True                 ; plot mods desired         
  res@gsnFrame              = False                ; don't advance frame yet
  res@gsnXYBarChart         = True                 ; turn on bar chart
  res@gsnXYBarChartBarWidth = 0.75                 ; change bar widths
  res@gsnXYBarChartColors = (/"firebrick","red","orange","green", \
  "navy","blue","SkyBlue","SlateBlue"/)            ; choose colors
  
  res@tmXBOn                = False                ; turn off tickmarks at bot
  res@trYMinF               = 0                    ; bring bars down to zero
  res@trXMinF               = 0                    ; adds space on either end
  res@trXMaxF               = 9                    ; of the 1st and last bars
  
  res@tiMainString          = "Estimated Cancer Deaths for 2002"

  plot = gsn_csm_xy (wks,x,y,res)                  ; create plot
  
;**********************************************************
; add text labels
;**********************************************************  
  txres                     = True                 ; text mods desired
  txres@txFontHeightF       = 0.018                ; default size is HUGE!
  txres@txAngleF            = 52.                  ; text angle
  txres@txJust              = "CenterLeft"         ; puts text on top of bars
  
  do n = 1, 8
    gsn_text(wks,plot,labels(n-1),n,y(n-1)+1500,txres) ; add labels
  end do
  frame(wks)
;**********************************************************
; create second plot
;**********************************************************  
  res@tiYAxisString = "Number of Deaths"
  plot = gsn_csm_xy (wks,x,y,res)
;**********************************************************
; add labelbar to second plot
;********************************************************** 
  getvalues plot                ; get plot size for use in creating labelbar
  "vpXF"      : vpx
  "vpYF"      : vpy
  "vpHeightF" : vph
  "vpWidthF"  : vpw
  end getvalues

  lbw    = 0.4 * vpw           ; Make labelbar size a fraction of the plot.
  lbh    = 0.5 * vph
  nboxes = dimsizes(res@gsnXYBarChartColors)
   
  lbres                    = True          ; labelbar only resources
  lbres@vpWidthF           = 0.4 * vpw     ; labelbar width
  lbres@vpHeightF          = 0.5 * vph     ; labelbar height
  lbres@lbBoxMajorExtentF  = 0.75          ; puts space between color boxes
  lbres@lbFillColors       = res@gsnXYBarChartColors ; labelbar colors
  lbres@lbMonoFillPattern  = True          ; Solid fill pattern
  lbres@lbLabelFontHeightF = 0.008         ; font height. default is small
  lbres@lbLabelJust        = "CenterLeft"  ; left justify labels
   
  gsn_labelbar_ndc(wks,nboxes,labels,vpx+vph-lbw,0.77,lbres)
   
  frame(wks)
end
