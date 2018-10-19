; -------------------------------------------------------
; GPCP ONE-DEGREE DAILY PRECIPITATION DATA SET
;
; new:      http://www.ncdc.noaa.gov/thredds/catalog/gpcp/daily/catalog.html
; standard: http://precip.gsfc.nasa.gov/
;
; -------------------------------------------------------
; read the documentation for updates and details
; -------------------------------------------------------
; Convert binary to netCDF
; -------------------------------------------------------
;               USER INPUT
; -------------------------------------------------------

  DIRI = "/scratch/GPCP/binary/"
  DIRO = "/scratch/GPCP/netCDF/"                ; output directory with netCDF

  PACK = False
; -------------------------------------------------------
;               END USER INPUT
; -------------------------------------------------------
  if (PACK) then
      optPack = True
      optPack@min_value = 0.
      optPack@max_value = 3000.                 ; max value thru 2009 = 1975 mm/day :-)
      optPack@scale_factor =  0.1
      optPack@add_offset   =  0.0
  else
      optPack = False
  end if


load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

; -------------------------------------------------------
; define lat/lon grid: GPCP goes from N=>S
; -------------------------------------------------------
  nlat = 180
  mlon = 360
  lon  = lonGlobeFo(mlon,"lon","longitude","degrees_east")
  lat  = latGlobeFo(nlat,"lat","latitude","degrees_north")
  lat  = lat(::-1)      ; make N=>S
  printVarSummary(lat)

; -------------------------------------------------------
; Define generic file attributes
; -------------------------------------------------------

   nline           = inttochar(10)    ; new line character
   fAtt            = 0  ; attributes for netCDF file
   fAtt@creation_date =  systemfunc("date")

   fAtt@ref_1      =  nline + \
       "Huffman, G.J., R.F. Adler, M.M. Morrissey, S. Curtis  " + nline + \
       "R. Joyce, B. McGavock, and J. Susskind, 2001:         " + nline + \
       "Global precipitation at one-degree daily resolution from multi-satellite observations" + nline +\  
       "J. Hydrometeor., 2, 36-50" + nline

   fAtt@ref_2      =  nline + \
       "Bolvin, David T., Robert F. Adler, George J. Huffman  " + nline + \
       "Eric J. Nelkin, Jani P. Poutiainen, 2009:             " + nline + \
       "Comparison of GPCP Monthly and Daily Precipitation Estimates with High-Latitude Gauge Observations" + nline + \
       "J. Appl. Meteor. Climatol., 48, 1843-1857" + nline + \
       "http://dx.doi.org/10.1175/2009JAMC2147.1" + nline

   fAtt@ref_3      =  nline + \
       "Adler, Robert F., Guojun Gu, George J. Huffman, 2012: " + nline + \ 
       "Estimating Climatological Bias Errors for the Global Precipitation Climatology Project (GPCP)" + nline + \
       "J. Appl. Meteor. Climatol., 51, 84-99" + nline + \
       "http://dx.doi.org/10.1175/JAMC-D-11-052.1" + nline 

   fAtt@Conversion = "NCL: http://www.ncl.ucar.edu/"
   fAtt@Convention = "CF-1.0"
   fAtt@Source     = "ftp://rsd.gsfc.nasa.gov/pub/1dd-v1.1/"
   fAtt@GSFC       = "http://precip.gsfc.nasa.gov/"
   fAtt@Comment    = "netCDF version of original binary file(s)"
   fAtt@Title      = "GPCP ONE-DEGREE DAILY PRECIPITATION DATA SET"

; -------------------------------------------------------
; names of all 1dd files in the directory "diri"
; -------------------------------------------------------
   diri = DIRI
   fili = systemfunc("cd "+diri+" ; ls gpcp_1dd_v1.1_p1d*")
   nfil = dimsizes( fili )
   print(fili)

   diro = DIRO
