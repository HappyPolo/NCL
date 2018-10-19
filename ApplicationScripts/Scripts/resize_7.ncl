; ***********************************************
; resize_7.ncl
; ***********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************************
begin
;************************************************
; read in data
;************************************************
  f     = addfile ("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
  u     = f->U                                    ; get u data
;************************************************
; plotting parameters
;************************************************
  wks   = gsn_open_wks ("png","resize")           ; open workstation
  
  res                  = True                     ; plot mods desired
  res@gsnDraw          = False                    ; don't draw plot yet
  res@gsnFrame         = False                    ; don't advance frame yet
  res@vpWidthF         = 0.8                      ; set width and height
  res@vpHeightF        = 0.3
  res@tiYAxisString    = u@long_name + " (" + u@units + ")"
  
; first plot  
  res@tiMainString     = "plot1"
  res@vpXF             = 0.15
  res@vpYF             = 0.9
  plot1  = gsn_csm_xy (wks,u&lat,u(0,:,{82}),res) ; create plot
  
; second plot  
  res@tiMainString     = "plot2"
  res@vpXF             = 0.15
  res@vpYF             = 0.4
  plot2  = gsn_csm_xy (wks,u&lat,u(0,:,{3}),res) ; create plot
;**********************************
; now maximize the plot
;**********************************   
; Maximize these plots for PS or PDF output. If output is                    
; to an X11 window or an NCGM file, then this routine doesn't                
; do anything.                                                               
  
  psres = True                                                               
  maximize_output(wks,psres)  ; calls draw and frame for you 
end
