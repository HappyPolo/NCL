;*************************************************
; panel_22.ncl
;
; Concepts illustrated:
;   - Combining two sets of paneled plots on one page
;   - Drawing two labelbars in a combined panel plot
;   - Drawing two main titles in a combined panel plot
;   - Generating dummy data using "generate_2d_array"
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************************

begin
;
; Generate some dummy data.
;
  u_em_f = generate_2d_array(10, 10, -19.69, 15.82, 0, (/129,129/))
  u_em_g = generate_2d_array(10, 10, -27.95, 15.85, 1, (/129,129/))
  u_es_f = generate_2d_array(10, 10,   1.00,  7.17, 2, (/129,129/))
  u_es_g = generate_2d_array(10, 10,   0.00,  6.89, 3, (/129,129/))

;
; Open PNG workstation.
;
  wks = gsn_open_wks("png","panel")

;
; Create arrays to hold plots.
;
  plot_L = new(2,graphic)
  plot_R = new(2,graphic)

;
; Set up resources.
;
  res                     = True
  res@gsnDraw             = False
  res@gsnFrame            = False

  res@cnFillOn            = True
  res@cnFillPalette       = "testcmap"
  res@cnLinesOn           = False

; Map

  res@mpLimitMode         = "Corners"
  res@mpLeftCornerLatF    =  29.44295
  res@mpLeftCornerLonF    = -86.81332
  res@mpRightCornerLatF   =  46.52098
  res@mpRightCornerLonF   = -64.54309

  res@mpCenterLonF        = -76.99792
  res@mpCenterLatF        =  38.50165
  res@mpLambertParallel1F =  38.5
  res@mpLambertParallel2F =  38.5
  res@mpLambertMeridianF  = -76.99792
  res@cnLevelSelectionMode = "ManualLevels"

  res@tmXTOn                = False
  res@tmYROn                = False
  res@tmXBMinorOn           = False
  res@tmYLMinorOn           = False
  res@tmYRMinorOn           = False
  res@tfDoNDCOverlay        = True          ; native projection

  res@lbLabelBarOn          = False         ; add labelbar later

  res@pmTickMarkDisplayMode = "Always"

  res@cnMinLevelValF	    = -20
  res@cnMaxLevelValF	    =  20
  res@cnLevelSpacingF	    = 2.5

  res@gsnRightString        = "PLOT 1"
  res@gsnLeftString	    = "DUMMY DATA"
  plot_L(0) = gsn_csm_contour_map(wks,u_em_f,res)

  res@gsnRightString    = "PLOT 2"
  res@gsnLeftString	= "DUMMY DATA"
  plot_L(1) = gsn_csm_contour_map(wks,u_em_g,res)

  res@cnMinLevelValF	= 0
  res@cnMaxLevelValF	= 8
  res@cnLevelSpacingF	= 1

  res@gsnRightString    = "PLOT 3"
  res@gsnLeftString	= "DUMMY DATA"
  plot_R(0) = gsn_csm_contour_map(wks,u_es_f,res)

  res@gsnRightString    = "PLOT 4"
  res@gsnLeftString	= "DUMMY DATA"
  plot_R(1) = gsn_csm_contour_map(wks,u_es_g,res)

;
; Panel these plots as two panels, each with one column and two rows. 
; We want each row to have its own main string, in which the plots in
; both sets are the same size.  So, we create a panel space for the
; two sets of plots that's the same size using the
; gsnPanelLeft/gsnPanelRight resources, and then we draw the main title
; strings using txString, and txPosXF to position each string, since the
; default is to center it in the middle of the page.
;
; You can set res_R@gsnPanelDebug and res_L@gsnPanelDebug to True to get
; the exact values of the new position and sizes of the plots. This way you
; can calculate what the new title positions are supposed to be. (The
; "new x" position plus 1/2 of the "new wdt" should be a good value
; for txPosXF.)
;
  res_L                    = True
  res_L@gsnFrame           = False
  res_L@gsnPanelRight      = 0.50
  res_L@gsnPanelLabelBar   = True
  res_L@gsnPanelMainString = "String for left column"  
  res_L@gsnPanelMainFont   = "helvetica-bold"
  res_L@gsnPanelMainPosXF  = 0.275
  res_L@pmLabelBarParallelPosF = 0.015
  
  res_R                    = True
  res_R@gsnFrame           = False
  res_R@gsnPanelLeft       = 0.50
  res_R@gsnPanelLabelBar   = True
  res_R@gsnPanelMainString = "String for right column"  
  res_R@gsnPanelMainFont   = "helvetica-bold"
  res_R@gsnPanelMainPosXF  = 0.775
  res_R@pmLabelBarParallelPosF = 0.015
  
  gsn_panel(wks,plot_L,(/2,1/),res_L)
  gsn_panel(wks,plot_R,(/2,1/),res_R)
  
  frame(wks)
end
