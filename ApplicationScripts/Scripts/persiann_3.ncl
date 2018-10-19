;***************************************************************
; persiann_3.ncl
;
; Concepts illustrated:
;   - Reading PERSIANN 0.25 data
;   - Reading big endian binary files
;   - Reading records written by a fortran direct access write
;   - Adding meta data (attributes and coordinates [time, lat, lon])
;   - Interpolating to two different grids: 1x1 and CAM (96,144)
;   - Counting missing values
;   - Calculating areal averages
;   - Explicitly setting contour levels
;   - Creating packed netCDF files
;***************************************************************
;
; ftp://hydis8.eng.uci.edu/pub/PERSIANN/tar_6hr/readme.html
; The data files for each 6hr period have been tarred together for each month and named:
;   YYYY_MM_PERS6hr.tar
;   where YYYY is the 4-digit year and MM is the 2-digit month.
;
;   Each tar file contains 4 data files for each day
;   raw6hrYYDDDHH.bin.gz
;   where YY is the 2-digit year, DDD is the 3-digit DOY (julian day), 
;   and HH is the 2-digit hour (GMT) of the beginning of the 6hr period. 
;   HH is 00, 06, 12, or 18
;
;   ftp://hydis8.eng.uci.edu/pub/PERSIANN/tar_6hr
;
;   The data files have been gzipped.
;
;   The data is a single global grid
;   400 rows x 1440 col
;   covering
;   50N to 50S latitude
;   & 0 to 360 longitude
;   at
;   0.25 x 0.25 deg resolution
;   Units are
;   mm/6hr
;   with NODATA values set negative ( < 0)
;
;   The data order in files start up at the NorthWest corner center of pixel would be at: 
;   49.875N & 0.125
;   and continue east to the next pixel center at: 
;   49.875N & 0.375
;   until the end of that row (the NorthEast corner) at pixel center: 
;   49.875N & 359.875
;   with the last value in the file (in the SouthEast corner) at: 
;   49.875S & 359.875
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
   diri   = "./DATA/"                        ; specify input directory
   fili   = "raw6hr0324400.bin"              ; binary uncompressed
                                             ; OUTPUT
   netCDF = True                             ; generate netCDF file
   PLOT   = True                             ; generate plots

   if (netCDF) then
       ncDir   = "./"                        ; directory for netCDF output
       ncFil   = "raw6hr0324400.nc"          ; netCDF name output
       ncPack  = True                        ; True=>create "short"; False=>float
   end if

   if (PLOT) then
       pltDir  = "./"                        ; directory for plot output
       pltName = "persiann"                  ; plot name root
       pltType = "png"                       ; send graphics to PNG file
   end if

;***************************************************************
; End User Input
;***************************************************************
; Miscellaneous: Parse the file name to extract strings/ date info
;***************************************************************
   filc        = tochar( fili ) 
   yy_str      = tostring(filc(6: 7))     ; "yy" 
   ddd_str     = tostring(filc(8:10))     ; "ddd" 
   hh_str      = tostring(filc(11:12))    ; "hh" 
   yyyy        = toint( yy_str ) + 2000 ; full year
   ddd         = toint( ddd_str)        ; day  of year
   hh          = toint( hh_str)         ; hour of day

   monday      = monthday(yyyy,ddd)
   mm          = monday/100                   ; month
   dd          = monday - (mm*100)            ; day


;***************************************************************
; Read (big endian) binary file
;***************************************************************
   setfileoption("bin","ReadByteOrder","BigEndian")

   nlat  = 400                           
   mlon  = 1440
   prc   = fbindirread(diri+fili,0, (/nlat,mlon/),"float")
   
;***************************************************************
; Add meta data
;***************************************************************
   prc@_FillValue  = -9999.
   prc@units       = "mm/6hr"
   prc@long_name   = "PERSIANN precip"

;***************************************************************
; Negative values indicate missing (_FillValue)
;***************************************************************
   prc   = where(prc.lt.0, prc@_FillValue, prc)

