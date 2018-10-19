; ===============================================
; h_time_2.ncl              
; ===============================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
;================================================
; get data
;================================================
 fili  =  "ts.nc"                                 ; filename
 
 f     = addfile (fili , "r")                     ; add file 
 lev   = f->lev                                   ; levels
 lat   = f->lat                                   ; latitudes
 time  = f->time                                  ; months since
 date  = f->date                                  ; YYYYMM
 v     = f->V                                     ; Zonal means (time,lev,lat)
 klev  = dimsizes(lev)                            ; number of levels
 ntim  = dimsizes(time)                           ; number of time steps

 wgt   = (/ 1., 3., 4., 3., 1./)   ; weights for  temporal smoother
 wgt   = wgt/sum(wgt)              ; normalize

 ind14S= ind(lat.eq.-1.395307)     ; subscript index of 1.4S
;================================================
; smooth data
;================================================
; temporary 3D [1,7,132] 
 v3D   = wgt_runave(v(lat|ind14S:ind14S,lev|:,time|:), wgt, 0) 
 v2D   = onedtond( ndtooned(v3D), (/klev,ntim/) )
 delete (v3D)                      
 v2D!0 = "lev"
 v2D!1 = "time"
 v2D&lev = lev
 v2D&time= time
;================================================
; plot
;================================================
 wks   = gsn_open_wks ("png", "h_time" )     ; send graphics to PNG file
 res = True
 res@tiMainString    = "Zonal Mean at 1.4S"
 res@cnLevelSpacingF = 0.5
 res@gsnDraw         = False
 res@gsnFrame        = False

; note this data is already on pressure levels. If this were model
; data, it would be necessary to convert from hybrid to pressure levels
; before plotting.
 plot = gsn_csm_pres_hgt (wks,v2D,res) 
; set up options for shading function
 opt  = True
 opt@gsnShadeFillType = "pattern"
 opt@gsnShadeLow      = 3
 opt@gsnShadeHigh     = 17
 plot = gsn_contour_shade (plot, -0.55, 0.5, opt)    ; add shading to areas < -.5 contour and
                                                    ; to areas >.5 contour
 draw (plot)
 frame(wks)
end
