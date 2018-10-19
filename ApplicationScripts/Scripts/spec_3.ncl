;*************************************************
; spec_3.ncl
;
; Concepts illustrated:
;   - Calculating confidence intervals
;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;************************************************
begin
;************************************************
; variable and file handling
;************************************************
   fn  = "SOI_Darwin.nc" ; define filename
   in  = addfile(fn,"r")                                  ; open netcdf file
   soi  = in->DSOI                                        ; get data
;************************************************
; set function arguments
;************************************************
  d   = 0    ; detrending opt: 0=>remove mean 1=>remove mean + detrend
  sm  = 21   ; smooth: should be at least 3 and odd
  pct = 0.10 ; percent taper: (0.0 <= pct <= 1.0) 0.10 common. 
;************************************************
; calculate spectrum
;************************************************
  sdof = specx_anal(soi,d,sm,pct)
;************************************************
; plotting parameters
;************************************************
   wks  = gsn_open_wks("ps","spec")              ; Opens a ps file
   plot = new(4,graphic)                         ; create graphic array 

   r               = True                        ; plot mods desired
   r@gsnDraw       = False                       ; do not draw
   r@gsnFrame      = False                       ; do not advance frame
   r@tiMainString  = "SOI"                       ; title
   r@tiXAxisString = "Frequency (cycles/month)"  ; xaxis
   r@tiYAxisString = "Variance"                  ; yaxis
;************************************************
; first plot
;************************************************
   plot(0)=gsn_csm_xy(wks, sdof@frq, sdof@spcx, r)  ; create plot 
;***********************************************
; second plot: Generate quick-n-dirty plot showing 
;              5 and 95% "red noise" confidence 
;	       bounds
;***********************************************
   splt = specx_ci(sdof, 0.05, 0.95)             ; calc confidence interval
   plot(1) = gsn_csm_xy(wks,sdof@frq, splt,r)
;***********************************************
; Third Plot: Generate fancier plot showing 
;             "red noise" confidence bounds
;             (a) solid for spectrum and Markov, 
;             (b) dash for bounds 
;***********************************************
   r@xyLineThicknesses   = (/2.,1.,1.,1./)       ; Define line thicknesses 
   r@xyDashPatterns      = (/0,0,1,1/)           ; Dash patterns 
   plot(2) = gsn_csm_xy(wks,sdof@frq, splt,r)
;***********************************************
; Fouth Plot: Generate color plot showing 
;             "red noise" confidence bounds
;***********************************************
   r@xyLineColors        = (/"foreground","green","blue","red"/)
   plot(3) = gsn_csm_xy(wks,sdof@frq, splt,r)
;***********************************************
   res_P             = True                        ; panel mods desired
   res_P@gsnMaximize = True                        ; blow up plot
   gsn_panel(wks,plot,(/2,2/),res_P)               ; create panel plots
end


