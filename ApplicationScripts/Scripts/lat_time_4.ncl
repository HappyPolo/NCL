;*********************************************
; lat_time_4.ncl
;*********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still needs to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
 f     = addfile ("b003_TS_200-299.nc" , "r") 
 lat   = f->lat                                       ; get lat
 lon   = f->lon                                       ; get lon 
 time  = f->time                                      ; get time
 temp  = f->TS

 lon90W  = ind(lon.eq.270.)                           ; subscript at 90W

 shov      = temp(lon|lon90W:lon90W,lat|:,time|:)
 dims      = dimsizes(shov)                           ; shov=3D(1,31,127)
 sdemo     = onedtond(ndtooned(shov), (/dims(1),dims(2)/) )
 sdemo!0   = "lat"
 sdemo!1   = "time"
 sdemo&lat = lat
 sdemo&time= time
 sdemo = smth9 (sdemo,0.5, 0.25, False)               ; 2D smoother   
;*************************
; plotting parameters
;*************************
 wks   = gsn_open_wks ("png", "lat_time" ) ; send graphics to PNG file
 res                  = True               ; plot mods desired
 res@gsnDraw          = False              ; required to make
 res@gsnFrame         = False              ; contour style changes
 res@vpXF             = 0.12               ; default is 0.2 (change aspect)
 res@vpYF             = 0.8                ; default is 0.8
 res@vpHeightF        = 0.4                ; default is 0.6
 res@vpWidthF         = 0.8                ; default is 0.6
;*************************
; plot 1
;*************************
printVarSummary(sdemo&lat)

 res@tiMainString     = "Default latitudinal spacing" ; title
 plot = gsn_csm_lat_time(wks, sdemo, res ) 
 opt  = True
 opt@gsnShadeFillType = "pattern"
 opt@gsnShadeLow      = 3
 opt@gsnShadeHigh     = 17
 plot = gsn_contour_shade(plot, -0.51, 0.51, opt)
 plot = ZeroLineContour  (plot)
 draw (plot)                                ; draw the contour object
 frame (wks)                                ; advance frame
;*************************
; plot 2
;*************************
 res@tiMainString     = "Latitudinal spacing to 90 degrees" ; title
 plot = gsn_csm_lat_time(wks, add90LatY(sdemo), res ) 
 plot = gsn_contour_shade(plot, -0.51, 0.51, opt)
 plot = ZeroLineContour  (plot)
 draw (plot)                                ; draw the contour object
 frame (wks)   
end
