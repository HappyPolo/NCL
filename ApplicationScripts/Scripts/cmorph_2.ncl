;***************************************************************
; cmorph_2.ncl
;
; Concepts illustrated:
;   - Reading big endian binary files
;   - Reading records written by a fortran direct access write
;   - Reading CMORPH 0.25 data
;   - Adding meta data (attributes and coordinates [time, lat, lon])
;   - Interpolate to two different grids: 1x1 and CAM (96,144)
;   - Counting missing values
;   - Calculating areal averages
;   - Explicitly setting contour levels and colors
;   - Creating a netCDF file
;***************************************************************
;; 
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
;   fili   = "20090620_dly-025deg_cpc+comb"   ; binary uncompressed
;   fili   = "20090620_3hr-025deg_cpc+comb"
   fili   = "CMORPH+MWCOMB_DAILY-025DEG_20170408"

                                             ; OUTPUT
   netCDF = True                             ; generate netCDF file
   PLOT   = True                             ; generate plots

   if (netCDF) then
       ncDir   = "./"                        ; directory for netCDF output
       ncFil   = fili + ".1x1.nc"            ; netCDF name output
   end if

   if (PLOT) then
       pltDir  = "./"                        ; directory for plot output
       pltName = "cmorph"                    ; graphics name output
       pltType = "png"                       ; send graphics to PNG file
   end if

;***************************************************************
; End User Input
;***************************************************************
; Miscellaneous: Parse the file name to extract strings
;***************************************************************
   filc        = stringtochar( fili ) 
   date_str    = (/ filc(0:7) /)        ; yyyymmdd as a string
   file_str    = (/ filc(0:18)/)        ; unique
   if (PLOT) then
       pltName = pltName +"_"+file_str
   end if

;***************************************************************
; Read (big endian) binary file
;***************************************************************
   setfileoption("bin","ReadByteOrder","BigEndian")

   nlat  = 480                                    ; from ctl file  
   mlon  = 1440

   comb  = fbindirread(diri+fili,0, (/nlat,mlon/),"float")
   cpc   = fbindirread(diri+fili,1, (/nlat,mlon/),"float")

;***************************************************************
; Add meta data. Note: Some grid points have missing data [_FillValue]
;***************************************************************
   comb@_FillValue = -9999.
   comb@units      = "mm/hr"
   comb@long_name  = "Merged microwave precip" 

   cpc@_FillValue  = -9999.
   cpc@units       = "mm/hr"
   cpc@long_name   = "CMORPH precip"

;***************************************************************
; Change from mm/hr to mm/day
;***************************************************************
   comb            = comb*24    
   cpc             = cpc*24    
   comb@units      = "mm/day"
   cpc@units       = "mm/day"

;***************************************************************
; Create/Add coordinate variables. See above Grads ctl   
;***************************************************************
   lat       =  59.875 - ispan(0,nlat-1,1)*0.25  
   lon       =   0.125 + ispan(0,mlon-1,1)*0.25 
                                        ;latitude
   lat!0     = "lat"
   lat&lat   =  lat
   lat@units = "degrees_north"
                                        ;longitude
   lon!0     = "lon"
   lon&lon   =  lon
   lon@units = "degrees_east"

;***************************************************************
; Associate the spatial coordinates with variables
;***************************************************************

   comb!0    = "lat"                   ; 1st ... name the dimensions
   comb!1    = "lon"
   comb&lat  =  lat                    ; create coordinate variable
   comb&lon  =  lon                    ; create coordinate variable

   copy_VarCoords( comb, cpc )         ; same coordinates

;***************************************************************
; Simple data exploration:
;    Are there missing data?
;    Count the number of missing values in each variable
;    Calculate weighted areal averages: ignore missing grid points
;    Calculate weighted areal averages of precip occurrence only
; Print results
;***************************************************************

   nMsg_comb = num(ismissing(comb))
   nMsg_cpc  = num(ismissing(cpc ))

   rad      = 4.*atan(1.0)/180.
   clat_025 = cos(lat*rad)    ; simple cosine weighting

   combAvg_025 = wgt_areaave(comb, clat_025, 1.0, 0)
   cpcAvg_025  = wgt_areaave( cpc, clat_025, 1.0, 0)

   print(" ")
   print("Number missing: nMsg_comb="+nMsg_comb+"   nMsg_cpc="+nMsg_cpc)
   print(" ")
   print("Original 0.25 grid: combAvg="+combAvg_025+"   cpcAvg="+cpcAvg_025)
   print(" ")

