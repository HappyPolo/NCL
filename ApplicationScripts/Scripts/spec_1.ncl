;*************************************************
; spec_1.ncl
;
; Concepts illustrated:
;   - Calculating and plotting spectra
;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
;************************************************
begin
;************************************************
; variable and file handling
;************************************************
   fn  = "SOI_Darwin.nc" ; define filename
   in  = addfile(fn,"r")                                 ; open netcdf file
   soi  = in->DSOI                                       ; get data
;************************************************
; set function arguments
;************************************************
; detrending opt: 0=>remove mean 1=>remove mean and detrend
  d = 0
; smoothing periodogram: (0 <= sm <= ??.) should be at least 3 and odd
  sm = 7
; percent tapered: (0.0 <= pct <= 1.0) 0.10 common. 
  pct = 0.10
;************************************************
; calculate spectrum
;************************************************
  spec = specx_anal(soi,d,sm,pct)
;************************************************
; plotting
;************************************************
   wks  = gsn_open_wks("ps","spec")                ; Opens a ps file 

   res = True					   ; no plot mods desired
   res@tiMainString = "SOI"		           ; title
   res@tiXAxisString = "Frequency (cycles/month)"  ; xaxis
   res@tiYAxisString = "Variance"                  ; yaxis

   plot=gsn_csm_xy(wks,spec@frq,spec@spcx,res)     ; create plot   
;***********************************************
end


