;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; "The 1996-97 winter season is the golden standard for MJO. 
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl"    

begin
                           ; time window 
  twStrt = 19900101        
  twLast = 19991231

  diri   = "/Users/shea/Data/AMWG/"

 ;vName  = "U_anom"        ; name of variable on the file
 ;fili   = "uwnd.day.850.anomalies.1980-2005.nc"

  vName  = "OLR_anom"      ; name of variable on the file
  fili   = "olr.day.anomalies.1980-2005.nc"
  f      = addfile(diri+fili, "r")  

  nameRegion = (/ "IO" , "WP" /)
  latS       = (/ -10. , -20.  /)       
  latN       = (/   5. ,  -5.  /)
  lonL       = (/  75. , 160.  /)
  lonR       = (/ 100. , 185.  /)

  nRegion = dimsizes(nameRegion)
  nBounds = dimsizes(latS)

  if (nRegion.ne.nBounds) then
      print("mjo_spectra: nRegion and nBounds do not match")
      print("             nRegion="+nRegion )
      print("             nBounds="+nBounds )
      exit
  end if

  pltDir  = "./"                     ; plot directory
  pltType = "x11"                    ; x11, ps, eps, pdf, png     
  pltName = "mjo_spectra"

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

  lat   = f->lat
  wgty  = cos(0.01745329*lat)       ; MJO CLivar specify cos(lat)
  copy_VarCoords(lat, wgty)

;************************************************************
; driver to calculate and plot the spectra
;************************************************************

  optMJO= True
;;optMJO@spcConLim = (/ 0.10, 0.90/)
  mjo_spectra (X, date, wgty, latS, latN, lonL, lonR, nameRegion \
              ,pltDir, pltType, pltName, optMJO)

end
