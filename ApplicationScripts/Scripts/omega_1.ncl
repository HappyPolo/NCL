;***********************************************
; omega_1.ncl
;
; Concepts illustrated:
;   - Computing omega from CCSM output.
;   - Drawing a X reference line in an XY plot
;   - Drawing a legend inside an XY plot
;   - Changing the width and height of a legend
;   - Reversing the Y axis
;***********************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  fccm = addfile("/ptmp/shea/OMEGA/debug_omega.cam2.h0.0000-01-01-00000.nc", "r")
  hyam  = fccm->hyam
  hybm  = fccm->hybm
  hyai  = fccm->hyai
  hybi  = fccm->hybi
  p0    = fccm->P0
  psfc  = fccm->PS
  u     = fccm->U
  v     = fccm->V
  omega = omega_ccm_driver(p0,psfc,u,v,hyam,hybm,hyai,hybi)
  printVarSummary(omega)
  OMEGA = fccm->OMEGA

  print (omega(0,:,{10},{180}) +"   "+ OMEGA(0,:,{10},{180}) ) 
;=============================================================================  
  wks = gsn_open_wks("ps","omega_1") 
  resxy                   = True                      ; plot mods desired
  resxy@gsnXRefLine       = 0.0                       ; draw ref line
  resxy@trYReverse        = True                      ; reverse Y-axis
  resxy@xyLineThicknesses = (/2.0,2.0/)           
  resxy@xyLineColors      = (/"blue","red"/)          ; change line colors
  resxy@trYMinF           = 0.0
  resxy@trYMaxF           = 1000.0

  resxy@pmLegendDisplayMode    = "Always"             ; turn on legend
  resxy@xyExplicitLegendLabels = (/" omega_ccm_driver"," omega calculated by model"/)
  resxy@pmLegendSide           = "Top"                ; Change location of 
  resxy@pmLegendParallelPosF   = .65                  ; move units right
  resxy@pmLegendOrthogonalPosF = -0.75                ; move units down
  resxy@lgPerimOn = False
  resxy@pmLegendWidthF         = 0.12                   ; Change width and
  resxy@pmLegendHeightF        = 0.12                   ; height of legend.
  resxy@lgLabelFontHeightF     = .015                    ; change font height

  y = omega(:1,:,{10},{180})
  y(1,:) = (/ OMEGA(0,:,{10},{180}) /)
  plt  = gsn_csm_xy (wks,y,omega&lev,resxy) 
end
