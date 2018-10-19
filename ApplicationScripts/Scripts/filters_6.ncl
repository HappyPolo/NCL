; ***********************************************
; filters_6.ncl
; ***********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"    

begin

  ; diri  = "/Users/shea/Data/AMWG/"
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
  delete(date)
  delete(time)

  x     = f->$vName$(iStrt:iLast,{0},{120}) ; subperiod

  time  = x&time                        ; explicit for clarity
  date  = cd_calendar(time,-2)          ; yyyymmdd subperiod

  yrfrac= yyyymmdd_to_yyyyfrac (date, 0)
  delete(yrfrac@long_name)

  ntim  = dimsizes(x)                   ; #times in sub-period

; ***********************************************
; create the Lanczos filter weights 
; ***********************************************
  ihp     = 2                             ; band pass
  sigma   = 1.0                           ; Lanczos sigma

  nWgt    = 731                           ; loose 365 each end                            
  fca     = 1./60.                        ; start freq
  fcb     = 1./30.                        ; last  freq
  wgt     = filwgts_lanczos (nWgt, ihp, fca, fcb, sigma )

; ***********************************************
; perform FFT
; ***********************************************

  cf   = ezfftf (x)                    ; cf(2,ntim/2)   [sub-period]
                                       ; map response of digitial
                                       ; filter to fft space
  fcf  = fspan(0, 0.5, ntim/2)         ; fft freq

; ***********************************************
; Map Lanczos response to FFT freq  
; ***********************************************
  wcf  = linint1 (wgt@freq, wgt@resp, False, fcf, 0)

; ***********************************************
; Apply 'wcf' to the Fourier coef  
; ***********************************************
  cf(0,:) = cf(0,:)*wcf                ; apply mapped response coef
  cf(1,:) = cf(1,:)*wcf                ; to fft coef

; ***********************************************
; Fourier synthesis with the weighted fourier coef
; ***********************************************
  xfft = ezfftb(cf, 0.0)               ; fourier synthesis
 ;xfft = ezfftb(cf, cf@xbar)           ; fourier synthesis
  xfft@process    =  "FFT with Lanczos response mapped to FFT space"

; ***********************************************
; Manually set the end points to _FillValue
; ***********************************************
  xfft(0:nWgt/2)  = 1e20               ; manually set to _FillValue  
  xfft(ntim-(nWgt/2):ntim-1) = 1e20  
  xfft@_FillValue = 1e20 

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
  res@xyLineThicknessF = 2
  res@xyLineColors     = "black"
  
  res@gsnCenterString  = "FFT with Lanczos Weighting: 30-60 day"     
  plot = gsn_csm_xy (wks,yrfrac, xfft,res)     
end

