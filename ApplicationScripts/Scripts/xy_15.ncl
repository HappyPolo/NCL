; ***********************************************
; xy_15.ncl
;
; Concepts illustrated:
;   - Turning off the top and right borders of an XY plot
;   - Turning the tickmarks inward on the X axis
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

 res                  = True                     ; plot mods desired

 res@tmYRBorderOn     = False                    ; turn off right border
 res@tmYROn           = False                    ; no YR tick marks

 res@tmXTBorderOn     = False                    ; turn off top border
 res@tmXTOn           = False                    ; no XT tick marks

 res@tmXBMajorOutwardLengthF = 0.0               ; draw tickmarks inward
 res@tmXBMinorOutwardLengthF = 0.0               ; draw minor ticks inward

 plot  = gsn_csm_xy (wks,u&lat,u(0,:,{82}),res) ; create plot
end
