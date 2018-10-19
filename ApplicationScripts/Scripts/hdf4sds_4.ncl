;***************************************************************
; hdf4sds_4.ncl
;
; Concepts illustrated:
;   - Reading an HDF4-SDS file which has geographic as file attributes 
;   - Converting "short" data to "float"
;   - Generating geographic information            
;   - Interpolating to a lower resolution grid.
;   - Drawing contours over a Robinson map
;   - Writing data to a NetCDF file using the easy but inefficient method
;***************************************************************
; Source: http://oceancolor.gsfc.nasa.gov/PRODUCTS/L3_sst.html
;         Daily Mapped 4-km and 9-km files in HDF format
;
;*********** Load Libraries ************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
;**************************************************************
begin
   wcStrt = systemfunc("date")
;***************************************************************
; User Input
;***************************************************************
                                             ; INPUT
   diri   = "./"                             ; input directory
   fili   = "A2008266.L3m_DAY_SST_9.hdf"     ; binary uncompressed

   nlat  = 360                               ; target half deg grid    
   mlon  = 720 
                                             ; OUTPUT
   netCDF = True                             ; generate netCDF file
   PLOT   = True                             ; generate plots

   if (netCDF) then
       ncDir   = "./"                        ; directory for netCDF output
       sfx     = get_file_suffix(fili,0) 
       ncFil   = sfx@fBase+".HalfDeg.nc"     ; netCDF name output
       ncVarName = "SST"                     ; name of output variable  [optional]
       TITLE   = "MODIS Aqua Level 3 SST"    ; recommended but optional   
       FTP     = "ftp://oceans.gsfc.nasa.gov/MODISA/Mapped/Daily/9 "    ; optional
       INFO    = "http://oceancolor.gsfc.nasa.gov/PRODUCTS/L3_sst.html "; optional
   end if

   if (PLOT) then
       pltDir  = "./"                        ; directory for plot output
       sfx     = get_file_suffix(fili,1) 
       pltName = sfx@fBase                   ; output graphic name
       pltType = "ps"                                            
   end if

;***************************************************************
; End User Input
;***************************************************************

;***************************************************************
; Open HDF file
; NCL [5.1.1] does not allow unsigned integers. 
; Read signed (short) integers. Manually, convert to integers; then, scale.
;***************************************************************

   f      = addfile (diri+fili, "r")
   L3M    = f->l3m_data                    
   L3M@_FillValue = integertoshort( -1 )   

   l3m    = new ( dimsizes(L3M), "integer", -1)
   l3m    = L3M
   l3m    = where(l3m.lt.0, (65535+l3m)   , l3m)

   X      = (l3m*f@Slope) + f@Intercept
   X@_FillValue = 1e20
   dimX   = dimsizes( X )

   NLAT   = dimX(0)                 ; sst grid size X(NLAT,MLON)
   MLON   = dimX(1)

;***************************************************************
; Extract temporal information 
;***************************************************************
   year = 0                          ; cast as integer 
   doy  = 0
   year = f@Start_Year               ; ridiculous  .. f@Start_Year is "short"
   doy  = f@Start_Day                ; day of year .. short also
  
   mmdd     = monthday( year, doy)
   yyyymmdd = year*10000 + mmdd 

;***************************************************************
; Extract/generate geographical information associated with X
; Create meta data and associate meta data with variable [data object]
;***************************************************************
 
   latS   = f@SW_Point_Latitude
   lonW   = f@SW_Point_Longitude
   latN   = abs(latS)
   lonE   = abs(lonW)

   LAT    = latGlobeFo(NLAT, "LAT", "latitude" , "degrees_north")
   LAT    = LAT(::-1)               
   LON    = lonGlobeFo(MLON, "LON", "longitude", "degrees_east")   ; 0 to 360 (nominal)
   LON    = (/ LON - 180. /)      ; make -180 to 180 (nominal)
   LON&LON= LON                   ; update coordinates

   X!0    = "LAT"                 ; name dimensions
   X!1    = "LON"
   X&LAT  =  LAT                  ; create coordinate variables
   X&LON  =  LON

   X@long_name = f@Parameter  
   X@units     = f@Units
   X@Measure   = f@Measure

   printVarSummary(X)
   printMinMax(X, True)
 ;;print(LAT+"    "+L3M(:,0)+"    "+l3m(:,0)+"   "+X(:,0))

;***************************************************************
; Create/Add coordinate variables for OUTPUT grid. 
;***************************************************************

   lat    = latGlobeFo(nlat, "lat", "latitude" , "degrees_north")
   lon    = lonGlobeFo(mlon, "lon", "longitude", "degrees_east")   ; 0 to 360 (nominal)
   lon    = (/ lon - 180. /)  ; subtract 180 from all values 
   lon&lon= lon           ; update coordinates

;***************************************************************
; Interpolate to a 0.5x0.5 grid [meta info is *only* needed for netCDF]
; Use simple cos(LAT) weighting
;***************************************************************
   wcStrtInt  = systemfunc("date")

   opt        = True
   opt@critpc = 25                 ; default is 100%

   clat       = cos(LAT*0.01745)

   X_HALF   = area_hi2lores_Wrap (X&LON,X&LAT, X , True, clat,  lon, lat, opt)
   X_HALF@long_name  =  X@long_name + " (0.5x0.5)"

   wallClockElapseTime(wcStrtInt, "area_hi2lores" , 0)

   if (PLOT) then
;***************************************************************
; Create plot 
;***************************************************************
       wks    = gsn_open_wks(pltType, pltDir+pltName)
       gsn_define_colormap(wks, "amwg")
