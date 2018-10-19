load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl"    
   
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
begin
                           ; time window 
  twStrt = 19800101        
  twLast = 20051231

  latS   = -10.
  latN   =  10.

  diri   = "./"

;;vName  = "U_anom"        ; name of variable on the file
;;fili   = "uwnd.day.850.anomalies.1980-2005.nc"  

  vName  = "OLR_anom"        ; name of variable on the file
  fili   = "olr.day.anomalies.1980-2005.nc"         

  f      = addfile(diri+fili, "r")  

  pltDir  = "./"
  pltType = "ps"
  pltName = "mjoclivar"

;************************************************************
; time indices corresponding to the desired time window
;************************************************************

  date  = cd_calendar(f->time, -2)   ; entire file
  iStrt = ind(date.eq.twStrt)        ; desired dates
  iLast = ind(date.eq.twLast)
  delete(date)

;************************************************************
; Read user specified period
;************************************************************

  if (getfilevartypes(f,vName) .eq. "short") then
      X = short2flt( f->$vName$(iStrt:iLast,{latS:latN},:) ) ; all data in window
  else
      X = f->$vName$(iStrt:iLast,{latS:latN},:) 
  end if
  printVarSummary( X )
  printMinMax(X, True)

  time  = X&time                     ; clarity
  date  = cd_calendar( time , -2 )   ; yyyymmdd

;************************************************************
; MJO Clivar says to average the data over latitude and
; use the averaged to compute spectra. 
; No areal weighting  for -10 to 10
;************************************************************

 ;x = dim_avg_Wrap( X(time|:,lon|:,lat|:) )    ; (time,lon) ; v5.1.0 & previous
  x = dim_avg_n_Wrap( X, 1 )                   ; (time,lon) ; v5.1.1 onward
  
;************************************************************
; calculate and plot the OLR spectra
;************************************************************
  optWavFrq     = False
  optPlot       = True
  optPlot@cnLinesOn    = False

  nameSeason = (/"winter" , "summer"/)
  
  do ns=0,dimsizes(nameSeason)-1
     wf      = mjo_wavenum_freq_season (x, date,nameSeason(ns), optWavFrq)  
     optPlot@tiMainString = nameSeason(ns)+": "+twStrt+"-"+twLast
     mjo_wavenum_freq_season_plot (wf, nameSeason(ns), pltDir, pltType, pltName, optPlot) 
  end do
end
