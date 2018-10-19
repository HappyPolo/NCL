;*******************************************************
; vert_4.ncl
;*******************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  

begin
   
  in_hy      = addfile("atmos.nc","r")  
  in_sig     = addfile("T6319810305.nc","r")  

  sig_levels = in_sig->sig_level       ; sigma level (top to bottom)
  ps         = in_sig->PS              ; required by sigma2hybrid  
  tmp        = in_sig->T              

  hyam       = in_hy->hyam             ; get hybrid coefficients from file
  hybm       = in_hy->hybm
  lev        = in_hy->lev              ; get level array
  P0         = 100000.                 ; pressure base (PA)

  t          = tmp(time|:,lat|:,lon|:,sig_level|:)              ;reorder
  tmp2    = sigma2hybrid(t,sig_levels,hyam,hybm,P0,ps,1)


  tmp2!0  = "time"                                ; name dimension
  tmp2!1  = "lat"
  tmp2!2  = "lon"
  tmp2!3  = "lev"

  t_sigma     = tmp2(time|:,lev|:,lat|:,lon|:)    ; put back in orig order
  t_sigma&lon = t&lon                             ; assign coordinate varb
  t_sigma&lat = t&lat
  t_sigma&lev = lev
;*******************************************************
; create plot
;*******************************************************
  wks  = gsn_open_wks("png","vert")               ; send graphics to PNG file

  res                 = True                      ; plot mods desired
  res@cnFillOn        = True                      ; turn on color fill
  res@cnFillPalette   = "wh-bl-gr-ye-re"          ; set color map
  res@lbLabelStride   = 2                         ; every other color
  res@tmYRMode        = "Automatic"               ; turn off height labels

  res@tiMainString    = "Data on Sigma Levels"    ; title
  plot  = gsn_csm_contour(wks,tmp(0,:,{30},:), res )  ; create plot


  res@tiMainString    = "Data on Hybrid Levels"    ; title
  plot  = gsn_csm_contour(wks,t_sigma(0,:,{30},:), res )  ; create plot

end
