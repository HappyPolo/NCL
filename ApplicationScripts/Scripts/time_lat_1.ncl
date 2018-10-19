;*********************************************
; time_lat_1.ncl
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
 wks   = gsn_open_wks ("png", "time_lat" )         ; send graphics to PNG file 


 res                  = True                       ; plot mods desired
 res@tiMainString     = "default black and white"  ; title
 res@tmXBLabelStride  = 2
 res@tiYAxisString    = "time"
 plot = gsn_csm_time_lat(wks, ts(:,:,{80}), res ) 

end
