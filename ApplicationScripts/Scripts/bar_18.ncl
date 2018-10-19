;*************************************************
; bar_18.ncl
;
; Concepts illustrated:
;   - Drawing stacked bar plots
;   - Creating a blank plot
;   - Attaching a custom labelbar to a bar chart
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  
 bars = ispan(0,46,1)


  nbars = dimsizes(bars)

  d1 = fspan(0.1,2.3,47)  
  d2 = fspan(0.2,2.1,47) 
  d3 = fspan(0.5,3.2,47)
  d4 = fspan(0.3,4.1,47) 
line = fspan(3.1,1.1,47)


;==============================================
  wks = gsn_open_wks("png","bar")        ; send graphics to PNG file
;
; Set resources for blank plot. Be sure to set axes limits
; that represent d that will be added later via polygons.
;
  res                          = True

  res@gsnDraw                  = False   ; Don't draw
  res@gsnFrame                 = False   ; Don't advance frame

;  res@vpWidthF                 = 0.3     ; Make long and
;  res@vpHeightF                = 0.9     ; narrow

;---Set axes limits. Add extra space for X max.
  res@trYMinF                  = 0.0
  res@trYMaxF                  = (max(d2) + max(d1)+max(d3) + max(d4))*1.2  
  res@trXMinF                  = 0
  res@trXMaxF                  = nbars + 1

  res@gsnTickMarksPointOutward = True

;---Put city labels on X axis
  res@tmXBMode                 = "Explicit"
  res@tmXBValues               = ispan(1,nbars+1,12)
  res@tmXBLabels               = (/2003,2004,2005,2006,2007/)

  res@tmXBLabelFontHeightF     = 0.01   ; make labels smaller

;--Turn off X axis tickmarks
  res@tmXBMajorLengthF         = 0.
  res@tmXBMajorOutwardLengthF  = 0.  
  res@tmYLMajorLengthF         = 0.01
  res@tmYLMajorOutwardLengthF  = 0.01

  res@tmXTOn                   = False   ; Turn off top tickmarks

;---Create blank plot without Y grid lines
  plot_without_xgrid = gsn_blank_plot(wks,res)

;---Create blank plot with Y grid lines
  res@tmYMajorGrid                = True    ; Turn on grid lines
  res@tmYMajorGridLineDashPattern = 2       ; Dashed lines
  res@tmYMajorGridThicknessF      = 1.0     ; default is 2 (?)
  plot_with_xgrid = gsn_blank_plot(wks,res)

;---Arrays to hold the bar values and the bars themselves.
  dum1 = new(nbars,graphic)
  dum2 = new(nbars,graphic)
  dum3 = new(nbars,graphic)
  dum4 = new(nbars,graphic)

;---Set some resources for the bars.
  bres           = True
  bres@gsEdgesOn = True      ; Outline the polygons (bars)

  
  dnames = (/"d1", "d2", "d3","d4"/) 
  colors  = (/"red", "green", "pink", "magenta"/)

  do i=1,nbars


    bres@gsFillColor           = colors(0)
      
    ybar      = (/0,d1(i-1),d1(i-1),0,0/)
    xbar      = (/i-0.25,i-0.25,i+0.25,i+0.25,i-0.25/)
    dum1(i-1) = gsn_add_polygon(wks,plot_without_xgrid,xbar,ybar,bres)

    bres@gsFillColor          = colors(1)
    
    ybar      = (/d1(i-1),d2(i-1)+d1(i-1),d2(i-1)+d1(i-1),d1(i-1),d1(i-1)/)
    dum2(i-1) = gsn_add_polygon(wks,plot_without_xgrid,xbar,ybar,bres)
    
    bres@gsFillColor          = colors(2)

    ybar      = (/d1(i-1)+d2(i-1),d3(i-1)+d2(i-1)+d1(i-1),d3(i-1)+d2(i-1)+d1(i-1),d1(i-1)+d2(i-1),d1(i-1)+d2(i-1)/)
    dum3(i-1) = gsn_add_polygon(wks,plot_without_xgrid,xbar,ybar,bres)
 
    
    bres@gsFillColor          = colors(3)

    ybar      = (/d1(i-1)+d2(i-1)+d3(i-1),d4(i-1)+d3(i-1)+d2(i-1)+d1(i-1),d4(i-1)+d3(i-1)+d2(i-1)+d1(i-1),d1(i-1)+d2(i-1)+d3(i-1),d1(i-1)+d2(i-1)+d3(i-1)/)
    dum4(i-1) = gsn_add_polygon(wks,plot_without_xgrid,xbar,ybar,bres)

end do


;**********************************************************
; add labelbar to plot
;********************************************************** 

nboxes =dimsizes(colors)


  getvalues plot_with_xgrid                ; get plot size for use in creating labelbar
  "vpXF"      : vpx
  "vpYF"      : vpy
  "vpHeightF" : vph
  "vpWidthF"  : vpw
  end getvalues

;  lbw    = 0.15 * vpw           ; Make labelbar size a fraction of the plot.
;  lbh    = 0.2 * vph

   
  lbres                    = True          ; labelbar only resources
  lbres@lbPerimOn          = False
  lbres@vpWidthF           = 0.25 * vpw     ; labelbar width
  lbres@vpHeightF          = 0.35 * vph     ; labelbar height
  lbres@lbBoxMajorExtentF  = 0.8          ; puts space between color boxes
  lbres@lbFillColors       = colors ; labelbar colors
  lbres@lbMonoFillPattern  = True          ; Solid fill pattern
  lbres@lbLabelFontHeightF = 0.02          ; font height. default is small
  lbres@lbJustification    = "TopLeft"
;  lbres@lbLabelJust        = "CenterLeft"  ; left justify labels
   
  gsn_labelbar_ndc(wks,nboxes,dnames,0.24,0.76,lbres)

;======================= for line ======================================
  xyres                     = res
  xyres@xyMarkLineMode      = "MarkLines"
  xyres@xyMarkerThicknessF  = 3
  xyres@xyLineThicknessF    = 4.0      
  xyres@xyLineColor         = "NavyBlue"

xyres@xyExplicitLegendLabels   = (/"line"/)
xyres@pmLegendDisplayMode       = "Always"   ; Display a legend.


 xyres@pmLegendSide             = "Top"               ; Change location of 
 xyres@pmLegendParallelPosF     = 0.185                 ; move units right
 xyres@pmLegendOrthogonalPosF   = -0.48                ; move units down
 
  xyres@pmLegendWidthF          = 0.12                ; Change width and
  xyres@pmLegendHeightF         = 0.05                ; height of legend.
  xyres@lgLabelFontHeightF      = 0.01                 ; change font height
  xyres@lgPerimOn               = False      ; legend perimeter.


;---Turn off bottom, top, and left tickmarks
  xyres@tmXBOn              = False
;  xyres@tmXTOn              = False
  xyres@tmYLOn              = False
;  xyres@tmYROn              = False
;  xyres@tmYRLabelsOn        = False
 
  xyres@trXMinF              = -1 
  xyres@trXMaxF              = dimsizes(line)

  xyres@vpXF      = vpx
  xyres@vpYF      = vpy
  xyres@vpWidthF  = vpw 
  xyres@vpHeightF = vph 
  xyres@gsnDraw    =False
  xyres@gsnFrame   =False

 xy_plot = gsn_csm_xy (wks,bars,line,xyres)


  anno_id  = gsn_add_annotation(plot_with_xgrid, xy_plot, False)



  pres             = True
  pres@gsnMaximize = True
  maximize_output(wks,pres)


;frame(wks)


end
