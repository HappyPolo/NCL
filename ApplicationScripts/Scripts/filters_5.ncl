;********************************************
; filters_5.ncl
;********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"    
begin
;********************************************
; Series length 
;********************************************
     N   = 1000                  ; original series length [1000 days]
     N2  = N/2                   ; fourier length
     frq = fspan(0, 0.5, N2)     ; freq   [ 0.0 ... 0.5]

;********************************************
; Band Pass cut off frequencies
;********************************************
     fcb = 1./20                 ; band pass (days)
     fca = 1./100

;********************************************
; Create frequency boxcar: All coef outside band set to 0.0
;********************************************
     cf  = new ( (/2,N2/), float, "No_FillValue")
     cf  = 1.0                  ; real and imag all = 1.0
     
     iZero = ind(frq.lt.fca .or. frq.gt.fcb)
     cf(:,iZero) = 0.0          ; outside band of interest
     
     cfBox       = cf           ; save for plot
;********************************************
; Fourier synthesis using boxcar Fourier coef
;********************************************
     x = ezfftb(cf, 0.0)

; ***********************************************
; create the Lanczos filter weights: MJO CLivar 
; ***********************************************
     ihp     = 2                             ; band pass
     sigma   = 1.0                           ; Lanczos sigma
     nWgt    = 201                           ; loose 100 each end                            
     wgt     = filwgts_lanczos (nWgt, ihp, fca, fcb, sigma )

; ***********************************************
; Map the Lanczos response into Fourier space
; ***********************************************
     wcf  = linint1 (wgt@freq, wgt@resp, False, frq, 0)
                               
     cf(0,:) = cf(0,:)*wcf                ; apply mapped response coef
     cf(1,:) = cf(1,:)*wcf                ; to fft coef
       
     xmap = ezfftb(cf, 0.0)               ; fourier synthesis
     xmap@process  =  "FFT with Lanczos response mapped to FFT space"

;********************************************
; plot
;********************************************
     plot  = new ( 3, "graphic")
     wks   = gsn_open_wks( "png", "filters")  ; send graphics to PNG file
     res   = True
     res@gsnDraw     = False
     res@gsnFrame    = False
     res@trYMaxF     =  1.1
     res@trYMinF     = -0.1
     res@gsnYRefLine = 0.0
     res@xyLineThicknessF = 2
     res@vpHeightF   = 0.4             ; change aspect ratio of plot
     res@vpWidthF    = 0.7                  
     res@gsnCenterString = "Frequency Boxcar: 20-100 days"
     plot(0)  = gsn_csm_xy (wks,frq,cfBox(0,:),res)

     delete(res@trYMinF)
     delete(res@trYMaxF)

     res@gsnCenterString = "Fourier Synthesis of 20-100 day Frequency Boxcar"
     plot(1)  = gsn_csm_y (wks,x,res)

     res@gsnCenterString = xmap@process
     plot(2)  = gsn_csm_y (wks,xmap,res)

     resP                 = True    
     resP@gsnMaximize     = True
     gsn_panel(wks,plot,(/3,1/),resP) 

end
