; ***********************************************
; xy_16.ncl
;
; Concepts illustrated:
;   - Drawing a legend inside an XY plot
;   - Drawing an X reference line in an XY plot
;   - Reversing the Y axis
;   - Using log scaling and explicit labeling
;   - Changing the labels in a legend
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
 u     = f->U  
;************************************************
; to plot multiple lines, you must put them into
; a multidimensional array
;************************************************
 data      = new((/4,dimsizes(u&lev)/),float)

 data(0,:) = u(0,:,{20},{0})
 data(1,:) = u(0,:,{30},{0})
 data(2,:) = u(0,:,{40},{0})
 data(3,:) = u(0,:,{50},{0})
;************************************************
; create plot
;************************************************
 wks   = gsn_open_wks ("png","xy")                  ; send graphics to PNG file

 res                   = True                       ; plot mods desired
 res@tiMainString      = "Profile Plot"             ; add title
 res@trYReverse        = True                       ; reverse Y-axis
 res@gsnFrame          = False                      ; don't advance frame yet

; add a legend
 res@pmLegendDisplayMode    = "Always"              ; turn on legend
 
 res@pmLegendSide           = "Top"                 ; Change location of 
 res@pmLegendParallelPosF   = .90                   ; move units right
 res@pmLegendOrthogonalPosF = -0.8                  ; more neg = down
 
 res@pmLegendWidthF         = 0.12                  ; Change width and
 res@pmLegendHeightF        = 0.25                  ; height of legend.
 res@lgLabelFontHeightF     = .02                   ; change font height
 res@lgPerimOn              = False                 ; no box around
; labels for the legend
 res@xyExplicitLegendLabels = (/"20N","30N","40N","50N"/)

 plot  = gsn_csm_xy (wks,data,u&lev,res)            ; create plot
;************************************************
; add polyline
;************************************************
 gsn_polyline(wks,plot,(/0,0/),(/0,1000/),False)
 frame(wks)

;************************************************
; Change to log scaling for Y Axis
;************************************************
 res@xyYStyle          = "Log"
 res@tmYLMode          = "Explicit"                ; explicit labels
 res@tmYLValues        = (/ 1000, 700,500,400,300,200,100,50,30,10,5,1/)
 res@tmYLLabels        = ""+res@tmYLValues         ; make strings

 plot  = gsn_csm_xy (wks,data,u&lev,res)           ; create plot
 gsn_polyline(wks,plot,(/0,0/),(/0,1000/),False)
 frame(wks)
end
