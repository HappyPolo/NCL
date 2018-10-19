;*************************************************
; bfband_2.ncl
;
; Concepts illustrated:
;   - Specifying bandwidth and reading individual grid point  
;   - Apply 'filwgts_lanczos' *and* Apply 'bw_bandpass_filter' 
;   - plot raw time series
;   - Plot filterd and envelope series
;   - plot filterd and envelope series
;************************************************
; # These libraries are automatically loaded from 6.2.0 onward #
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"  

; ***********************************************
; Specify assorted constants
; ***********************************************

  LAT     = 0  
  LON     = 120

  ca      = 50          ; Butterworth
  cb      = 40   

  nWgt    = 1461        ; Lanczos: loose 730 each end (2years)                            

  pltType = "png"       ; send graphics to PNG file
  pltName = "bfband"

; ***********************************************
; Read the full time series fpr a specified (LAT,LON)
; ***********************************************

  diri    = "./"
  vName   = "U_anom"        ; name of variable on the file
  fili    = "uwnd.day.850.anomalies.1980-2005.nc"
  f       = addfile(diri+fili, "r")

  u       = f->U_anom(:,{LAT},{LON})

  dimu    = dimsizes(u)
  ntim    = dimu(0)

; ***********************************************
; calculate the start and stop frequency band limits
; ***********************************************

  fca     = 1.0/ca                        ; start freq
  fcb     = 1.0/cb                        ; last  freq

; ***********************************************
; Lanczos filter
; ***********************************************

  ihp     = 2                             ; band pass
  sigma   = 1.0                           ; Lanczos sigma

  wgt     = filwgts_lanczos (nWgt, ihp, fca, fcb, sigma )
  u_lz    = wgt_runave_Wrap ( u, wgt, 0 )     
  u_lz@long_name = "Lanczos Bandpass: "+cb+"-"+ca+" day"
  printVarSummary(u_lz)                        

; ***********************************************
; Butterworth filter
; ***********************************************
  opt     = False                              ; use defaults
  u_bf    = bw_bandpass_filter(u,fca,fcb,opt, 0)     ; dims=0
  u_bf@long_name = "BW Bandpass: "+cb+"-"+ca+" day"

  copy_VarMeta(u,u_bf)
  printVarSummary(u_bf)                        

; ***********************************************
; create new date array for use on the plot
; ***********************************************

  date    = cd_calendar(u&time,-2)        ; yyyymmdd
  yrfrac  = yyyymmdd_to_yyyyfrac (date, 0)
  delete(yrfrac@long_name)
  delete(u@long_name)

  pStrt = 19951231           
  pLast = 19980101

  iStrt = ind(date.eq.pStrt)        ; user specified dates
  iLast = ind(date.eq.pLast)

; ***********************************************
; plots
; ***********************************************
  Y       = new( (/2,ntim/), typeof(u), "No_FillValue") 
  Y(0,:)  = (/ u_lz /) 
  Y(1,:)  = (/ u_bf /)     

  plot    = new ( 2, "graphic") 
  wks     = gsn_open_wks (pltType,pltName)

  res              = True            ; plot mods desired
  res@gsnDraw      = False           ; don't draw 
  res@gsnFrame     = False           ; don't advance frame yet      

  res@vpHeightF    = 0.4             ; change aspect ratio of plot
  res@vpWidthF     = 0.8                  
  res@vpXF         = 0.1             ; start plot at x ndc coord 
  res@gsnYRefLine  = 0.0             ; create a reference line   
  res@trYMinF      =-4.0
  res@trYMaxF      = 4.0
  res@tmXBFormat   = "f" 

;---> PLOT 1:  (a) filtered series; (b) Lanczos

  res@gsnCenterString = "Anomaly U ["+LAT+","+LON+"]" 
  plot(0) = gsn_csm_xy (wks,yrfrac(iStrt:iLast),u(iStrt:iLast),res)      

  res@xyMonoDashPattern      = True
  res@xyLineThicknesses      = (/2.0,1.0/)   
  res@xyLineColors           = (/"black","red"/)    ; change line color
                                                    ; add a legend
  res@pmLegendDisplayMode    = "Always"             ; turn on legend
  res@pmLegendSide           = "Top"                ; Change location of 
  res@pmLegendParallelPosF   = .70                  ; move units right
  res@pmLegendOrthogonalPosF = -0.5                 ; more neg = down
  res@pmLegendWidthF         = 0.10                 ; Change width and
  res@pmLegendHeightF        = 0.125                ; height of legend.
  res@lgLabelFontHeightF     = .02                  ; change font height
  res@lgPerimOn              = False                ; no box around
  res@xyExplicitLegendLabels = (/"Lanczos","Butterworth"/)

  res@gsnCenterString  = "Lanczos ("+nWgt+")/Butt Band Pass Filtered: "+cb+"-"+ca+" day"     
  res@xyLineThicknesses = (/3.0,1.5/)   
  plot(1) = gsn_csm_xy (wks,yrfrac(iStrt:iLast),Y(:,iStrt:iLast),res) 
  
  resP                 = True    
  resP@gsnMaximize     = True
  gsn_panel(wks,plot,(/2,1/),resP) 

;---> PLOT 2:  (a) filtered series; (b) Lanczos  [ begin end effect ]  

  nStrt = 0
  nLast = nWgt
  res@pmLegendDisplayMode    = "NoCreate"            ; turn legend off

  res@gsnCenterString = "Anomaly U ["+LAT+","+LON+"]" 
  plot(0) = gsn_csm_xy (wks,yrfrac(nStrt:nLast),u(nStrt:nLast),res)      

  res@pmLegendDisplayMode    = "Always"             ; turn on legend
  res@gsnCenterString  = "Lanczos ("+nWgt+")/Butt Band Pass Filtered: "+cb+"-"+ca+" day"     
  res@xyLineThicknesses = (/3.0,1.5/)   
  res@xyLineColors      = (/"blue","red"/)          ; change line color
  plot(1) = gsn_csm_xy (wks,yrfrac(nStrt:nLast),Y(:,nStrt:nLast),res) 
  
  resP                 = True    
  resP@gsnMaximize     = True
  gsn_panel(wks,plot,(/2,1/),resP) 
