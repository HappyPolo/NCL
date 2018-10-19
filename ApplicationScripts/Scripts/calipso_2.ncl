;***************************************************************
; calipso_2.ncl
;
; Concepts illustrated:
;   - Reading CALIPSO data
;   - Creating several vertical profile and cross-section plots
;
;***************************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
; ==============================================================
; Open the file:
; ==============================================================
  diri    = "./"                   		; path to file
  fili	  = "clcalipso_obs4MIPs_CALIOP_L3_CALIPSO-GOCCP-v2.1_20101201_20101231.nc"
  varname = "clcalipso"
  f       = addfile (diri+fili, "r")            ; entire file

  alt40   = f->alt40                            ; hgt above sea level
  kalt    = dimsizes(alt40)
  
  time    = f->time  
  ntime   = dimsizes(time)

  yyyymm  = cd_calendar(time,-1)
  yyyyfrac= yyyymm_to_yyyyfrac(yyyymm,0)
  utc_date= cd_calendar(time,0)

  data   = f->$varname$                         ; (time, alt40, lat, lon)
  printVarSummary(data)

; **************************************************************
  pltType = "png"                          ; send graphics to PNG file

  wks  = gsn_open_wks(pltType,"calipso")
  plot = new(4,graphic) 

  res                      = True
  res@gsnDraw              = False        ; don't draw yet
  res@gsnFrame             = False        ; don't advance frame yet

  resP                     = True         ; modify the panel plot
  resP@gsnMaximize         = True         ; large format

  nt = 0   ; only one time step in file
; *************************************************************************
; height - cloud fraction
; *************************************************************************

  data&alt40            = data&alt40/1000
  data&alt40@units      = "km"

  delete(data@long_name)                     ; do not want on plot
  delete(data@standard_name)                 ; do not want on plot
  delete(data@units)                         ; do not want on plot
  delete(data&alt40@long_name)               ; do not want on plot
  delete(data&alt40@standard_name)           ; do not want on plot

  printVarSummary(data)

  res@trXMinF           = 0.0                ; less white space
  res@trXMaxF           = 1.0  

  lonpart               = (/350,175, 90,170/)
  latpart	        = (/-10,  5, 0 ,-65/)
  npart                 = dimsizes(lonpart)
  
  txt  = new( npart, "string")
  do i=0,npart-1
       txt(i) = "lat, lon = ("+latpart(i)+","+lonpart(i)+")"
  end do

  resP@gsnPanelFigureStrings = txt         ; add strings to panel
  resP@gsnPanelFigureStringsFontHeightF = 0.015       ; make small
  resP@gsnPanelFigureStringsPerimOn     = False
  resP@amJust           = "TopLeft"         

  do i=0,npart-1                           ; (time,alt40,lat,lon)=>(0,1,2,3,4)
     plot(i) = gsn_csm_xy(wks,data(nt,:,{latpart(i)},{lonpart(i)}),data&alt40,res)
  end do              ; i

  resP@txString	= "CALIPSO: height (km) - Cloud Fraction: "+yyyymm(nt)
  gsn_panel(wks,plot,(/2,2/),resP)
; *************************************************************************
; Cross-sections: zonal, meridional, arbitrary
; *************************************************************************
  delete(res@trXMinF)
  delete(res@trXMaxF)
  delete(resP@gsnPanelFigureStrings)
  
  res@lbLabelBarOn         = False

  res@cnFillOn             = True         ; turn on color fill
  res@cnFillPalette        = "WhiteBlueGreenYellowRed"  ; set color map
  res@cnLinesOn            = False        ; True is default
  res@cnLineLabelsOn       = False        ; True is default
  res@cnInfoLabelOn        = False

  res@cnLevelSelectionMode = "ManualLevels"  
  res@cnMinLevelValF       = 0.10         
  res@cnMaxLevelValF       = 0.90        
  res@cnLevelSpacingF      = 0.10       

  res@vpWidthF             = 0.95         ; default 0.6
  res@trYMaxF              = 21.0         ; force nice max

  LATX    = -12.0                         ; 'zonal'
  LONX    =  160.0                        ; 'meridional'
                                          ; arbitrary cross-section
  NPTS    = 70                            ; user specified number of points
  dist    = gc_latlon(-30,  125.,  38., 245., NPTS, 2)
  print(dist)

  datax   = linint2_points_Wrap(data&lon,data&lat,data(nt,:,:,:), False \
                               ,dist@gclon, dist@gclat, 2)
  printVarSummary(datax)
  printMinMax(datax, 0)

  resP@gsnPanelFigureStrings = (/"lonx="+LONX \
                                ,"latx="+LATX \
                                ,"(-30,125) to (38,245)"/) ; add strings to panel

  plot(0) = gsn_csm_contour(wks,data(nt,:,:,{LONX}),res)  ; (alt40,lat)
  plot(1) = gsn_csm_contour(wks,data(nt,:,{LATX},:),res)  ; (alt40,lon)

  N1 = NPTS-1                             ; convenience
  res@tmXBMode   = "Explicit"
  res@tmXBValues = (/0, 10, 20, 30, 40, 50, 60,  N1/)
  res@tmXBLabels = (/sprintf("%5.1f", dist@gclat( 0))+"~C~"+sprintf("%5.1f", dist@gclon( 0)) \
                    ,sprintf("%5.1f", dist@gclat(10))+"~C~"+sprintf("%5.1f", dist@gclon(10)) \
                    ,sprintf("%5.1f", dist@gclat(20))+"~C~"+sprintf("%5.1f", dist@gclon(20)) \
                    ,sprintf("%5.1f", dist@gclat(30))+"~C~"+sprintf("%5.1f", dist@gclon(30)) \
                    ,sprintf("%5.1f", dist@gclat(40))+"~C~"+sprintf("%5.1f", dist@gclon(40)) \
                    ,sprintf("%5.1f", dist@gclat(50))+"~C~"+sprintf("%5.1f", dist@gclon(50)) \
                    ,sprintf("%5.1f", dist@gclat(60))+"~C~"+sprintf("%5.1f", dist@gclon(60)) \
                    ,sprintf("%5.1f", dist@gclat(N1))+"~C~"+sprintf("%5.1f", dist@gclon(N1)) /)

  plot(2) = gsn_csm_contour(wks,datax,res)

  resP@gsnPanelScalePlotIndex     = 2 ;---Scale plots based on 3rd plot
  resP@gsnPanelLabelBar    = True         ; add common colorbar
  resP@txString            = "CALIPSO: Cross Section: Cloud Fraction: "+yyyymm(nt)
  gsn_panel(wks,plot(0:2),(/3,1/),resP)

