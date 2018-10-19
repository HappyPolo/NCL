;*********************************************
; lat_time_1.ncl
;*********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

 fili  = "sst8292a.nc"                                ; data
 
 f     = addfile (fili , "r")                         ; add file
 lat   = f->lat                                       ; get lat
 lon   = f->lon                                       ; get lon 
 time  = f->time                                      ; get time
 date  = f->date                                      ; get date
 sst   = f->SSTA                                      ; sst anomalies

 lon90W  = ind(lon.eq.270.)                           ; subscript at 90W
 latS      = -30.
 latN      =  30.
 shov      = sst(lon|lon90W:lon90W,{lat|latS:latN},time|:)
 dims      = dimsizes(shov)                   ; shov=3D array=(1,31,127)
 sdemo     = onedtond(ndtooned(shov), (/dims(1),dims(2)/) )
 sdemo!0   = "lat"
 sdemo!1   = "time"
 sdemo&lat = lat({lat|latS:latN})
 sdemo&time= time
                                   
 sdemo = smth9 (sdemo,0.5, 0.25, False)               ; 2D smoother

 gtPat = 17                                           ; stiple
 ltPat = 3                                            ; hatch
;*************************
; plotting parameters
;*************************
 wks   = gsn_open_wks ("png", "lat_time" ) ; send graphics to PNG file
 res                  = True               ; plot mods desired
 res@gsnDraw          = False              ; don't draw yet
 res@gsnFrame         = False              ; don't advance frame yet

 res@tiMainString     = "SST Anomalies at 90W" ; title

 res@vpXF             = 0.12               ; default is 0.2 change aspect
 res@vpYF             = 0.8                ; default is 0.8 ration
 res@vpHeightF        = 0.4                ; default is 0.6
 res@vpWidthF         = 0.8                ; default is 0.6

 res@cnLevelSelectionMode = "ManualLevels" ; manual levels
 res@cnMinLevelValF       = -4.            ; min level
 res@cnMaxLevelValF       =  4.            ; max level
 res@cnLevelSpacingF      =  0.5           ; contour spacing

 plot = gsn_csm_lat_time(wks, sdemo, res ) 
 opt  = True
 opt@gsnShadeFillType = "pattern"
 opt@gsnShadeLow      = ltPat
 opt@gsnShadeHigh     = gtPat
 plot = gsn_contour_shade(plot, -0.69, 0.25, opt)
 plot = ZeroLineContour (plot)
 draw (plot)                                ; draw the contour object
 frame (wks)                                ; advance frame

end
