;***************************************************************
; eemd_4.ncl    
;
; Concepts illustrated:
;   - Reading data from a NetCDF file
;   - Extracting user specified time series
;   - Specifying 'eemd' options
;***************************************************************
; Requires NCL 6.4.0 or higher
;***************************************************************

; open file and read 

  diri   = "./"
  infile = "tas_1m_187101_201012_NOAA_20CR.nc"
  f = addfile(infile,"r")

  tas = f->tas(:,0:2,10)        ; (time,lat,lon)
  printVarSummary(tas)          ; (time,3)

; set arguments

  ensemble_size    = 250
  noise_strength   = 0.2
  rng_seed         = 0
  num_imfs         = 0          ; calculate 'M'

  opt              = True
  opt@S_number     = 4
  opt@num_siftings = 50
  opt@rng_seed     = 0

  tas_eemd         = eemd(tas, num_imfs, ensemble_size, noise_strength, opt, 0)
  tas@long_name    = "IMFs"
  tas_eemd!0       = "M"           ; IMFs  
  tas_eemd!1       = "time"  
  tas_eemd!2       = "lat"
  tas_eemd&time    =  tas&time
  tas_eemd&lat     =  tas&lat

  printVarSummary(tas_eemd)  ; [M | 10] x [time | 1680] x [lat | 3]
  printMinMax(tas_eemd,0)

; arra sizes 

  dime  = dimsizes(tas_eemd)
  M     = dime(0)
  ntim  = dime(1)
  nlat  = dime(2)

; plots

  wks   = gsn_open_wks("png","eemd")

  nplt  = 4
  plot  = new( nplt, "graphic")

  res             = True
  res@gsnDraw     = False
  res@gsnFrame    = False

  res@vpWidthF    = 0.7      ; Make plots wider than 
  res@vpHeightF   = 0.2      ; they are high.

  res@xyLineThicknessF = 2.0   ; Twice as thick

; Change y axis string and color for each plot.

  nl= 0

  m = 0                                       ; index
 ;res@tiYAxisString = "M="+(m+1)              ; IMF
  res@xyLineColor   = "Purple"
  plot(0) = gsn_csm_y(wks,tas_eemd(m,:,nl),res)    ; Create the four plots.

  m = 1
 ;res@tiYAxisString = "M="+(m+1)
  res@xyLineColor   = "Brown"
  plot(1) = gsn_csm_y(wks,tas_eemd(m,:,nl),res)    ; They won't be drawn yet.

  m = 2
 ;res@tiYAxisString = "M="+(m+1)
  res@xyLineColor   = "Orange"
  plot(2) = gsn_csm_y(wks,tas_eemd(m,:,nl),res)

  m = 9
 ;res@tiYAxisString = "M="+(m+1)
  res@xyLineColor   = "ForestGreen"
  plot(3) = gsn_csm_y(wks,tas_eemd(m,:,nl),res)

  pres = True
  pres@gsnMaximize               = True
  pres@gsnPanelMainString        = "TAS: "+tas&lat(nl) ; new resource added in NCL V6.4.0
  pres@gsnPanelFigureStrings     = "IMF "+(/1,2,3,10/) ; add strings to panel
  pres@gsnPanelFigureStringsJust = "TopLeft"           ; new resource added in NCL V6.4.0

  gsn_panel(wks,plot,(/4,1/),pres)
