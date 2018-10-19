;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; "The 1996-97 winter season is the golden standard for MJO. 
;  More recently, there was a strong MJO during Dec-Jan 2008."
;  Klaus Weikman (NOAA)
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl"    

;******************** MAIN **********************************
begin
                           ; time window : include enough buffer
  twStrt = 19950101        ; 4 years: winter 96-97 MJO gold standard
  twLast = 19981231

  thStrt = 19960101        ; plot start time
  thLast = 19971231        ; plot last  time

  spd    = 1               ; samples per day
  bpf    = (/20,100,201/)  ; input for band pass

  diri   = "/Users/shea/Data/AMWG/"
 ;vName  = "olr"           ; name of variable on the file
 ;fili   = "olr.day.mean.nc"
 ;vName  = "U_anom"        ; name of variable on the file
 ;fili   = "uwnd.day.850.anomalies.1980-2005.nc"

  vName  = "OLR_anom"      ; name of variable on the file
  fili   = "olr.day.anomalies.1980-2005.nc"
  f      = addfile(diri+fili, "r")  

  latS    =   0.           ; arbitrary
  latN    =  20.
  lonL    =  60.
  lonR    = 280.

  pltDir  = "./"
  pltType = "x11"                    ; x11, ps, eps, pdf, png
  pltName = "mjo"         

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
      X = short2flt( f->$vName$(iStrt:iLast,:,:) ) ; all data in window
  else
      X = f->$vName$(iStrt:iLast,:,:) 
  end if
  printVarSummary( X )
  printMinMax(X, True)

  time  = X&time                     ; clarity
  date  = cd_calendar( time , -2 )   ; yyyymmdd

  hStrt = ind(date.eq.thStrt)        ; indices of desired plot dates
  hLast = ind(date.eq.thLast)

;************************************************
; Extract Area averages and filtered series 
; Use NCL's coordinate subscripting
;************************************************

  x       = X(:,{latS:latN},{lonL:lonR})  ; explicitly extract [clarity]  
 ;printVarSummary( X )
 ;printMinMax(X, True)

  wgty    = latRegWgt(x&lat, "double", 0)
  optArea = False
  xAreaT  = band_pass_area_time(x, spd, bpf, wgty, optArea)

  printVarSummary(xAreaT)              ; (time)
  printMinMax(xAreaT, True)

;************************************************
; Plot  band_pass_area_time result 
;************************************************
  time    = x&time                     ; clarity
  date    = cd_calendar( time , -2 )   ; yyyymmdd

  optArea = True
  optArea@pltTitle = xAreaT@long_name+": Area ["+latS+":"+latN+" , "+lonL+":"+lonR+"]"
  band_pass_area_time_plot(xAreaT, time, pltDir, pltType ,pltName, optArea)

end
