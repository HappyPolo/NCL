;***************************************
; panel_15.ncl
;
; Concepts illustrated:
;   - Combining two sets of paneled plots on one page
;   - Drawing two labelbars in a combined panel plot
;
;***************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************
begin
  in = addfile("h_avg_Y0191_D000.00.nc","r")
  t  = in->T
;***************************************
; create first two individual plots
;***************************************
  wks = gsn_open_wks("png","panel")        ; send graphics to PNG file
  plot = new(2,graphic)
  res                   = True             ; plot mods desired
  res@cnFillOn          = True             ; turn on color
  res@cnLinesOn         = False            ; turn off contour lines
  res@cnFillPalette     = "gui_default"    ; set color map
  res@lbLabelBarOn      = False            ; turn off individual label bars
  res@gsnDraw           = False            ; don't draw yet
  res@gsnFrame          = False            ; don't advance frame yet
  res@gsnAddCyclic      = False            ; data already has cyclic point

  res@cnLevelSelectionMode = "ManualLevels"; manual set levels so lb consistent
  res@cnMinLevelValF       = 0             ; min level
  res@cnMaxLevelValF       = 28            ; max level
  res@cnLevelSpacingF      = 2             ; contour interval
  res@mpLandFillColor      = "white"       ; make land white

  res@gsnCenterString = "level 0"
  plot(0) = gsn_csm_contour_map_ce(wks,t(0,0,:,:),res)
  res@gsnCenterString = "level 1"
  plot(1) = gsn_csm_contour_map_ce(wks,t(0,1,:,:),res)
;***************************************
; panel first two plots
;***************************************
  pres1                     = True
  pres1@gsnPanelLabelBar    = True       ; common label bar
  pres1@gsnFrame            = False      ; don't advance frame yet
  pres1@lbOrientation       = "vertical" ; vertical label bar
; we use PanelBottom to tell the plot to only draw in the top part of the page.
; since there are two plots here, and we have limited the plot to the upper
; 0.6 of the page, each plot will have a size 0.3.
  pres1@gsnPanelBottom      = 0.4        ; move bottom up from 0.0 to 0.4
  gsn_panel(wks,plot,(/2,1/),pres1)
;***************************************
; create third individual plots
;***************************************
  res@cnMinLevelValF       = 0             ; min level
  res@cnMaxLevelValF       = 20            ; max level
  res@cnLevelSpacingF      = 2             ; contour interval
  res@gsnCenterString = "level 6"
  plot2 = gsn_csm_contour_map_ce(wks,t(0,6,:,:),res)
;***************************************
; create panel of just third plot to keep aspect ratio
; the same as the panel above
;***************************************
  pres2                     = True
  pres2@gsnPanelLabelBar    = True       ; common label bar
  pres2@gsnPanelTop         = 0.4        ; draw up to the bdry of upper plot
  pres2@gsnPanelBottom      = 0.1        ; move bottom up so size is 0.3
  pres2@gsnFrame            = False      ; don't advance frame yet
  pres2@lbOrientation       = "vertical" ; vertical label bar
  gsn_panel(wks,plot2,(/1,1/),pres2)
; now advance frame for all plots
  frame(wks)

end








