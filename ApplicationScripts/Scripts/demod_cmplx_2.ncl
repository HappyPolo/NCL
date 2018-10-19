;----------------------------------------------------------------------
; demod_cmplx_2.ncl
;
; Concepts illustrated:
;   - Using 'addfiles' read sea level pressure data from a suite of netCDF files
;   - Using 'short2flt' to unpack the sea level pressure data
;   - Using coordinate subscripting to delineate the Kanton region
;   - Calculating smoothed daily mean climatology
;   - Creating a daily anomaly for the entire period of record.
;   - Creating variables for input to 'demod_cmplx'    
;   - Drawing a time series plot
;----------------------------------------------------------------------
;     Bloomfield, P. (1976)
;     Fourier Analysis of Time series: An Introduction
;     Wiley , 1976:  Chapter 6
;----------------------------------------------------------------------
; This script uses 'demod_cmplx' to explicitly extract the amplitudes
; and phase variables from the returned variable of type 'list'.
;----------------------------------------------------------------------
; The data files for this example can be found at:
;
; http://www.esrl.noaa.gov/psd/data/gridded/data.ncep.reanalysis.html
;
; Click "Daily"
; Click "Surface"
; Click "Sea-level pressure" ... "Daily" ... 'see list'
; 
; Download the files spanning 1995 to 2015
;
;   slp.1995.nc
;   slp.1996.nc
;   slp.1997.nc
;    . . .
;   slp.2014.nc
;   slp.2015.nc
;----------------------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; Location of Kanton Island  (2.8N,  188.325E)
; Pick of a local regions and average

   latS  = 0.0                ; latS = 2.8
   latN  = 5.0                ; latN = 2.8
   lonL  = 185.0              ; lonL = 188.325    
   lonR  = 190.0              ; lonR = 188.325

;---Specify day used to compute the demodulation frequency

   nday = 35.0                ; could be fractional

;---Numberof harmonics to use in smoothing climatology

   nHarm = 2

;---Open file(s); Read variable across all files

   diri = "./"
   fili = systemfunc("cd "+diri+" ; ls slp.[1-2]*nc")
   print(fili)
   print(" ")
   
   f    = addfiles(diri+fili, "r")
   X    = f[:]->slp(:,{latS:latN},{lonL:lonR})   ; (time,lat,lon)
   printVarSummary(X)
   printMinMax(X, 0)
   print(" ")

;---Transfer to a one-dimensional array

   if (latS.eq.latN .and. lonL.eq.lonR) then
       x = X(:,0,0)
   else
       x =dim_avg_n_Wrap(X, (/1,2/))             ; average all points (no area wgt)  
   end if
   delete(X)                                     ; no longer needed

   printVarSummary(x)                            ; x(time)
   printMinMax(x, 0)
   print(" ")

;---Change units to hPa; Convenience only; Better for plotting

   x       = x*0.01 
   x@units = "hPa"
   printVarSummary(x)
   printMinMax(x, 0)
   print(" ")

;---Read time and create required yyyyddd                    

   TIME    = cd_calendar(x&time, 0)
   year    = toint( TIME(:,0) )
   month   = toint( TIME(:,1) )
   day     = toint( TIME(:,2) ) 

   ddd     = day_of_year(year, month, day) 
   yyyyddd = year*1000 + ddd          ; needed for input
   yyyymmdd= year*10000 + month*100 + day

   dimx    = dimsizes(x)
   ntim    = dimx(0)                  ; ntim = dimsizes(x)

   ymdStrt = yyyymmdd(0)
   ymdLast = yyyymmdd(ntim-1)

;---Compute daily climatology (clmDayT in 6.4.0)

   xClmDay = clmDayT(x, yyyyddd)      ; daily climatology
   printVarSummary(xClmDay)           

;---Smooth daily climatology ... kinda like an 'infinite sample'

   xClmDaySmth = smthClmDayT (xClmDay, nHarm)   

;---Compute daily anomalies (calcDayAnomT in 6.4.0) using either climatology
;---Prefer using smooth

   xDayAnom  = calcDayAnomT (x, yyyyddd, xClmDaySmth)  ; anomalies from smooth clm     
   printVarSummary(xDayAnom)
   printMinMax(xDayAnom, True)

;---Specify demodumation frequency

   frqdem = nday/tofloat(ntim)  

;---Perform complex demodulation on the anomaly series

   nwt    = 183
   frqcut = 0.75*frqdem         ; (1/ntim) < frqc <= frqd
   xd     = demod_cmplx(xDayAnom, frqdem, frqcut, nwt, 0, False)
   print(xd)                    ; type list

;---Explicitly extract returned variable(s) from list variable; convenience only

   xAmp  = xd[0]                ; [0] list syntax;   xAmp(time)
   xPha  = xd[1]                ; [1]                xPha(time)
   delete(xd)                   ; no longer needed

   printVarSummary(xAmp)
   printMinMax(xAmp,0)
   print(" ")

   printVarSummary(xPha)
   printMinMax(xPha,0)
   print(" ")

;===============================================================
; PLOT
;======================================
   yyyyfrac = yyyyddd_to_yyyyfrac(yyyyddd, 0.0)    ; 6.4.0
   yrStrt   = yyyyddd(0)/1000
   yrLast   = yyyyddd(ntim-1)/1000

   plot     = new ( 4, "graphic")
   
   wks          = gsn_open_wks ("ps","demod_cmplx")
   res          = True                   ; plot mods desired
   res@gsnDraw  = False                  ; don't draw  frame yet      
   res@gsnFrame = False                  ; don't advance frame yet      

   res@vpHeightF= 0.4                    ; change aspect ratio of plot
   res@vpWidthF = 0.8                  
   res@vpXF     = 0.145                  ; move left edge
   
   res@tiMainString    = "Kanton Island:"+yrStrt+"-"+yrLast+" nday="+nday 

   x@long_name  = "SLP"
   plot(0) = gsn_csm_xy (wks,yyyyfrac,x,res)  
   delete(res@tiYAxisString)

   xDayAnom@long_name  = "Anomalies"
   plot(1) = gsn_csm_xy (wks,yyyyfrac,xDayAnom,res)        ; create plot
   delete(res@gsnYRefLine)

   xAmp@long_name  = "Amplitudes"
   plot(2) = gsn_csm_xy (wks,yyyyfrac,xAmp ,res) 
   xPha@long_name  = "Phase"
   plot(3) = gsn_csm_xy (wks,yyyyfrac,xPha,res)   

;********************************************
; create attached plots
;********************************************
 
  res1                     = True
  res2                     = True
  res2@gsnAttachPlotsXAxis = True
  amid = gsn_attach_plots(plot(0),(/plot(1),plot(2),plot(3)/),res1,res2)
  draw(plot)    
  frame(wks)

  clmDayPlt      = new ((/2,366/), typeof(xClmDay), getFillValue(xClmDay))
  clmDayPlt(0,:) = xClmDay
  clmDayPlt(1,:) = (/ xClmDaySmth /)
  res@trXMinF    = 0.0
  res@trXMaxF    = 366.0
  res@gsnCenterString = "Daily Climatology: Raw and Smoothed"
  plt = gsn_csm_xy (wks,ispan(1,366,1),clmDayPlt ,res)