;***************************************************************
; Interpolate to a 1x1 grid [meta info is *only* needed for netCDF]
; Calculate areal averages after interpolation
;***************************************************************
   lat1       = ispan(-58,  58, 1)*1.0 
   lat1!0     = "lat1"
   lat1@units = "degrees_north"
   lat1&lat1  = lat1

   lon1       = ispan( 0 , 359, 1)*1.0 
   lon1!0     = "lon1"
   lon1@units = "degrees_east"
   lon1&lon1  = lon1

   opt        = True
  ;opt@critpc = 50                 ; default is 100%
   comb_1x1   = area_hi2lores_Wrap (comb&lon,comb&lat, comb , True, clat_025,  lon1, lat1, opt)
   cpc_1x1    = area_hi2lores_Wrap ( cpc&lon, cpc&lat,  cpc , True, clat_025,  lon1, lat1, opt)

   comb_1x1@long_name = comb@long_name + " (1x1)"
   cpc_1x1@long_name  =  cpc@long_name + " (1x1)"

;***************************************************************
; Interpolate to a CAM (96,144) grid [meta info is only needed for netCDF]
; All grids poleward of 57.875 will be _FillValue 
;***************************************************************
   latCAM        = fspan(-90,  90, 96) 
   latCAM!0      = "latCAM"
   latCAM@units  = "degrees_north"
   latCAM&latCAM = latCAM

   lonCAM        = fspan( 0 , 357.5, 144) 
   lonCAM!0      = "lonCAM"
   lonCAM@units  = "degrees_east"
   lonCAM&lonCAM = lonCAM

   comb_CAM   = area_hi2lores_Wrap (comb&lon,comb&lat, comb , True, clat_025, lonCAM, latCAM, opt) 
   cpc_CAM    = area_hi2lores_Wrap ( cpc&lon, cpc&lat,  cpc , True, clat_025, lonCAM, latCAM, opt)

   comb_CAM@long_name = comb@long_name + " (CAM 1.9x2.5)"
   cpc_CAM@long_name  =  cpc@long_name + " (CAM 1.9x2.5)"

;***************************************************************
; Calculate the areal averages of the interpolated grids
;***************************************************************
   clat_1x1 = cos(lat1*rad)
   clat_CAM = cos(latCAM*rad)

   combAvg_1x1 = wgt_areaave(comb_1x1, clat_1x1, 1.0, 0)
    cpcAvg_1x1 = wgt_areaave( cpc_1x1, clat_1x1, 1.0, 0)

   combAvg_CAM = wgt_areaave(comb_CAM, clat_CAM, 1.0, 0)
    cpcAvg_CAM = wgt_areaave( cpc_CAM, clat_CAM, 1.0, 0)

   print(" ")
   print("Interpolated 1x1: combAvg_1x1="+combAvg_1x1+"   cpcAvg_1x1="+cpcAvg_1x1)
   print("Interpolated CAM: combAvg_CAM="+combAvg_CAM+"   cpcAvg_CAM="+cpcAvg_CAM)
   print(" ")

;***************************************************************
; Create plot ? Only do the CPC [CMORPH] variable
; resource 'cnFillPalette' introduced in NCL 6.1.0 (Oct 28, 2012)
;***************************************************************
   if (PLOT) then
       wks    = gsn_open_wks(pltType, "cmorph")
   
       plot = new ( 3 , "graphic")
     
       res                      = True     ; plot mods desired
       res@gsnDraw              = False    ; don't draw
       res@gsnFrame             = False    ; don't advance frame
     
       res@cnFillOn             = True     ; turn on color fill
       res@cnLinesOn            = False    ; turn of contour lines
       res@cnFillMode           = "CellFill"           ; Cell Mode
       res@cnFillMode           = "RasterFill"         ; Raster Mode
       res@cnLinesOn            =  False       ; Turn off contour lines
       res@cnLineLabelsOn       =  False       ; Turn off contour lines

       res@cnLevelSelectionMode = "ExplicitLevels"              
       res@cnLevels             = (/0.1,1,2.5,5,10,15,20,25,50,75/) ; "mm/day" 
       res@cnFillPalette        = (/"Snow","PaleTurquoise","PaleGreen","SeaGreen3" ,"Yellow" \   ; contour colors
                                   ,"Orange","HotPink","Red","Violet", "Purple", "Brown"/)       ; one more color than contour levels


       res@cnMissingValFillPattern = 0         ; make 'missing' black
       res@cnMissingValFillColor   = "black"
   
       res@lbLabelBarOn         = False    ; turn off individual cb's
     
       res@mpMinLatF            = -60.     ; CMORPH limits [approx]
       res@mpMaxLatF            =  60.
       res@mpCenterLonF         = 210.
       res@mpFillOn             = False
   
      ;res@mpShapeMode          = "FreeAspect"
      ;res@vpWidthF             = 0.8
      ;res@vpHeightF            = 0.4

       res@gsnCenterString = "Areal Mean="+sprintf("%4.2f", combAvg_025)
       plot(0) = gsn_csm_contour_map_ce(wks,comb, res)

       res@gsnCenterString = "Areal Mean="+sprintf("%4.2f", combAvg_1x1)
       plot(1) = gsn_csm_contour_map_ce(wks,comb_1x1, res)

       res@gsnCenterString = "Areal Mean="+sprintf("%4.2f", combAvg_CAM)
       plot(2) = gsn_csm_contour_map_ce(wks,comb_CAM, res)
     
       resP = True
       resP@gsnMaximize         = True                ; make ps/eps/pdf large [no effect x11]
     ;;resP@gsnPaperOrientation = "Portrait"          ; force portrait
       resP@gsnPanelLabelBar    = True                ; add common colorbar
       resP@lbLabelAutoStride   = True
       resP@lbLabelFontHeightF  = 0.0175              ; change font size
       resP@txString            = "CMORPH: "+fili
       gsn_panel(wks,plot,(/3,1/),resP)               ; now draw as one plot
   end if    ; PLOT
  
