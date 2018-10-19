;----------------------------------------------------------------------
; eemd_5.ncl    
;
; Concepts illustrated:
;   - Reading data from a CSV file
;----------------------------------------------------------------------
; Requires NCL 6.4.0 or higher
;----------------------------------------------------------------------
; This example mimics the one in the pyeemd tutorial:
;
; http://pyeemd.readthedocs.io/en/master/tutorial.html
;
; The tutorial provides a link to the "ecg.csv" data file.
;----------------------------------------------------------------------

begin
;---Read 1D array of data from CSV file
  x = asciiread("ecg.csv",-1,"float")
  
;---Set EEMD options
  ensemble_size  = 250
  num_imfs       = 10
  noise_strength = 0.2
  S_number       = 4
  num_siftings   = 50
  dims           = 0  ; Which dimension to operate on.
                      ; For 1D, this can only be 0.

  opt              = True  
  opt@S_number     = S_number
  opt@num_siftings = num_siftings

  xe = ceemdan(x,num_imfs,ensemble_size,noise_strength,opt,dims)

;---Start the graphics
  wks   = gsn_open_wks("x11","eemd")

;---Set plotting options to mimic matplotlib example
  res                  = True
  res@vpWidthF         = 0.7     ; Make plots wider than 
  res@vpHeightF        = 0.6      ; they are high.
  res@trXMinF          = -50
  res@trXMaxF          = 1350
  res@xyLineColor      = "SteelBlue"
  res@xyLineThicknessF = 5

  ymins = (/-140,-100,-120, -110, -105, -70, -70, -12, -12, -21.0/)
  ymaxs = (/ 155, 120, 150,  120,  105,  55,  62,   7,  20,  -3/)

;---Plot original data
;  plot = gsn_csm_y(wks,x,res)

;---Plot each IMF
  nimf = dimsizes(xe(:,0))
  do nt=0,nimf-1
    res@trYMinF      = ymins(nt)
    res@trYMaxF      = ymaxs(nt)
    if(nt.lt.(nimf-1)) then
      res@tiMainString = "IMF #" + (nt+1)
    else
      res@tiMainString = "Residual"
    end if
    print(nt + " " + min(xe(nt,:)) + " / " + max(xe(nt,:)))
;    printMinMax(xe(nt,:),0)
;    plot_e = gsn_csm_y(wks,xe(nt,:),res)
  end do
end