;***************************************************************
; Create/Add coordinate variables. See above.   
;***************************************************************
   lat       =  49.875 - ispan(0,nlat-1,1)*0.25  
   lon       =   0.125 + ispan(0,mlon-1,1)*0.25 
                                        ;latitude
   lat!0     = "lat"
   lat&lat   =  lat
   lat@units = "degrees_north"
   lat@long_name = "latitude"
                                        ;longitude
   lon!0     = "lon"
   lon&lon   =  lon
   lon@units = "degrees_east"
   lon@long_name = "longitude"

;***************************************************************
; Associate the spatial coordinates with variables
;***************************************************************

   prc!0    = "lat"                   ; 1st ... name the dimensions
   prc!1    = "lon"
   prc&lat  =  lat                    ; create coordinate variable
   prc&lon  =  lon                    ; create coordinate variable

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

   prcAvg   = wgt_areaave( prc, clat, 1.0, 0)

   print(" ")
   print("Number missing: nMsg_prc="+nMsg_prc)
   print(" ")
   print("Original 0.25 grid: prcAvg="+prcAvg)
   print(" ")

;***************************************************************
; Interpolate to different grids
; PERSIANN is N->S; "area_hi2lores" requires S->N
; Use NCL syntax to reorder the 'prc'. 
; For clarity create a temporary variable to contain the reordered array.
;***************************************************************
   work = prc(::-1,:)            ; work is S=>N

;***************************************************************
; Interpolate to a 1x1 grid [meta info is *only* needed for netCDF]
;***************************************************************
   lat1       = ispan(58, -58, 1)*1.0
   lat1!0     = "lat1"
   lat1@units = "degrees_north"
   lat1@long_name = "latitude"
   lat1&lat1  = lat1

   lon1       = ispan( 0 , 359, 1)*1.0
   lon1!0     = "lon1"
   lon1@units = "degrees_east"
   lon1@long_name = "longitude"
   lon1&lon1  = lon1

   opt        = True
  ;opt@critpc = 50                 ; default is 100%
   prc_1x1    = area_hi2lores_Wrap (work&lon,work&lat, work , True, clat,  lon1, lat1, opt  )
   prc_1x1@long_name = prc@long_name + " 1x1"

   clat_1x1   = cos(lat1*rad)      ; simple cosine weighting
   prcAvg_1x1 = wgt_areaave( prc_1x1, clat_1x1, 1.0, 0)

;***************************************************************
; Interpolate to a CAM (96,144) grid [meta info is only needed for netCDF]
; All grids poleward of 57.875 will be _FillValue
;***************************************************************
   latCAM        = fspan(-90,  90, 96)
   latCAM!0      = "latCAM"
   latCAM@units  = "degrees_north"
   latCAM@long_name  = "degrees_north"
   latCAM&latCAM = latCAM

   lonCAM        = fspan( 0 , 357.5, 144)
   lonCAM!0      = "lonCAM"
   lonCAM@units  = "degrees_east"
   lonCAM@long_name  = "longitude"
   lonCAM&lonCAM = lonCAM

   prc_CAM    = area_hi2lores_Wrap (work&lon, work&lat, work, True, clat, lonCAM, latCAM, opt  )
   prc_CAM@long_name = prc@long_name + " CAM (1.9x2.5)"
   clat_CAM   = cos(latCAM*rad)      ; simple cosine weighting
   prcAvg_CAM = wgt_areaave( prc_CAM, clat_CAM, 1.0, 0)

   delete(work)

