;----------------------------------------------------------------------
; panel_36.ncl
;
; Concepts illustrated:
;   - Paneling four plots on a page
;   - Drawing a custom labelbar
;   - Generating dummy data
;   - Using "getvalues" to retrieve resource values
;   - Using cnFillPalette to assign a color palette to contours
;   - Adding a common title to paneled plots
;----------------------------------------------------------------------
; This example shows how to draw four plots on one page, where the top
; two plots have unique color bars, and the bottom two plots share the
; same color bar. gsn_panel is used to draw all four plots.
;
; The labelbars are turned on for all four plots, to make sure that
; all plots are exactly the same size. However, the 3rd and 4th plots'
; labelbars are effectively not seen, because they are being
; drawn with transparent and white colors. This allows us to then
; drawn a custom labelbar for these two plots, over these "hidden"
;  labelbars.
; 
; See "panel_vp_36.ncl" for another way to draw a similar graphic,
; using viewport resources (instead of gsn_panel) to resize and 
; position each plot.
;----------------------------------------------------------------------
; Note: this example may generate the safe, but annoying warning:
; warning:lbFillColors is not a valid resource in panel_contour at this time
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;---Generate 4 dummy data sets, with data3 and data4 having similar ranges.
  nx    = 100
  ny    = 100
  data1 = generate_2d_array(10, 10, -19.,16., 0, (/ny,nx/))
  data2 = generate_2d_array(10, 10,   0.,100., 3, (/ny,nx/))
  data3 = generate_2d_array(10, 12, -50.,10., 1, (/ny,nx/))
  data4 = generate_2d_array(10, 15, -40.,20., 2, (/ny,nx/))

;---Set some constants to use in the graphics later.
  ypos_lbar     = 0.10             ; y position of bottom labelbar
  color_plot1   = "BlueRed"        ; color map for 1st plot
  color_plot2   = "BlueYellowRed"  ; color map for 2nd plot
  color_plots34 = "NCV_banded"     ; color map for 3rd and 4th plots

;---Start the graphics.
  wks = gsn_open_wks("png","panel")    ; send graphics to PNG file

;---Set resources common to all four plots
  res                      = True
  res@gsnDraw              = False
  res@gsnFrame             = False
  res@cnLineLabelsOn       = False     ; Turn off contour line labels
  res@cnFillOn             = True      ; Turn on contour fill
  res@cnInfoLabelOn        = False     ; Turn off info label

  res1                     = res
  res1@cnFillPalette       = color_plot1
  res1@lbLabelBarOn        = True
  plot1 = gsn_csm_contour(wks,data1,res1)

  res2                     = res
  res2@cnFillPalette       = color_plot2
  res@cnLevelSelectionMode = "ManualLevels"
  res2@lbLabelBarOn        = True
  res2@cnMinLevelValF      = 0.
  res2@cnMaxLevelValF      = 100.
  res2@cnLevelSpacingF     = 2.5
  plot2 = gsn_csm_contour(wks,data2,res2)

;
; Create a large array of -1 values to more than cover 
; how many contour levels we might have.
;
  lbcolors_transparent = conform_dims(50,-1,-1)
  res3                     = res
  res3@cnFillPalette       = color_plots34
  res3@lbLabelFontColor    = "white"                ; this makes the labelbar labels invisible
  res3@lbBoxLinesOn        = False
  res3@lbFillColors        = lbcolors_transparent   ; the colors are fully transparent
  plot3 = gsn_csm_contour(wks,data3,res3)

  res4                     = res
  res4@cnFillPalette       = color_plots34
  res4@lbLabelFontColor    = "white"                ; this makes the labelbar labels invisible
  res4@lbBoxLinesOn        = False
  res4@lbFillColors        = lbcolors_transparent   ; the colors are fully transparent
  plot4 = gsn_csm_contour(wks,data4,res4)

  pres                = True
  pres@gsnPanelMainString = "Four plots, one title, three labelbars"
  pres@gsnMaximize    = True
  pres@gsnFrame       = False
  pres@gsnPanelSave   = True   ; a secret resource telling NCL to leave the paneled plots in their resized format.
  gsn_panel(wks,(/plot1,plot2,plot3,plot4/),(/2,2/),pres)

;
; Retrieve the size and location of the 3rd and 4th plots and their labelbar 
; info, so we can recreate a common labelbar for both plots.
; 
  getvalues plot3
    "vpXF"               : vpx3     ; this is for positioning the common labelbar
    "lbLabelFontHeightF" : font_height
    "lbLabelStrings"     : labels
  end getvalues
  getvalues plot4
    "vpXF"               : vpx4     ; this is for positioning 
    "vpWidthF"           : vpw4     ; the common lablebar
  end getvalues
  nlabels = dimsizes(labels)

;---Set some labelbar resources
  lbcolors_fill            = span_color_rgba(res3@cnFillPalette,nlabels+1)
  lbres                    = True
  lbres@vpWidthF           = (vpx4 + vpw4) - vpx3
  lbres@vpHeightF          = 0.08
  lbres@lbAutoManage       = False
  lbres@lbOrientation      = "horizontal"
  lbres@lbJustification    = "CenterCenter"
  lbres@lbMonoFillPattern  = True
  lbres@lbFillColors       = lbcolors_fill
  lbres@lbLabelFontHeightF = font_height
  lbres@lbPerimOn          = False

;---Draw a labelbar at the bottom of the frame
  gsn_labelbar_ndc(wks,nlabels,labels,vpx3,ypos_lbar,lbres)

;---Now that we have everything drawn, advance the frame
  frame(wks)
end