;************************************************
; Create netCDF ?
; Recommend to always create a 'time' dimension 
; Save only the interpolated CMORPH (uncomment to sabe "COMB")
;************************************************
  
   if (netCDF) then
       ntim     = 1
       NLAT     = dimsizes(lat1) ; 1x1 grid size
       MLON     = dimsizes(lon1)

       yyyy     = stringtointeger( (/filc( 0: 3)/) ) 
       mm       = stringtointeger( (/filc( 4: 5)/) ) 
       dd       = stringtointeger( (/filc( 6: 7)/) ) 
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
       globeAtt@title        = "CMORPH: 0.25 Daily interpolated to a 1x1 grid"    
       globeAtt@ftp          = "ftp://ftp.cpc.ncep.noaa.gov/precip/global_CMORPH/daily_025deg"
       globeAtt@acronym      = "CMORPH: CPC Morphing Technique"
       globeAtt@description  = "http://www.cpc.noaa.gov/products/janowiak/cmorph_description.html"
       globeAtt@referenceon  = nline + \
                              "Joyce, R. J., J. E. Janowiak, P. A. Arkin, and P. Xie, 2004:       "+nline+\
                              "CMORPH: A method that produces global precipitation estimates      "+nline+\
                              "        from passive microwave and infrared data at high spatial   "+nline+\
                              "        and temporal resolution. J. Hydromet., 5, 487-503.         "+nline
     
       globeAtt@creation_date= systemfunc ("date" )
     
       NCFILE = ncDir + ncFil
       system ("/bin/rm -f " +  NCFILE)    ; remove any pre-exist file 
           
       ncdf   = addfile(NCFILE,"c")     
     
      ;setfileoption(ncdf, "definemode", True)
     
       fileattdef( ncdf, globeAtt )        ; create the global [file] attributes
                                         
       dimNames = (/"time", "lat", "lon" /)  
       dimSizes = (/ ntim ,  NLAT,  MLON /) 
       dimUnlim = (/ True , False, False /)   
       filedimdef(ncdf, dimNames  , dimSizes,  dimUnlim )
     
       filevardef   (ncdf, "time"  , typeof(time), getvardims(time) )
       filevarattdef(ncdf, "time", time)
     
       filevardef   (ncdf, "lat", typeof(lat1), "lat")
       filevarattdef(ncdf, "lat", lat1)
          
       filevardef   (ncdf, "lon", typeof(lon1), "lon")
       filevarattdef(ncdf, "lon", lon)
     
       filevardef   (ncdf, "date"  , typeof(date), getvardims(date) )
       filevarattdef(ncdf, "date", date)
     
     ;;filevardef    (ncdf, "COMB"  , typeof(comb_1x1) , (/ "time", "lat", "lon" /) )
       filevardef    (ncdf, "CMORPH", typeof(cpc_1x1 ) , (/ "time", "lat", "lon" /) )

     ;;filevarattdef (ncdf, "COMB"  , comb_1x1)
       filevarattdef (ncdf, "CMORPH",  cpc_1x1 )
     
       ncdf->time   = (/ time /)
       ncdf->lat    = (/ lat1/)
       ncdf->lon    = (/ lon1/)
       ncdf->date   = (/ date /)

     ;;ncdf->COMB(0:0,:,:)   = (/ comb_1x1 /)   ; trick to force 2D array into 3D reserved space
       ncdf->CMORPH(0:0,:,:) = (/ cpc_1x1  /)

   end if    ; netCDF
  end
