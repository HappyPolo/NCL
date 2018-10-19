; ***********************************************
; xy_17.ncl
;
; Concepts illustrated:
;   - Filling the area between two curves in an XY plot
;
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
; to plot multiple lines, you must put them into
; a mulidimensional array
;************************************************
 data      = new((/2,dimsizes(u&lat)/),float)

 data(0,:) = u(0,:,{82})
 data(1,:) = u(0,:,{-69})
;************************************************
; plotting parameters
;************************************************
 wks   = gsn_open_wks ("png","xy")                 ; send graphics to PNG file

 res                   = True                      ; plot mods desired
 res@tiMainString      = "Filled XY plot"          ; add title

 res@xyDashPattern     = 0                         ; solid line for curves

;
; Note: these resources are only available in V5.1.0. There's
; an old way of doing this; see the code below.
;
 res@gsnXYAboveFillColors = "red"
 res@gsnXYBelowFillColors = "green"

 plot  = gsn_csm_xy (wks,u&lat,data,res) ; create plot

;
; To accomplish the same results using an older version
; of NCL, you first need to set these two resources:
;
;  res@gsnDraw           = False                     ; don't draw plot
;  res@gsnFrame          = False                     ; don't advance frame
;
; and then after the call to "gsn_csm_xy", add the following code:
;
;  plot = fill_xy2(wks,plot,u&lat,data(0,:),data(1,:),"red","green")
;
;  draw(plot)
;  frame(wks)
;
end
