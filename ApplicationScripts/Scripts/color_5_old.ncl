;*************************************************
; color_5_old.ncl
;
; Concepts illustrated:
;   - Using a blue-white-red color map
;   - Adding a common labelbar to paneled plots
;   - Paneling four plots on a page
;   - Using coordinate subscripting to read a specified geographical region
;************************************************
; Note: This script is the old way of doing 
; color in NCL (NCL versions 6.0.0 and older).
;
; See color_4.ncl for a more modern way.
;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
;************************************************
begin
  a = addfile("UVPCVrDv.nc","r")
  lev = a->lev                                   ; used for labels
  chi = a->CHI(0,:,:,:)                          ; all levels 1st time
  chi = chi/1.e6                                 ; scale for convenience
;************************************************
; plot parameters
;************************************************
  wks = gsn_open_wks("ps","color")               ; open a ps file
  gsn_define_colormap(wks,"BlWhRe")              ; choose colormap

  res                      = True                ; Use plot options
  res@cnFillOn             = True                ; Fill contours

;---This resource not needed in NCL V6.1.0
  res@gsnSpreadColors      = True                ; use full range of colors

  res@cnLevelSelectionMode = "ManualLevels"      ; set manual contour levels
  res@cnMinLevelValF       = -10.                ; set min contour level
  res@cnMaxLevelValF       =  10.                ; set max contour level
  res@cnLevelSpacingF      =   1.                ; set contour spacing

  res@gsnDraw              = False               ; Do not draw plot
  res@gsnFrame             = False               ; Do not advance frome

  res@lbLabelBarOn         = False               ; turn off the label bar
;************************************************
; individual plots
;************************************************
  plot = new(4,graphic)                          ; create graphics array

  res@gsnCenterString      = lev({850})          ; level nearest 850
  plot(0) = gsn_csm_contour_map(wks,chi({850},:,:), res)  

  res@gsnCenterString      = lev({700})          ; level nearest 700
  plot(1) = gsn_csm_contour_map(wks,chi({700},:,:), res) 

  res@gsnCenterString      = lev({500})          ; level nearest 500
  plot(2) = gsn_csm_contour_map(wks,chi({500},:,:), res)  

  res@gsnCenterString      = lev({250})          ; level nearest 250
  plot(3) = gsn_csm_contour_map(wks,chi({250},:,:), res) 
;************************************************************
; now create panel plot with its own resources
;************************************************************
  resPanel                 = True                 ; panel mods desired
  resPanel@gsnPanelLabelBar= True                 ; label bar on panel
  resPanel@gsnMaximize     = True                 ; fill up the page
  gsn_panel(wks,plot,(/2,2/),resPanel)            ; draw: 2-down , 2-across
end
