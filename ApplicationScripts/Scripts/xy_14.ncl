; ***********************************************
; xy_14.ncl
;
; Concepts illustrated:
;   - Adding labels to a curve in an XY plot
;   - Changing the font and color of XY line labels
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
; plotting parameters
;************************************************
 wks   = gsn_open_wks ("png","xy")               ; send graphics to PNG file

 res                        = True               ; plot mods desired
 res@tiMainString           = "Label a Line"     ; add title


 res@xyLabelMode            = "Custom"           ; label a line
 res@xyExplicitLabels       = "label"            ; text to use
 res@xyLineLabelFontHeightF = 0.020              ; font height
 res@xyLineLabelFontColor   = "red"              ; label color

 plot  = gsn_csm_xy (wks,u&lat,u(0,:,{82}),res) ; create plot
end
