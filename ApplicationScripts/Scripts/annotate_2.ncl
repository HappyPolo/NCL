;********************************************************
; annotate_2.ncl
;
; Concepts illustrated:
;   - Drawing a bar chart
;   - Drawing a custom labelbar
;   - Attaching a labelbar to a plot
;   - Turning off the bottom tickmark labels and tickmarks
;   - Using "getvalues" to retrieve the size of a plot
;********************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;
; Create the data.
;
  x = (/1,2,3,4,5,6,7,8/)
  y = (/154900,56600,40000,30200,29700,24400,21700,13900/)
  labels = (/"Lung","Colon/rectum","Breast","Prostate","Pancreas",\
  "Non-Hodgkin's Lymphoma","Leukemias","Ovary"/)

  wks = gsn_open_wks("png","annotate")             ; send graphics to PNG file

  res                       = True                 ; plot mods desired         
  res@gsnMaximize           = True                 ; maximize plot in frame
  res@gsnDraw               = False                ; don't draw plot yet
  res@gsnFrame              = False                ; don't advance frame yet
  res@gsnXYBarChart         = True                 ; turn on bar chart
  res@gsnXYBarChartBarWidth = 0.75                 ; change bar widths
  res@gsnXYBarChartColors   = (/"firebrick","red","orange","green", \
                               "navy","blue","SkyBlue","SlateBlue"/)
  
  res@tmXBOn                = False                ; turn off tickmarks at bot
  res@trYMinF               = 0                    ; bring bars down to zero
  res@trXMinF               = 0                    ; adds space on either end
  res@trXMaxF               = 9                    ; of the 1st and last bars
  
  res@tiMainString          = "Estimated Cancer Deaths for 2002"

  plot = gsn_csm_xy (wks,x,y,res)     ; Create plot, but don't draw it yet.

  getvalues plot                      ; Get plot size for use in
    "vpHeightF" : vph                 ; determining size of
    "vpWidthF"  : vpw                 ; labelbar.
  end getvalues

;
; Set up resources for the labelbar.
;
  nboxes = dimsizes(res@gsnXYBarChartColors)
   
  lbres                    = True          ; labelbar only resources
  lbres@lbAutoManage       = True          ; Necessary to control sizes
  lbres@vpWidthF           = 0.4 * vpw     ; labelbar width
  lbres@vpHeightF          = 0.5 * vph     ; labelbar height
  lbres@lbBoxMajorExtentF  = 0.75          ; puts space between color boxes
  lbres@lbFillColors       = res@gsnXYBarChartColors ; labelbar colors
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
  annoid = gsn_add_annotation(plot,lbid,amres)

  draw(plot)      ; When you draw plot, labelbar will also get drawn.
  frame(wks)
end
