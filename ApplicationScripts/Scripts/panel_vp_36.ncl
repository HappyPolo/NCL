;----------------------------------------------------------------------
; panel_36_vp.ncl
;
; Concepts illustrated:
;   - Using viewport resources to specify the locations of plots
;   - Drawing a custom labelbar
;   - Drawing a custom title
;   - Generating dummy data
;   - Using "getvalues" to retrieve resource values
;   - Using cnFillPalette to assign a color palette to contours
;----------------------------------------------------------------------
;
; This example shows how to draw four plots on one page, where the top
; two plots have unique color bars, and the bottom two plots share the
; same color bar. Viewport resources are used to position the four
; plots, and then the title and labelbar are created separately and
; drawn, also using viewport resources.
; 
; See "panel_36.ncl" for another way to draw a similar graphic,
; using "gsn_panel".
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"


begin
;---Generate 4 dummy data sets, with data3 and data4 having similar ranges.
  nx    = 100
  ny    = 100
  data1 = generate_2d_array(10, 10, -19., 16., 0, (/ny,nx/))
  data2 = generate_2d_array(10, 10,   0.,100., 3, (/ny,nx/))
  data3 = generate_2d_array(10, 12, -50., 10., 1, (/ny,nx/))
  data4 = generate_2d_array(10, 15, -40., 20., 2, (/ny,nx/))

;---Set some constants to use in the graphics later.
  xpos_title    = 0.50             ; x position of main title
  ypos_title    = 0.96             ; y position of main title
  xpos_lbar     = 0.10             ; x position of bottom labelbar
  ypos_lbar     = 0.10             ; y position of bottom labelbar
  xpos_plots13  = 0.16             ; x position of 1st and 3rd plots
  xpos_plots24  = 0.54             ; x position of 2nd and 4th plots
  ypos_plots12  = 0.92             ; y position of 1st and 2nd pots
  ypos_plots34  = 0.46             ; y position of 3rd and 4th plots
  plots_wh      = 0.32             ; width and height of all plots
  color_plot1   = "BlueRed"        ; color map for 1st plot
  color_plot2   = "BlueYellowRed"  ; color map for 2nd plot
  color_plots34 = "NCV_banded"     ; color map for 3rd and 4th plots

;---Start the graphics.
  wks = gsn_open_wks("png","panel_vp") ; send graphics to PNG file

;---Set resources common to all four plots
  res                      = True
  res@gsnFrame             = False     ; Each plot will be drawn in same frame
  res@vpWidthF             = plots_wh
  res@vpHeightF            = plots_wh
  res@cnLineLabelsOn       = False     ; Turn off contour line labels
  res@cnFillOn             = True      ; Turn on contour fill
  res@cnInfoLabelOn        = False     ; Turn off info label

;---Set resources for first plot (upper left)
  res1                     = res
  res1@vpXF                = xpos_plots13
  res1@vpYF                = ypos_plots12
  res1@cnFillPalette       = color_plot1
  plot1 = gsn_csm_contour(wks,data1,res1)

;---Set resources for second plot (upper right)
  res2                     = res
  res2@vpXF                = xpos_plots24
  res2@vpYF                = ypos_plots12
  res2@cnLevelSelectionMode= "ManualLevels"
  res2@cnMinLevelValF      = 0.
  res2@cnMaxLevelValF      = 100.
  res2@cnLevelSpacingF     = 2.5
  res2@cnFillPalette       = color_plot2
  plot2 = gsn_csm_contour(wks,data2,res2)

;---Set resources for third plot (lower left)
  res3                     = res
  res3@vpYF                = ypos_plots34
  res3@vpXF                = xpos_plots13
  res3@lbLabelBarOn        = False
  res3@cnFillPalette       = color_plots34
  plot3 = gsn_csm_contour(wks,data3,res3)

;---Set resources for fourth plot (lower right)
  res4                     = res
  res4@vpXF                = xpos_plots24
  res4@vpYF                = ypos_plots34
  res4@lbLabelBarOn        = False
  res4@cnFillPalette       = color_plots34
  plot4 = gsn_csm_contour(wks,data4,res4)

;---Retrieve strings and font size for labelbar for use in panel plot
  getvalues plot3
    "lbLabelStrings"     : labels
    "lbLabelFontHeightF" : font_height
  end getvalues
  nlabels = dimsizes(labels)

;---Draw a main title at top of frame
  txres                    = True
  txres@txFontHeightF      = 0.02
  gsn_text_ndc(wks,"Four plots, one title, three labelbars",\
               xpos_title,ypos_title,txres)

;---Set some labelbar resources
  lbcolors_fill            = span_color_rgba(res3@cnFillPalette,nlabels+1)
  lbres                    = True
  lbres@vpWidthF           = (xpos_plots24 + plots_wh) - xpos_plots13
  lbres@vpHeightF          = 0.08
  lbres@lbAutoManage       = False
  lbres@lbOrientation      = "horizontal"
  lbres@lbJustification    = "CenterCenter"
  lbres@lbMonoFillPattern  = True
  lbres@lbFillColors       = lbcolors_fill
  lbres@lbLabelFontHeightF = font_height
  lbres@lbPerimOn          = False

;---Draw a labelbar at the bottom of the frame
  gsn_labelbar_ndc(wks,nlabels,labels,xpos_plots13,ypos_lbar,lbres)

;---Now that we have everything drawn, advance the frame
  frame(wks)

end

