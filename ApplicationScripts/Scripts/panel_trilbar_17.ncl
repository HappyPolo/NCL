;*************************************************
; panel_trilbar_17.ncl
;
; Concepts illustrated:
;   - Combining two sets of paneled plots on one page
;   - Drawing two labelbars in a combined panel plot
;   - Generating dummy data using "generate_2d_array"
;   - Drawing extra text on a paneled plot
;   - Using cnFillPalette to assign a color palette to contours
;   - Using lbBoxEndCapStyle to draw triangles at the end of a labelbar
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
  u_em_f = generate_2d_array(10, 10, -19.69, 21.82, 0, (/129,129/))
  u_em_g = generate_2d_array(10, 10, -27.95, 19.05, 1, (/129,129/))
  u_es_f = generate_2d_array(10, 10,   1.00,  8.17, 2, (/129,129/))
  u_es_g = generate_2d_array(10, 10,   0.00,  6.89, 3, (/129,129/))

  wks = gsn_open_wks("png","panel_trilbar")   ; send graphics to PNG file

;
; Create arrays to hold plots.
;
  plot_U = new(2,graphic)
  plot_L = new(2,graphic)

;
; Set up resources.
;
  res                     = True
  res@gsnDraw             = False
  res@gsnFrame            = False

  res@cnFillOn            = True
  res@cnLinesOn           = False
  res@cnLineLabelsOn      = False

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

  res@tmXTOn                = False
  res@tmYROn                = False
  res@tmXBMinorOn           = False
  res@tmYLMinorOn           = False
  res@tmYRMinorOn           = False
  res@tfDoNDCOverlay        = True          ; native projection

  res@lbLabelBarOn          = False         ; add labelbar later

  res@cnLevelSelectionMode  = "ManualLevels"; manually manage contour levels
  res@cnMinLevelValF	    = -20
  res@cnMaxLevelValF	    =  20
  res@cnLevelSpacingF	    = 2.5

  res@cnFillPalette         = "testcmap"
  res@gsnRightString        = "PLOT 1"
  res@gsnLeftString	    = "DUMMY DATA"
  plot_U(0) = gsn_csm_contour_map(wks,u_em_f,res)

  res@gsnRightString    = "PLOT 2"
  res@gsnLeftString	= "DUMMY DATA"
  plot_U(1) = gsn_csm_contour_map(wks,u_em_g,res)

  res@cnFillPalette      = "precip_11lev"
  res@cnMinLevelValF	 = 1
  res@cnMaxLevelValF   	 = 8
  res@cnLevelSpacingF	 = 1

  res@gsnRightString    = "PLOT 3"
  res@gsnLeftString	= "DUMMY DATA"
  plot_L(0) = gsn_csm_contour_map(wks,u_es_f,res)

  res@gsnRightString    = "PLOT 4"
  res@gsnLeftString	= "DUMMY DATA"
  plot_L(1) = gsn_csm_contour_map(wks,u_es_g,res)

;
; Panel these plots.  We want to have a main string, and two sets of panels
; in which the plots in both sets are the same size.  So, we create a panel
; space for the two sets of plots that's the same size using the
; gsnPanelTop/gsnPanelBottom resources, and then we draw the main title
; string separately at the top with gsn_text_ndc.
;
  res_U                   = True
  res_U@gsnFrame          = False
  res_U@gsnPanelTop       = 0.90
  res_U@gsnPanelBottom    = 0.45
  res_U@gsnPanelLabelBar  = True
  res_U@pmLabelBarWidthF  = 0.6
  res_U@lbBoxEndCapStyle  = "TriangleBothEnds"     ; default is "RectangleEnds"
  
  res_L                   = True
  res_L@gsnFrame          = False
  res_L@gsnPanelTop       = 0.45
  res_L@gsnPanelLabelBar  = True
  res_L@pmLabelBarWidthF  = 0.6
  res_L@lbBoxEndCapStyle  = "TriangleHighEnd"     ; Low end will have rectangle end

  txres               = True
  txres@txFontHeightF = 0.03
  gsn_text_ndc(wks,"lbBoxEndCapStyle: triangle-end labelbars",0.5,0.95,txres)
  
  gsn_panel(wks,plot_U,(/1,2/),res_U)
  gsn_panel(wks,plot_L,(/1,2/),res_L)
  
  frame(wks)
end

