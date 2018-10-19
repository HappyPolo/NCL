; ***********************************************
; xy_2.ncl
;
; Concepts illustrated:
;   - Drawing an XY plot with multiple curves
;   - Changing the line color for multiple curves in an XY plot
;   - Changing the line thickness for multiple curves in an XY plot
;   - Drawing XY plot curves with both lines and markers
;   - Changing the default markers in an XY plot
;   - Making all curves in an XY plot solid
;
; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************************
begin

;---Read in data
 f     = addfile ("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
 u     = f->U                                    ; get u data

;---To plot multiple lines, you must put them into a mulidimensional array.
 data      = new((/2,dimsizes(u&lat)/),float)

 data(0,:) = u(0,:,{82})
 data(1,:) = u(0,:,{-69})

 wks   = gsn_open_wks ("png","xy")                 ; send graphics to PNG file

;---Set plotting parameters

 res                   = True                      ; plot mods desired
 res@tiMainString      = "Two curve XY plot"       ; add title
;
; Similiar resources are xyLineThicknessF and xyLineColor,
; which will affect all lines in the array.
;
 res@xyLineThicknesses = (/  1.0,   2.0/)          ; make second line thicker
 res@xyLineColors      = (/"blue","red"/)          ; change line color

 plot  = gsn_csm_xy (wks,u&lat,data,res) ; create plot

;---Second plot, 3 curves.
 data2      = new((/3,dimsizes(u&lat)/),float)

 data2(0,:) = u(0,:,{82})
 data2(1,:) = u(0,:,{0})
 data2(2,:) = u(0,:,{-69})

 delete(res@xyLineThicknesses)      ; Don't want this resource any more

 res@xyDashPattern  = 0                         ; Make curves all solid
 res@xyMarkLineMode = "MarkLines"               ; Markers *and* lines
 res@xyMarkers      = (/6,11,16/)               ; 3 different markers
 res@xyMarkerColors := (/"blue","red","green"/) ; 3 different colors

 res@tiMainString      = "Multiple line XY plot with markers"      ; add title

 plot  = gsn_csm_xy (wks,u&lat,data2,res) ; create plot
end
