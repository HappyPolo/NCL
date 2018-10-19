;*********************************************
; time_lat_2.ncl
;*********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"


begin
 f  = addfile ("b003_TS_200-299.nc" , "r"); add file
 ts = f->TS
;*************************
; plotting parameters
;*************************
 wks   = gsn_open_wks ("png", "time_lat" )  ; send graphics to PNG file 


 res                  = True                ; plot mods desired
 res@tiMainString     = "color example"     ; title
 res@tmXBLabelStride  = 2                   ; tick mark label stride
 res@tiYAxisString    = "time"              ; y axis title

 res@cnFillOn         = True                ; color on
 res@lbLabelStride    = 2                   ; every other label
 res@lbOrientation    = "Vertical"          ; vertical label bar
 res@cnLinesOn        = False               ; turn off contour lines
 res@cnFillPalette    = "ViBlGrWhYeOrRe"    ; set color map
 res@cnLevelSpacingF  = 5                   ; contour spacing

 plot = gsn_csm_time_lat(wks, ts(:,:,{80}), res ) 

end
