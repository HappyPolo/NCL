;*************************************************
; panel_39.ncl
;
; Concepts illustrated:
;   - Using gsnPanelDebug to get position and size information
;   - Paneling plots using vp resources
;
;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************************

begin
;---Generate four sets of dummy data.
  u1 = generate_2d_array( 5, 10, -19, 16, 0, (/100,100/))
  u2 = generate_2d_array( 3, 15,  10, 50, 1, (/100,100/))
  u3 = generate_2d_array( 8, 13, -30,-10, 2, (/100,100/))
  u4 = generate_2d_array( 4, 12,  30, 90, 3, (/100,100/))


;---Color maps to use for each plot
  color_maps = (/"BlueDarkRed18","BrownBlue12",\
                 "BlueDarkOrange18","GreenMagenta16"/)

;---Open PNG workstation.
  wks = gsn_open_wks("png","panel")

;---Create arrays to hold plots.
  plot = new(4,graphic)

;---Set up resources.
  res                     = True
  res@gsnDraw             = False
  res@gsnFrame            = False

  res@cnFillOn            = True
  res@cnLinesOn           = False

  res@cnFillPalette       = color_maps(0)
  res@gsnRightString      = "PLOT 1"
  res@gsnLeftString	  = "DUMMY DATA"
  plot(0) = gsn_csm_contour(wks,u1,res)

  res@cnFillPalette       = color_maps(1)
  res@gsnRightString      = "PLOT 2"
  res@gsnLeftString	  = "DUMMY DATA"
  plot(1) = gsn_csm_contour(wks,u2,res)

  res@cnFillPalette       = color_maps(2)
  res@gsnRightString      = "PLOT 3"
  res@gsnLeftString	  = "DUMMY DATA"
  plot(2) = gsn_csm_contour(wks,u3,res)

  res@cnFillPalette       = color_maps(3)
  res@gsnRightString      = "PLOT 4"
  res@gsnLeftString	  = "DUMMY DATA"
  plot(3) = gsn_csm_contour(wks,u4,res)

;
; Panel these four plots with gsnPanelDebug set to True,
; so it will print out the viewport values used for 
; the four plots.
;
  pres               = True
  pres@gsnPanelDebug = True
  gsn_panel(wks,plot,(/2,2/),pres)

;
; The output from gsnPapelDebug=True is:
;
;   There are 4 valid plots out of 4 total plots
;   -------Panel viewport values for each plot-------
;       plot #0
;       new x,y      = 0.151784,0.972398
;       orig wdt,hgt = 0.6,0.6
;       new wdt,hgt  = 0.335466,0.335466
;   -------Panel viewport values for each plot-------
;       plot #1
;       new x,y      = 0.539827,0.972398
;       orig wdt,hgt = 0.6,0.6
;       new wdt,hgt  = 0.335466,0.335466
;   -------Panel viewport values for each plot-------
;       plot #2
;       new x,y      = 0.151784,0.472398
;       orig wdt,hgt = 0.6,0.6
;       new wdt,hgt  = 0.335466,0.335466
;   -------Panel viewport values for each plot-------
;       plot #3
;       new x,y      = 0.539827,0.472398
;       orig wdt,hgt = 0.6,0.6
;       new wdt,hgt  = 0.335466,0.335466

;
; 
; Using the "new" values above, you can set the vpXXX resources by hand
; and not use gsn_panel at all. Note that these plots all are the same
; size, so you only need to set vpWidthF and vpHeightF once
;
;
  res@gsnDraw   = True   ; Turn draw back on

  res@vpWidthF  = 0.335466
  res@vpHeightF = 0.335466

;---Draw first plot in upper left corner
  res@vpXF      = 0.151784
  res@vpYF      = 0.972398
  res@cnFillPalette = color_maps(0)
  plot(0) = gsn_csm_contour(wks,u1,res)

;---Draw second plot in upper right corner
  res@vpXF      = 0.539827
  res@cnFillPalette = color_maps(1)
  plot(1) = gsn_csm_contour(wks,u2,res)

;---Draw third plot in lower left corner
  res@vpXF      = 0.151784
  res@vpYF      = 0.472398
  res@cnFillPalette = color_maps(2)
  plot(2) = gsn_csm_contour(wks,u3,res)

;---Draw fourth plot in upper right corner
  res@vpXF      = 0.539827
  res@cnFillPalette = color_maps(3)
  plot(3) = gsn_csm_contour(wks,u4,res)

  frame(wks)



end