; -------------------------------------------------------
; Loop over all files and create individual netCDF.
; Use "ncrcat" if one file is desired/
; -------------------------------------------------------
  setfileoption("bin","ReadByteOrder","BigEndian")

  do nf=0,nfil-1
     yyyy  = toint( str_get_cols(fili(nf), 18, 21) )
     mm    = toint( str_get_cols(fili(nf), 22, 23) )

     ntim  = days_in_month(yyyy, mm )

          ; read header + all days in the month
     dumy  = fbindirread(diri+fili(nf),0,360+ntim*360*180,"float")
          ; create netCDF
     prec  = onedtond( dumy(360:), (/ntim,nlat,mlon/) )   ; skip header
     delete (dumy)   ; size may change for next month

; ---------------------------------------------------------
; Construct primary data structure
; ---------------------------------------------------------
     prec@long_name  = "GPCP: daily precipitation"
     prec@units      = "mm/day"
     prec@_FillValue = -99999.
     prec@missing_value = prec@_FillValue

     prec!0   = "time"
     prec!1   = "lat"
     prec!2   = "lon"

     prec&lat =  lat
     prec&lon =  lon

; ---------------------------------------------------------
; create time variables
; ---------------------------------------------------------
     yyyymm = yyyy*100 + mm
     days   = ispan(1,ntim,1)
     hh     = 12                      ; middle of day (arbitrary) 

     date   = yyyymm*10000 + days*100 + hh   
     date!0 = "time"
     date@long_name = "gregorian date"
     date@units     = "yyyymmddhh"
     
     YYYY   = conform(date, yyyy, -1)  ; make scalar a vector to match "days"
     MM     = conform(date,   mm, -1)
     HH     = conform(date,   hh, -1)
     ZERO   = conform(date,    0, -1)

     tunits = "days since 1990-01-01 00:00:00"      ; arbitrary
     time   = ut_inv_calendar(YYYY,MM,days,HH, ZERO , ZERO ,tunits, 0)
     time!0 = "time"
     time@long_name = "time"
     time@units     = tunits

; ---------------------------------------------------------
; create netCDF
; ---------------------------------------------------------
     yyyymm = yyyy*100 + mm
    ;ncfile = diro+fili(nf)+".nc"
     ncfile = diro+"GPCP.1DD."+yyyymm+".nc"
     print (ncfile)
     system ("/bin/rm -f " + ncfile)  ; remove an pre-file
   
     ncdf   = addfile(ncfile,"c")       ; "c"reate the netCDF file
   
     fileattdef( ncdf, fAtt )
   
     dimNames = (/ "time", "lon", "lat"  /)
     dimSizes = (/   -1  ,  mlon, nlat   /)
     dimUnlim = (/  True , False, False  /)
     filedimdef( ncdf, dimNames, dimSizes, dimUnlim )
                                            ; Define 1D variables.
     filevardef   ( ncdf, "time", typeof(time), getvardims(time) )
     filevarattdef( ncdf, "time", time )
   
     filevardef   ( ncdf, "lat", typeof(lat), getvardims(lat) )
     filevarattdef( ncdf, "lat", lat )
   
     filevardef   ( ncdf, "lon", typeof(lon), getvardims(lon) )
     filevarattdef( ncdf, "lon", lon )
                                            ; Define 1D variables.
     filevardef   ( ncdf, "date", typeof(date), getvardims(date) )
     filevarattdef( ncdf, "date", date )
   
     if (PACK) then
         filevardef   ( ncdf, "PREC", "short", getvardims(prec) )
         pShort     = pack_values(prec, "short", optPack)
         delete(pShort@vMin_original_data) ; extraneous
         delete(pShort@vMax_original_data)
         filevarattdef( ncdf, "PREC", pShort )
     else
         filevardef   ( ncdf, "PREC", typeof(prec), getvardims(prec) )
         filevarattdef( ncdf, "PREC", prec )
     end if
                                               ; Write variables.
     ncdf->time     = (/time/)
     ncdf->lat      = (/lat /)
     ncdf->lon      = (/lon /)
     ncdf->date     = (/date/)
     if (PACK) then
         ncdf->PREC = (/pShort/)
         delete(pShort)
     else
         ncdf->PREC = (/prec/)
     end if

                    ; size may change for next month
     delete( [/ prec, time, date, days, YYYY, MM, HH, ZERO/] )
  end do
  
end
