;***************************************************************
; trmm_3B40RT_2.ncl
;
; Concepts illustrated:
;   - Reading *binary* files with multiple data types
;   - Book-keeping of 'pointers' indicating location of data types
;   - Extractiing time information from the file name and creating
;     time related variables for CF-1.0 compliant netCDF.
;   - Writing data to a NetCDF file with a time dimension
;     with the original data types.
;***************************************************************
; --------------------------3B40RT-----------------------------
; Header:
; Each file starts with a header that is one 2-byte-integer 
;   row in length, or 2880 bytes. 
; Following the header, 6 data fields appear: 
;   precipitation (2-byte integer; NCL type 'short') 
;   precipitation_error (2-byte integer; NCL type 'short')
;   # pixels (1-byte integer; NCL type 'byte')
;   # ambiguous pixels (1-byte integer; NCL type 'byte')
;   # rain pixels (1-byte integer; NCL type 'byte')
;   # source      (1-byte integer; NCL type 'byte')
; All fields are 1440x480 grid boxes (0-360E,60N-S). 
;   The first grid box center is at (0.125E,59.875N)
; The binary file is 'big endian'
; -------------------------------------------------------------
; typical file name: 3B40RT.2001012212.7R2.bin
; source:        ftp://disc2.nascom.nasa.gov/data/TRMM/Gridded/3B40RT/
; documentation: ftp://trmmopen.gsfc.nasa.gov/pub/merged/V7Documents/3B4XRT_doc_V7.pdf
; -------------------------------------------------------------
; Reference:
;  George J. Huffman at al, 2007 
;  The TRMM Multisatellite Precipitation Analysis (TMPA): 
;      Quasi-Global, Multiyear, Combined-Sensor Precipitation Estimates at Fine Scales
;  J. Hydrometeor, 8, 38–55       
;  doi: http://dx.doi.org/10.1175/JHM560.1 
; -------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
;***************************************************************
; User Input
;***************************************************************
                                             ; INPUT
   fili_prefix = "3B40RT"
   diri   = "/Users/shea/Data/TRMM/"+fili_prefix+"/"  ; input directory
   fili   = systemfunc("cd "+diri+" ; ls "+fili_prefix+"*bin") 
   nfili  = dimsizes(fili)
   print(fili)
                                             ; OUTPUT
   ncDir   = "./"                        ; directory for netCDF output

   nlat   = 480
   mlon   = 1440
   lhead  = 2880     ; characters (bytes)

  ;print("lhead="+lhead+"  nlat="+nlat+"  " \
  ;     +"mlon="+mlon+"   nlat*mlon="+nlat*mlon)

   prcScale = 0.01    
   errScale = 0.01    

;***************************************************************
; End User Input
;***************************************************************
; Loop over files: Read BigEndian binary file ( byte_order=big_endian )
;***************************************************************

   setfileoption("bin","ReadByteOrder","BigEndian")
 do nf=0,nfili-1
