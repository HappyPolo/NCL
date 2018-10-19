;***************************************************************
; heat_1.ncl    
;
; Concepts illustrated:
;   - Specifying options at the top of script
;   - Opening netCDF file 
;   - Reading user specified grid locations 
;   - Computing relative humidity via temperature and specific humidity
;   - Computing a Heat Index (HI) for each time (here, hourly values)
;   - Plotting the HI time series for each location
;   - Writing a netCDF with *two* unlimited dimensions
;***************************************************************
; Requires NCL 6.4.0 or higher
;***************************************************************

;===========================================================================
; options
;===========================================================================

   PLOT       = True
   if (PLOT) then
       typPlt = "ps"       ; ps,pdf,x11,png,...
       dirPlt = "./"       ; where plots will be written
       filPlt = "heat"
   end if

   netCDF     = True
   if (netCDF) then
       dirNc  = "./"       ; where nc file will be saved
       filNc  = "HEAT_INDEX"
      ;setfileoption("nc","Format","NetCDF4Classic")   ; only one unlimited dimension
       setfileoption("nc","Format","NetCDF4")          ; multiple unlimited dimensions
   end if
                           ; heat_index_nws option
   io = (/1,0/)            ; degK input, degC output

   ni = (/ 15137, 29772, 31557 /)
                           ; Ciudad Guyana, Venezuela 
                           ; Dahrain, Saudi Arabia
                           ; Alexandra, Louisiana
;===========================================================================
; Open CLM file
;===========================================================================

   diri = "./"
   fili = "BCLTILE_SE_CAM5_1.00.cam.h1.2004-2005.nc"   ; hourly data (10.2 GB)
   f    = addfile(diri+fili,"r") 
   if (isatt(f,"case")) then
       case = f@case
   end if

;===========================================================================
; Read variable at user specified locations only
;===========================================================================
  ;tStrt = get_cpu_time()

   lat  = f->lat(ni)             ; (lndgrid)); same for all files
   lon  = f->lon(ni)             ;              "             "
   print("===================")
   print(ni+"  "+lat+"  "+lon)
   print("===================")

   tref = f->TREFHT(:,ni)         ; K   
   qref = f->QREFHT(:,ni)         ; kg/kg
   psfc = f->PS(:,ni)             ; Pa       close to REFHT    

   printVarSummary(tref)          ; tref: [time | 17520] x [ncol | 3]
   printMinMax(tref, 0)
   printVarSummary(qref)          ;       "               
   printMinMax(qref, 0)
   printVarSummary(psfc)          ;       "
   printMinMax(psfc, 0)

;===========================================================================
; Heat Index computations: National Weather Service method
;===========================================================================

   rhref = relhum(tref, qref, psfc)       ; must be calculated
   rhref@long_name = "relative humidity"
   rhref@units     = "%"
   printMinMax(rhref,0)

   iou   = (/1,0/)                        ; input degK; output degC
   HI    = heat_index_nws(tref, rhref, io, False) 
   printVarSummary(HI)
   printMinMax(HI, 0)

   HImax = calculate_daily_values(HI, "max", 0, opt)   ; contributed.ncl
   HImax@long_name = "daily maximum Heat Index"
   if (isatt(HImax, "time")) then
       delete(HImax@time)                 ; historical artifact
   end if
   print("---")
   printVarSummary(HImax)
   printMinMax(HImax(:,0),0)
   printMinMax(HImax(:,1),0)
   printMinMax(HImax(:,2),0)

;===========================================================================
; time for netCDF and Plot
;===========================================================================

   time = HI&time                     ; ALL times ('time')
   dimt = dimsizes(time)
   ntim = dimt(0)

   ymdhms    = cd_calendar(time, 0)
   yyyy      = toint(ymdhms(:,0))
   mm        = toint(ymdhms(:,1))
   dd        = toint(ymdhms(:,2))
   hh        = toint(ymdhms(:,3))
   minit     = toint(ymdhms(:,4))
   sec       = toint(ymdhms(:,5)) 

   yrStrt    = yyyy(0)
   yrLast    = yyyy(ntim-1)
   nyrs      = yrLast-yrStrt+1
   print("yrStrt="+yrStrt+"  yrLast="+yrLast)

   yyyy!0    = "yyyy"
   yyyy&yyyy =  yyyy
   yyyy@long_name = "current year"
   if (isatt(time,"calendar")) then
       yyyy@calendar  = time@calendar
   end if

   date      = yyyy*10000 + mm*100 + dd
   date!0    = "time"
   datesec   = hh*3600 + sec
   datesec!0 = "time" 
   date@long_name    = "current date (YYYYMMDD)"
   datesec@long_name = "current seconds of current date"

