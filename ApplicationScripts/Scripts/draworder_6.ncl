;********************************************************
; draworder_6.ncl
;
; Concepts illustrated:
;   - Drawing a bar chart
;   - Drawing a custom labelbar
;   - Attaching a labelbar to a plot
;   - Turning off the bottom tickmark labels and tickmarks
;   - Using "getvalues" to retrieve the limits of a plot
;   - Overlaying a bar chart on a blank plot to force the drawing order of plot elements
;********************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

undef("add_labelbar")
procedure add_labelbar(wks,xyplot,labels,xyres)
local nboxes, lbres, annoid, lbid, amres, vpw, vph
begin
  getvalues xyplot                    ; Get plot size for use in
    "vpHeightF" : vph                 ; determining size of
    "vpWidthF"  : vpw                 ; labelbar.
  end getvalues
;
; Set up resources for the labelbar.
;
  nboxes = dimsizes(xyres@gsnXYBarChartColors)
   
  lbres                    = True          ; labelbar only resources
  lbres@lbAutoManage       = True          ; Necessary to control sizes
  lbres@vpWidthF           = 0.4 * vpw     ; labelbar width
  lbres@vpHeightF          = 0.5 * vph     ; labelbar height
  lbres@lbBoxMajorExtentF  = 0.75          ; puts space between color boxes
  lbres@lbFillColors       = xyres@gsnXYBarChartColors ; labelbar colors
  lbres@lbMonoFillPattern  = True          ; Solid fill pattern
  lbres@lbLabelFontHeightF = 0.08          ; font height. default is small
  lbres@lbLabelJust        = "CenterLeft"  ; left justify labels

  lbid = gsn_create_labelbar(wks,nboxes,labels,lbres)
   
;
; Now, create some annotation resources indicating how we want to
; attach the labelbar to the plot. Here, we are using the top right
; corner of the labelbar as the point which we are going to position
; it, and then we use amParallelPosF and amOrthogonalPosF to indicate
; where we want to place it.
;
; amParallelPosF/amOrthogonalPosF                                       ;
;    0.0/ 0.0  -  annotation in dead center of plot
;    0.5/ 0.5  -  annotation at bottom right of plot
;    0.5/-0.5  -  annotation at top right of plot
;   -0.5/-0.5  -  annotation at top left of plot
;   -0.5/ 0.5  -  annotation at bottom left of plot
;                                                                 
  amres                  = True
  amres@amJust           = "TopRight"
  amres@amParallelPosF   =  0.5
  amres@amOrthogonalPosF = -0.5
  annoid = gsn_add_annotation(xyplot,lbid,amres)
  xyplot@anno = annoid
  return
end

begin
;
; Create the data.
;
  x = (/1,2,3,4,5,6,7,8/)
  y = (/154900,56600,40000,30200,29700,24400,21700,13900/)
  labels = (/"Lung","Colon/rectum","Breast","Prostate","Pancreas",\
  "Non-Hodgkin's Lymphoma","Leukemias","Ovary"/)

  wks = gsn_open_wks("png","draworder")            ; send graphics to PNG file

  res                       = True                 ; plot mods desired         
  res@gsnMaximize           = True                 ; maximize plot in frame
  res@gsnDraw               = False                ; don't draw plot yet
  res@gsnFrame              = False                ; don't advance frame yet
  res@gsnXYBarChart         = True                 ; turn on bar chart
  res@gsnXYBarChartBarWidth = 0.75                 ; change bar widths
  res@gsnXYBarChartColors   = (/"firebrick","red","orange","green", \
                               "navy","blue","SkyBlue","SlateBlue"/)
  
  res@trYMinF               = 0                    ; bring bars down to zero
  res@trXMinF               = 0                    ; adds space on either end
  res@trXMaxF               = 9                    ; of the 1st and last bars
  
  res@tiMainString          = "Estimated Cancer Deaths for 2002"

  res@tfPolyDrawOrder = "PostDraw"

  plot = gsn_csm_xy (wks,x,y,res)     ; Create plot, but don't draw it yet.

  getvalues plot
     "trXMinF" : xmin
     "trXMaxF" : xmax
     "trYMinF" : ymin
     "trYMaxF" : ymax
  end getvalues

;---Resources for "blank" plot that will contain gray box
  bres              = True
  bres@trXMinF      = xmin
  bres@trXMaxF      = xmax
  bres@trYMinF      = ymin
  bres@trYMaxF      = ymax
  bres@tmXBOn       = False
  bres@tmXBLabelsOn = False
  blank_plot = gsn_csm_blank_plot(wks,bres)

;---Values for the gray box
  yavg = avg(y)
  ystd = stddev(y)
  ymin = yavg-ystd/2.
  ymax = yavg+ystd/2.
  xbox = (/xmin,xmax,xmax,xmin,xmin/)
  ybox = (/ymin,ymin,ymax,ymax,ymin/)

;---Resources for gray box
  gnres                 = True
  gnres@tfPolyDrawOrder = "PreDraw"
  gnres@gsFillColor     = "LightGray"
  box = gsn_add_polygon(wks,blank_plot,xbox,ybox,gnres)

  add_labelbar(wks,plot,labels,res)

;---Overlay bar chart on blank plot so gray box gets drawn on bottom
  overlay(blank_plot,plot)
  draw(blank_plot)
  frame(wks)
end
