;================================================;
;  maponly_13.ncl
;================================================;
;
; Concepts illustrated:
;   - Drawing several different map projections
;   - Zooming in on Europe, using several different map projections
;
;================================================;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  wks  = gsn_open_wks("png","maponly")   ; send graphics to PNG file

  res                = True              ; plot mods desired
  res@gsnDraw        = False             ; don't draw the plots
  res@gsnFrame       = False             ; don't advance the frame
  res@mpLimitMode    = "LatLon"          ; use lat/lon coordinates to limit area
  res@mpMinLatF      = 30.
  res@mpMaxLatF      = 90.
  res@mpMinLonF      = -40.
  res@mpMaxLonF      = 60.
  res@gsnCenterStringFontHeightF = 0.03  ; set the center string font height
  
  
  yres = True                            ; panel resource list
  yres@gsnMaximize = True                ; maximize the plots
  yres@gsnPaperOrientation  = "portrait" ; set paper orientation to portrait
  
  map = new(13,graphic)
  
  res@mpProjection = "Stereographic"       
  res@gsnCenterString = res@mpProjection+" Projection"
  map(0) = gsn_csm_map(wks,res)
  
  res@mpProjection = "LambertEqualArea"       
  res@gsnCenterString = res@mpProjection+" Projection"
  map(1) = gsn_csm_map(wks,res)
  
  res@mpProjection = "Orthographic"       
  res@gsnCenterString = res@mpProjection+" Projection"
  map(2) = gsn_csm_map(wks,res) 
  
  res@mpProjection = "Gnomonic"       
  res@gsnCenterString = res@mpProjection+" Projection"
  map(3) = gsn_csm_map(wks,res)

  res@mpProjection = "AzimuthalEquidistant"       
  res@gsnCenterString = res@mpProjection+" Projection"
  map(4) = gsn_csm_map(wks,res)
  
  res@mpProjection = "Satellite"       
  res@gsnCenterString = res@mpProjection+" Projection"
  map(5) = gsn_csm_map(wks,res)

  res@mpProjection = "CylindricalEquidistant"       
  res@gsnCenterString = res@mpProjection+" Projection"
  map(6) = gsn_csm_map(wks,res)

  res@mpProjection = "Mercator"       
  res@gsnCenterString = res@mpProjection+" Projection"
  map(7) = gsn_csm_map(wks,res)

  res@mpProjection = "Mollweide"       
  res@gsnCenterString = res@mpProjection+" Projection"
  map(8) = gsn_csm_map(wks,res)

  res@mpProjection = "CylindricalEqualArea"       
  res@gsnCenterString = res@mpProjection+" Projection"
  map(9) = gsn_csm_map(wks,res)

  res@mpProjection = "RotatedMercator"       
  res@gsnCenterString = res@mpProjection+" Projection"
  map(10) = gsn_csm_map(wks,res)    
    
  res@mpProjection = "Robinson"       
  res@gsnCenterString = res@mpProjection+" Projection"
  map(11) = gsn_csm_map(wks,res)    
    
  res@mpProjection = "LambertConformal"       
  res@gsnCenterString = res@mpProjection+" Projection"
  map(12) = gsn_csm_map(wks,res)    
    
  yres@gsnPanelYWhiteSpacePercent = 5.0  ; set white space between panels in y-direction
  gsn_panel(wks,map(:2),(/2,2/),yres)
  
  yres@gsnPanelYWhiteSpacePercent = 15.0  
  gsn_panel(wks,map(3:5),(/2,2/),yres)
  gsn_panel(wks,map(6:9),(/2,2/),yres)
  
  yres@gsnPanelYWhiteSpacePercent = 5.0  
  gsn_panel(wks,map(10:12),(/2,2/),yres)
end 
  
