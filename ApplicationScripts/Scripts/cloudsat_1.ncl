;***************************************************************
; cloudsat_1.ncl
;
; Concepts illustrated:
;   - Read CLOUDSAT reflectivity from a netCDF file 
;   - Fix some non-conforming units [ie, not udunits recognized]
;   - Perform time and level averages                 
;   - Create several vertical cross-sections               
;   - Plot the data amd cross sections
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
  fili	  = "cfadDbze94_200606-200612.nc"
  varname = "cfadDbze94"
  f       = addfile (diri+fili, "r")            ; entire file

  dbze	  = f->dbze                             ; equivalent reflectivity factor
  alt40   = f->alt40                            ; hgt above sea level
  kalt    = dimsizes(alt40)
  
  time    = f->time                             ; "months since ..." [bad units]
  ntime   = dimsizes(time)

  yyyymm  = cd_calendar(time,-1)
  yyyyfrac= yyyymm_to_yyyyfrac(yyyymm,0)
  utc_date= cd_calendar(time,0)
  months  = utc_date(:,1)

  data   = f->$varname$                         ; (time, dbze, alt40, lat, lon)
  printVarSummary(data)

  data&lat@units = "degrees_north"              ; fix non-CF conforming units units
  data&lon@units = "degrees_east"

; **************************************************************
; Averages over 'dbze' and 'time'
; **************************************************************
                                          ; (time,dbze,alt40,lat,lon)=>(0,1,2,3,4)
  data1	= dim_sum_n_Wrap(data ,1)         ; (time,alt40,lat,lon)
  data2 = dim_avg_n_Wrap(data1,0)         ; (alt40,lat,lon)

  printVarSummary(data1)
  printVarSummary(data2)
  
; **************************************************************
  pltType = "png"                         ; send graphics to PNG file

  wks  = gsn_open_wks(pltType,"cloudsat")
  plot = new(4,graphic) 

  res                      = True
  res@gsnDraw              = False        ; don't draw yet
  res@gsnFrame             = False        ; don't advance frame yet
  res@lbLabelBarOn	   = False

  res@mpFillOn             = False        ; turn off map fill
  res@cnFillOn             = True         ; turn on color fill
  res@cnFillPalette        = "WhiteBlueGreenYellowRed" ; set color map
  res@cnLinesOn            = False        ; True is default
  res@cnLineLabelsOn       = False        ; True is default

  resP                     = True         ; modify the panel plot
  resP@gsnMaximize         = True         ; large format
  resP@gsnPanelLabelBar    = True         ; add common colorbar

; *************************************************************************
; lat - lon maps 
; *********************** lat - lon maps **********************************

  res@cnLevelSelectionMode = "ManualLevels"  ; set manual contour levels
  res@cnMinLevelValF    = 0.025              ; set min contour level
  res@cnMaxLevelValF    = 0.60               ; set max contour level
  res@cnLevelSpacingF   = 0.025              ; set contour spacing

  lvl = (/ 1200,  5520,  10230, 14160 /)     ; levels (m)  desired
  res@gsnLeftString     = "total cloud fraction"
  do i=0,3
     res@gsnRightString	= alt40({lvl(i)})+" "+alt40@units
     plot(i) = gsn_csm_contour_map(wks,data2({lvl(i)},:,:),res)
  end do

  resP@txString         = "Time mean: "+yyyymm(0)+"-"+yyyymm(ntime-1)+": "+data@long_name
  gsn_panel(wks,plot,(/2,2/),resP)
  
