;***************************************************************
; fao56_1.ncl       <=== Full Penman-Monteith [ FAO 56 ]
;
; Concepts illustrated:
;   - Setting user options at top of script. 
;     The 'albedo', 'cnum' and 'cden' are appropriate for the FAI-56 SHORT CROP estimates
;   - Reading variables from multiple CESM-CLM files (netCDF) via addfules      
;   - Resetting the 'time' variable to reflect the 'center-of-mass' of the observations.
;   - Use Penman-Monteith method to estimate reference evapotranspiration 
;     as expressed by rquation 52 in the FAO 56 paper. 
;   - Calculate arrays containing year-month, annual and climatological values
;   - Optional: Use 'stat_dispersion' to provide statistical information
;   - Optional: Create a netCDF file
;   - Optional: Plot assorted quantities: yyyymm, climatology, annual

; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/crop.ncl"

;***************************************************************
; The 'crop.ncl' library is available from 6.4.0 onward
;***************************************************************

;===========================================================================
; options
;===========================================================================
   statMaxMin = True       ; information on range of the component variables
   statDisp   = True       ; statistical distribution of derived reference ET0

   PLOT       = True
   if (PLOT) then
       typPlt = "png"      ; ps,pdf,x11,png,...
       dirPlt = "./"
       filPlt = "FAO56.Penman_Monteith"
   end if

   netCDF     = True
   if (netCDF) then
       dirNc  = "./"
       filNc  = "FAO56.Penman_Monteith"
       setfileoption("nc","Format","NetCDF4Classic")
   end if

;===========================================================================
; Open all CLM files
;===========================================================================

  ;diri = "./"
  ;diri = "/project/cas/shea/CESM/CLM/abtawfik/MONTHLY/BCL_NOTILE_SE_CAM5/"     ; CGD
  ;diri = "/Users/shea/Data/CESM/CLM/abtawfik/MONTHLY/BCL_NOTILE_SE_CAM5/"      ; MAC; Sherkin
   diri = "/glade/p/work/shea/abtawfik/MONTHLY/BCL_NOTILE_SE_CAM5/"             ; YELLOWSTONE
   fili = systemfunc("cd "+diri+" ; ls BCL_NOTILE_SE_CAM5_1.00.clm2.h0*.nc")
   nfili= dimsizes(fili)
   print("nfili="+nfili)

   f    = addfiles(diri+fili,"r") 
   case = f[0]@case_id

;===========================================================================
; Reassign the time to the center-of-mass of times ( mid-month)
;===========================================================================

   time = time_reassign(f,"time")   ; fix issue with PNNL clm4p5 time variable
   jday = getMidMonDay(time)        ; mid-month day of current year

;===========================================================================
; Read variable(s) multiple data file. Here from CLM 
;===========================================================================

   lat  = f[0]->lat                 ; (lndgrid)); same for all files
   lon  = f[0]->lon                 ;              "             "
   topo = f[0]->topo                ; m

   tmin = f[:]->TREFMNAV            ; (time, lndgrid)  ; K
   tmax = f[:]->TREFMXAV  
   rh2m = f[:]->RH2M                ; % rh
   u10  = f[:]->U10                 ; wind at 10m

   tavg = (tmin+tmax)*0.5           ; FAO 56 says to use this           
   copy_VarMeta(tmin, tavg)
   tavg@long_name = "(tmin+tmax)*0.5"
  ;printVarSummary(tavg)
  ;printMinMax(tavg, 0)

;===========================================================================
; Set FAO-56 standardized TALL CROP constants
; ASCE-ET (American Society of Civil Engineering)
;===========================================================================
   albedo = 0.23
   cnum   = 1600.0
   cden   = 0.38

