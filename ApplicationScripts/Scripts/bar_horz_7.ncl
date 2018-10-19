;********************************************************
; bar_horz_7.ncl
;
; Concepts illustrated:
;   - Drawing filled bars
;   - Changing the height of the bars in a bar plot
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
  y = (/13900,21700,24400,29700,30200,40000,56600,154900/)
  labels = (/"Ovary","Leukemias","Non-Hodgkin's Lymphoma","Pancreas",\
  "Prostate","Breast","Colon/rectum","Lung"/)
;********************************************************
; create the plot
;********************************************************   
  wks = gsn_open_wks("png","bar_horz")             ; send graphics to PNG file
  res                       = True                 ; plot mods desired         
  res@gsnFrame              = False                ; don't advance frame yet
  res@gsnXYBarChart         = True                 ; turn on bar chart
  res@gsnXYBarChartBarWidth = 0.75                 ; change bar widths
  res@gsnXYBarChartColors = (/"SlateBlue","SkyBlue","blue","navy", \
  "green","orange","red","firebrick"/)             ; choose colors
  
  res@tmYLOn                = False                ; turn off tickmarks at bot
  res@trYMinF               = 0                    ; bring bars down to zero
  res@trXMinF               = 0                    ; adds space on either end
  res@trYMaxF               = 9                    ; of the 1st and last bars
  
  res@gsnXRefLine           = 0

  res@tiMainString          = "Estimated Cancer Deaths for 2002"

  plot = gsn_csm_xy (wks,y,x,res)                  ; create plot
  
;**********************************************************
; add text labels
;**********************************************************  
  txres                     = True                 ; text mods desired
  txres@txFontHeightF       = 0.018                ; default size is HUGE!
  txres@txJust              = "CenterLeft"         ; puts text on top of bars
  
  do n = 1, 8
    gsn_text(wks,plot,labels(n-1),y(n-1)+1500,n,txres) ; add labels
  end do
  frame(wks)
;**********************************************************
; create second plot
;**********************************************************  
  plot = gsn_csm_xy (wks,y,x,res)
;**********************************************************
; add labelbar to second plot
;********************************************************** 
  getvalues plot                ; get plot size for use in creating labelbar
  "vpXF"      : vpx
  "vpYF"      : vpy
  "vpHeightF" : vph
  "vpWidthF"  : vpw
  end getvalues

  lbw    = 0.4 * vph           ; Make labelbar size a fraction of the plot.
  lbh    = 0.5 * vpw
  nboxes = dimsizes(res@gsnXYBarChartColors)
   
  lbres                    = True          ; labelbar only resources
  lbres@vpWidthF           = 0.4 * vph     ; labelbar width
  lbres@vpHeightF          = 0.5 * vpw     ; labelbar height
  lbres@lbBoxMajorExtentF  = 0.75          ; puts space between color boxes
  lbres@lbFillColors       = res@gsnXYBarChartColors ; labelbar colors
  lbres@lbMonoFillPattern  = True          ; Solid fill pattern
  lbres@lbLabelFontHeightF = 0.01          ; font height. default is small
  lbres@lbLabelJust        = "CenterLeft"  ; left justify labels
   
  gsn_labelbar_ndc(wks,nboxes,labels,vpx+vph-lbw-0.05,0.49,lbres)
   
  frame(wks)
end
