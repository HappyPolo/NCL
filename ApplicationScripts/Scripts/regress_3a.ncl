;*************************************************
; regress_3a.ncl
;
; Concepts illustrated:
;   - Use coordinate subscripting to extract a region
;   - Use 'cd_calendar' and 'ind' to select a time period
;   - Change values and units
;   - Use 'month_to_annual' to calculate annual means
;   - Use 'wgt_areaave' to calculate areal means
;   - Calculating the least squared regression for a one dimensional array
;     using 'reg_multlin_stats'
;   - Drawing two lines on a plot using an overlay approach
;
;*************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;************************************************
; Specify geographical region and time span (year-month start and end
;************************************************

  latS     =   0               
  latN     =  90
  lonL     =   0
  lonR     = 360

  ymStrt   = 190101     
  ymLast   = 201012
  
  pltType  = "png"
  pltName  = "regress_3a"
  pltTitle = "Northern Hemisphere (C): "+(ymStrt/100)+"-"+(ymLast/100)

;************************************************
; Read from netCDF file: variable is type short...unpack
;************************************************
  diri   = "./"
  fili   = "air.sig995.mon.mean.nc"
  f      = addfile(diri+fili,"r")

  YYYYMM = cd_calendar( f->time, -1)

  iStrt  = ind(YYYYMM.eq.ymStrt)
  iLast  = ind(YYYYMM.eq.ymLast)

  x      = short2flt( f->air(iStrt:iLast,{latS:latN},{lonL:lonR}) )
  printVarSummary(x)

  x      = x-273.15             ; illustration
  x@units= "degC"

  dimx = dimsizes(x)
  ntim = dimx(0)                ; all years and months
  nlat = dimx(1)
  mlon = dimx(2)

  yyyymm = cd_calendar(x&time, -1)
  yyyy   = yyyymm/100

;************************************************
; Areal averages: cos(lat) is good enough
;************************************************
  wgt   = cos(0.01745329*x&lat)

  xann  = month_to_annual(x , 1)                 ; [year| 110]x[lat| 46]x[lon| 180]
  xavg  = wgt_areaave_Wrap(xann , wgt, 1.0, 1)   ; [year| 110]      

  year  = ispan(yyyy(0), yyyy(ntim-1), 1)*1.0
  nyrs  = dimsizes(year)

  xavg&year  = year

;************************************************
; Perform linear regression on annual means
;************************************************

 ;rc = regline(year, xavg)                   ; degC/year
 ;rc = rc*(year-rc@xave) + rc@yave

  rc = reg_multlin_stats(xavg, year, False)  ; degC/year
  rc@long_name = "trend"
  rc@units     = "degC/year"
  print(rc)

  xrc = rc@Yest                              ; model fit

  rc = rc(1)*10                              ; (degC/year)(10_year/decade)  
  rc@units = "degC/decade"

;************************************************
; create plot: use overlay approach
;************************************************

  wks = gsn_open_wks(pltType ,pltName)             ; open a ps file

  res                    = True                    ; plot mods desired
  res@gsnDraw            = False
  res@gsnFrame           = False
  res@xyLineThicknessF   = 2.                      ; line thickness
  res@trXMinF            = min(year)-1            
  res@trXMaxF            = max(year)+1
  res@tiYAxisString      = "Annual Mean Sfc. Temp (C)"
  res@tiXAxisString      = "Year"
 
  res@tiMainString       = pltTitle
  res@gsnLeftString      = "20th Century Reanalysis"
  res@gsnRightString     = sprintf("%5.3f", rc(1))+" ("+rc@units+")"
  plot  = gsn_csm_xy (wks,year,xavg,res)   

  gsres                   = True          
  gsres@gsLineColor       = "red"  
  gsres@gsLineThicknessF  = 3.0
  dummy = gsn_add_polyline (wks,plot,year,xrc,gsres)

  draw(plot)
  frame(wks)
