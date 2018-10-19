;***********************************
; wavelet_1.ncl
;
; Concepts illustrated:
;   - Computing wavelets
;***********************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;***********************************
begin
;************************************    
; create pointer to file and read in variables
;************************************  
  f    = addfile ("NAO_b053.03_0000-0999.nc","r")
  nao  = f->NAO                     ; one value/year
  time = nao&time 
  N    = dimsizes(time)       

;************************************    
; Remove mean and linear trend (recommended, not required)
; Missing values are not allowed. 
;************************************  
  nao  = dtrend(nao,False)

;************************************
; compute wavelet (Missing values not allowed due to use of FFT)
;************************************  
  mother  = 0
  param   = 6.0
  dt      = 1.              ;for NAO (timesteps in units of years)
  s0      = 0.25
  dj      = 0.25
  jtot    = 44
  npad    = N
  nadof   = new(2,float)
  noise   = 1 
  siglvl  = .05
  isigtest= 1
  
  w = wavelet(nao,mother,dt,param,s0,dj,jtot,npad,noise,isigtest,siglvl,nadof)
;************************************
; create coodinate arrays for plot
;************************************
  power            = onedtond(w@power,(/jtot,N/))
  power!0          = "period"                        ; Y axis
  power&period     = w@period

  power!1          = "time"                          ; X axis
  power&time       = time

  power@long_name  = "Power Spectrum"
  power@units      = "unit^2"

; compute significance ( >= 1 is significant)
  SIG              = power                            ; transfer meta data
  SIG              = power/conform (power,w@signif,0)
  SIG@long_name    = "Significance"
  SIG@units        = " "
;************************************
; initial resource settings
;************************************
  wks = gsn_open_wks("png","wavelet")             ; send graphics to PNG file
  plot = new(2,graphic)                           ; create graphical array

  res                     = True                  ; plot mods desired 
  res@gsnFrame            = False                 ; don't advance frame yet
  res@gsnDraw             = False                 ; don't draw yet

  res@cnFillOn            = True                  ; turn on color
  res@cnFillPalette       = "BlAqGrYeOrReVi200"   ; set color map
  res@cnFillMode          = "RasterFill"          ; turn on raster mode
  res@cnRasterSmoothingOn = True                  ; turn on raster smoothing
  res@cnLinesOn           = False                 ; turn off contour lines
  res@lbOrientation       = "Vertical"            ; vertical label bar

  res@trYReverse          = True                  ; reverse y-axis
  res@tmLabelAutoStride   = True

  res@vpHeightF           = .4                    ; height and width of plot
  res@vpWidthF            = .85


  res@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
  res@cnMinLevelValF       = 0.0                  ; set min contour level
  res@cnMaxLevelValF       = 20.0                 ; set max contour level
  res@cnLevelSpacingF      = 2.0                  ; set contour spacing

; power
  res@gsnLeftString       = "Wavelet Power"
  plot(0) = gsn_csm_contour(wks,power({0:64},499:N-1),res)  

; significance
  res@cnMinLevelValF      = 1.0                ; set min contour level
  res@cnMaxLevelValF      = 4.0                ; set max contour level
  res@cnLevelSpacingF     = 3.0                ; set contour spacing
  res@gsnLeftString       = "Wavelet Significance"
  plot(1) = gsn_csm_contour(wks,SIG({0:64},499:N-1),res) 
;****************************
; create panel plot
;****************************
  resP                              = True
  resP@txString                     = "NAO: case b053.03" 
  resP@gsnPanelYWhiteSpacePercent   = 2
  gsn_panel(wks,plot,(/2,1/),resP)
end
