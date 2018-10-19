;************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************
begin
;************************************
 in = addfile("./T.pwc.01.2000.cdf","r")
 T=in->Temp

 T&Longitude@units = "degrees_east"     ; required to match gsn_csm convention
 T&Latitude@units  = "degrees_north"    ; ditto
;************************************
; create plot
;************************************
 wks = gsn_open_wks("x11","pwc_2")            ; type and name of output
 gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose colormap
 plot = new(2,graphic)                        ; create plot array


 res                      = True     ; plot mods desired

 res@cnFillOn             = True     ; turn on color fill
 res@cnLinesOn            = False    ; turn off contour lines
 res@gsnSpreadColors      = True     ; use full colormap
 res@gsnSpreadColorStart  = 14       ; start at color 14
 res@gsnSpreadColorEnd    = 193      ; end at color 193

 res@lbLabelBarOn         = False    ; turn off label bar
 res@cnInfoLabelOn        = False    ; turn off info label
 res@cnLineLabelsOn       = False    ; turn off line labels

 res@gsnCenterString      = "Slice along 35N"

 res@cnLevelSelectionMode = "ManualLevels"      ; manually set contour levels
 res@cnMinLevelValF       = 0.0                 ; just to make label bar
 res@cnMaxLevelValF       = 19.0                ; numbers come out even
 res@cnLevelSpacingF      = 0.25                ; contour spacing
 
 res@gsnDraw              = False               ; don't draw b/c we want to
 res@gsnFrame             = False		; panel 
;***********************************************
; create plot 1
;***********************************************
 plot(0) = gsn_csm_contour(wks,T(20,:,{35},:),res)     ; create plot

;***********************************************
; create plot 2
;***********************************************
 res@gsnYAxisIrregular2Linear = True
 plot(1) = gsn_csm_contour(wks,T(20,:,{35},:),res)     ; create plot
;***********************************************
; create panel plot
;***********************************************

 panel_res                  = True                ; panel only resources
 panel_res@gsnPanelLabelBar = True                ; Common label bar
 panel_res@txString         = "20 Jan 2000"       ; main title
 panel_res@lbLabelStride    = 4                   ; every 4th label bar label
 panel_res@gsnMaximize      = True                ; fill the page

 gsn_panel(wks,plot,(/2,1/),panel_res)
end


