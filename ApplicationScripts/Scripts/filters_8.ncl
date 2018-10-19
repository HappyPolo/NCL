; ===============================================
; filter_8.ncl
; ===============================================
;
; (a) Specify low-pass (ihp=0) or band-pass (ihp=2)
; (b) Specify a stop  frequency (fca) for a low pass filter
;     Specify start/stop frequencies (fca/fcb) for a band pass filter
; (c) Specify one or more numbers of weights.
;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 


begin
  pltDir         = "./"
  pltType        = "png"            ; "x11", "png", "ps", "ncgm", "eps"
  pltName        = "filters"

  printWgts      = False
  printResponse  = False

  createFileIeee = False
  createFileAscii= False

  srate = 1.0
                          ; choose one option; comment out the other
  ;ihp   = 0               ; low pass
  ihp   = 2               ; band pass          

                          ; number of weights must be odd
  if (ihp.eq.0) then
      nwgt  = (/ 5, 11, 31, 51, 101, 201 /) 
      bStrt = 5. 
      fca   = 1./(srate*bStrt)
      bLast = -999.       ; not used
      fcb   = -999.   
;      pltName = pltName + ".LowPass."+bStrt
  end if

  if (ihp.eq.2) then
      nwgt  = (/ 91, 181, 365, 731, 1461 /)   ; narrow bandwidth
      bStrt =  30.
      bLast =  60.
      fca   = 1./(srate*bLast)
      fcb   = 1./(srate*bStrt)   
;      pltName = pltName + ".BandPass."+bStrt+"-"+bLast
  end if

  sigma  = (/ 1.00/)      ; , 1.50, 2.00/)           ; 1.0 is normal
  
  fStop = 0.5             ; set to 0.5 except when plot subset wanted
  if (ihp.eq.2) then
      fStop = min( (/2*fcb, 0.5/) )        
  end if
;;fStop = 0.30            ; set to 0.5 except when plot subset wanted

