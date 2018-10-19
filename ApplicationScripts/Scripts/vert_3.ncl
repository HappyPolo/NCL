;*************************************************
; NCL tutorial script: vert_3.ncl
; this script demonstrates how to use int2p to 
; interpolate from one set of pressure levels to 
; another. Since we only have model data that is
; on hybrid levels, we will conduct that interpolation
; first.
;
; As of V5.2.0 and later, you can use int2p_n for
; faster interpolation (no reordering required).
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;************************************************
begin
;************************************************
; file handling
;************************************************
   fn  = "atmos.nc" ; define filename
   in  = addfile(fn,"r")                         ; open netcdf file
;************************************************
; read needed variables from file
;************************************************
   T = in->T                                     ; select variable to ave
   P0mb =1000.
   hyam = in->hyam                               ; get a coefficients
   hybm = in->hybm                               ; get b coefficients
   PS   = in->PS                                 ; get pressure
;************************************************
; define other arguments required by vinth2p
;************************************************
; type of interpolation: 1 = linear, 2 = log, 3 = loglog
   interp = 2 

; is extrapolation desired if data is outside the range of PS
   extrap = False

; create an array of desired pressure levels:
   pnew = (/ 1000.0,900.0,850.0,700.0,500.0,300.0,200.0,20.0/)            
;************************************************
; calculate T on pressure levels
;************************************************
; note: vinth2p will only accept 3 dimensions, so the first time step is 
; chosen in the example below.
;
; note, the 7th argument is not used, and so is set to 1.
;************************************************
  TonP = vinth2p(T(0,:,:,:),hyam,hybm,pnew,PS(0,:,:),interp,P0mb,1,extrap)
;************************************************
; calculate TonP on a different set of pressure levels
;************************************************
  lev       = (/ 950.0,900.0,800.0,650.0,550.0,400.0,100.0/)
  lev@units = "mb"        ; units attribute required by gsn_csm_pres_hgt
  
;**********************************************************  
; use int2p to interpolate: This operates on the rightmost 
; dimension so use named dimensions to reorder
; 
; As of V5.2.0, you will be able to use int2p_n_Wrap so no
; reordering is required. See code below.
;*********************************************************
  tmp     = int2p(pnew,TonP(lat|:,lon|:,lev_p|:),lev,1)
  tmp!0   = "lat"         ; assign named dimension so can reorder and plot
  tmp!1   = "lon"
  tmp!2   = "lev"
  tmp&lev = lev           ; required by gsn_csm_pres_hgt
  
  result = tmp(lev|:,lat|:,lon|:) ; plot template want in lev,lat order

; For V5.2.0 and higher, comment out code above, and use this
; one line instead.
; result = int2p_n_Wrap(pnew,TonP,lev,1,0)

;************************************************
; plot parameters that do not change
;************************************************
  wks  = gsn_open_wks("png","vert")               ; send graphics to PNG file

  res                 = True                      ; plot mods desired
  res@cnFillOn        = True                      ; turn on color fill
  res@cnFillPalette   = "wh-bl-gr-ye-re"          ; set color map
  res@lbLabelStride   = 2                         ; every other color
  res@tiMainString    = "Pressure to Pressure Interpolation" 
  res@tmYRMode        = "Automatic"               ; turn off height labels

  plot  = gsn_csm_pres_hgt(wks,result(:,:,5), res )  ; create plot

end