; 'time' for HImax; there will be 2 different times on the file

   time_max           = HImax&time   ; for clarity and later netCDF use
   time_max@long_name = "time of day at which Heat Index max occurred"
   time_max!0         = "time_max"
   time_max&time_max  = time_max
   printVarSummary(time_max)

   HImax!0        = "time_max"       ;rename for netCDF
   HImax&time_max =  time_max
   printVarSummary(HImax)
   printVarSummary(HImax&time_max)   ; verify
    
   if (PLOT) then
;===========================================================================
; General Graphical resources
;===========================================================================
      NTIM   = dimsizes(HImax(:,0))

      plot   = new( 3, "graphic")

      filPlt = "HeatIndex."+yrStrt+"-"+yrLast+"."+case
      pthPlt = dirPlt+filPlt

      wks    = gsn_open_wks(typPlt, pthPlt)
      gsn_define_colormap(wks,"amwg256")

      res                     = True
      res@gsnDraw             = False
      res@gsnFrame            = False
      res@gsnMaximize         = True

      res@vpHeightF= 0.4                    ; change aspect ratio of plot
      res@vpWidthF = 0.8                  

      res@trYMinF  = 0.00                   ; min value on y-axis
      res@trYMaxF  = 60.0                   ; max value on y-axis

      res@trXMinF  = 0.00                   ; min value on y-axis
      res@trXMaxF  = NTIM                   ; max value on y-axis
    
     ;res@tiYAxisString    = "Heat Index"    ; y-axis label      
      res@tiXAxisString    = "days since "+yyyy(0)+"-"+sprinti("%0.2i",mm(0)) \
                                                  +"-"+sprinti("%0.2i",dd(0))
      res@tiMainString     = "NWS Heat Index"
      
      res@gsnYRefLine            = (/ 25, 35, 41, 54 /); Caution, Extreme Caution, Danger, Extreme
      res@gsnYRefLineColors      = (/ "yellow", "green", "blue", "red" /)
      res@gsnYRefLineThicknesses = (/ 1,2,3,4/)
    
     ;delete(HImax@long_name)
      
      plot(0) = gsn_csm_y (wks,HImax(:,0),res)    
      plot(1) = gsn_csm_y (wks,HImax(:,1),res)   
      plot(2) = gsn_csm_y (wks,HImax(:,2),res)  
    
      txres               =  True
      txres@txFontHeightF = 0.02
      txres@txJust        = "CenterLeft"
      txres@txFontThicknessF = 2.0      ; default=1.00
      txres@txFontHeightF    = 0.025    ; default=0.05
    
      do n=0,dimsizes(ni)-1
         label = "("+sprintf("%4.1f", lat(n))+","+sprintf("%5.2f", lon(n))+")"
         text  = gsn_add_text(wks,plot(n),label,0.15*res@trXMaxF \
                                               ,0.25*res@trYMaxF ,txres)
      end do
    
      res1                     = True
      res2                     = True
      res2@gsnAttachPlotsXAxis = True
      amid = gsn_attach_plots(plot(0),(/plot(1),plot(2)/),res1,res2)
      draw(plot)    
      frame(wks)
   end if

   if (netCDF) then

       filNc  = filNc+"."+fili
       pthNc  = dirNc+filNc
       system("/bin/rm -f "+pthNc)       ; remove any pre-existing file
       ncdf = addfile(pthNc ,"c")        ; open output netCDF file

      ;===================================================================
      ; create global attributes of the file (optional)
      ;===================================================================
       fAtt               = True            ; assign file attributes
       fAtt@title         = "Heat Index (NWS method): "+yrStrt+"-"+yrLast+": "+case
       if (isvar("case")) then
          fAtt@case       = case
       end if
  
       fAtt@Conventions   = "None"
       fAtt@creation_date = systemfunc ("date")

       fileattdef( ncdf, fAtt )            ; copy file attributes
       filedimdef(ncdf,"time",-1,True)     ; make time an UNLIMITED dimension
       filedimdef(ncdf,"time_max",-1,True) ;      time_max

       ncdf->lat     = lat       
       ncdf->lon     = lon       
       ncdf->HI      = HI                  ; ALL HI hourly values     
       ncdf->HImax   = HImax               ; Max HI for each day
   end if

