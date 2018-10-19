;*************************************************
; pub_1.ncl
; Concepts illustrated:
;   - Turning off labels and tickmarks
;   - Compressing plots
;   - Paneling plots
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
  wks = gsn_open_wks("png" ,"pub")              ; send graphics to PNG file
  res = True                                    ; plot mods desired
  res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res@cnMinLevelValF       = -10.               ; set min contour level
  res@cnMaxLevelValF       =  35.               ; set max contour level
  res@cnLevelSpacingF      =   5.               ; set contour spacing

  res@cnInfoLabelOrthogonalPosF = -0.07         ; move contour label up
  res@tmXBLabelsOn         = False              ; do not draw bottom labels
  res@tmXBOn               = False              ; no bottom tickmarks

  res@gsnDraw              = False              ; Do not draw plot
  res@gsnFrame             = False              ; Do not advance frame

  plot = new(3,graphic)                         ; create graphics array

  plot(0) = gsn_csm_contour_map_ce(wks,u, res)       ; create plot object
  opt     = True
  opt@gsnShadeFillType = "pattern"
  opt@gsnShadeLow = 3
  opt@gsnShadeHigh = 17
  plot(0) = gsn_contour_shade(plot(0),-5., 30.,opt)  ; shade cons<=-5 and >=30
  delete(opt)

  plot(1) = gsn_csm_contour_map_ce(wks,u, res)  ; create plot object
  opt     = True
  opt@gsnShadeFillType = "pattern"
  opt@gsnShadeLow = 3
  plot(1) = gsn_contour_shade(plot(1), 0.99, 30., opt)    ; shade contours < 0.
  delete(opt) 

  plot(2) = gsn_csm_contour_map_ce(wks,u, res)  ; create plot object
  opt     = True
  opt@gsnShadeFillType = "pattern"
  opt@gsnShadeHigh = 17
  plot(2) = gsn_contour_shade(plot(2),0., 30., opt)      ; shade contours >= 30.

;*******************************************
; draw panel plot with title
;*******************************************
  pres             = True                 ; mod panel plot
  pres@txString    = "Example of Compressed Panel Plot" ; add common title
  gsn_panel(wks,plot,(/3,1/),pres)        ; create panel plot
end