; *************************************************************************
; height - radar reflectivity
; *************************************************************************

  delete(data&alt40@long_name)               ; do not want on plot
  delete(data&alt40@standard_name)           ; do not want on plot
  delete(data&dbze@long_name)                ; do not want on plot
  delete(data&dbze@standard_name)            ; do not want on plot

  delete(res@mpFillOn)                       ; the following are not maps

  res@cnLevelSelectionMode = "ManualLevels"  ; set manual contour levels
  res@cnMinLevelValF    = 0.01               ; set min contour level
  res@cnMaxLevelValF    = 0.14               ; set max contour level
  res@cnLevelSpacingF   = 0.01               ; set contour spacing
  res@cnInfoLabelOn	= False
  
  res@tiXAxisString     = ""
  res@tiYAxisString     = alt40@standard_name + " ("+data&alt40@units+")"
  res@tmYLFormat        = "f" 
  res@tmXBFormat        = "f" 

  res@gsnLeftString     = ""                 ; no txxt at top of plots
  res@gsnRightString    = ""

  res@trXMinF           = -30.0              ; less white space
  res@trXMaxF           =  20.0

  lonpart               = (/ 0,  0, 90, 90/)
  latpart	        = (/ 0, 45, 0 , 45/)
  npart                 = dimsizes(lonpart)
  
  txt  = new( npart, "string")
  do i=0,npart-1
       txt(i) = "lat, lon = ("+latpart(i)+","+lonpart(i)+")"
  end do

  resP@gsnPanelFigureStrings = txt         ; add strings to panel
  resP@gsnPanelFigureStringsFontHeightF = 0.015       ; make small
  resP@gsnPanelFigureStringsPerimOn     = False
  resP@amJust           = "TopLeft"         

  do nt=0,0             ; ntime-1
    do i=0,npart-1
                                          ; (time,dbze,alt40,lat,lon)=>(0,1,2,3,4)
       dataReshape        = data(time|nt,alt40|:,dbze|:,lat|latpart(i),lon|lonpart(i))
       plot(i) = gsn_csm_contour(wks,dataReshape,res)
    end do              ; i

    resP@txString	= "CloudSat: height ("+data&alt40@units+") - radar reflectivity (dBze): "+yyyymm(nt)
    gsn_panel(wks,plot,(/2,2/),resP)
  end do                ; nt

; *************************************************************************
; Cross-sections: zonal, meridional, arbitrary
; *************************************************************************
  delete(res@tiXAxisString)               ; not appropriate for following plots
  delete(res@trXMinF)
  delete(res@trXMaxF)
  delete(resP@gsnPanelFigureStrings)

  res@cnLevelSelectionMode = "ManualLevels"  
  res@cnMinLevelValF       = 0.05         
  res@cnMaxLevelValF       = 0.75        
  res@cnLevelSpacingF      = 0.10       

  res@vpWidthF             = 0.95         ; default 0.6

  LATX    =   8.0                         ; 'zonal'
  LONX    = -150.0                        ; 'meridional'
                                          ; arbitrary cross-section
  NPTS    = 50                            ; user specified number of points
  dist    = gc_latlon(-20, -175.,  38., -125., NPTS, -2)
  print(dist)

  datax   = linint2_points_Wrap(data1&lon,data1&lat,data1(nt,:,:,:), False \
                               ,dist@gclon, dist@gclat, 2)
  printVarSummary(datax)
  printMinMax(datax, 0)

  resP@gsnPanelFigureStrings = (/"lonx="+LONX \
                                ,"latx="+LATX \
                                ,"(-20,-175) to (38,-125)"/) ; add strings to panel

printVarSummary(data1)

  nt      = 2                             ; arbitrary
  plot(0) = gsn_csm_contour(wks,data1(nt,:,:,{LONX}),res)  ; (alt40,lat)

  plot(1) = gsn_csm_contour(wks,data1(nt,:,{LATX},:),res)  ; (alt40,lon)


  N1 = NPTS-1                             ; convenience
  res@tmXBMode   = "Explicit"
  res@tmXBValues = (/0, 10, 20, 30, 40, N1/)
  res@tmXBLabels = (/sprintf("%5.1f", dist@gclat( 0))+"~C~"+sprintf("%5.1f", dist@gclon( 0)) \
                    ,sprintf("%5.1f", dist@gclat(10))+"~C~"+sprintf("%5.1f", dist@gclon(10)) \
                    ,sprintf("%5.1f", dist@gclat(20))+"~C~"+sprintf("%5.1f", dist@gclon(20)) \
                    ,sprintf("%5.1f", dist@gclat(30))+"~C~"+sprintf("%5.1f", dist@gclon(30)) \
                    ,sprintf("%5.1f", dist@gclat(40))+"~C~"+sprintf("%5.1f", dist@gclon(40)) \
                    ,sprintf("%5.1f", dist@gclat(N1))+"~C~"+sprintf("%5.1f", dist@gclon(N1)) /)


  plot(2) = gsn_csm_contour(wks,datax,res)

  resP@gsnPanelScalePlotIndex     = 2 ;---Scale plots based on 3rd plot
  resP@txString         = "Cross Section: "+yyyymm(nt)+": "+data1@long_name
  gsn_panel(wks,plot(0:2),(/3,1/),resP)

