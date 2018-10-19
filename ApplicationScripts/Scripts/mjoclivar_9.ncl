
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl"    

  
;******************** MAIN **********************************
begin
                           ; Must include period of mutual overlap
  twStrt = 19961001        ; include enough temporal buffer for filter
  twLast = 20051231        ; at least 100 days on each side of season

 ;cwStrt = 20001101        ; correlation window for specified season 
 ;cwLast = 20010531       

  pName  = "data"          ; name of variable on precipitation file
  dirp   = "/Users/shea/Data/AMWG/"
  filp   = "pregpcp19962008.daily.nc"     ; last date w data 20080430

  uName  = "U_anom"        ; name of variable on U-anomaly file
  diru   = "/Users/shea/Data/AMWG/"
  filu   = "uwnd.day.850.anomalies.1980-2005.nc"

  nameSeason = (/ "winter", "summer", "annual" /)

  nameRegion = "IO"        ; Indian Ocean base region
  latS_IO    = -10.
  latN_IO    =   5. 
  lonL_IO    =  75.
  lonR_IO    = 100. 

  latS_globe = -30.        ; global subset  [Fig 6]
  latN_globe =  30. 

  latn       =  10.        ; lat band for (lag,lon) Fig 5
  lats       = -10.

  lonl       =  80.        ; lon band for (lag,lat) Fig 6
  lonr       = 100.

  pltName    = "mjo"       ; output plot name         
  pltType    = "ps"       ; x11, ps, eps, pdf, png 
  pltDir     = "./"        ; output plot directory

;************************************************
; create Lanczos BandPass Filter
;************************************************
  ihp    = 2                          ; bpf=>band pass filter
  nWgt   = 201
  sigma  = 1.0                        ; Lanczos sigma
  fca    = 1./100.                    ; MJO clivar
  fcb    = 1./20.
  wgt    = filwgts_lanczos (nWgt, ihp, fca, fcb, sigma )

;************************************************************
; PRECIPITATION:
;     time indices corresponding to the desired time window
;     Read user specified period
;************************************************************

  f      = addfile(dirp+filp, "r")  
  date_p = cd_calendar(f->time, -2)   ; entire file
  iStrt  = ind(date_p.eq.twStrt)      ; desired dates
  iLast  = ind(date_p.eq.twLast)
  delete(date_p)
                                      ; P(time,lat,lon)
  if (getfilevartypes(f,pName) .eq. "short") then
      P  = short2flt( f->$pName$(iStrt:iLast,{latS_globe:latN_globe},:)) 
  else
      P  = f->$pName$(iStrt:iLast,{latS_globe:latN_globe},:) 
  end if

  printVarSummary( P )
  printMinMax(P, True)

  time_p = P&time                     ; clarity
  date_p = cd_calendar(time_p, -2 )   ; yyyymmdd
  
  wyIO   = f->lat({latS_IO:latN_IO})  
  wyIO   = cos(0.017459*wyIO)         ; spatial wgt

;************************************************************
; U ANOMALIES:
;     time indices corresponding to the desired time window
;     Read user specified period
;************************************************************

  f      = addfile(diru+filu, "r")  
  date_u = cd_calendar(f->time, -2)     ; entire file
  iStrt  = ind(date_u.eq.twStrt)        ; desired dates
  iLast  = ind(date_u.eq.twLast)
  delete(date_u)
                                        ; U(time,lat,lon)
  if (getfilevartypes(f,uName) .eq. "short") then
      U  = short2flt( f->$uName$(iStrt:iLast,{latS_globe:latN_globe},:)) 
  else
      U  = f->$uName$(iStrt:iLast,{latS_globe:latN_globe},:) 
  end if

  printVarSummary( U )
  printMinMax(U, True)

  time_u = U&time                     ; clarity
  date_u = cd_calendar(time_u , -2 )  ; yyyymmdd

  wyU    = f->lat({latS_IO:latN_IO})
  wyU    = cos(0.017459*wyU)          ; MJO Clivar says cos(lat) wgting

;************************************************
; make sure dates agree
;************************************************

  if (.not.all(date_p.eq.date_u)) then
      print("date mismatch: exit")
      exit
  end if

;************************************************
; Create wgted area average of the base IO precip series  (time)
; Really, no need to area weight here .... area is very small.
;************************************************

  PIO    = wgt_areaave_Wrap(P(:,{latS_IO:latN_IO},{lonL_IO:lonR_IO}), wyIO, 1., 0)
  PIO    = dtrend (PIO, False)                                   ; rmv overall trend
  PIO    = wgt_runave_leftdim( PIO, wgt, 0 )                     ; apply filter
  
;************************************************
; Create LAT average of the global Precip and U series  (time,lon)
; Really, no need to area weight here
;************************************************

  P_timeLon   = dim_avg_Wrap(P( time|:,lon|:,{lat|lats:latn}) )  ; (time,lon)
  P_timeLon   = dtrend_leftdim (P_timeLon, False)                ; rmv overall trend
  P_timeLon   = wgt_runave_leftdim( P_timeLon, wgt, 0 )          ; apply filter

  U_timeLon   = dim_avg_Wrap(U( time|:,lon|:,{lat|lats:latn}) )  ; (time,lon)
  U_timeLon   = dtrend_leftdim (U_timeLon, False)                ; rmv overall trend
  U_timeLon   = wgt_runave_leftdim( U_timeLon, wgt, 0 )

;************************************************
; Create LON average of the global Precip and U series  (time,lat)
; Really, no need to area weight here
;************************************************

  P_timeLat   = dim_avg_Wrap(P( time|:,lat|:,{lon|lonl:lonr}) )  ; (time,lat)
  P_timeLat   = dtrend_leftdim (P_timeLat, False)                ; rmv overall trend
  P_timeLat   = wgt_runave_leftdim( P_timeLat, wgt, 0 )          ; apply filter

  U_timeLat   = dim_avg_Wrap(U( time|:,lat|:,{lon|lonl:lonr}) )  ; (time,lat)
  U_timeLat   = dtrend_leftdim (U_timeLat, False)                ; rmv overall trend
  U_timeLat   = wgt_runave_leftdim( U_timeLat, wgt, 0 )

;*************************************************************************
; Calculate/Plot the mean seasonal cross-correlations at +/- 'mxlag' lags
;*************************************************************************
  optXcor   = False
  mxlag     = 25
  nSeason   = dimsizes(nameSeason)

  optPlot                  = True
  optPlot@gsnLeftString    = "precip (color)"    
  optPlot@gsnRightString   = "U (lines)"  
  optPlot@smth9            = 0.25                ; local spatial smoothing

  timePeriod               =  twStrt+"-"+twLast  ; panel title 

  do ns=0,nSeason-1                              ; loop over each season
     rp_timelon = mjo_xcor_lag (PIO, P_timeLon, date_u, mxlag, nameSeason(ns), optXcor)
     ru_timelon = mjo_xcor_lag (PIO, U_timeLon, date_u, mxlag, nameSeason(ns), optXcor)

     rp_timelat = mjo_xcor_lag (PIO, P_timeLat, date_u, mxlag, nameSeason(ns), optXcor)
     ru_timelat = mjo_xcor_lag (PIO, U_timeLat, date_u, mxlag, nameSeason(ns), optXcor)

     optPlot@txString      = nameSeason(ns)+": "+timePeriod
     pltNameSeason = pltName+"."+nameSeason(ns)
     mjo_xcor_lag_ovly_panel(rp_timelon, ru_timelon, rp_timelat, ru_timelat \
                            ,pltType, pltDir, pltNameSeason, optPlot)
  end do
end
