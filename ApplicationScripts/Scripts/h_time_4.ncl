; ===============================================
; h_time_4.ncl              
; ===============================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;================================================
; get data
;================================================
  f     = addfile ("ts.nc", "r")
  v     = f->V    
;================================================
; smooth data
;================================================
  wgt   = (/ 1., 3., 4., 3., 1./)                  ; wgts for temporal smooth
  wgt   = wgt/sum(wgt)                             ; normalize

  slice   = v(lev|:,time|:,lat|0)                  ; trick to copy meta data
  slice   = wgt_runave(v(lat|30,lev|:,time|:), wgt, 0) 
;================================================
; plot
;================================================
  wks   = gsn_open_wks ("png", "h_time")           ; send graphics to PNG file
  res                      = True                  ; plot mods desired
  
  res@cnFillOn             = True                  ; turn on color
  res@cnFillPalette        = "BlWhRe"              ; set color map
  res@cnLinesOn            = False                 ; no contour lines

  res@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
  res@cnMinLevelValF       = -4.                  ; set min contour level
  res@cnMaxLevelValF       =  4.                  ; set max contour level
  res@cnLevelSpacingF      = 0.5                  ; set contour spacing
  

; in this example, we only plot part of the vertical extent. This reduces
; the number of tickmarks on the height axis. The following will increase
; the number:
  res@tmYRTickSpacingF     = 1                    ;

  plot = gsn_csm_pres_hgt (wks,slice({1000:500},:),res) 
end
