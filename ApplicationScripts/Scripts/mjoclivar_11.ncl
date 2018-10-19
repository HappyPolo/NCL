;******************************************************
; mjoclivar_11.ncl
;
; Concepts illustrated:
;   - Rearranging longitude data to span -180 to 180
;
; List not finished.
;
;******************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl"    

;******************** MAIN **********************************
begin

  twStrt = 19960101        ; time window
  twLast = 19991231

  xName  = "OLR_anom"        ; name of variable on OLR file
  dirx   = "./"
  filx   = "olr.day.anomalies.1980-2005.nc"

  yName  = "U_anom"        ; name of variable on U-anomaly file
  diry   = "./"
  fily   = "uwnd.day.850.anomalies.1980-2005.nc"

  latN       =  15.
  latS       = -15.

  pltName    = "MJO"       ; output plot name
  pltType    = "ps"         ; x11, ps, eps, pdf, png
  pltDir     = "./"        ; output plot directory
;************************************************************
; OLR anomalies:
;     time indices corresponding to the desired time window
;     Read user specified period
;************************************************************

  f      = addfile(dirx+filx, "r")
  date_x = cd_calendar(f->time, -2)   ; entire file
  iStrt  = ind(date_x.eq.twStrt)      ; desired dates
  iLast  = ind(date_x.eq.twLast)
  delete(date_x)
                                      ; P(time,lat,lon)
  if (getfilevartypes(f,xName) .eq. "short") then
      X  = short2flt( f->$xName$(iStrt:iLast,{latS:latN},:))
  else
      X  = f->$xName$(iStrt:iLast,{latS:latN},:)
  end if

  if (X&lon(0) .lt. 0) then
      X = lonFlip( X )       ; force 0 to 360 to match Y
  end if

  printVarSummary( X )
  printMinMax(X, True)

  time_x = X&time                     ; clarity
  date_x = cd_calendar(time_x, -2 )   ; yyyymmdd

; ***********************************************************
; U ANOMALIES:
;     time indices corresponding to the desired time window
;     Read user specified period
;************************************************************

  f      = addfile(diry+fily, "r")
  date_y = cd_calendar(f->time, -2)     ; entire file
  iStrt  = ind(date_y.eq.twStrt)        ; desired dates
  iLast  = ind(date_y.eq.twLast)
  delete(date_y)
                                        ; U(time,lat,lon)
  if (getfilevartypes(f,yName) .eq. "short") then
      Y  = short2flt( f->$yName$(iStrt:iLast,{latS:latN},:))
  else
      Y  = f->$yName$(iStrt:iLast,{latS:latN},:)
  end if

  if (Y&lon(0) .lt. 0) then
      Y = lonFlip( Y )       ; force 0 to 360 to match X
  end if

  printVarSummary( Y )
  printMinMax(Y, True)

  time_y = Y&time                     ; clarity
  date_y = cd_calendar(time_y , -2 )  ; yyyymmdd

;************************************************
; make sure dates/sizes agree
;************************************************

  if (.not.all(date_x.eq.date_y)) then
      print("****date mismatch: exit****")
      exit
  end if
  if (.not.all(dimsizes(X).eq.dimsizes(Y))) then
      print("****size mismatch: exit****")
      print("dimsizes(X)="+dimsizes(X))
      print("dimsizes(Y)="+dimsizes(Y))
      exit
  end if

  if (.not.all(X&lon.eq.Y&lon)) then
      print("****longitude mismatch: exit****")
      exit
  end if

;*****************************************************
; Calculate the cross-spectra
;*****************************************************

  segLen = 256
  segOverLap = -50
  STC    =  mjo_cross (X, Y, segLen, segOverLap, False)

  printVarSummary(STC)
  print("===")
  do n=0,15
     print(STC@varName(n)+":  min="+min(STC(n,:,:)) \
                         +":  max="+max(STC(n,:,:)) )
  end do
  print( STC@prob+"   "+STC@prob_coh2 )

;************************************************
; plot
;************************************************
  yrStrt = twStrt/10000 
  yrLast = twLast/10000 

; default
  opt = True
  opt@txString = "Default: "+abs(latS)+"S-"+latN+"N: "+yrStrt+"-"+yrLast
  mjo_cross_plot(STC ,pltDir, pltType ,pltName, opt)

; sample of plotting just values a where coherence^2 >= 0.925
  opt@pltProb  = 0.925
  pltName      = "MJO_1"           ; output plot name         
  np  = ind(STC@prob .eq. opt@pltProb)
  opt@txString = "prob="+opt@pltProb+" ==> "+STC@prob_coh2(np)
  mjo_cross_plot(STC ,pltDir, pltType ,pltName, opt)
  delete(opt@pltProb)

; sample ... do not plot the phases
  opt@pltPhase = False        ; no phases ploted
  pltName      = "MJO_2"      ; output plot name         
  opt@txString = "No Phases Plotted"
  mjo_cross_plot(STC ,pltDir, pltType ,pltName, opt)
end
