;----------------------------------------------------------------------
; h_lat_6.ncl
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
;----------------------------------------------------------------------
begin
  f     = addfile ("mxclim.nc","r")
  u     = f->U(0,:,:)                             ; get u for January

  wks   = gsn_open_wks ("png", "h_lat" )          ; send graphics to PNG file

  res                      = True                 ; plot mods desired

  res@cnLevelSelectionMode = "ManualLevels"       ; manually select levels
  res@cnLevelSpacingF      = 5.0                  ; contour spacing
  res@cnMinLevelValF       = -50.                 ; min level
  res@cnMaxLevelValF       =  50.                 ; max level
  res@cnLineLabelsOn       = True                 ; turn on line labels
  res@cnFillOn             = True                 ; turn on color fill
  res@cnFillPalette        = "BlWhRe"             ; choose colormap
  res@tiYAxisString        = u&lev@long_name + " (" + u&lev@units + ")"   

; Note: u is already on pressure levels. If this were model data, it
; would be necessary to interpolate from the hybrid coordinates to 
; pressure levels.
  
  plot  = gsn_csm_pres_hgt(wks, u, res )   ; place holder
  
end
