;----------------------------------------------------------------------
; fanal_4.ncl
;
; Concepts illustrated:
;   - Create separate sine waves an compine (superposition)
;   - Derive the amplitude, phase, percent variancefor each sine wave
;   - Plot the sine waves and marke the location of the phase for each harmonic.
;---------------------------------------------------------

    N     = 144
    
    pi    = 4*atan(1.0)
    tpN   = 2.0*pi/N

    A     = (/20, 10, 5/)
    phi   = (/ N/2 , N/2, N/4  /)
    
    xx    = ispan(0,N-1,1)*1.0

    y0    = A(0)*cos(tpN*(  xx - phi(0)))
    y1    = A(1)*cos(tpN*(2*xx - phi(1)))
    y2    = A(2)*cos(tpN*(3*xx - phi(2)))
    yy    = y0 + y1 + y2

    finfo = fourier_info( yy, 3, 1)
    print(finfo)

;************************************************
; plotting parameters
;************************************************
    yplt = new((/4,N/),typeof(yy))
    yplt(0,:) = y0
    yplt(1,:) = y1
    yplt(2,:) = y2
    yplt(3,:) = yy

    wks   = gsn_open_wks ("png","fanal")  ; send graphics to PNG file 

    res                   = True                       ; plot mods desired
    res@gsnDraw           = False
    res@gsnFrame          = False

    res@tiMainString      = "Fourier Info" 
    res@xyLineThicknesses = (/2,2,2,3/) 
    res@xyMonoDashPattern = True

    res@vpHeightF= 0.4                    ; change aspect ratio of plot
    res@vpWidthF = 0.8                  
    res@vpXF     = 0.1                 
  
    res@trXMinF  =  0
    res@trXMaxF  = N-1
    res@trYMinF  = -40.0
    res@trYMaxF  =  30.0

    res@gsnYRefLine   = 0.0             ; create a reference line
    res@xyLineColors  = (/"blue","red","green","black"/)

    plot  = gsn_csm_xy (wks,xx,yplt,res) 

    gsres                = True       ; poly res
    gsres@gsMarkerIndex  = 16         ; Use filled dots for markers.
    gsres@gsMarkerThicknessF = 2.0
    gsn_polymarker(wks,plot,finfo(1,:),finfo(0,:),gsres)

    draw(plot)
    frame(wks)