;************************************************
; Create plot ?
; Mimic the plot style used by PERSIANN URL
;************************************************
   if (PLOT) then
       plot    = new ( 3, "graphic")
   
      ;pltName = pltName +"_"+ yy_str + ddd_str + hh_str  ; make unique
       pltName = "persiann"
  
       wks     = gsn_open_wks(pltType, pltDir+pltName)
       colors  = (/"black", "Gray80","Sienna","Blue", "SkyBlue1","PaleTurquoise" \
                ,"SeaGreen3" ,"Yellow", "Red","HotPink"/) 
   
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
       res@cnLevels             = (/0,1,3,6,15,25,45,50,70/) ; "mm/6hr" 
       res@cnMissingValFillPattern = 0
       res@cnMissingValFillColor   = "black"
   
       res@lbLabelBarOn         = False    ; turn off individual cb's
   
       res@mpMinLatF            = -50.     ; CMORPH limits [approx]
       res@mpMaxLatF            =  50.
       res@mpCenterLonF         = 210.
       res@mpFillOn             = False
       res@mpOutlineOn          = True
       res@mpOutlineBoundarySets  = "National"   ; turn on country boundaries
       res@mpGeophysicalLineColor = "white"      ; color of cont. outlines
       res@mpGeophysicalLineThicknessF = 1.5     ; thickness of outlines
       res@mpNationalLineColor  = "white"

      ;res@mpShapeMode          = "FreeAspect"
      ;res@vpWidthF             = 0.8
      ;res@vpHeightF            = 0.4
   
       res@gsnCenterString = "Areal Mean="+sprintf("%4.2f",  prcAvg)
       plot(0)    = gsn_csm_contour_map(wks,prc, res)
   
       res@gsnCenterString = "Areal Mean="+sprintf("%4.2f",  prcAvg_1x1)
       plot(1)    = gsn_csm_contour_map(wks,prc_1x1, res)
   
       res@gsnCenterString = "Areal Mean="+sprintf("%4.2f",  prcAvg_CAM )
       plot(2)    = gsn_csm_contour_map(wks,prc_CAM, res)

       resP = True
       resP@gsnMaximize         = True                ; make ps/eps/pdf large [no effect x11]
     ;;resP@gsnPaperOrientation = "Portrait"          ; force portrait
       resP@gsnPanelLabelBar    = True                ; add common colorbar
       resP@lbLabelFontHeightF  = 0.0150              ; change font size
       resP@txString            = "PERSIANN: "+fili+": "+mm+"/"+dd+"/"+yyyy+" ("+hh_str+"Z)"
       gsn_panel(wks,plot,(/3,1/),resP)               ; now draw as one plot

   end if    ; PLOT
  
;************************************************
; Create netCDF ?
; Recommend to always create a 'time' dimension 
;************************************************
  
   if (netCDF) then
       ntim     = 1

       tunits   = "hours since 1990-01-01 00:00:0.0"
       time     = cd_inv_calendar(yyyy,mm,dd,hh, 0,0d0,tunits, 0)
       time!0   = "time"

       date     = yyyy*1000000 + mm*10000 + dd*100 + hh
       date!0   = "time"
       date@units = "yyyymmddhh"
       
       globeAtt              = 1
       globeAtt@title        = "PERSIANN: 0.25 6hr"    
       globeAtt@ftp          = "ftp://hydis8.eng.uci.edu/pub/PERSIANN"
       globeAtt@acronym      = "PERSIANN: Precipitation Estimation from Remotely Sensed Information using Artificial Neural Networks"
       globeAtt@description  = "http://hydis8.eng.uci.edu/persiann/"
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

           filevardef(ncdf, "PRC"  , "short" , (/ "time", "lat", "lon" /) )
           filevarattdef(ncdf, "PRC", prc_short)
        else
           filevardef    (ncdf, "PRC"  , typeof(prc) , (/ "time", "lat", "lon" /) )
           filevarattdef (ncdf, "PRC"  , prc)
       end if
     
       ncdf->time   = (/ time /)
       ncdf->lat    = (/ lat /)
       ncdf->lon    = (/ lon /)
       ncdf->date   = (/ date /)
       if (ncPack) then
           ncdf->PRC(0:0,:,:) = (/ prc_short  /)
       else
           ncdf->PRC(0:0,:,:) = (/ prc  /)
       end if

   end if    ; netCDF
  end
