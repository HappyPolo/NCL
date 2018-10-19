;----------------------------------------------------------------------
; xy_vert_17.ncl
;
; Concepts illustrated:
;   - Filling the area between two curves in a XY plot
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;----------------------------------------------------------------------
begin

;---Read in data
 f = addfile ("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
 u = f->U                                    ; get u data

;---To plot multiple curves, you must put them into a mulidimensional array
 data      = new((/2,dimsizes(u&lat)/),float)
 data(0,:) = u(0,:,{82})
 data(1,:) = u(0,:,{-69})

;---Plotting parameters
 wks   = gsn_open_wks ("png","xy_vert")            ; send graphics to PNG file

 res                   = True                      ; plot mods desired
 res@tiMainString      = "Filled XY plot"          ; add title
 res@xyDashPattern     = 0                         ; solid line for curves

 res@gsnXYRightFillColors = "red"
 res@gsnXYLeftFillColors = "green"

 plot = gsn_csm_xy (wks,data,u&lat,res) ; create plot
end
