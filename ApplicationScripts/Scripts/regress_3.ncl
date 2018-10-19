;*************************************************
; regress_3.ncl
;
; Concepts illustrated:
;   - Use coordinate subscripting to extract a region
;   - Use 'cd_calendar' and 'ind' to select a time period
;   - Change values and units
;   - Use 'month_to_annual' to calculate annual means
;   - Use 'wgt_areaave' to calculate areal means
;   - Calculating the least squared regression for a one dimensional array
;   - Drawing two lines on a plot using an overlay approach
;
;*************************************************
; Data Source:
; http://www.esrl.noaa.gov/psd/data/gridded/data.20thC_ReanV2.monolevel.mm.html
;************************************************
; Specify geographical region and time span (year-month start and end)
;************************************************

  latS     =   0               
  latN     =  90
  lonL     =   0
  lonR     = 360

  ymStrt   = 190101     
  ymLast   = 201212

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

  if (getfilevartypes(f,"air").eq."short") then
      x = short2flt( f->air(iStrt:iLast,{latS:latN},{lonL:lonR}) )
  else
      x = f->air(iStrt:iLast,{latS:latN},{lonL:lonR})
  end if
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
  printVarSummary(year)
  printVarSummary(xavg)
  print(year+"  "+xavg)

;************************************************
; Perform linear regression on annual means
;************************************************

  rc = regline_stats(year, xavg)                ; degC/year
  rc@long_name = "trend"
  rc@units     = "degC/year"
  print(rc)

  nx   = dimsizes(xavg)
  pltarry      = new ( (/6,nx/), typeof(x))
  pltarry(0,:) = xavg                              ; use markers
  pltarry(1,:) = rc@Yest                           ; regression values
  pltarry(2,:) = rc@YMR025                         ; MR: mean response
  pltarry(3,:) = rc@YMR975
  pltarry(4,:) = rc@YPI025                         ; PI: prediction interval
  pltarry(5,:) = rc@YPI975

;************************************************
; create plot: use overlay approach
;************************************************
    wks  = gsn_open_wks("png","regress")             ; send graphics to PNG file
    
    res                     = True                   ; plot mods desired
    res@xyMarkLineModes     = (/"Lines  ","Lines" \  ; choose which have markers
                               ,"Lines"  ,"Lines" \ 
                               ,"Lines"  ,"Lines" /)
    res@xyMarkers           = 16                     ; choose type of marker 
    res@xyMarkerSizeF       = 0.0075                 ; Marker size (default 0.01)

    res@xyDashPatterns      = 0                      ; solid line 
   ;res@xyMonoDashPattern   = True
    res@xyLineThicknesses   = (/1,3,2,2,2,2/)        
    res@xyLineColors        = (/ "black", "black"\
                               , "blue" , "blue" \
                               , "red"  , "red"  /)
    res@tmYLFormat          = "f"                    ; not necessary but nicer labels 

  ;;res@trXMinF                =  min(year)
    res@trXMaxF                =  max(year)

    res@tiMainString           = "regline_stats: 20th Renalysis: 1901-2012"
    plot                       = gsn_csm_xy (wks,year,pltarry(0:1,:),res) 

;---Make legend smaller and move into plot
    res@pmLegendDisplayMode    = "Always"            ; turn on legend
    res@pmLegendSide           = "Top"               ; Change location of 
    res@pmLegendParallelPosF   = .225                ; move units right
    res@pmLegendOrthogonalPosF = -0.45               ; move units down
    res@pmLegendWidthF         = 0.15                ; Change width and
    res@pmLegendHeightF        = 0.175               ; height of legend.
    res@lgPerimOn              = True                ; turn off/on box around
    res@lgLabelFontHeightF     = .015                ; label font height
    res@xyExplicitLegendLabels = (/"data"         , "regline"       \
                                  ,"5% response"  , "95% response"  \   
                                  ,"5% prediction", "95% prediction"/)  

    plot                       = gsn_csm_xy (wks,year,pltarry,res)           ; create plot
