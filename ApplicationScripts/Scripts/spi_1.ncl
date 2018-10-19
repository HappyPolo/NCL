;----------------------------------------------------------------------
; spi_1.ncl
;
; Concepts illustrated:
;   - Computing the Standardized Precipitation Index (SPI)
;   - Drawing a time series plot
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

   diri   = "./"
   fili   = "Boulder.precip.1894-2010.nc"
   f      = addfile(diri+fili, "r")

   yyyymm = f->time

   ntim   = dimsizes(yyyymm)
   if ((ntim%12).ne.0) then
        print("ntim must be divisible by 12")
        exit
   end if
   print(ntim)

   prc    = f->PRECIP
   prc@_FillValue = -999.0      ; change from the default
   pmsg   = prc@_FillValue      ; convenience

   printVarSummary(prc)
   printMinMax(prc,0)

   runlen = (/ 3, 6, 12, 24, 36, 48 /)
   nrun   = dimsizes(runlen)

   opt    = False
  ;opt@spi_type = 3             ; 6.3.0 onward; only if opt=True

   spi = new( (/nrun,ntim/), typeof(prc), pmsg)
   do nr=0,nrun-1
      spi(nr,:) = dim_spi_n(prc, runlen(nr), opt, 0)
   end do

   print(prc&time+sprintf("%8.2f", prc)   \
                 +sprintf("%8.2f", spi(0,:))+sprintf("%8.2f", spi(1,:)) \
                 +sprintf("%8.2f", spi(2,:))+sprintf("%8.2f", spi(3,:)) \
                 +sprintf("%8.2f", spi(4,:))+sprintf("%8.2f", spi(5,:)) )

;*********************************
; plot parameters
;*********************************
  
  year    = yyyymm/100
  yrStrt  = year(0)
  yrLast  = year(ntim-1)
  nyear   = yrLast-yrStrt+1
  yyyymm  = yyyymm_time(yrStrt, yrLast, "integer") 
  yrfrac  = (/ yyyymm_to_yyyyfrac(yyyymm, 0.0) /)

  wks          = gsn_open_wks ("png","spi")  ; send graphics to PNG file
  res          = True                   ; plot mods desired
  res@gsnDraw  = False
  res@gsnFrame = False
  res@vpHeightF= 0.4                    ; change aspect ratio of plot
  res@vpWidthF = 0.8                  
  res@vpXF     = 0.1                    ; start plot at x ndc coord 
  
  res@trYMinF  = -3.0                   ; min value on y-axis
  res@trYMaxF  =  3.0                   ; max value on y-axis
  res@gsnYRefLine       = 0.0           ; create a reference line   
  res@xyMonoDashPattern = True
  res@xyLineThicknessF  = 1  
  
  plt = new ( nrun, "graphic")
  xyLineColors      = (/"black","red","blue", "green","brown","magenta"/)          ; change line color
  do n=0,nrun-1 
     res@xyLineColors = xyLineColors(n)
     res@gsnCenterString = "run="+runlen(n) 
     plt(n) = gsn_csm_xy (wks,yrfrac,spi(n,:),res)  
  end do

  resP            = True                         ; modify the panel plot
  resP@txString   = "SPI:  Boulder: 1894-2010" ; title
  resP@gsnMaximize = True
  gsn_panel(wks,plt,(/3,2/),resP)               ; now draw as one plot

