;----------------------------------------------------------------------
;  lb_horz_22.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Attaching a custom labelbar to a bar chart
;   - Applying fill opacities to filled elements
;   - Using functions for cleaner code
;----------------------------------------------------------------------
; Population data acquired from 
; http://www.worldometers.info/world-population/population-by-country/

; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;----------------------------------------------------------------------
; This procedure adds a labelbar to the top right corner of the given 
; plot, given a list of labels, fill colors, and an opacity value.
;
; The lbFillOpacityF resource was added in NCL V6.4.0.
;----------------------------------------------------------------------
undef("add_labelbar")
procedure add_labelbar(wks,plot,labels,colors,opacity_value)
local lbres, vph, vpw, lbid, amres
begin
  getvalues plot                      ; Get plot size for use in
    "vpHeightF" : vph                 ; creating labelbar.
    "vpWidthF"  : vpw
  end getvalues

  nboxes = dimsizes(colors)

  lbres                    = True          ; labelbar only resources
  lbres@lbAutoManage       = True          ; Necessary to control sizes
  lbres@vpWidthF           = 0.2 * vpw     ; labelbar width
  lbres@vpHeightF          = 0.7 * vph     ; labelbar height
  lbres@lbBoxMajorExtentF  = 0.85          ; puts space between color boxes
  lbres@lbFillColors       = colors(::-1,:)        ; labelbar colors
  lbres@lbMonoFillPattern  = True          ; Solid fill pattern
  lbres@lbLabelFontHeightF = 0.08          ; font height. default is small
  lbres@lbLabelJust        = "CenterLeft"  ; left justify labels
  lbres@lbLabelAutoStride  = False
  lbres@lbLabelStride      = 1
  lbres@lbFillOpacityF     = opacity_value

  lbid = gsn_create_labelbar(wks,nboxes,labels(::-1),lbres)
   
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
  amres@amParallelPosF   =  0.4
  amres@amOrthogonalPosF =  -0.5
  plot@annoid = gsn_add_annotation(plot,lbid,amres)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
;---Generate list of 30 countries with the highest populations.
  countries = (/"China","India","U.S.","Indonesia","Brazil","Pakistan",\
                "Nigeria","Bangladesh","Russia","Mexico","Japan",\
                "Philippines","Ethiopia","Viet Nam","Egypt","Germany",\
                "Iran","DR Congo","Turkey","Thailand","U.K.","France",\
                "Italy","Tanzania","South Africa","Myanmar","South Korea",\
                "Colombia","Kenya","Spain"/)
  population = (/1382323332,1326801576,324118787,260581100,209567920,\
                  192826502, 186987563,162910864,143439832,128632004,\
                  126323715, 102250133,101853268, 94444200, 93383574,\
                   80682351, 80043146,  79722624, 79622062, 68146609,\
                   65111143, 64668129,  59801004, 55155473, 54978907,\
                   54363426, 50503933,  48654392, 47251449, 46064604/) 
  ncountries = dimsizes(countries)
  x          = ispan(1,ncountries,1)

  rgba      = span_color_rgba("matlab_jet",ncountries)


;---Start the graphics
  wks = gsn_open_wks("png","lb_horz")              ; send graphics to PNG file

  res                       = True                 ; plot mods desired         
  res@gsnMaximize           = True                 ; maximize plot in frame
  res@gsnDraw               = False                ; don't draw plot yet
  res@gsnFrame              = False                ; don't advance frame yet

  res@trXMinF               = 0                   ; bring bars down to zero
  res@trYMinF               = min(x) - 1          ; adds space on either end
  res@trYMaxF               = max(x) + 1          ; of the 1st and last bars
  
  res@gsnXYBarChart         = True                 ; turn on bar chart
  res@gsnXYBarChartBarWidth = 0.75                 ; change bar widths
  res@gsnXYBarChartColors   = rgba
  res@gsnXRefLine           = 0
  
  res@tmYLOn                = False                ; turn off X tickmarks and labels

;---Labels for X axis
  res@tmXBMode              = "Explicit"
  res@tmXBValues            = ispan(0,14,2)*1e8
;  res@tmXBLabels            = (/"0","200 million","400 million","600 million","800 million",\
;                                "1 billion","1.2 billion", "1.4 billion"/)
  res@tmXBLabels            = (/"0", "200M", "400M", "600M", "800M", "1BN", \
                              "1.2BN", "1.4BN"/)

  res@tiMainString          = "Top " + ncountries + " most populous countries in 2016"

;---Create first plot; no opacities applied
  res@tiXAxisString = "No opacity applied"
  plot = gsn_csm_xy (wks,population,x,res)     ; Create plot, but don't draw it yet.
  add_labelbar(wks,plot,countries,rgba,1.0)    ; Attach a custom labelbar to the plot
  draw(plot)                                   ; Draws plot and labelbar
  frame(wks)

;---Create second plot; opacity applied to labelbar colors only
  res@tiXAxisString = "Opacity applied to labelbar only"
  plot = gsn_csm_xy (wks,population,x,res)
  add_labelbar(wks,plot,countries,rgba,0.50)
  draw(plot)
  frame(wks)

;---Create third plot; multiple opacities applied to plot and labelbar
  rgba(:,3) = fspan(1,0.01,ncountries)
  res@gsnXYBarChartColors = rgba
  res@tiXAxisString = "Opacity applied to bars and labelbar"
  plot = gsn_csm_xy (wks,population,x,res)
  add_labelbar(wks,plot,countries,rgba,1.0)
  draw(plot)
  frame(wks)
end