;***************************************************************
; Read Header (2880 characters (character=byte in length)           
;***************************************************************

   hdrc   = fbindirread (diri+fili(nf), 0, lhead , "character")  ; header
   hdrs   = tostring(hdrc)        ; create string
   nfld  = str_fields_count(hdrs, " ")

   hdrs_parse = new (nfld, "string","No_FillValue")
   do k=0,nfld-1
      hdrs_parse(k) = str_get_field(hdrs, k+1, " ") 
   end do

   if (nf.eq.0) then   ; initial file only
       print(hdrs)
       print(nfld)
       print(hdrs_parse)
   end if

; extract data: typical file name: 3B40RT.2001012212.7R2.bin
;                                  01234567890123456

   yyyy           = toint( str_get_cols(fili(nf), 7,10) )
   mm             = toint( str_get_cols(fili(nf),11,12) )
   dd             = toint( str_get_cols(fili(nf),13,14) )
   hh             = toint( str_get_cols(fili(nf),15,16) )
   yyyymmddhh     = toint( str_get_cols(fili(nf), 7,16) )
   print(fili(nf)+"  nf="+nf+"  yyyy="+yyyy+"  mm="+mm+"  dd="+dd+"  hh="+hh)

;***************************************************************
; Read data source as type short
; Skip header; Read precip (short); skip header; read type short; reshape & scale
; Eliminate negative precipitation values
;***************************************************************
   lhead2 = lhead/2  ; header length as type 'short' 

   works  = fbindirread (diri+fili(nf), 0, -1, "short") 
   works@_FillValue = toshort(-31999)
   printVarSummary(works)

   starts = lhead2                ; length of header in terms of "short"
   lasts  = starts+nlat*mlon-1 
  ;print("starts="+starts+"  lasts="+lasts+"  (lasts-starts+1)="+(lasts-starts+1))

   prc    = onedtond(works(starts:lasts), (/nlat,mlon/) )    

;***************************************************************
; Read error  (short); skip header and precip; read err; reshape & scale
;***************************************************************

   starts = lasts+1  
   lasts  = starts+nlat*mlon-1
  ;print("starts="+starts+"  lasts="+lasts+"  (lasts-starts+1)="+(lasts-starts+1))

   err    = onedtond(works(starts:lasts), (/nlat,mlon/) )    

;***************************************************************
; Read entire source as type byte; skip header (char), precip and error (short)
;***************************************************************

   workb  = fbindirread (diri+fili(nf), 0, -1, "byte")  

;***************************************************************
;   # pixels (1-byte integer)
;   # ambiguous pixels (1-byte integer)
;   # rain pixels (1-byte integer)
;   # source      (1-byte integer)
;***************************************************************
   startb = lhead + 4*nlat*mlon     
   lastb  = startb+nlat*mlon-1
  ;print("startb="+startb+"  lastb="+lastb+"  (lastb-startb+1)="+(lastb-startb+1))
   pix    = onedtond(workb(startb:lastb),(/nlat,mlon/) )
   print("pix: min="+min(pix)+"    max="+max(pix))

   startb = lastb + 1
   lastb  = startb+nlat*mlon-1
  ;print("startb="+startb+"  lastb="+lastb+"  (lastb-startb+1)="+(lastb-startb+1))
   pixa   = onedtond(workb(startb:lastb),(/nlat,mlon/) )
   print("pixa: min="+min(pixa)+"    max="+max(pixa))

   startb = lastb + 1
   lastb  = startb+nlat*mlon-1
  ;print("startb="+startb+"  lastb="+lastb+"  (lastb-startb+1)="+(lastb-startb+1))
   pixrain  = onedtond(workb(startb:lastb),(/nlat,mlon/) )
   print("pixrain: min="+min(pixrain)+"    max="+max(pixrain))

   startb = lastb + 1
   lastb  = startb+nlat*mlon-1
  ;print("startb="+startb+"  lastb="+lastb+"  (lastb-startb+1)="+(lastb-startb+1))
   src    = onedtond(workb(startb:lastb),(/nlat,mlon/) )

;***************************************************************
; Add meta data
;***************************************************************
   prc@units       = "mm/hr"
   prc@long_name   = "TRMM_3B40RT: Hourly Rain Rate" 
   prc@scale_factor=  prcScale
   prc@add_offset  =  0.0
   prc@missing_value  =  prc@_FillValue

   err@units       = "mm/hr"
   err@long_name   = "TRMM_3B40RT: Error Hourly Rain Rate" 
   err@_FillValue  =  prc@_FillValue
   err@scale_factor=  errScale
   err@add_offset  =  0.0

   pix@units       = "....."
   pix@long_name   = "TRMM_3B40RT: Pixels" 

   pixa@units       = "....."
   pixa@long_name   = "TRMM_3B40RT: Ambiguous Pixels" 

   pixrain@units     = "....."
   pixrain@long_name = "TRMM_3B40RT: Rain Pixels" 

   src@long_name   = "Data Source" 
   src@source      = "0=no observation, 1=AMSU, 2=TMI, 3=AMSR, 4=SSMI, "+\
                     "5=SSMIS, 6=MHS, 30=AMSU&MHS avg, 31=conical avg, "+\
                     "50=IR, 1,2,3,4,5,6+100=Sparce Sample"

;*****************************************************
; Create TRMM coordinate variables. See README
;*****************************************************
   lat        = 59.875 - ispan(0,nlat-1,1)*0.25 
   lon        = ispan(0,mlon-1,1)*0.25 

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
;***************************************************************
   prc!0      = "lat"                   ; 1st ... name the dimensions
   prc!1      = "lon"
   prc&lat    =  lat                    ; create coordinate variable
   prc&lon    =  lon                    

   err!0      = "lat"                  
   err!1      = "lon"
   err&lat    =  lat                  
   err&lon    =  lon                    

   pix!0      = "lat"                  
   pix!1      = "lon"
   pix&lat    =  lat                  
   pix&lon    =  lon                    

   pixa!0     = "lat"                  
   pixa!1     = "lon"
   pixa&lat   =  lat                  
   pixa&lon   =  lon                    

   pixrain!0  = "lat"                  
   pixrain!1  = "lon"
   pixrain&lat=  lat                  
   pixrain&lon=  lon                    

   src!0      = "lat"                
   src!1      = "lon"
   src&lat    =  lat                
   src&lon    =  lon                    

   printVarSummary(prc)
   printMinMax(prc, 0)
   printVarSummary(err)
   printMinMax(err, 0)
   printVarSummary(src)
   printMinMax(src, 0)

;************************************************
; Create netCDF 
; Recommend to always create a 'time' dimension 
;************************************************
  
   ntim     = 1
   ncFil    = fili_prefix +"."+ yyyymmddhh+".nc"

   tunits   = "hours since 1997-01-01 00:00:0.0"
   time     = cd_inv_calendar(yyyy,mm,dd,hh, 0,0d0,tunits, 0)
   time!0   = "time"

   date     = yyyymmddhh
   date!0   = "time"
   date@long_name = "Current date as YYYYMMDDHH"

   nline    = inttochar(10)         ; new line character
   
   globeAtt              = 1
   globeAtt@netCDF_creation_date= systemfunc ("date" )

   globeAtt@reference    = nline + \
    "George J. Huffman at al, 2007                                          "+nline+\
    "   The TRMM Multisatellite Precipitation Analysis (TMPA):              "+nline+\
    "   Quasi-Global, Multiyear, Combined-Sensor Precipitation Estimates at Fine Scales" +nline+\
    "   J. Hydrometeor, 8, 38–55 ,  doi: http://dx.doi.org/10.1175/JHM560.1" +nline+\
    "   "+nline

   do n=0,nfld-1
      s = str_split( hdrs_parse(n), "=" )
      globeAtt@$s(0)$ = s(1)
   end do
   globeAtt@title        = "TRMM_"+fili_prefix    
     
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
     
   filevardef    (ncdf, "PRC"  , typeof(prc) , (/ "time", "lat", "lon" /) )
   filevarattdef (ncdf, "PRC"  , prc)

   filevardef(ncdf, "RELERR"   , typeof(err), (/ "time", "lat", "lon" /) )
   filevarattdef(ncdf, "RELERR", err)
     
   filevardef    (ncdf, "PIX"  , typeof(pix) , (/ "time", "lat", "lon" /) )
   filevarattdef (ncdf, "PIX"  , pix)
     
   filevardef    (ncdf, "PIXA"  , typeof(pixa) , (/ "time", "lat", "lon" /) )
   filevarattdef (ncdf, "PIXA"  , pixa)
     
   filevardef    (ncdf, "PIX_RAIN"  , typeof(pixrain) , (/ "time", "lat", "lon" /) )
   filevarattdef (ncdf, "PIX_RAIN"  , pixrain)
     
   filevardef    (ncdf, "SRC"  , typeof(src) , (/ "time", "lat", "lon" /) )
   filevarattdef (ncdf, "SRC"  , src)
     
   ncdf->time   = (/ time /)
   ncdf->lat    = (/ lat /)
   ncdf->lon    = (/ lon /)
   ncdf->date   = (/ date /)
   ncdf->PRC(0:0,:,:)     = (/ prc  /)
   ncdf->RELERR(0:0,:,:)  = (/ err  /)
   ncdf->PIX(0:0,:,:)     = (/ pix  /)
   ncdf->PIXA(0:0,:,:)    = (/ pixa /)
   ncdf->PIX_RAIN(0:0,:,:)= (/ pixrain /)
   ncdf->SRC(0:0,:,:)     = (/ src /)

 end do      ; nf
