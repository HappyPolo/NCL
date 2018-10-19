;*************************************************
; panel_8.ncl
;
; Concepts illustrated:
;   - Paneling four plots on a page
;   - Removing tickmarks and labels from paneled plots so they can be drawn closer together
;   - Drawing shaded contours
;   - Moving the contour informational label into the plot
;
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
;************************************************
; read in zonal winds
;************************************************
  u = a->U(1,:,:)                                ; read July zonal winds
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png" ,"panel")            ; send graphics to PNG file
  res = True                                    ; plot mods desired

  res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res@cnMinLevelValF       = -10.               ; set min contour level
  res@cnMaxLevelValF       =  35.               ; set max contour level
  res@cnLevelSpacingF      =   5.               ; set contour spacing

  res@cnInfoLabelOrthogonalPosF = -0.07         ; move contour label up

  res@gsnDraw              = False              ; Do not draw plot
  res@gsnFrame             = False              ; Do not advance frame

  plot = new(4,graphic)                         ; create graphics array
;******************************
; first plot
;******************************
  res@tmXBLabelsOn         = False              ; do not draw bottom labels
  res@tmXBOn               = False              ; no bottom tickmarks
  res@tmYRLabelsOn         = False              ; no right labels
  res@tmYROn               = False              ; no right tickmarks
  plot(0) = gsn_csm_contour_map(wks,u, res)       ; create plot object
  opt     = True
  opt@gsnShadeFillType = "pattern"
  opt@gsnShadeLow      = 3
  opt@gsnShadeHigh     = 17
  plot(0) = gsn_contour_shade(plot(0),-5., 30.,opt)  ; shade cons<-5 and >30
;******************************
; second plot 
;******************************
  res@tmYLLabelsOn     = False
  res@tmYLOn           = False                
  plot(1) = gsn_csm_contour_map(wks,u, res)  ; create plot object
  delete(opt@gsnShadeHigh)
  plot(1) = gsn_contour_shade(plot(1), 0., 30., opt)      ; shade contours < 0. 
;******************************
; third plot 
;******************************
  delete(res@tmYLLabelsOn)
  delete(res@tmYLOn) 
  delete(res@tmXBLabelsOn)
  delete(res@tmXBOn)
  plot(2) = gsn_csm_contour_map(wks,u, res)  ; create plot object
  delete(opt@gsnShadeLow)
  opt@gsnShadeHigh = 17
  plot(2) = gsn_contour_shade(plot(2),-0.01,30.,opt)      ; shade contours > 30.
;******************************
; fourth plot 
;******************************
  res@tmYLLabelsOn     = False
  res@tmYLOn           = False                
  plot(3) = gsn_csm_contour_map(wks,u, res)  ; create plot object
  opt@gsnShadeLow = 3
  plot(3) = gsn_contour_shade(plot(3), 0., 30., opt)      ; shade cons < 0 and > 30. 
;*******************************************
; draw panel plot with title
;*******************************************
  gsn_panel(wks,plot,(/2,2/),False)        ; create panel plot

end
