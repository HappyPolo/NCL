;*************************************************
; spec_5.ncl
; A variation of spec_4
;************************************************
;;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;************************************************
begin
;************************************************
; Variable and file handling
; The is available from: 
;     http://www.ncl.ucar.edu/Applications/Data/
;************************************************
   fn  = "SOI_Darwin.nc"                       ; define filename
   in  = addfile(fn,"r")                       ; open netcdf file
   soi  = in->DSOI                             ; get data
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
  printVarSummary(splt)                          ; splt(4,702)
;************************************************
; plotting
;************************************************
   wks  = gsn_open_wks("ps","spec")              ; Opens a ps file

   r = True                                      ; plot mods desired
   r@tiMainString = "SOI: Darwin"                ; title
   r@tiXAxisString = "Frequency (cycles/month)"  ; xaxis
   r@tiYAxisString = "Variance/frq_interval"     ; yaxis

;***********************************************
; Generate log plot showing "red noise" confidence bounds
; (a) log scaling and (b) the Band Width
;***********************************************
   f = sdof@frq                                 ; convenience

   r@trYMinF             = 0.00                 ; manually set lower limit
   r@trYMaxF             = 20.0                 ;   "          upper
   r@gsnFrame            = False                ; do not advance frame
   plot  = gsn_csm_xy(wks,f, splt,r)

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

   r@gsnFrame          = True                   ;reset to default
;***********************************************
; PLOT abscissa as period (1/frequency)
;***********************************************
   p   = 1/f                                    ; *highly non-linear*
   p!0 = "f"
   p&f = f
   p@long_name = "period"
   p@units     = "month"
   
 ;;print("====")
 ;;print(f+"   "+p+"  "+splt(0,:) )             ; print 
 ;;print("====")

   r@tiXAxisString = "Period (month)"          ; xaxis
   r@tiYAxisString = "Variance/freq"           ; yaxis

   ip   = ind(p.le.240)                        ; all indices for "short" periods
   plot = gsn_csm_xy(wks,p(ip), splt(:,ip),r)     

   r@trXReverse = True
   plot = gsn_csm_xy(wks,p(ip), splt(:,ip),r)     
end
