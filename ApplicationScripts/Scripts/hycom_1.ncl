;*****************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;*****************************************************
begin
  filename = "archv.0021_016_00_3zu.nc"
  in       = addfile(filename,"r")
  u        = in->u
;*****************************************************
;   Create plot
;*****************************************************
 wks  = gsn_open_wks("ps","hycom")                  ; select output
 gsn_define_colormap(wks,"BlWhRe")                  ; choose colormap 
 i = NhlNewColor(wks,1.0,.89,.76)                   ; add bisque to colormap 

 res                             = True             ; plot mods desired

 res@cnFillOn                    = True             ; turn on color 
 res@cnLinesOn                   = False
 res@gsnAddCyclic                = False            ; regional data
 res@gsnSpreadColors             = True             ; use full color map
 res@gsnSpreadColorEnd           = -3               ; don't use added bisque
 res@lbLabelAutoStride           = True             ; nice label bar labels

 res@mpLandFillColor             = "bisque"         ; choose land color

 res@cnLevelSelectionMode        = "ManualLevels"   ; manual contour levels
 res@cnMinLevelValF              = -0.8             ; set min contour level
 res@cnMaxLevelValF              =  0.8             ; set max contour level
 res@cnLevelSpacingF             =  0.1             ; contour interval

; zoom in on region
 res@mpMinLatF                   = min(u&Latitude)
 res@mpMaxLatF                   = max(u&Latitude)
 res@mpMinLonF                   = min(u&Longitude)
 res@mpMaxLonF                   = max(u&Longitude)

 res@tiMainString                = "Hycom:archv.0021_016_00_3zu.nc" 

 plot  = gsn_csm_contour_map_ce(wks,u(0,0,:,:),res)

end




