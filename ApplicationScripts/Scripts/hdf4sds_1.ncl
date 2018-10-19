;***************************************************************
; hdf4sds_1.ncl
;
; Concepts illustrated:
;   - Reading HDF4-SDS files
;   - Attaching coordinate arrays to a variable
;   - Adding a missing value (_FillValue)
;   - Writing data to a NetCDF file using the easy but inefficient method
;   - Explicitly setting contour levels
;   - Counting missing values
;   - Calculating areal averages
;***************************************************************
; TRMM
; http://disc.sci.gsfc.nasa.gov/precipitation/documentation/TRMM_README/TRMM_3B42_readme.shtml
; http://disc.sci.gsfc.nasa.gov/data/datapool/TRMM_DP/01_Data_Products/02_Gridded/06_3-hour_Gpi_Cal_3B_42/
;
;*********** Load Libraries ************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
;**************************************************************
begin
;***************************************************************
; User Input
;***************************************************************
                                             ; INPUT
   diri   = "./"                             ; input directory
   fili   = "3B42.030901.0.6.HDF"            ; binary uncompressed
                                             ; OUTPUT
   netCDF = True                             ; generate netCDF file
   PLOT   = True                             ; generate plots

   if (netCDF) then
       ncDir   = "./"                        ; directory for netCDF output
       ncFil   = "3B42.030901.0.6.nc"        ; netCDF name output
       ncPack  = True                        ; True=>create "short"; False=>float
   end if

   if (PLOT) then
       pltDir  = "./"                        ; directory for plot output
       pltName = "hdf4sds"                   ; plot name
       pltType = "png"                       ; send graphics to PNG file
   end if

;***************************************************************
; End User Input
;***************************************************************
; Miscellaneous: Parse the file name to extract strings/ date info
;***************************************************************
   filc        = stringtochar( fili ) 
   yy_str      = chartostring(filc(5: 6))     ; "yy" 
   mon_str     = chartostring(filc(7: 8))     ; "mon" 
   dd_str      = chartostring(filc(9:10))     ; "dd" 
   tst_str     = chartostring(filc(13))       ; test for "."
   if (tst_str.eq.".") then                   ; hour of day
       hh_str  = "0"+chartostring(filc(12))   ; "00", "03", "06", "09"
   else
       hh_str  = chartostring(filc(12:13))    ; "12", ..., "21"
   end if

   yyyy        = stringtoint( yy_str ) + 2000 ; full year
   mm          = stringtoint( mon_str )       ; month
   dd          = stringtoint( dd_str )        ; day  of month
   hh          = stringtoint( hh_str )

;***************************************************************
; Read hdf 
; The "scan" dimension corresponds to "time".
; Note the HDF dimension order is (time,lon,lat)
; We want (time,lat,lon) order to match the model 
; Use NCL's dimension reordering syntax to accomplish this
;***************************************************************

   f      = addfile (diri+fili, "r")
   work   = f->precipitation                   ; (scan, longitude, latitude)
   prc    = work(scan|:,latitude|:,longitude|:)
   work   = f->relativeError       
   relerr = work(scan|:,latitude|:,longitude|:)
   delete(work)
   
;***************************************************************
; Add meta data: See above README 
;***************************************************************
   prc@_FillValue  = -9999.
   prc@units       = "mm/hr"
   prc@long_name   = "TRMM_3B42 precip"

   relerr@_FillValue = -9999.
   relerr@units      = "mm/hr"
   relerr@long_name  = "TRMM_3B42 Relative Error"

;*****************************************************
; Create TRMM coordinate variables. See README
;*****************************************************
   nlat       = 400
   mlon       = 1440
   lat        = ispan(0,nlat-1,1)*0.25 -  49.875
   lon        = ispan(0,mlon-1,1)*0.25 - 179.875

   lat@long_name = "latitude"
   lat@units  = "degrees_north"
   lat!0      = "lat"
   lat&lat    =  lat

   lon@long_name = "longitude"
   lon@units  = "degrees_east"
   lon!0      = "lon"
   lon&lon    =  lon

