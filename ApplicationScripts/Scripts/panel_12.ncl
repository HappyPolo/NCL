;************************************
; panel_12.ncl
;************************************
;
; Concepts illustrated:
;   - Drawing four plots on a page with two separate labelbars
;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************
begin

 in = addfile("h_avg_Y0191_D000.00.nc","r")
 T=in->T(:,:,:,{0:360})               ; get rid of cyclic points
 S=in->S(:,:,:,{0:360})  
;************************************
;create plot
;************************************
 wks = gsn_open_wks("png","panel")      ; send graphics to PNG file

;***********************************************************************
; create arrays:

; note, for this technique to work, you must create separate arrays for the
; two separate panel plots. This is required to get the correct label bar.
;************************************************************************
 plot_A = new(2,graphic)
 plot_B = new(2,graphic)
;*******************************************
; common resources
;*******************************************
 res                      = True
 res@cnFillOn             = True     ; turn on color fill
 res@cnFillPalette        = "gui_default"
 res@gsnDraw              = False    ; do not draw picture
 res@gsnFrame             = False    ; do not advance frame
 res@gsnPolar             = "SH"     ; choose hemisphere
 res@lbLabelBarOn         = False    ; no individual label bars
 res@cnLinesOn            = False    ; no contour lines
;*******************************************
;  set manual sevels for temperature data
;*******************************************
 res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
 res@cnMinLevelValF       =  0.                ; set min contour level
 res@cnMaxLevelValF       =  30.               ; set max contour level
 res@cnLevelSpacingF      =   2.               ; set contour spacing

 plot_A(0)=gsn_csm_contour_map_polar(wks,T(0,0,:,:),res)
 plot_A(1)=gsn_csm_contour_map_polar(wks,T(0,5,:,:),res)
;*******************************************
;  set manual sevels for salinity
;*******************************************
 res@cnMinLevelValF       =  -0.001             ; set min contour level
 res@cnMaxLevelValF       =   0.001             ; set max contour level
 res@cnLevelSpacingF      =   .0001             ; set contour spacing

 plot_B(0)=gsn_csm_contour_map_polar(wks,S(0,0,:,:),res)
 plot_B(1)=gsn_csm_contour_map_polar(wks,S(0,3,:,:),res)
;*******************************************
;  create panel resources
;*******************************************
 pres1                  = True                ; mods desired
 pres1@gsnFrame         = False               ; save panel until both ready
 pres1@gsnPanelRight    = 0.5                 ; draw from left edge to center
 pres1@gsnPanelLabelBar = True                ; commom label bar
 pres1@lbLabelStride    = 2                   ; every other label

 pres2                  = True                ; mods desired
 pres2@gsnFrame         = False               ; save panel until both ready
 pres2@gsnPanelLeft     = 0.5		      ; draw from center to right edge 
 pres2@gsnPanelLabelBar = True		      ; commom label bar
 pres2@lbLabelStride    = 4		      ; every 4th label

 gsn_panel(wks,plot_A,(/2,1/),pres1)          ; create first panel
 gsn_panel(wks,plot_B,(/2,1/),pres2)          ; create second panel

 frame(wks)                                   ; draw both on same page

 
end


