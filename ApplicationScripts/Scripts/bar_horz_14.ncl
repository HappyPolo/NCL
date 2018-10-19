;********************************************************
; bar_horz_14.ncl
;
; Concepts illustrated:
;   - Drawing an XY curve on top of filled bars
;   - Using gsn_add_annotation to attach one plot as an annotation of another
;   - Changing the width of the bars in a bar plot
;   - Filling the bars in a bar plot with different colors
;   - Setting the minimum/maximum value of the X and Y axis in a bar plot
;   - Rotating the X axis string 45 degrees
;   - Drawing an X reference line in an XY plot
;   - Changing the color and thickness of an X reference line
;********************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;---Create some dummy data
  nmos = 12

;---Dummy X axis values
  x      = ispan(1,nmos,1)
  xrange = max(x) - min(x)
  deltax = xrange/10.

;---Dummy bar chart values (units="mm")
  y1 = random_uniform(0,100,nmos)

;---Dummy XY curve values (units="deg C")
  av    = 30.
  sd    = 10.
  y2 = random_normal(av,sd,nmos)

;---Start the graphics
  wks = gsn_open_wks("png","bar_horz")             ; send graphics to PNG file

;---Set resources common to both plots
  res                       = True                 ; plot mods desired         
  res@gsnFrame              = False
  res@gsnDraw               = False

  res@trYMinF               = min(x) - deltax
  res@trYMaxF               = max(x) + deltax
  res@trXMinF               = 0.0    ; set to same for both plots
                                     ; we'll let ncl set the max X
;---XY curve resources
  xyres                     = res
  xyres@xyLineThicknessF    = 2.0               ; default is 1.0
  xyres@xyLineColor         = "NavyBlue"

;---Turn off bottom, top, and left tickmarks
  xyres@tmYLOn              = False
  xyres@tmYROn              = False
  xyres@tmXBOn              = False
  xyres@tmXTOn              = True
  xyres@tmXTLabelsOn        = True

;---Set a title on right Y axis.
  xyres@tiXAxisString       = "~S~o~N~C"
  xyres@tiXAxisSide         = "Top"

  xyres@gsnXRefLine           = 20               ; Draw horiz line at y=20
  xyres@gsnXRefLineColor      = "NavyBlue"
  xyres@gsnXRefLineThicknessF = 2.0

;---Bar chart resources
  bres                       = res  
  bres@gsnXYBarChart         = True            ; Turn on bar chart
  bres@gsnXYBarChartBarWidth = 0.75            ; Change bar widths
  bres@gsnXYBarChartColors   = "yellow"        ; Color for bars
  bres@tmXTOn                = False
  
  bres@trXMinF               = 0.              ; Make sure X axis starts at 0.

  bres@gsnXRefLine           = 0.

  bres@tiYAxisString         = "XY curve over a bar chart"
  bres@tiXAxisString         = "mm"

  bar_plot = gsn_csm_xy (wks,y1,x,bres)

;---Get viewport values for bar plot
  getvalues bar_plot
    "vpXF"      : vpx
    "vpYF"      : vpy
    "vpWidthF"  : vpw
    "vpHeightF" : vph
  end getvalues
;
; Make sure XY curve is drawn in same viewport space as bar plot
; Note there is no attempt to mathematically map the left and 
; right Y axis to each other. 
;
  xyres@vpXF      = vpx
  xyres@vpYF      = vpy
  xyres@vpWidthF  = vpw
  xyres@vpHeightF = vph

  xy_plot = gsn_csm_xy (wks,y2,x,xyres)

;
; The default behavior of gsn_add_annotation is is to add one 
; plot to the dead center of the other. We don't need to 
; set any "annotation" resources here.
;
  anno_id  = gsn_add_annotation(bar_plot, xy_plot, False)

;
; "maximize_output" will resize graphics to maximize them
; on the page. This is necessary so that right Y axis
; labels don't run off the page.
;
  pres             = True
  pres@gsnMaximize = True
  maximize_output(wks,pres)
  
end