;***************************************************************
; Associate the spatial coordinates with variables
; Rename the dimension to match the model. 
; Convenience only, not required.
;***************************************************************
   prc!0      = "time"
   prc!1      = "lat"                   ; 1st ... name the dimensions
   prc!2      = "lon"
   prc&lat    =  lat                    ; create coordinate variable
   prc&lon    =  lon                    

   relerr!0   = "time"
   relerr!1   = "lat"            
   relerr!2   = "lon"
   relerr&lat =  lat            
   relerr&lon =  lon                    

;***************************************************************
; Simple data exploration: 
;    Are there missing data?
;    Count the number of missing values in each variable
;
;    Calculate weighted areal averages: ignore missing grid points
;    Print results
;***************************************************************

   nMsg_prc = num(ismissing(prc ))
   rad      = 4.*atan(1.0)/180.

   clat     = cos(lat*rad)    ; simple cosine weighting

   prcAvg   = wgt_areaave(    prc, clat, 1.0, 0)
   relerrAvg= wgt_areaave( relerr, clat, 1.0, 0)

   print(" ")
   print("Number missing: nMsg_prc="+nMsg_prc)
   print(" ")
   print("TRMM_3B42: prcAvg="+prcAvg+" relerrAvg="+relerrAvg)
   print(" ")
   printMinMax(prc, False)
   printMinMax(relerr, True)

;************************************************
; Create plot ?
;************************************************
   if (PLOT) then
       plot    = new ( 2, "graphic")
   
       wks    = gsn_open_wks(pltType, pltDir+pltName)
       colors = (/"Snow"    \
               ,"PaleTurquoise","PaleGreen","SeaGreen3" ,"Yellow"  \
               ,"Orange","HotPink","Red","Violet", "Purple", "Brown"/)
   
       res                      = True     ; plot mods desired
       res@gsnDraw              = False    ; let gsn_panel do plotting
       res@gsnFrame             = False
       res@gsnMaximize          = True     ; make ps/eps/pdf large
     
       res@cnFillOn             = True     ; turn on color fill
       res@cnFillPalette        = colors   ; set color map
       res@cnLinesOn            = False    ; turn of contour lines
      ;res@cnFillMode           = "CellFill"           ; Cell Mode
       res@cnFillMode           = "RasterFill"         ; Raster Mode
       res@cnLineLabelsOn       =  False       ; Turn off contour lines
       res@cnLevelSelectionMode = "ExplicitLevels"              
       res@cnMissingValFillPattern = 0
       res@cnMissingValFillColor   = "black"

       res@lbOrientation        = "vertical"   ; vertical label bar
       res@lbLabelFontHeightF   = 0.01         ; change font size
       res@pmLabelBarOrthogonalPosF = -0.01    ; move a bit to left
       res@pmLabelBarWidthF     =  0.1     
       res@mpMinLatF            = -50.         ; CMORPH limits [approx]
       res@mpMaxLatF            =  50.
       res@mpCenterLonF         = 210.
       res@mpFillOn             = False
       res@mpOutlineOn          = True
       res@mpOutlineBoundarySets  = "National"   ; turn on country boundaries

      ;res@mpShapeMode          = "FreeAspect"
      ;res@vpWidthF             = 0.8
      ;res@vpHeightF            = 0.4
   
       res@cnLevels             = (/0.1,1,2.5,5,10,15,20,25,50,75/) ; "mm/3hr" 
       res@gsnCenterString = "Areal Mean="+sprintf("%4.2f",  prcAvg)
       plot(0)    = gsn_csm_contour_map_ce(wks,prc(0,:,:), res)

       delete(res@cnLevels)
       res@cnLevels             = (/0.1,0.3,0.5,1,2,3,5,10,15,20/) ; "mm/3hr" 
       res@gsnCenterString = "Areal Mean="+sprintf("%4.2f",  relerrAvg)
       plot(1)    = gsn_csm_contour_map_ce(wks,relerr(0,:,:), res)

       resP = True
       resP@gsnMaximize         = True                ; make ps/eps/pdf large [no effect x11]
     ;;resP@gsnPaperOrientation = "Portrait"          ; force portrait
       resP@txString            = fili+": [ "+mm+"/"+dd+"/"+yyyy+" ("+hh_str+"Z) ]"
       gsn_panel(wks,plot,(/2,1/),resP)               ; now draw as one plot
   end if
  