;
; This will not be necessary in V6.1.0 and later. Named colors can
; be used without having to first add them to the color map.
;
       i = NhlNewColor(wks,0.7,0.7,0.7)    ; add gray to colormap
   
       plot = new ( 2 , "graphic")
     
       res                      = True     ; plot mods desired
       res@gsnDraw              = False    ; don't draw
       res@gsnFrame             = False    ; don't advance frame
       res@gsnSpreadColors      = True
       res@gsnSpreadColorEnd    = -2  
     
       res@cnFillOn             = True     ; turn on color fill
       res@cnLinesOn            = False    ; turn of contour lines
       res@cnFillMode           = "RasterFill" ; Raster Mode
       res@cnLinesOn            =  False       ; Turn off contour lines
       res@cnLineLabelsOn       =  False       ; Turn off contour lines
       res@cnMissingValFillColor= "background" ; "foreground"
   
       res@lbLabelBarOn         = False        ; turn off individual cb's
     
       res@mpCenterLonF         = 0.           ; 210.
       res@mpFillOn             = True 
       res@mpLandFillColor      = "grey"              ; color of land
       res@mpFillDrawOrder      = "PostDraw"
       res@mpPerimOn            = False	     
       res@mpProjection         = "Robinson"       
       res@mpGridAndLimbOn      = True 
       res@mpGridLatSpacingF    =  30        
       res@mpGridLonSpacingF    =  30.      
       res@mpGridLineDashPattern=  11         ; 0 - solid,  1/2/11 - dash    
       res@mpGridLineThicknessF = 0.5

       plot(0) = gsn_csm_contour_map(wks,X, res)
       plot(1) = gsn_csm_contour_map(wks,X_HALF, res)

       resP = True
       resP@gsnMaximize         = True                ; make ps/eps/pdf large
     ;;resP@gsnPaperOrientation = "Portrait"          ; force portrait
       resP@gsnPanelLabelBar    = True                ; add common colorbar
       resP@lbLabelAutoStride   = True
       resP@lbLabelFontHeightF  = 0.0175              ; change font size
       resP@txString            = fili
       gsn_panel(wks,plot,(/2,1/),resP)               ; now draw as one plot
   end if    ; PLOT        
  
;************************************************
; Create netCDF ?
; Recommend to always create a 'time' dimension 
; Save only the interpolated X [sst_1x1]
;************************************************
  
   if (netCDF) then
       if (.not. isvar("ncVarName")) then
           ncVarName   = "X"
       end if
       ncVarNameInterp = ncVarName+"_INTERP"

       ntim     = 1

       yyyy     = year
       mm       = mmdd/100 
       dd       = mmdd -(mm*100)
       hh       = 12             ; center of 'mass' for the day
       mn       = 0

       tunits   = "hours since 1990-01-01 00:00:0.0"
       time     = cd_inv_calendar(yyyy,mm,dd,hh,mn,0d0,tunits, 0)
       time!0   = "time"

       date     = yyyy*1000000 + mm*10000 + dd*100 + hh
       date!0   = "time"
       date@units = "yyyymmddhh"
       
       nline  = inttochar(10)

       globeAtt              = 1
       if (isvar("TITLE")) then
           globeAtt@title    = TITLE+": "+yyyy+"-"+mm+"-"+dd    
       else
           globeAtt@title    = yyyy+"-"+mm+"-"+dd    
       end if

       if (isvar("FTP")) then
           globeAtt@ftp      = FTP
       end if
  
       if (isvar("INFO")) then
           globeAtt@information  = INFO
       end if

       globeAtt@source_file  = fili
       globeAtt@creation_date= systemfunc ("date" )
     
       NCFILE = ncDir + ncFil
       system ("/bin/rm -f " +  NCFILE)    ; remove any pre-exist file 
           
       ncdf   = addfile(NCFILE,"c")     
     
      ;setfileoption(ncdf, "definemode", True)
     
       fileattdef( ncdf, globeAtt )        ; create the global [file] attributes
                                         
       dimNames = (/"time", "LAT", "LON", "lat", "lon" /)  
       dimSizes = (/ ntim ,  NLAT,  MLON,  nlat,  mlon /) 
       dimUnlim = (/ True , False, False, False, False /)   
       filedimdef(ncdf, dimNames  , dimSizes,  dimUnlim )
     
       filevardef   (ncdf, "time"  , typeof(time), getvardims(time) )
       filevarattdef(ncdf, "time", time)
     
       filevardef   (ncdf, "LAT", typeof(LAT), "LAT")   ; original grid coords
       filevarattdef(ncdf, "LAT", LAT)
          
       filevardef   (ncdf, "LON", typeof(LON), "LON")
       filevarattdef(ncdf, "LON", LON)
     
       filevardef   (ncdf, "lat", typeof(lat), "lat")   ; interpolated grid coords
       filevarattdef(ncdf, "lat", lat)
          
       filevardef   (ncdf, "lon", typeof(lon), "lon")
       filevarattdef(ncdf, "lon", lon)
     
       filevardef   (ncdf, "date"  , typeof(date), getvardims(date) )
       filevarattdef(ncdf, "date", date)
     
       filevardef    (ncdf, ncVarName, typeof(X) , (/ "time", "LAT", "LON" /) )
       filevarattdef (ncdf, ncVarName,  X )
     
       filevardef    (ncdf, ncVarNameInterp, typeof(X_HALF ) , (/ "time", "lat", "lon" /) )
       filevarattdef (ncdf, ncVarNameInterp,  X_HALF )
     
       ncdf->time   = (/ time /)
       ncdf->lat    = (/ lat/)
       ncdf->lon    = (/ lon/)
       ncdf->date   = (/ date /)
       ncdf->$ncVarName$(0,:,:)       = (/ X /)
       ncdf->$ncVarNameInterp$(0,:,:) = (/ X_HALF /)

   end if    ; netCDF

   wallClockElapseTime(wcStrt, fili , 0)
  end

