; ***********************************************
; xy_3.ncl
;
; Concepts illustrated:
;   - Reversing the Y axis
;   - Changing the line dash pattern in an XY plot
;   - Creating your own line dash pattern for an XY plot
;   - Changing the line color and thickness in an XY plot
;   - Creating a vertical profile plot
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
 f     = addfile ("atmos.nc","r")
 u     = f->U                                      ; get u data
;************************************************
; plotting parameters
;************************************************
 wks   = gsn_open_wks ("png","xy")                  ; send graphics to PNG file

 res                   = True                       ; plot mods desired
 res@tiMainString      = "Profile Plot"             ; add title
 res@trYReverse        = True                       ; reverse Y-axis
 res@xyDashPatterns    = 15                         ; choose dash patterns
 plot  = gsn_csm_xy (wks,u(0,:,{30},{0}),u&lev,res) ; create plot
;************************************************
; create your own dash pattern using NhlNewDashPattern
; available since NCL version 4.2.0.a030
;************************************************
; arguments
; wks
; pattern string

 res@xyLineColor     = "blue"
 res@tiMainString    = "Make your own dash pattern"
 res@xyLineThicknesses = 4.0

; the pattern string is the tricky part of this function. See the function
; documentation for examples of the patterns used in the present dash patterns

; this pattern will make a standard dash have more spaces between the lines
; so that when thickened for publication purposes, you can still see that
; a line is dashed. The $ is pen down (line), and the _ is pen up (space). 

 pattern = "$$$$______$$$$______$$$$______$$$$_____$$$$______"

 res@xyDashPatterns = NhlNewDashPattern(wks,pattern)
 plot               = gsn_csm_xy (wks,u(0,:,{30},{0}),u&lev,res) 

end