;===========================================================================
; Miscellaneous
;===========================================================================

   dimt  = dimsizes(tmin)
   ntim  = dimt(0)
   npts  = dimt(1)
     
   month          = ispan(1,12,1)
   month@long_name= "current month"
   month!0        = "month"
   month&month    =  month

   monName = (/"January","February","March","April" \
            ,"May","June","July","August"         \
            ,"September","October","November","December"/)
                  ; for netCDF
   monName!0      = "month"                 ; overkill  !!!
   monName&month  =  month
   monName@long_name = "name of month"
   if (isatt(time,"calendar")) then
       monName@calendar  = time@calendar
   end if

   yyyymm    = cd_calendar(time,-1)
   yrStrt    = yyyymm(0)/100
   yrLast    = yyyymm(ntim-1)/100
   nyrs      = yrLast-yrStrt+1

   year      = ispan(yrStrt, yrLast, 1)
   year!0    = "year"
   year&year =  year
   year@long_name = "current year"
   if (isatt(time,"calendar")) then
       year@calendar  = time@calendar
   end if
   printVarSummary(year)
                                   ; unit indicators which are used below
   tunit = 1                       ; model temperature unit is K
   wunit = 0                       ; model wind unit is m/s
   punit = 1                       ; model pressure unit is Pa

   runit = 1                       ; FAO-56 common radiation unit [ MJ/(m2-day) ]
;===========================================================================
; FAO 56 computations: Penman-Monteith 
;===========================================================================
                                   ; default
   P0    = 101.3                   ; kPa
   Z0    = 0.0                     ; m

   z10   = 10.0                    ; height above sfc of wind speed
                                   
   u2    = u2_fao56(u10, conform(u10, z10, -1), (/wunit,wunit/) )  
   printVarSummary(u2)

   ea    = actvpr_rhmean_fao56(tmin, tmax, rh2m, (/tunit,punit/))  
   printVarSummary(ea)

   slp   = satvpr_slope_fao56 (tavg, (/tunit, punit/))        
   printVarSummary(slp)

   TOPO  = conform(tmin, topo, 1)
   p     = prsatm_tz_fao56(tavg, TOPO, P0, Z0, (/tunit, punit, punit/))   
   printVarSummary(p)

   g     = psychro_fao56(p, (/punit, punit/))           
   printVarSummary(g)

   G = 0.0
   if (ntim.eq.2) then
      ;G := 0.14*(tavmon(0)-tavmon(1))   
       G := 0.14*(tavg(0)-tavg(1))   
   else if (ntim.ge.3) then
            G := center_finite_diff_n (tavg,1.0,False,0,0)  
        end if 
   end if
   G@long_name = "soil flux"
   G@units     = "MJ/(m2-day)"
                                    ; saturation vapor pressure
   esTmin = satvpr_mean_fao56(tmin, tmin, (/tunit, punit/))
   esTmax = satvpr_mean_fao56(tmax, tmax, (/tunit, punit/)) 
   esAvg  = (esTmin+esTmax)*0.5           
   
   edef   = esAvg-ea                ; deficit
   edef   = where(edef.le.0, 1e-6, edef)   

   radext = radext_fao56(jday, lat, runit)         ; external rad
   sunhrx = daylight_fao56(jday, lat)              ; max               

   sunhr  = (1-albedo)*sunhrx                      ; arbitrary
   copy_VarMeta(sunhrx, sunhr)
   sunhr@long_name = "Actual sun hours; via albedo"

   radsol = radsol_fao56(radext,sunhrx,sunhr,(/runit, runit/),False) ; MJ/(m2-day)
   radsol_clr = radsol_clrsky_fao56(radext, False)                   ; MJ/(m2-day)

   netlw = netlw_fao56(tmin, tmax, ea, radext, radsol \
                      ,(/tunit,punit,runit,runit/), False)           ; MJ/(m2-day) 
   netsw = netsw_fao56(radsol, albedo)                               ; MJ/(m2-day)
   netrad= netrad_fao56(netsw, netlw)              ; 

