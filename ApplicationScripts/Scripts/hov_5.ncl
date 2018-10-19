; ===========================================
; hov_5.ncl
; ===========================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; ===========================================
begin
  diri  = ncargpath("data") + "/cdf/"
  f     = addfile (diri+"chi200_ud_smooth.nc","r")
  scale = 1.e6                                  ; scale factor
  chi   = f->CHI                                ; get chi
  chi   = chi/scale                             ; scale for convenience
;==============================================
; create color plot
;=============================================
  wks  = gsn_open_wks ("png", "hov" )           ; send graphics to PNG file

  res                      = True               ; plot mods desired
  res@cnFillOn             = True               ; turn on color fill
  res@cnFillPalette        = "BlWhRe"           ; set color map

  res@tiMainString         = "Pacific Region"   ; title

  res@cnLevelSelectionMode = "ManualLevels"     ; manual contour levels
  res@cnMinLevelValF       = -10.	        ; min level
  res@cnMaxLevelValF       =  10.               ; max level
  res@cnLevelSpacingF      = 2.                 ; contour level spacing
  
  plot = gsn_csm_hov(wks, chi(:,{100:220}), res) 
  
end
