;*************************************************
; NCL Graphics: polar_4.ncl
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
  u = a->U(1,:,:)                                ; read July zonal winds
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","polar")             ; send graphics to PNG file
  plot = new(2,graphic)                         ; create graphic array

  res = True                                    ; plot mods desired
  res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res@cnMinLevelValF       = -10.               ; set min contour level
  res@cnMaxLevelValF       =  35.               ; set max contour level
  res@cnLevelSpacingF      =   5.               ; set contour spacing
  res@tiMainString         = "CCM2 T42 July"    ; plot title
  res@gsnCenterString      = "300 mb"           ; plot center string

  res@mpGridLatSpacingF    = 45.                ; change latitude  line spacing
  res@mpGridLonSpacingF    = 90.                ; change longitude line spacing

  res@gsnDraw              = False              ; Do not draw plot
  res@gsnFrame             = False              ; Do not advance frome
;************************************************
; first plot
;************************************************
  res@gsnPolar             = "NH"                   ; specify the hemisphere
  plot(0) = gsn_csm_contour_map_polar(wks,u, res)   ; create plot object
  opt     = True
  opt@gsnShadeFillType = "pattern"
  opt@gsnShadeLow = 3
  opt@gsnShadeHigh = 17
  plot(0) = gsn_contour_shade(plot(0),-5, 30, opt)   ; shade contours<-5 and >30
;************************************************
; second plot
;************************************************
  res@gsnPolar             = "SH"                  ; specify the hemisphere
  plot(1) = gsn_csm_contour_map_polar(wks,u, res)  ; create plot object
  delete(opt@gsnShadeLow)
  delete(opt@gsnShadeHigh)
  opt@gsnShadeMid = 17
  plot(1) = gsn_contour_shade(plot(1),5.,20.,opt)   ; shade contours between 5 and 20
;************************************************
; panel plot
;************************************************
  pres = True
  pres@gsnPanelYWhiteSpacePercent = 5           ; increase white space around
                                                ; indiv. plots in panel
  pres@gsnMaximize                = True        ; fill the page
  gsn_panel(wks,plot,(/2,1/),pres)              ; create panel plot

end