; Penman-Monteith

   refevt = refevt_penman_fao56(tavg, netrad, G, g, u2, edef, slp, albedo, cnum, cden, 0) 

   if (statDisp) then     ; gross look at yyyymm statistical distribution
       printVarSummary(refevt)
       print("")

       opt = True                                 ; [1]
       opt@PrintStat    = True
       penman_stats     = stat_dispersion(refevt   , opt )
       print("--------------------")
   end if

   if (statMaxMin) then   ; Crude statistical overview of component terms
       printMinMax(slp,0)
       printMinMax(  p,0)
       printMinMax(  g,0)
       printMinMax(G,0)
       printMinMax(esTmin,0)
       printMinMax(esTmax,0)
       printMinMax(esAvg ,0)
       printMinMax(  u2,0)
       printMinMax(  ea,0)
       printMinMax(edef,0)
       printMinMax(radext,0)
       printMinMax(sunhrx,0)
       printMinMax(radsol,0)
       printMinMax(radsol_clr,0)
       printMinMax(refevt,0)
       print("--------------------")
   end if

;===========================================================================
; Climatologies
;===========================================================================
; Monthly Climatologies
;===========================================================================

   refevt_clm    = new ( (/12,npts/), typeof(refevt   ), refevt@_FillValue)
   do nmo=0,11
       refevt_clm(nmo,:)    = dim_avg_n(refevt   (nmo::12,:), 0)
   end do

   refevt_clm@long_name = "P-M climatology: "
   refevt_clm!1 = refevt!1  
   refevt_clm!0 = "month"
   refevt_clm&month = month
  ;printVarSummary(refevt_clm)
  ;printMinMax(refevt_clm,0)
  ;print("--------------------")

;===========================================================================
; Wgted annual avg:   [  (nnn/12)*365 ==> fractional part of year ]
;===========================================================================

   refevt_annavg = new ( (/nyrs,npts/), typeof(refevt), refevt@_FillValue)
   nyr = -1
   do nt=0,ntim-1,12
      nyr = nyr+1
      refevt_annavg(nyr,:) = dim_avg_n(refevt(nt:nt+11,:), 0)  ; sum of mm/day  [:]
      nnn = dim_num_n(.not.ismissing(refevt(nt:nt+11,:)), 0)    ; # of non-msg months [:]
      refevt_annavg(nyr,:) = refevt_annavg(nyr,:)*(365*(nnn/12.0))
   end do
   refevt_annavg@long_name = "Annual Penman-Monteith: ETo FAO56"
   refevt_annavg@units     = "mm/year [approx]"
   refevt_annavg!0         = "year"
   refevt_annavg&year      =  year
   refevt_annavg!1         = refevt!1

   if (statDisp) then
       printVarSummary(refevt_annavg)
       opt_annavg = True                                 ; [1]
       opt_annavg@PrintStat = True
       penman_ann_stats      = stat_dispersion(refevt_annavg   , opt_annavg)
       print("--------------------")
   end if

   if (PLOT) then
;===========================================================================
; Graphics
;===========================================================================
; General Graphical resources
;===========================================================================

      plot   = new( 4, "graphic")

      filPlt = filNc+"."+yrStrt+"-"+yrLast+"."+case+".tall_crop"
      pthPlt = dirPlt+filPlt

      print("filPlt="+filPlt)
      print("pthPlt="+pthPlt)
      print("typPlt="+typPlt)

      wks    = gsn_open_wks(typPlt, pthPlt)
      gsn_define_colormap(wks,"amwg256")

      res                     = True
      res@gsnDraw             = False
      res@gsnFrame            = False
      res@gsnAddCyclic        = False

      res@sfXArray            = lon
      res@sfYArray            = lat
      res@trGridType          = "TriangularMesh"

      res@cnFillOn            = True
      res@cnLinesOn           =  False            ; Turn off contour lines
      res@cnLineLabelsOn      =  False            ; Turn off contour lines

      res@cnFillMode          = "RasterFill"
     ;res@cnRasterSmoothingOn = True

      res@cnLevelSelectionMode= "ManualLevels"    ; set manual contour levels
      res@cnMinLevelValF      =  1.5              ; set min contour level
      res@cnMaxLevelValF      =  9.5              ; set max contour level
      res@cnLevelSpacingF     =  0.25             ; set contour spacing

      res@lbLabelBarOn        = False             ; turn off individual lb's

      res@mpFillOn            = True
      res@mpOceanFillColor    = "white"
      res@mpLandFillColor     = "transparent"
      res@mpFillDrawOrder     = "postdraw"

      resP                    = True              ; panel resoources
      resP@gsnMaximize        = True
      resP@gsnPanelLabelBar   = True              ; add common colorbar
     ;resP@pmLabelBarHeightF  = 0.1               ; wider than default
     ;resP@pmLabelBarWidthF   = 0.7               ; smaller than default