; -------------- END USER INPUT----------------------------

  Nsig = dimsizes(sigma)

  Nwgt = dimsizes(nwgt)           ; # of wgts to test
  Nr   = 2*max(nwgt)+3            ; max # response pts
  if (ihp.eq.2) then
      Nmax = max((/6,Nr/))        ; max # of pts
  else
      Nmax = Nr
  end if
  
  nCurve = Nwgt+1                ; # of curves
  X      = new ( (/nCurve, Nmax/), float) ; curves to hold data
  Y      = new ( (/nCurve, Nmax/), float) 
  X!0 = "curve"
  Y!0 = "curve"
  X!1 = "freq"
  Y!1 = "response"
  
 do ns=0,Nsig-1
  do n=0,Nwgt-1
     wgt  = filwgts_lancos (nwgt(n), ihp, fca, fcb, sigma(ns) )  
     if (printResponse) then
         print (wgt@freq+"   "+wgt@resp)
     end if
     
     nPts = 2*nwgt(n)+3
     X(n+1,0:nPts-1) = wgt@freq
     Y(n+1,0:nPts-1) = wgt@resp
     if (printWgts) then
         print ("======= nwgt="+nwgt(n)+" =======")  
         print ("        wgt="+wgt)  
     end if
     if (createFileIeee) then
         fil6 = "wgtsIeee."+nwgt(n)+"_sigma"+sigma(ns) 
         system ("/bin/rm "+diro+filo)
         fbinrecwrite (diro+filo,-1,wgt)
     end if
     if (createFileAscii) then
         filo = "wgtsAscii."+nwgt(n)+"_sigma"+sigma(ns) 
         system ("/bin/rm "+diro+filo)
         asciiwrite (diro+filo,sprintf("%10.9f", wgt) )
     end if
     delete (wgt)
  end do

  if (fStop.le.0.0 .or. fStop.gt.0.5) then
      print ("Bad fStop: fStop="+fStop)
      exit
  end if
                            ; ideal
  if (ihp.eq.0)  then       ; LOW PASS
      X(0,0) = 0.0                     
      Y(0,0) = 1.0                     
      X(0,1) = fca                   
      Y(0,1) = 1.0                  
      X(0,2) = fca                   
      Y(0,2) = 0.0                  
      X(0,3) = fStop                 
      Y(0,3) = 0.0                  
      gsnTitle  = "Low Pass"
      gsnLeft   = "fca="+sprintf("%4.3f", fca)
     ;gsnRight  = "pa="+sprintf("%4.1f", 1./fca)
      gsnRight  = oneDtostring(nwgt)
  end if
  if (ihp.eq.1)  then       ; HIGH PASS 
      X(0,0) = 0.0                     
      Y(0,0) = 0.0                     
      X(0,1) = fca                   
      Y(0,1) = 0.0                  
      X(0,2) = fca                   
      Y(0,2) = 1.0                  
      X(0,3) = fStop                 
      Y(0,3) = 1.0                  
      gsnTitle  = "High Pass"
      gsnLeft   = "fca="+sprintf("%4.3f", fca)
     ;gsnRight  = "pa="+sprintf("%4.1f", 1./fca)
      gsnRight  = oneDtostring(nwgt)
  end if
  if (ihp.eq.2)  then       ; BAND-PASS 
      X(0,0) = 0.0                     
      Y(0,0) = 0.0                     
      X(0,1) = fca                   
      Y(0,1) = 0.0                  
      X(0,2) = fca                   
      Y(0,2) = 1.0                  
      X(0,3) = fcb                   
      Y(0,3) = 1.0                  
      X(0,4) = fcb                   
      Y(0,4) = 0.0                  
      X(0,5) = fStop                 
      Y(0,5) = 0.0                  
      gsnTitle  = "Band Pass: "+bStrt+"-"+bLast+" srate="+srate
      gsnLeft   = "fca="+sprintf("%6.5f", fca)+"; fcb="+sprintf("%6.5f", fcb)
     ;gsnRight  = "pa="+sprintf("%4.1f", 1./fca)+"; pb="+sprintf("%4.1f", 1./fcb)
      gsnRight  = oneDtostring(nwgt)
  end if

  X@long_name = "frequency"
  Y@long_name = "response"
  
  xx = (/0.0,fStop/)   ; Create data for a polyline for marking
  yy = (/0.0, 0.0 /)   ; the Y = 0.0 line in each graph.

  wks = gsn_open_wks (pltType, pltName)

  res = True
  res@trYMinF = -0.1
  res@trYMaxF =  1.1
  res@trXMinF =  0.0
  res@trXMaxF =  fStop
  res@tiMainString    = gsnTitle + ":  sigma ="+sprintf("%3.2f", sigma(ns) )
  res@gsnLeftString   = gsnLeft 
  res@gsnRightString  = gsnRight 

 ;res@xyLineThicknessF    = 2.                    ; choose line thickness
 ;plot  = gsn_csm_xy (wks,X,Y,res)                ; create plot

  res@gsnDraw  = False                            ; don't draw
  res@gsnFrame = False                            ; don't advance frame

 ;indStop = ind(X(0,:).ge.fStop)
 ;print ("fStop="+fStop)
 ;print (indStop)
 ;print (X(0,:))
 ;plot  = gsn_csm_xy (wks,X(0,:indStop),Y(0,:indStop),res)  ; create plot
  plot  = gsn_csm_xy (wks,X(0,:),Y(0,:),res)  ; create plot
           
  resGs = True
  resGs@gsLineThicknessF = 2.0

  do n=1,nCurve-1
     resGs@gsLineDashPattern = n-1                ; dash pattern
     indStop = ind(X(n,:).eq.fStop)
     if (.not.ismissing(indStop)) then
         gsn_polyline(wks,plot,X(n,:indStop),Y(n,:indStop),resGs)  
     else
         N = 2*nwgt(n-1)-1
         indStop = ind(fStop.gt.X(n,0:N-2) .and. fStop.le.X(n,1:N-1))
         iStop   = indStop(0)
         gsn_polyline(wks,plot,X(n,:iStop),Y(n,:iStop),resGs)  
     end if
     delete(indStop)
  end do

  draw(plot)                                      ; draw
  frame(wks)  
 end do    ; sigma loop
end
