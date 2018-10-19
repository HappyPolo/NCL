;****************************************************
; xy_7.ncl
;****************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
;****************************************************
begin
;***************************
; read in data
;***************************
  f    = addfile ("TestData.xy3.nc" , "r")
  p    = f->P(0,0:35)                 ; read in left  variable (y1)
  t    = f->T(0,0:35)                 ; read in right variable (y2)
  time = f->time(0:35)                ; this is our x
;***************************
; plot parameters
;***************************
  wks = gsn_open_wks("ps","xy") 

; left variable
  resL                        = True 
  resL@xyLineThicknesses      = 2.                  ; thicker line
  resL@tiYAxisString = t@long_name +"  "+"[solid]"  ; axis string

; right variable
  resR                        = True                      
  resR@xyDashPatterns         = 1                   ; dashed line for 2nd
  resR@xyLineThicknesses      = 2                   ; thicker line
  resR@tiYAxisString = p@long_name +"  "+"[dash]"   ; axis string

  plot = gsn_csm_xy2(wks,time,t,p,resL,resR)
;***********************************
; second plot: offset and color
;***********************************
  resL@trYMaxF           =   16.                    ; axis max
  resL@trYMinF           =    0.                    ; axis min
  resL@tiMainString      = "Curves Offset"          ; title
  resL@xyLineColors      = "blue"                   ; line color
  
  resR@trYMaxF           = 1024.                    ; axis max
  resR@trYMinF           = 1008.                    ; axis min
  resR@xyLineColors      = "red"                    ; line color
  plot = gsn_csm_xy2(wks,time,t,p,resL,resR)
end
