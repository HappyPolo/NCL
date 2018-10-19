; ===============================================
; filters_1.ncl
; ===============================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  f = addfile ("chi200_ud_smooth.nc", "r") 
  scale = 1.e6                                     ; create scale factor
  tmp   = f->CHI                                   ; get chi
  tmp   = tmp/scale                                ; scale for convenience
;===============================
; filter over time dimension
;===============================
  wgt  = (/1., 3., 5., 6., 5., 3., 1./)            ; weights
  wgt  = wgt/sum(wgt)                              ; normalize wgts
  yhov = wgt_runave (tmp(lon|:,time|:), wgt, 0)   ; compute running ave
  
  yhov!0    = "lon"                                ; name dimensions
  yhov!1    = "time"
;===============================
; return variable to original dimension  order for plotting
;===============================
  chov      = yhov(time|:,lon|:)                   ; move to 2D array for plot
  chov&time = tmp&time                                ; set coordinate
  chov&lon  = tmp&lon
  copy_VarAtts(tmp,chov)                           ; copy attributes
;=====================================
; create plot
;=====================================
   wks  = gsn_open_wks ("png", "filters" )      ; send graphics to PNG file

   res                      = True              ; Plot mods desire
   res@tiMainString         = "Pacific Region"  ; title
   res@trYReverse           = True              ; reverse y axis

   res@cnLevelSelectionMode = "ManualLevels"    ; manually set contour levels
   res@cnMinLevelValF       = -10.              ; min level
   res@cnMaxLevelValF       =  10.              ; max level
   res@cnLevelSpacingF      =   2.              ; contour interval

   res@cnFillOn             = True              ; turn on color fill
   res@cnFillPalette        = "BlWhRe"          ; set color map
   res@cnLinesOn            = False             ; turn off contour lines

   res@tmYLMode            = "Explicit"         ; Define own tick mark labels.
   res@tmYLValues    = (/  0. ,  30.,  61.,   89., 120., 150. /)
   res@tmYLLabels    = (/"DEC","JAN","FEB","MAR" ,"APR","MAY" /)
   
   plot = gsn_csm_hov(wks, chov(:,{100:220}), res) 

end
