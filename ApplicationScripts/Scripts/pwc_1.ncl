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
 wks = gsn_open_wks("ps","ocean")            ; type and name of output
 gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose colormap


 res                      = True     ; plot mods desired

 res@cnFillOn             = True     ; turn on color fill
 res@cnLinesOn            = False    ; turn off contour lines
 res@gsnSpreadColors      = True     ; use full colormap
 res@gsnSpreadColorStart  = 14       ; start at color 14
 res@gsnSpreadColorEnd    = 193      ; end at color 193
 res@lbLabelStride        = 4        ; every 4th label bar label

 res@tiMainString         = "20 Jan 2000"       ; main title
 res@gsnCenterString      = "Sigma Level: 0"    ; extra center string

 res@cnLevelSelectionMode = "ManualLevels"      ; manually set contour levels
 res@cnMinLevelValF       = 7.0                 ; just to make label bar
 res@cnMaxLevelValF       = 19.0                ; numbers come out even
 res@cnLevelSpacingF      = 0.25                ; contour spacing

 res@gsnAddCyclic         = False               ; regional data

 res@mpMaxLatF            = max(T&Latitude)     ; map subregion
 res@mpMinLatF            = min(T&Latitude)
 res@mpMaxLonF            = max(T&Longitude)
 res@mpMinLonF            = min(T&Longitude)

 plot = gsn_csm_contour_map_ce(wks,T(20,0,:,:),res)     ; create plot
end