;************************************************
; Create netCDF ?
; Recommend to always create a 'time' dimension 
;************************************************
  
   if (netCDF) then
       ntim     = 1

       tunits   = "hours since 1997-01-01 00:00:0.0"
       time     = cd_inv_calendar(yyyy,mm,dd,hh, 0,0d0,tunits, 0)
       time!0   = "time"

       date     = yyyy*1000000 + mm*10000 + dd*100 + hh
       date!0   = "time"
       date@units = "yyyymmddhh"

       nline    = inttochar(10)         ; new line character
       
       globeAtt              = 1
       globeAtt@title        = "TRMM_3B42"    
       globeAtt@ftp          = nline + \
               "http://disc.sci.gsfc.nasa.gov/data/datapool/TRMM_DP/01_Data_Products/02_Gridded/06_3-hour_Gpi_Cal_3B_42" +nline
       globeAtt@acronym      = ""
       globeAtt@description  = nline + \
"http://disc.sci.gsfc.nasa.gov/precipitation/documentation/TRMM_README/TRMM_3B42_readme.shtml" + nline
       globeAtt@info         = nline + \
               "The 3B-42 estimates are scaled to match the monthly rain gauge analyses"+nline+\
               "used in 3B-43.The output is rainfall for 0.25x0.25 degree grid boxes   "+nline+\
               "every 3 hours."+nline
       globeAtt@creation_date= systemfunc ("date" )
     
       NCFILE = ncDir + ncFil
       system ("/bin/rm -f " +  NCFILE)    ; remove any pre-exist file 
           
       ncdf   = addfile(NCFILE,"c")     
     
      ;setfileoption(ncdf, "definemode", True)
     
       fileattdef( ncdf, globeAtt )        ; create the global [file] attributes
                                         
       dimNames = (/"time", "lat", "lon" /)  
       dimSizes = (/ ntim ,  nlat,  mlon /) 
       dimUnlim = (/ True , False, False /)   
       filedimdef(ncdf, dimNames  , dimSizes,  dimUnlim )
     
       filevardef   (ncdf, "time"  , typeof(time), getvardims(time) )
       filevarattdef(ncdf, "time", time)
     
       filevardef   (ncdf, "lat", typeof(lat), getvardims(lat))
       filevarattdef(ncdf, "lat", lat)
          
       filevardef   (ncdf, "lon", typeof(lon), getvardims(lon))
       filevarattdef(ncdf, "lon", lon)
     
       filevardef   (ncdf, "date"  , typeof(date), getvardims(date) )
       filevarattdef(ncdf, "date", date)
     
       if (ncPack) then
           optPack = True
           optPack@scale_factor = 0.001       ; COARDS/CF convention attributes
           optPack@add_offset   = 0.

           prc = round(prc*1000, 0)/1000.     ; avoid truncation bias
           prc_short = pack_values(prc, "short", optPack)

           relerr = round(relerr*1000, 0)/1000.     ; avoid truncation bias
           relerr_short = pack_values(relerr, "short", optPack)

           filevardef(ncdf, "PRC"  , "short" , (/ "time", "lat", "lon" /) )
           filevarattdef(ncdf, "PRC", prc_short)

           filevardef(ncdf, "RELERR"   , "short" , (/ "time", "lat", "lon" /) )
           filevarattdef(ncdf, "RELERR", relerr_short)
        else
           filevardef    (ncdf, "PRC"  , typeof(prc) , (/ "time", "lat", "lon" /) )
           filevarattdef (ncdf, "PRC"  , prc)

           filevardef(ncdf, "RELERR"   , typeof(relerr), (/ "time", "lat", "lon" /) )
           filevarattdef(ncdf, "RELERR", relerr)
       end if
     
       ncdf->time   = (/ time /)
       ncdf->lat    = (/ lat /)
       ncdf->lon    = (/ lon /)
       ncdf->date   = (/ date /)
       if (ncPack) then
           ncdf->PRC(0:0,:,:) = (/ prc_short  /)
           ncdf->RELERR(0:0,:,:) = (/ relerr_short  /)
       else
           ncdf->PRC(0:0,:,:) = (/ prc  /)
           ncdf->RELERR(0:0,:,:) = (/ relerr  /)
       end if

   end if    ; netCDF
  end
