;*************************************************
; panel_7.ncl
;
; Concepts illustrated:
;   - Paneling three plots vertically on a page
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
  res@tmXBLabelsOn         = False              ; do not draw bottom labels
  res@tmXBOn               = False              ; no bottom tickmarks

  res@gsnDraw              = False              ; Do not draw plot
  res@gsnFrame             = False              ; Do not advance frame

  plot = new(3,graphic)                         ; create graphics array  
;**********************************************************************
; Note that ShadeLtGtContour, ShadeLtContour, and ShadeGtContour
; all use greater (less) than, and NOT greater (less) than or equal to.
; These functions will find the closest CONTOUR less than
; the specified threshold value when choosing when to start shading. For 
; instance, for plot(0) below, ShadeLtGtContour(plot(0),0., 3,31.9.,17)
; will result in all areas -5. or less being shaded shade pattern 3, and
; all areas 30. or greater being shaded shade pattern 17. -5. is the 
; closest contour less than 0, and 30. is the closest contour greater than
; 31.9.
;
; Note: As of ncl version 4.3.0, ShadeLtGtContour, ShadeLtContour, and 
; ShadeGtContour have been superceded by the more versatile gsn_contour_shade.
;***********************************************************************
  
  plot(0) = gsn_csm_contour_map(wks,u, res)        ; create plot object
  opt = True
  opt@gsnShadeFillType = "pattern"
  opt@gsnShadeLow = 3
  opt@gsnShadeHigh = 17
  plot(0) = gsn_contour_shade(plot(0),-0.01,30.,opt)  ; shade cons <0 and >30

  delete(opt@gsnShadeHigh)

  plot(1) = gsn_csm_contour_map(wks,u, res)  ; create plot object
  plot(1) = gsn_contour_shade(plot(1), 0., 30., opt)      ; shade contours < 0. 

  delete(res@tmXBLabelsOn)
  delete(res@tmXBOn)       
  delete(opt@gsnShadeLow)
  opt@gsnShadeHigh = 17
  plot(2) = gsn_csm_contour_map(wks,u, res)  ; create plot object
  plot(2) = gsn_contour_shade(plot(2),0.,30.,opt)      ; shade contours > 30.

;*******************************************
; draw panel plot with title
;*******************************************
  pres                    = True              ; mod panel plot
  pres@gsnPanelBottom     = 0.05              ; add some space at bottom 
; pres@txString           = "Example of shaded contours"
  pres@gsnPanelMainString = "Example of shaded contours"
  gsn_panel(wks,plot,(/3,1/),pres)        ; create panel plot

end
