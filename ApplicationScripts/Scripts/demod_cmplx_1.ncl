;----------------------------------------------------------------------
; demod_cmplx_1.ncl
;
; Concepts illustrated:
;   - Reading a simple text file (Wolf Sunspot Numbers) via 'asciiread'
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
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;----------------------------------------------------------------------

;---Specify day used to compute the demodulation frequency
   diri = "./"
   fili = "sunspot_wolf.1700_1960.txt"

   x    = asciiread(diri+fili, -1, "float")
   x@long_name = "Sunspot Number" 
   printVarSummary(x)
   printMinMax(x, 0)
   print(" ")

   ntim = dimsizes(x)           ; # of yesrs

;---Specify demodumation frequency

   yr     = 22.0                ; could be fractional
   frqdem = yr/tofloat(ntim)  

;---Perform complex demodulation on the anomaly series

   nwt    = 41                  ; same # of pts as Bloomfield BUT different filter  
   frqcut = 0.50*frqdem         ; (1/ntim) < frqc <= frqd
   xd     = demod_cmplx(x, frqdem, frqcut, nwt, 0, False)
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
   yrStrt   = 1700
   yrLast   = 1960
   yyyy     = ispan(yrStrt, yrLast, 1)

   plot     = new (3, graphic)
   
   wks          = gsn_open_wks ("png","demod_cmplx")
   res          = True                   ; plot mods desired
   res@gsnDraw  = False                  ; don't draw  frame yet      
   res@gsnFrame = False                  ; don't advance frame yet      

   res@vpHeightF= 0.4                    ; change aspect ratio of plot
   res@vpWidthF = 0.8                  
   res@vpXF     = 0.145                  ; move left edge
   
   res@tiYAxisString   = x@long_name    ; y-axis label      
   res@tiMainString    = "Wolf Sun Spot:"+yrStrt+"-"+yrLast 

   plot(0) = gsn_csm_xy (wks,yyyy,x,res)  
   delete(res@tiYAxisString)
   plot(1) = gsn_csm_xy (wks,yyyy,xAmp ,res) 
   plot(2) = gsn_csm_xy (wks,yyyy,xPha,res)   

;********************************************
; create attached plots
;********************************************

  res1                     = True
  res2                     = True
  res2@gsnAttachPlotsXAxis = True
  amid = gsn_attach_plots(plot(0),(/plot(1),plot(2)/),res1,res2)
  draw(plot)    
  frame(wks)


