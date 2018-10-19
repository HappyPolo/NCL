;************************************
; panel_6.ncl
;
; Concepts illustrated:
;   - Paneling four plots on a page
;   - Adding white space around paneled plots
;
;************************************
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
 wks = gsn_open_wks("png","panel")             ; send graphics to PNG file

 plot = new(4,graphic)                         ; create graphic array

 res                      = True
 res@cnFillOn             = True         ; turn on color fill
 res@cnFillPalette        = "gui_default"
 res@gsnDraw              = False        ; do not draw picture
 res@gsnFrame             = False        ; do not advance frame
 res@gsnPolar             = "NH"         ; select northern hemisphere
 res@lbOrientation        = "Vertical"   ; vertical label bar
 res@gsnSpreadColors      = False        ; no longer automatic

 plot(0)=gsn_csm_contour_map_polar(wks,T(0,0,:,:),res)
 plot(1)=gsn_csm_contour_map_polar(wks,T(0,5,:,:),res)
 plot(2)=gsn_csm_contour_map_polar(wks,S(0,0,:,:),res)
 plot(3)=gsn_csm_contour_map_polar(wks,S(0,3,:,:),res)

; draw panel without white space
 gsn_panel(wks,plot,(/2,2/),False)

; draw panel with white space added
 resP                 = True
 resP@gsnPanelYWhiteSpacePercent = 5
 resP@gsnPanelXWhiteSpacePercent = 5
 gsn_panel(wks,plot,(/2,2/),resP)

 
end


