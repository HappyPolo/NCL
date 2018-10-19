;************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************
begin
;************************************
 in = addfile("T.pwc.01.2000.cdf","r")
 T=in->Temp

 T&Longitude@units = "degrees_east"     ; required to match gsn_csm convention
 T&Latitude@units  = "degrees_north"    ; ditto

;************************************
; pull out data 
;************************************

  data = new( (/5,dimsizes(T&Longitude)/),"float")
  data(0,:) = T(20,{-.0005},{35},:)
  data(1,:) = T(20,{-.0045},{35},:)
  data(2,:) = T(20,{-.0125},{35},:)
  data(3,:) = T(20,{-.0225},{35},:)
  data(4,:) = T(20,{-.0325},{35},:)

;************************************
; create plot
;************************************
 wks = gsn_open_wks("ps","pwc_4")            ; type and name of output

 res                      = True                   ; plot mods desired
 res@xyLineColors         = (/"blue","green","red","black","cyan"/)

 res@xyLineThicknesses    = (/2.0,2.0,2.0,2.0,2.0/); all lines double thick
 res@xyDashPatterns       = (/0,0,0,0,0/)          ; all solid
 res@gsnLeftString        = "Temp"                 ; some strings
 res@gsnRightString       = "C"
 res@gsnCenterString      = "at 35N"

 res@pmLegendDisplayMode    = "Always"            ; turn on legend
 res@pmLegendOrthogonalPosF = -1.1               ; move legend up
 res@pmLegendWidthF         = 0.15                ; Change width and
 res@pmLegendHeightF        = 0.18                ; height of legend
 res@lgPerimOn              = False               ; no box around it
 res@lgLabelFontHeightF     = .015                ; increase font height
 res@xyExplicitLegendLabels = (/"-.0005","-.0045","-.0125","-.0225","-.0325"/)

 res@tmXBTickSpacingF       = 10.                  ; spacing on labels
 plot=gsn_csm_xy(wks,T&Longitude,data,res)

end


