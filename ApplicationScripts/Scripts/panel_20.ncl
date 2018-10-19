; ***********************************************
; panel_20.ncl
;
; Concepts illustrated:
;   - Drawing four different-sized plots on the same page using viewport resources
;   - Maximizing plots after they've been created
;
; ***********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************************
begin
;
; Read data for XY plot
;
 f     = addfile ("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
 u     = f->U                                   ; get u data
 v     = f->V                                   ; get v data

 wks   = gsn_open_wks ("png","panel")           ; send graphics to PNG file

 xyres                  = True
 xyres@gsnFrame         = False                 ; don't advance frame
 xyres@gsnDraw          = False                 ; don't draw plots

 xyres@vpXF             = 0.08                  ; position and sizes
 xyres@vpYF             = 0.94                  ; for XY plot
 xyres@vpWidthF         = 0.40
 xyres@vpHeightF        = 0.40

 xyres@trYMinF          = -20                   ; y axis min
 xyres@trYMaxF          =  50                   ; y axis max

 xyres@tiMainString     = "Time = 0"            ; add title
 xyres@tmYLLabelsOn     = False                 ; turn off left labels

 xy0 = gsn_csm_xy (wks,u&lat,u(0,:,{82}),xyres) ; create plot

 xyres@vpXF             = 0.53                  ; change x position
 xyres@tiMainString     = "Time = 1"            ; add title
 xyres@tiYAxisString    = ""                    ; don't title this one
 xyres@tmYRLabelsOn     = True                  ; turn on right labels

 xy1 = gsn_csm_xy (wks,u&lat,u(1,:,{82}),xyres) ; create plot

 cnres                      = True
 cnres@gsnFrame             = False                 ; don't advance frame
 cnres@gsnDraw              = False                 ; don't draw plots

 cnres@vpXF                 = 0.05                  ; position and size
 cnres@vpYF                 = 0.45                  ; for contour plots
 cnres@vpWidthF             = 0.44
 cnres@vpHeightF            = 0.22

 cnres@cnFillOn             = True                  ; turn on contour fill
 cnres@cnFillPalette        = "StepSeq25"           ; set color map
 cnres@cnLevelSelectionMode = "ManualLevels"        ; set manual contour levels
 cnres@cnMinLevelValF       = -10.                  ; set min contour level
 cnres@cnMaxLevelValF       =  35.                  ; set max contour level
 cnres@cnLevelSpacingF      =   5.                  ; set contour spacing

 cnres@tmYROn               = False                 ; turn off right ticks

 cnres@gsnCenterString      = "300 mb"              ; plot center string
 cnres@gsnRightString       = "Time = 0"            ; plot right string

 cn0 = gsn_csm_contour_map(wks,u(0,:,:),cnres)

 cnres@vpXF                 = 0.51                  ; change x position

 cnres@tmYROn               = True                  ; turn on right ticks
 cnres@tmYLOn               = False                 ; turn off left ticks
 cnres@tmYLLabelsOn         = False                 ; turn off left labels

 cnres@gsnRightString       = "Time = 1"            ; plot right string

 cn1 = gsn_csm_contour_map(wks,u(1,:,:),cnres)

;
; Maximize plots in frame.
;
 psres = True                                                               
 maximize_output(wks,psres)  ; calls draw and frame for you 

;
; If you try to use gsn_panel to panel different sized plots, you
; will get unexpected results. You can turn on gsnPanelDebug to
; see what viewport values are used, and then use these values
; to set the viewport resources for each individual plot.
; pnlres               = True
; pnlres@gsnPanelDebug = True    ; Use to print values for position, width,
                                ; and height.
; gsn_panel(wks,(/xy0,xy1,cn0,cn1/),(/2,2/),pnlres)
end
