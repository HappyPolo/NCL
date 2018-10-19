;************************************************
; spec_4.ncl
;
; Concepts illustrated:
;   - Calculating and plotting spectra
;   - Calculating confidence intervals
;   - Making an axis logarithmic in an XY plot
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
; calculate confidence interval [here 5 and 95%]
; return 4 curves to be plotted
;************************************************
  splt = specx_ci (sdof, 0.05, 0.95)
;************************************************
; plotting
;************************************************
   wks  = gsn_open_wks("ps","spec")              ; Opens a ps file

   r = True                                      ; plot mods desired
   r@tiMainString = "SOI"                        ; title
   r@tiXAxisString = "Frequency (cycles/month)"  ; xaxis
   r@tiYAxisString = "Variance"                  ; yaxis
;***********************************************
; Generate log plot showing "red noise" confidence bounds
; (a) log scaling and (b) the Band Width
;***********************************************
   r@trYLog              = True                 ; log scaling
   r@trYMinF             = 0.10                 ; manually set lower limit
   r@trYMaxF             = 30.0                 ;   "          upper
   r@gsnFrame            = False                ; do not advance frame
   plot  = gsn_csm_xy(wks,sdof@frq, splt,r)

   xf   = (/0.40, 0.40+sdof@bw/)                ; Create band width line
   ys   = 0.75*max(sdof@spcx)                   ; 75% up Y axis
   yv   = (/ys,ys/)               
   rpl  = True                                  ; resources for polyline
   rpl@gsLineThicknessF  = 2                    ; Define line thickness 
   gsn_polyline(wks,plot,xf,yv,rpl)             ; Draw BandWidth

   txres= True                                  ; label BW line
   txres@txFontHeightF = 0.015                  ; font height
   txres@txJust        = "CenterLeft"           ; Set lable location
   gsn_text(wks,plot,"BW",0.41+sdof@bw,ys,txres); Label 
   frame (wks)
end


