;*************************************************
; spec_2.ncl
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
   fn  = "SLP_DarwinTahitiAnom.nc" 
   in  = addfile(fn,"r")                         ; open netCDF file          
   dslp  = in->DSLP                              ; get Darwin slp
   tslp =  in->TSLP                              ; get Tahiti slp
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
  spec = specxy_anal(dslp,tslp,d,sm,pct)
;************************************************
; plotting parameters that remain constant
;************************************************
   plot=new(6,graphic)                            ; creates a graphic array

   wks  = gsn_open_wks("ps","spec")               ; Opens a ps file

   res               = True                       ; no plot mods desired
   res@tiXAxisString = "Frequency (cycles/month)" ; xaxis
   res@gsnFrame      = False                      ; required for panel plots
   res@gsnDraw       = False                      ; required for panel plots
;************************************************
; create plot of cospectrum
;************************************************
   res@tiYAxisString = "Cospectrum"               ; yaxis
   plot(0)=gsn_csm_xy(wks,spec@frq,spec@cospc,res); create plot   
;***********************************************
; create plot of quadrature spectrum. 
;************************************************
   res@tiYAxisString = "Quadrature"               ; yaxis
   plot(1)=gsn_csm_xy(wks,spec@frq,spec@quspc,res); create plot   
;***********************************************
; create plot of coherance
;************************************************
   res@tiYAxisString = "Coherance SQ"             ; yaxis
   plot(2)=gsn_csm_xy(wks,spec@frq,spec@coher,res); create plot  
;***********************************************
; create plot of phase
;************************************************
   res@tiYAxisString = "Phase"                    ; yaxis
   plot(3)=gsn_csm_xy(wks,spec@frq,spec@phase,res); create plot  
;***********************************************
; create plot spec soi
;************************************************
   res@tiYAxisString = "Variance of DSLP"          ; yaxis
   plot(4)=gsn_csm_xy(wks,spec@frq,spec@spcx,res)  ; create plot  
;***********************************************
; create plot spec slp
;************************************************
   res@tiYAxisString = "Variance of TSLP"          ; yaxis
   plot(5)=gsn_csm_xy(wks,spec@frq,spec@spcy,res)  ; create plot  
;************************************************
   res_P             = True                        ; panel mods desired
   res_P@gsnMaximize = True                        ; blow up plot
   gsn_panel(wks,plot,(/3,2/),res_P)               ; create panel plot
end


