;----------------------------------------------------------------------
; bar_19.ncl
;
; Concepts illustrated:
;   - Drawing bars instead of curves in an XY plot
;   - Forcing the width of the bars in multiple bar plots to be the same size
;   - Paneling bar plots  
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    

begin
;---Create some dummy data for three bar charts, each with a different X axis.
  npts = 5
  ybeg = -5
  yend =  5

  npts1 = 5
  y1 = random_uniform(ybeg,yend,npts1)

  npts2 = 8
  y2 = random_uniform(ybeg,yend,npts2)

  npts3 = 10
  y3 = random_uniform(ybeg,yend,npts3)

  x1  = ispan(1,npts1,1)
  x2  = ispan(1,npts2,1)
  x3  = ispan(1,npts3,1)

  wks = gsn_open_wks("png","bar")

  res               = True
  res@gsnDraw       = False
  res@gsnFrame      = False
  res@gsnXYBarChart = True     ; Draw bars instead of lines
  res@trYMinF       = ybeg     ; Force Y axis to have same scale
  res@trYMaxF       = yend

  res@gsnXYBarChartColors = (/"blue","lawngreen","papayawhip","orange","brown"/)

  plot1 = gsn_csm_xy (wks,x1,y1,res)
  plot2 = gsn_csm_xy (wks,x2,y2,res)
  plot3 = gsn_csm_xy (wks,x3,y3,res)

;---Panel the original plots
  pres = True
  pres@gsnPanelMainString = "Multi-colored bars, different widths"
  gsn_panel(wks,(/plot1,plot2,plot3/),(/1,3/),pres)

;
; The width of the bars is based on the width of the plot divided by
; the number of bars.  If one plot has 10 bars and another plot has
; 5 bars and they are the same width, then the bars in the 10-bar plot
; will be half the width of the bars in the 5-bar plot. This next
; part of code shows how to make all the bars the same width, by
; figuring how which bars are the smallest, and scaling the other
; bars by this amount.
;
  width1 = 1./npts1
  width2 = 1./npts2
  width3 = 1./npts3

  min_width = min((/width1,width2,width3/))

  res@gsnXYBarChartBarWidth  = min_width/width1
  plot1 = gsn_csm_xy (wks,x1,y1,res)

  res@gsnXYBarChartBarWidth  = min_width/width2
  plot2 = gsn_csm_xy (wks,x2,y2,res)

  res@gsnXYBarChartBarWidth  = min_width/width3
  plot3 = gsn_csm_xy (wks,x3,y3,res)

;---Panel the resized bar plots
  pres@gsnPanelMainString = "Multi-colored bars, same width"
  gsn_panel(wks,(/plot1,plot2,plot3/),(/1,3/),pres)
end


