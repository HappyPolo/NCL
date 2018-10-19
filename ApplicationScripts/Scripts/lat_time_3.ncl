;*********************************************
; lat_time_3.ncl
;*********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;*********************************************
; read in data
;*********************************************
 fili  = "sst8292a.nc"                                ; data
 
 f     = addfile (fili , "r")                         ; add file
 sst   = f->SSTA                                      ; sst anomalies
;*********************************************
; manipulate data for plotting
;*********************************************
; lon90W  = ind(sst&lon.eq.270.)                      ; subscript at 90W

 shov      = sst({lon|270:270},lat|:,time|:)          ; put time last
 dims      = dimsizes(shov)                           

 sdemo     = onedtond(ndtooned(shov), (/dims(1),dims(2)/) )
 sdemo!0         = "lat"
 sdemo!1         = "time"
 sdemo&lat       = sst&lat
 sdemo&time      = sst&time
 sdemo@long_name = "SST"
 sdemo@units     = "C"
                                   
 sdemo = smooth92d (sdemo,0.5, 0.25)                  ; 2D smoother
;*************************
; plotting parameters
;*************************
 wks   = gsn_open_wks ("png", "lat_time" )  ; send graphics to PNG file 

 res                  = True                ; plot mods desired
 res@cnFillOn         = True                ; color on
 res@lbLabelStride    = 4                   ; every other label
 res@lbOrientation    = "Vertical"          ; vertical label bar
 res@pmLabelBarOrthogonalPosF = -0.04       ; move label bar closer to axis
 res@cnLinesOn        = False               ; turn off contour lines
 res@cnFillPalette    = "ViBlGrWhYeOrRe"    ; set color map

 res@tiMainString     = "Anomalies at 90W"  ; title

 res@vpXF             = 0.12                ; default is 0.2 (aspect ratio)
 res@vpYF             = 0.8                 ; default is 0.8
 res@vpHeightF        = 0.4                 ; default is 0.6
 res@vpWidthF         = 0.75                ; default is 0.6

 res@cnLevelSelectionMode = "ManualLevels" ; manual levels
 res@cnMinLevelValF       = -4
 res@cnMaxLevelValF       =  4
 res@cnLevelSpacingF      =  0.25 

 plot = gsn_csm_lat_time(wks, sdemo({-30:30},:), res) 

end