;===========================================================================
; YYYYMM: Penman-Monteith
;===========================================================================

      np = -1
      do nt=0,7,6     ; 0,ntim-1,6
         np = np+1
         res@gsnLeftString     = monName(nt%12)+" "+(yyyymm(nt)/100)
         res@gsnCenterString   = case
         plot(np) = gsn_csm_contour_map(wks,refevt(nt,:),res)
      end do
      resP@txString            = "Penman-Monteith: Tall Crop ET0: yyyymm"
      gsn_panel(wks,plot(0:1),(/2,1/),resP)

;===========================================================================
; Plot Monthly climatology
;===========================================================================
     
      np = -1
      do nmo=0,11,3
         np = np+1
         res@gsnLeftString   := monName(nmo) 
         res@gsnCenterString  = case
         plot(np) = gsn_csm_contour_map(wks,refevt(nmo,:),res)
      end do
      resP@txString           = "Penman-Monteith (Tall Crop ET0): Climatology: "+yrStrt+"-"+yrLast
      gsn_panel(wks,plot,(/2,2/),resP)

;===========================================================================
; Plot Annual Totals (mm/yesr)
;===========================================================================

      res@cnMinLevelValF      =  500.             ; set min contour level
      res@cnMaxLevelValF      =  2400.            ; set max contour level
      res@cnLevelSpacingF     =  50.              ; set contour spacing

      np = -1
      do nyr=0,nyrs-1,5
         np = np+1
         res@gsnLeftString   := yrStrt+nyr 
         res@gsnCenterString  = case
         plot(np) = gsn_csm_contour_map(wks,refevt_annavg(nyr,:),res)
      end do
      resP@txString           = "Penman-Monteith (Tall Crop ET0): Annual Total: mm/year"
      gsn_panel(wks,plot,(/2,2/),resP)
   end if

   if (netCDF) then
;===========================================================================
; netCDF
;===========================================================================
       filNc  = filNc+"."+yrStrt+"-"+yrLast+"."+case+".TallCrop.nc"
       pthNc  = dirNc+filNc
       system("/bin/rm -f "+pthNc)       ; remove any pre-existing file
       ncdf = addfile(pthNc ,"c")        ; open output netCDF file

      ;===================================================================
      ; create global attributes of the file (optional)
      ;===================================================================
       fAtt               = True            ; assign file attributes
       fAtt@title         = "FAO 56: Penman-Monteith Reference Tall Crop Evapotranspiration: "+yrStrt+"-"+yrLast+": "+case
       fAtt@case          = case
  
       if (isscalar(albedo)) then
           fAtt@albedo    = albedo
       end if
       if (isscalar(cnum)) then
           fAtt@cnum      = cnum
       end if
       if (isscalar(cden)) then
           fAtt@cden      = cden
       end if

       fAtt@Conventions   = "None"
       fAtt@creation_date = systemfunc ("date")
       fileattdef( ncdf, fAtt )            ; copy file attributes

       filedimdef(ncdf,"time",-1,True)     ; make time an UNLIMITED dimension
       ncdf->lat         = lat       
       ncdf->lon         = lon       
       ncdf->REFEVT      = refevt
       ncdf->REFEVT_CLM  = refevt_clm
       ncdf->REFEVT_ANN  = refevt_annavg
   end if
