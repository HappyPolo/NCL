;----------------------------------------------------------------------
; demod_cmplx_1b.ncl
;
; Concepts illustrated:
;   - Reading a simple text file (Wolf Sunspot Numbers) via 'asciiread'
;   - Creating variables for input to 'demod_cmplx'    
;   - Using 'demod_cmplx' and explicitly extracting the amplitudes and 
;     phase variables from the retrned variable of type 'list'
;   - Drawing a time series plot
;----------------------------------------------------------------------
;     Bloomfield, P. (1976)
;     Fourier Analysis of Time series: An Introduction
;     Wiley , 1976:  Chapter 6:   Figure 6.9
;----------------------------------------------------------------------
; Sunspot numbers are Version 1 to match those used by Bloomfield.
; Source: WDC-SILSO, Royal Observatory of Belgium, Brussels
;     http://www.sidc.be/silso/datafiles
;----------------------------------------------------------------------
;---Specify period used to compute the demodulation frequency
;   Figure 6.9 uses a period of 22 years
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
;=================================================;

   diri = "./"
   fili = "sunspot_wolf.1700_2014.yearssn.txt"  ; 1st row (line) has been removed

   nyrs = numAsciiRow(diri+fili)

   SSN  = asciiread(diri+fili, (/nyrs,2/), "float")
   SSN@long_name = "Sunspot Number: Source: WDC-SILSO, Royal Observatory of Belgium, Brussels" 
   printVarSummary(SSN)
   printMinMax(SSN(:,1), 0)
   print(" ")
                                ; for clarity & convenience, explicitly extract the values
   yyyy = SSN(:,0)      
   ssn  = SSN(:,1)  
   ssn@long_name = "Sun Spot Number (V1)"

   ntim = dimsizes(yyyy)        ; # of years

;---Specify demodulation frequency (could be fractional)

   yr     = 22.0                ; Figure 6.9 uses this
   frqdem = yr/tofloat(ntim)  

;---Perform complex demodulation on the anomaly series

   nwt    = 41                  ; same # of pts as Bloomfield BUT different filter  
   frqcut = 0.50*frqdem         ; (1/ntim) < frqc <= frqd
   ssndm  = demod_cmplx(ssn, frqdem, frqcut, nwt, 0, False)
   print(ssndm)                 ; type list

;---Explicitly extract returned variable(s) from list variable; convenience only

   ssnAmp  = ssndm[0]           ; [0] list syntax;   xAmp(time)
   ssnPha  = ssndm[1]           ; [1]                xPha(time)
   delete(ssndm)                ; no longer needed

   printVarSummary(ssnAmp)
   printMinMax(ssnAmp,0)
   print(" ")

   printVarSummary(ssnPha)
   printMinMax(ssnPha,0)
   print(" ")

;===============================================================
; PLOT
;======================================
   yrStrt   = toint(yyyy(0))
   yrLast   = toint(yyyy(ntim-1)) 

   plot     = new (3, graphic)
   
   wks          = gsn_open_wks ("png","demod_cmplx")
   res          = True                   ; plot mods desired
   res@gsnDraw  = False                  ; don't draw  frame yet      
   res@gsnFrame = False                  ; don't advance frame yet      

   res@vpHeightF= 0.4                    ; change aspect ratio of plot
   res@vpWidthF = 0.85                 
   res@vpXF     = 0.100                  ; move left edge

   res@trXMinF  = yrStrt
   res@trXMaxF  = yrLast+1
   
   res@tiYAxisString   = "SSN"           ; ssn@long_name    ; y-axis label      
   res@tiMainString    = "Wolf Sun Spot (V1):"+yrStrt+"-"+yrLast 

   plot(0) = gsn_csm_xy (wks,yyyy,ssn,res)  
   delete(res@tiYAxisString)
   plot(1) = gsn_csm_xy (wks,yyyy,ssnAmp,res) 
   plot(2) = gsn_csm_xy (wks,yyyy,ssnPha,res)   

;********************************************
; create attached plots
;********************************************

  res1                     = True
  res2                     = True
  res2@gsnAttachPlotsXAxis = True
  amid = gsn_attach_plots(plot(0),(/plot(1),plot(2)/),res1,res2)
  draw(plot)    
  frame(wks)
