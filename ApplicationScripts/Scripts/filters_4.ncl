; ***********************************************
; filters_4.ncl
; ***********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"    
begin

;  diri  = "/Users/shea/Data/AMWG/"
  diri  = "./"
  vName = "U_anom"        ; name of variable on the file
  fili  = "uwnd.day.850.anomalies.1980-2005.nc"
  f     = addfile(diri+fili, "r")

  time  = f->time
  date  = cd_calendar(time,-2)          ; yyyymmdd

  pStrt = 19950101      ; 4 years: winter 96-97 MJO gold standard
  pLast = 19981231
  iStrt = ind(date.eq.pStrt)            ; user specified dates
  iLast = ind(date.eq.pLast)

  X     = f->$vName$(:,{0},{120})       ; entire series

  yrfrac= yyyymmdd_to_yyyyfrac (date, 0)
  delete(yrfrac@long_name)

  x     = X(iStrt:iLast)                ; sub-period
  ntim  = dimsizes(x)                   ; #times in sub-period

; ***********************************************
; create the filter weights and apply
; ***********************************************
  ihp     = 2                             ; band pass
  sigma   = 1.0                           ; Lanczos sigma

  nWgt    = 731                           ; loose 365 each end                            
  fca     = 1./60.                        ; start freq
  fcb     = 1./30.                        ; last  freq
  wgt     = filwgts_lanczos (nWgt, ihp, fca, fcb, sigma )

  xbpf    = wgt_runave ( x, wgt, 0 )      ; sub-period
  XBPF    = wgt_runave ( X, wgt, 0 )      ; entire series

; ***********************************************
; perform FFT
; ***********************************************

  cf      = ezfftf (x)                    ; sub period (2, ntim/2)
  fcf     = fspan(0, 0.5, ntim/2) 
  ifcf    = ind(fcf.lt.fca .or. fcf.gt.fcb)
  cf(:,ifcf) = 0.0                        ; set coef to zero
  xfft    = ezfftb (cf, cf@xbar)    

; ***********************************************

  yPlot   = new ( (/3,ntim/) , typeof(x))

  yPlot(0,:) = XBPF(iStrt:iLast)     
  yPlot(1,:) = xfft
  yPlot(2,:) = xbpf                 

; ***********************************************
; create new date array for use on the plot
; ***********************************************
  pltType = "png"                    ; send graphics to PNG file
  pltName = "filters"
  wks     = gsn_open_wks (pltType,pltName)

  res              = True            ; plot mods desired
  res@gsnMaximize  = True
  res@vpHeightF    = 0.4             ; change aspect ratio of plot
  res@vpWidthF     = 0.8                  
  res@vpXF         = 0.1             ; start plot at x ndc coord 
  res@gsnYRefLine  = 0.0             ; create a reference line   
  res@xyMonoDashPattern= True
  res@xyLineThicknesses= (/  2, 2, 3 /)   ; xyLineThicknessF = 2
  res@xyLineColors     = (/ "black", "blue", "red" /)

  res@pmLegendDisplayMode    = "Always"            ; turn on legend
  res@pmLegendSide           = "Top"               ; Change location of 
  res@pmLegendParallelPosF   = .1                  ; move units right
  res@pmLegendOrthogonalPosF = -0.45               ; move units down
  res@pmLegendWidthF         = 0.12                ; Change width and
  res@pmLegendHeightF        = 0.12                ; height of legend.
  res@lgPerimOn              = False               ; turn off box around
  res@lgLabelFontHeightF     = .015                ; label font height
  res@xyExplicitLegendLabels = (/"BPF","FFT","bpf"/) ; create explicit labels
  res@tmXBFormat             = "f"
  
  res@gsnCenterString  = "Band Pass Filtered: 30-60 day"     
  plot = gsn_csm_xy (wks,yrfrac(iStrt:iLast),yPlot,res)     

    ; Create XY plot of frequency versus response

  xyres = True

  xyres@gsnMaximize    = True
  xyres@gsnFrame       = False
  xyres@tiMainString   = "Band Pass: 20-100 srate=1: sigma = " + sigma
  xyres@tiXAxisString  = "frequency"
  xyres@tiYAxisString  = "response"
  xyres@gsnLeftString  = "fca=" + fca + "; fcb=" + fcb
  xyres@gsnRightString = nWgt
  xyres@trXMaxF        = 0.07
  xyres@trYMaxF        = 1.1
  xyres@trYMinF        = -0.1
  xyres@xyLineThicknessF = 3.0

  plot = gsn_csm_xy(wks, wgt@freq, wgt@resp, xyres)

  polyX = (/0.0, fca, fca, fcb, fcb, 0.1/)      ; ideal filter
  polyY = (/0.0, 0.0, 1.0, 1.0, 0.0,  0.0 /)

  resGs = True
  resGs@gsLineThicknessF = 1.0

  gsn_polyline(wks,plot,polyX,polyY,resGs)

  frame(wks)

end

