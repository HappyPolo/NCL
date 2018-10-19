;********************************************
; h_long_5.ncl
;********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;********************************************
begin
  f     = addfile ("uvt.nc" , "r")  
  u     = f->U
; ===========================
; color plot
; ===========================
  wks   = gsn_open_wks ("png", "h_long" )          ; open workstation
  
  res                      = True                  ; plot mods desired
  res@tiMainString         = "January 1988"        ; title

  res@cnLevelSelectionMode = "ManualLevels"        ; manual contour levels
  res@cnLevelSpacingF      = 5.0                   ; contour interval
  res@cnMinLevelValF       = -50.                  ; min level
  res@cnMaxLevelValF       =  50.                  ; max level
  res@cnLineLabelsOn       = True                  ; turn on line labels
  res@cnFillOn             = True                  ; turn on color fill
  res@cnFillPalette        = "BlWhRe"              ; set color map
  
; note this data is already on pressure levels. If this were model data,
; it would be necessary to interpolate the data from hybrid coordinates
; to pressure levels.

  plot = gsn_csm_pres_hgt(wks,u(0,:,{-16},:),res)
  
; the "{}" allows you to use coordinate subscripting to select a particular 
; latitude vice array indice of the latitude you want. 
end

