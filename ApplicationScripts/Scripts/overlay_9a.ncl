;----------------------------------------------------------------------
; overlay_9a.ncl
;
; Concepts illustrated:
;   - Overlaying two contour plots that are in different data spaces
;   - Generating a bullseye pattern for contours
;   - Overlaying line contours on filled contours
;   - Using cnFillPalette to assign a color palette to contours
;   - Drawing titles on both Y axes
;   - Using functions for cleaner code
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;----------------------------------------------------------------------
;  Function to attach title to right Y axis
;----------------------------------------------------------------------
function add_right_title(wks,plot,title)
local txres, font_height, txid, amres
begin
;---Retrieve font height of left axis string.
  getvalues plot
    "tiXAxisFontHeightF" : font_height
  end getvalues

;---Create a right axis text string to add to plot.
  txres               = True
  txres@txAngleF      = 90.          ; Rotate string clockwise 
  txres@txFontHeightF = font_height  ; Use same font height as left axis

  txid = gsn_create_text(wks, title, txres)

;---Move text string to center/right edge of plot.
  amres                  = True
  amres@amParallelPosF   = 0.66   ; 0.5 is the right edge of the plot, so
                                  ; 0.66 is a little further to the right.
  amres@amOrthogonalPosF = 0.0    ; This is the center of the plot.
  amres@amJust           = "CenterCenter"
  annoid = gsn_add_annotation(plot, txid, amres)  ; Attach string to plot
  return(annoid)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
;----------------------------------------------------------------------
; Generate dummy data for 1st contour plot
;----------------------------------------------------------------------
  M     = 25
  ispn  = conform_dims((/M,M/),ispan(-M/2,M/2,1)^2,1)
  jspn  = conform_dims((/M,M/),ispan(-M/2,M/2,1)^2,0)
  data1 = 100. - sqrt(64*(jspn + ispn))

;---Add dummy coordinate arrays
  data1!0 = "y"
  data1!1 = "x"
  data1&x = ispan(1,M,1)
  data1&y = fspan(1000,10,M) 

;----------------------------------------------------------------------
; Generate dummy data for 2nd contour plot
;----------------------------------------------------------------------
  data2 = generate_2d_array(10, 10, -19.,16., 0, (/M,M/))

;---Add dummy coordinate arrays in a different data space
  data2!0 = "y"
  data2!1 = "x"
  data2&x = data1&x          ; Same as first dataset
  data2&y = ispan(1,M,1)     ; Different than first dataset

;----------------------------------------------------------------------
; Start the graphics
;----------------------------------------------------------------------
  wks = gsn_open_wks("png","overlay")  ; send graphics to PNG file

;----------------------------------------------------------------------
; Line contour plot
;----------------------------------------------------------------------

  cnres                        = True
  cnres@gsnDraw                = False
  cnres@gsnFrame               = False

  cnres@cnLinesOn                 = True      ; Line contours
  cnres@cnLineColor               = "DarkOrchid4"
  cnres@cnFillOn                  = False
  cnres@cnLineLabelsOn            = True
  cnres@cnLineThicknessF          = 2.0
  cnres@cnInfoLabelOrthogonalPosF = -0.13    ; Move into plot
  cnres@trYReverse                = False    

  cnres@tfDoNDCOverlay            = True  ; Line up four axes of both plots.
                                          ; No mathematical transformation
                                          ; is done.
;---Create line contour plot
  contour_ovly = gsn_csm_contour(wks,data2,cnres)

;---Get the labels used on the Y axis, so we can use these in final plot
  getvalues contour_ovly
    "tmYLValues" : y2values
    "tmYLLabels" : y2labels
  end getvalues

;
; Assuming a linear relationship, calculate how the labels of
; the line plot will correspond with the labels of the first plot.
; We'll use this information to label the right Y axis.
;
  y1range  = max(data1&y) - min(data1&y) 
  y2range  = max(data2&y) - min(data2&y) 
  yrvalues = (1-(y2values/y2range))*y1range

;----------------------------------------------------------------------
; Filled contour plot
;----------------------------------------------------------------------
  cnres@cnFillOn                = True        ; filled contours
  cnres@cnFillPalette           = "BlueYellowRed"
  cnres@cnLinesOn               = False
  cnres@cnLineLabelsOn          = False
  cnres@lbOrientation           = "Horizontal"

;---Titles
  cnres@tiMainString            = "Overlaying two datasets w/different Y axes"
  cnres@tiYAxisString           = "Filled contour Y axis string"

;---Labels for right Y axis
  cnres@tmYUseLeft              = False
  cnres@tmYRLabelsOn            = True
  cnres@tmYRMode                = "Explicit"
  cnres@tmYRValues              = yrvalues
  cnres@tmYRLabels              = y2labels

  cnres@trYReverse              = True     ; Just for fun

;---Create filled contour plot
  contour_base = gsn_csm_contour(wks,data1,cnres)

;
; Since tfDoNDCOverlay was set to True, it doesn't care that the two
; plots are in different data spaces. It simply lines up one plot
; with the other, and also removes titles and tickmarks from the
; overlay plot. This is why we added labels to the right Y axis
; explicitly.
;
  overlay(contour_base,contour_ovly)

;---Add a right title
  id = add_right_title(wks,contour_base,"Line contour Y axis string")

;
; Since we added string to outside of plot area, we need to 
; resize the plot so that it fits in the given workstation.
; This function draws the plot and advances the frame.
;
  psres = True                                                               
  psres@gsnPaperOrientation = "Portrait"
  maximize_output(wks,psres)
end
