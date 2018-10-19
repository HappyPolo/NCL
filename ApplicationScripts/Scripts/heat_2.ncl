;***************************************************************
; heat_2.ncl    
;
; Concepts illustrated:
;   - Specifying options at the top of script
;   - Opening neding a netCDF file
;   - Computing relative humidity via temperature and specific humidity
;   - Computing a Heat Index (HI) for each time (here, hourly values)
;   - Computing the max daily value at each grid point
;   - Smoothing the hourly HI values to minimize 'noisey' values
;   - Plotting the max HI over the 2004-2005 period at each grid point
;   - Writing a netCDF with *two* unlimited dimensions
;***************************************************************
; Requires NCL 6.4.0 or higher
;***************************************************************
;       HEAT INDEX
;     degC    degF       Notes
;    27-32    80-91    Caution: fatigue & cramps possible with prolonged exposure and activity.
;    32-41    90-105   Extreme caution: cramps, heat exhaustion & heat stroke
;    41-54   105-130   Danger: cramps, heat exhaustion are likely; heat stroke is probable
;      54+     130+    Extreme danger: heat stroke is imminent.
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
       filNc  = "HEAT_INDEX_MAX"
      ;setfileoption("nc","Format","NetCDF4Classic")   ; only one unlimited dimension
       setfileoption("nc","Format","NetCDF4")          ; multiple unlimited dimensions
   end if
                           ; heat_index_nws option
   io = (/1,0/)            ; degK input, degC output

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
   lat  = f->lat                 ; (lndgrid); same for all files
   lon  = f->lon                 ;              "             "

   tref = f->TREFHT               ; K   
   xref = f->QREFHT               ; kg/kg    specificic humidity
   psfc = f->PS                   ; Pa       close to REFHT    

   printVarSummary(tref)          ; tref: [time | 17520] x [ncol | 3]
   printMinMax(tref, 0)
   printVarSummary(xref)          ;       "               
   printMinMax(xref, 0)
   printVarSummary(psfc)          ;       "
   printMinMax(psfc, 0)

;===========================================================================
; Heat Index computations: National Weather Service method
;===========================================================================

   xref = relhum(tref, xref, psfc)       ; must be calculated; overwrite 
   xref@long_name = "relative humidity"
   xref@units     = "%"
   printMinMax(xref,0)

   delete( psfc )                        ; no longer needed 

   iou   = (/1,0/)                       ; input degK; output degC
   HI    = heat_index_nws(tref, xref, io, False) 
   printVarSummary(HI)                   ; [time | 17520] x [ncol | 48602]
   printMinMax(HI, 0)                    ; heat index: NWS: min=-76.0405   max=234.646

   delete( [/tref, xref/] )              ; no longer needed

   wgt  = (/1.0, 3.0, 5.0, 3.0, 1.0/)    ; pass arbitrary smoother over raw hourly computations 
   wgt  = wgt/sum(wgt)                   ; normalize
   HIsmth = wgt_runave_n_Wrap(HI, wgt, 1, 0)
   HIsmth@long_name = "Smoothed (1,3,5,3,1) Heat Index"
   print("---")
   printVarSummary(HIsmth)               ; [time | 17520] x [ncol | 48602]
   printMinMax(HIsmth, 0)

   HImax = calculate_daily_values(HIsmth, "max", 0, False)   ; contributed.ncl
   HImax@long_name = "daily maximum smoothed Heat Index"
   if (isatt(HImax, "time")) then
       delete(HImax@time)                ; historical artifact
   end if
   print("---")
   printVarSummary(HImax)
   printMinMax(HImax, 0)

   maxHI = dim_max_n_Wrap(HImax, 0)
   print("---")
   printVarSummary(maxHI)
   printMinMax(maxHI, 0)

   if (PLOT) then
;===========================================================================
; General Graphical resources
;===========================================================================
      yrStrt = 2004
      yrLast = 2005
      filPlt = "HeatIndexMax."+yrStrt+"-"+yrLast+"."+case
      pthPlt = dirPlt+filPlt

      wks    = gsn_open_wks(typPlt, pthPlt)
     ;gsn_define_colormap(wks,"amwg256")
      gsn_define_colormap(wks,"precip2_17lev")

      res                     = True
      res@gsnMaximize         = True

      res@sfXArray            = lon
      res@sfYArray            = lat
      res@trGridType          = "TriangularMesh"

      res@cnFillOn            = True
      res@cnLinesOn           =  False            ; Turn off contour lines
      res@cnLineLabelsOn      =  False            ; Turn off contour lines

      res@cnFillMode          = "RasterFill"
     ;res@cnRasterSmoothingOn = True

      res@cnLevelSelectionMode= "ManualLevels"    ; set manual contour levels
      res@cnMinLevelValF      =  26.0             ; set min contour level
      res@cnMaxLevelValF      =  54.0             ; set max contour level
      res@cnLevelSpacingF     =  2.0              ; set contour spacing

      res@mpFillOn            = True
      res@mpOceanFillColor    = "white"
      res@mpLandFillColor     = "transparent"
      res@mpFillDrawOrder     = "postdraw"

     ;res@pmLabelBarHeightF   = 0.1               ; wider than default
     ;res@pmLabelBarWidthF    = 0.7               ; smaller than default

      res@tiMainString        = "Max Heat Index: CLM Years: "+yrStrt+"-"+yrLast
      plot = gsn_csm_contour_map(wks,maxHI,res)
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
       fAtt@title         = "Max Heat Index (NWS method): "+yrStrt+"-"+yrLast+": "+case
       if (isvar("case")) then
          fAtt@case       = case
       end if
  
       fAtt@Conventions   = "None"
       fAtt@creation_date = systemfunc ("date")

       fileattdef( ncdf, fAtt )            ; copy file attributes

       ncdf->lat     = lat       
       ncdf->lon     = lon       
      ;ncdf->HI      = HI                  ; ALL HI hourly values     
       ncdf->HImax   = HImax               ; Max HI for each day
       ncdf->maxHI   = maxHI               ; Max HI over current period
   end if

