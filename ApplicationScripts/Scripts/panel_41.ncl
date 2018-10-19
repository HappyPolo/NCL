;----------------------------------------------------------------------
; panel_41.ncl
;
; Concepts illustrated:
;   - Paneling six plots on a page
;   - Adding a common title to paneled plots using a custom method
;   - Adding left, center, and right subtitles to a panel plot
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;----------------------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"


;----------------------------------------------------------------------
; Procedure to add a main title and left, center, and right subtitles 
; to a page that has paneled plots. Set any title to an empty string
; ("") if it is not desired.
;
; One can certainly draw the main title using gsnPanelMainString, but 
; this procedure does it by hand here so it can better control the 
; position with respect to the subtitles.
; 
; This procedure assumes that the paneled plots have already been 
; created with a margin left at the top for titles. It will print a
; warning if it thinks there's not enough room.
;----------------------------------------------------------------------
procedure draw_panel_titles(wks,plots,main_title,left_title,center_title,right_title)
local n, bb, top, rgt, lft, max_top, min_lft, max_rgt, vpx, vpw, xpos, ypos, \
valid_class_types, nplots, txres, main_title_font_height, sub_title_font_height,\
title_margin
begin
  valid_class_types = (/"xyPlotClass","contourPlotClass","mapPlotClass","vectorPlotClass"/)
;
; Loop through each paneled plot and retrieve the NDC locations of the
; topmost plots. This information will be used for positioning the 
; titles later.
;
  nplots = dimsizes(plots)
  do n=0,nplots-1

;---Make sure this is a plot object, and not a labelbar object or something else.
    class = NhlClassName(plots(n))
    if(.not.any(class.eq.valid_class_types)) then
      continue
    end if
;
; If this is a plot object, then get the right, left, and top edges so
; we can determine where to add the subtitles.
;
    getvalues plots(n)
      "vpXF"     : vpx
      "vpWidthF" : vpw
    end getvalues
    bb  = NhlGetBB(plots(n))
    top = bb(0)     ; Top of plot, above any titles, tickmarks, etc.

    lft = vpx       ; left of plot edge (not including tickmarks)
    rgt = vpx+vpw   ; right of plot edge (not including tickmarks)
    if(n.eq.0)
      max_top = top
      max_rgt = rgt
      min_lft = lft
    else
      max_top = max((/max_top,top/))
      max_rgt = max((/max_rgt,rgt/))
      min_lft = min((/min_lft,lft/))
    end if
  end do

;---Set font height sizes and a margin between the plots and the titles
  main_title_font        = "helvetica-bold"
  sub_title_font         = "helvetica"
  sub_title_font_height  = 0.015
  main_title_font_height = 0.022
  sub_title_font_height  = 0.015
  title_margin           = 0.005

;---Set resources for subtitles
  txres = True
  txres@txFont        = sub_title_font
  txres@txFontHeightF = sub_title_font_height

;----------------------------------------------------------------------
; Add sub titles
;----------------------------------------------------------------------

;---Set Y position for three subtitles, and test that you have room.
  ypos = max_top + title_margin
  if(ypos.ge.1-(title_margin+sub_title_font_height)) then
    print("add_panel_titles: Warning: there may not be enough room for your titles.")
    print("   You may need to set gsnPanelTop equal to a value slightly smaller than " + \
           (1.-(title_margin+sub_title_font_height)))
  end if
  if(left_title.ne."")
    txres@txJust = "BottomLeft"
    xpos = min_lft
    gsn_text_ndc(wks,left_title,xpos,ypos,txres)
  end if

  if(center_title.ne."") then
    txres@txJust = "BottomCenter"
    xpos = (min_lft+max_rgt)*0.5
    gsn_text_ndc(wks,center_title,xpos,ypos,txres)
  end if

  if(right_title.ne."") then
    txres@txJust = "BottomRight"
    xpos = max_rgt
    gsn_text_ndc(wks,right_title,xpos,ypos,txres)
  end if

;----------------------------------------------------------------------
; Add main title, if any.
;----------------------------------------------------------------------
  if(main_title.ne."") then
;---Set resources for main title
    txres@txFont        = main_title_font
    txres@txFontHeightF = main_title_font_height
    txres@txJust = "BottomCenter"
    xpos = (min_lft+max_rgt)*0.5
    ypos = max_top + sub_title_font_height + 3*title_margin   ; add more of a margin
    if(ypos.ge.1.-main_title_font_height) then
      print("add_panel_titles: Warning: there may not be enough room for your titles.")
      print("   You may need to set gsnPanelTop equal to a value slightly smaller than " + \
               (1.-(sub_title_font_height + 3*title_margin + main_title_font_height)))
    end if
    gsn_text_ndc(wks,main_title,xpos,ypos,txres)
  end if
end

;----------------------------------------------------------------------
; Main driver code.
;----------------------------------------------------------------------
begin
;---Read data with multiple time steps.
  fili  = "rectilinear_grid_2D.nc"
  f     = addfile(fili,"r")
  tsurf =  f->tsurf
  date  = cd_string(tsurf&time, "%D-%c %Y (%HH)" )  ; 03-Oct 2000 (00H)

;---Open PNG workstation.
  wks = gsn_open_wks("png","panel")

;---Create array to hold plots.
  nplots    = 6
  plots     = new(nplots,graphic)
  plot_idxs = (/0,6,18,24,30,36/)

;---Set resources
  res                      = True
  res@gsnDraw              = False
  res@gsnFrame             = False

  res@cnLinesOn            = False
  res@cnLineLabelsOn       = False
  res@cnFillOn             = True
; res@cnFillPalette        = "WhiteYellowOrangeRed"   ; choose color map

  res@cnLevelSelectionMode = "ManualLevels"         ; set contour levels manually
  res@cnMinLevelValF       =  250.                  ; minimum contour level
  res@cnMaxLevelValF       =  310.                  ; maximum contour level
  res@cnLevelSpacingF      =  1                     ; contour level spacing

  res@lbLabelBarOn         = False                  ; turn off labelbar
  res@gsnRightString       = ""                     ; Turn these off so we can add just one
  res@gsnLeftString        = ""                     ; set at the top of the paneled plots

  do n=0,nplots-1
    plots(n) = gsn_csm_contour_map(wks,tsurf(plot_idxs(n),:,:),res)
  end do

;---Panel the plots and draw the titles
  pres                         = True
  pres@gsnFrame                = False    ; Turn off so we can add titles

  pres@gsnPanelSave            = True     ; Don't resize plots back to original size after done

; pres@gsnPanelTop             = 0.95     ; Default is 1.0; may need to change to make room for titles

  pres@gsnPanelLabelBar        = True
  pres@pmLabelBarWidthF        = 0.8

  pres@gsnPanelFigureStrings   = date(plot_idxs)
  pres@gsnPanelFigureStringsFontHeightF = 0.008

  gsn_panel(wks,plots,(/3,2/),pres)
  draw_panel_titles(wks,plots,fili,tsurf@long_name,"","degK")
   
  frame(wks)   ; now advance the frame!
end
