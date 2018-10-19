load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

;------------------------------------------------------------------------
; Time and space coordinates
;------------------------------------------------------------------------

   yrStrt = 1901
   yrLast = 2002
   nyrs   = yrLast-yrStrt+1
   nmos   =   12
   ntim   = nyrs*nmos

; geographic region

   dlat   =  0.5
   latS   = 20.25
   latN   = 49.75
   nlat   = toint((latN-latS)/dlat)+1
   lat    = fspan(latS,latN,nlat)
   lat!0  = "lat"
   lat@long_name = "latitude"
   lat@units     = "degrees_north"
   lat&lat       = lat 
   printVarSummary(lat)

   dlon   =  0.5
   lonL   = -129.75
   lonR   =  -59.75
   mlon   = toint((lonR-lonL)/dlon)+1
   lon    = fspan(lonL,lonR,mlon)
   lon!0  = "lon"
   lon@long_name = "longitude"
   lon@units     = "degrees_east"
   lon&lon       = lon 
   printVarSummary(lon)

; time

   yyyymm = yyyymm_time(yrStrt,yrLast,"integer")
   yyyy   = yyyymm/100
   mm     = yyyymm - yyyy*100
   day    = mm    
   day    =  1
   hour   = mm    
   hour   =  0
   mn     = mm    
   mn     =  0
   sec    = mm
   sec    =  0

   tunits = "days since 1901-1-1 00:00:0.0"
   time   = cd_inv_calendar(yyyy,mm,day,hour,mn,sec,tunits, 0)

   delete(yyyymm&time)   ; these are integer
   yyyymm&time = time    ; reassign with double time

;------------------------------------------------------------------------
; data array; make 'short' rather than float to reduce size
;------------------------------------------------------------------------
 
   scpdsi = new( (/ntim,nlat,mlon/), "short")
   scpdsi!0 = "time"
   scpdsi!1 = "lat"
   scpdsi!2 = "lon"
   scpdsi&time = time 
   scpdsi&lat  = lat  
   scpdsi&lon  = lon  
   scpdsi@long_name = "self calibrating PDSI"
   scpdsi@scale_factor = 0.01
   scpdsi@add_offset   = 0.0 

;------------------------------------------------------------------------
; read ascii file
;------------------------------------------------------------------------

   diri   = "./"
   fili   = "scpdsi.usa.dat"
   datas  = asciiread(diri+fili, -1, "string")    ; data as string
   ndatas = dimsizes(datas)                       ; total # of rows

   ngrpt  = ndatas/(nyrs+1)                       ; # of grid points
  ;print("ngrpt="+ngrpt)

   do ng=0,ngrpt-1                                ; loop over all grid points
      ns = ng*(nyrs+1)                            ; index of grid pt start
      ne = ns+nyrs                                ;                  end

      gpLon = tofloat(str_get_cols(datas(ns), 28, 34))     ; extract grid pt lon
      gpLat = tofloat(str_get_cols(datas(ns), 38, 42))     ;                 lat

      jlat  = ind(gpLat.eq.lat)                   ; grid index values
      ilon  = ind(gpLon.eq.lon)

      if (ismissing(jlat) .or. ismissing(ilon)) then
          print("location error: gpLat="+gpLat+"  gpLon="+gpLon+ \
                               "  jlat="+ jlat+"   ilon="+ ilon  )
      else
          ks = 0
          ke = 11
          do nn=ns+1,ne
             scpdsi(ks:ke,jlat,ilon) = toshort(str_split(datas(nn)," -"))
             ks = ks+nmos
             ke = ke+nmos
          end do
      end if
   end do

;------------------------------------------------------------------------
; create netCDF
;------------------------------------------------------------------------

    cret = inttochar(10)                     ; carriage return (new line)

    diro = "./"
    filo = "CRU_scpdsi_usa.nc"
    system("/bin/rm -f "+diro+filo)          ; remove any pre-existing file
    ncdf = addfile(diro+filo ,"c")           ; open output netCDF file

    fAtt               = True                ; assign file attributes
    fAtt@creation_date = systemfunc ("date")        
    fAtt@Conventions   = "CF-1.0"   
    fAtt@NCL_script    = "asc2nc.cru_scpdsi_usa.ncl"
    fAtt@conversion    = "Converted from ascii CRU TS 2.1 format"
    fAtt@source_file   = fili
    fAtt@source_url    = "http://www.cru.uea.ac.uk/cru/data/drought/"

    fAtt@support       = cret + \
"Gerard van der Schrier acknowledges support of the UK Natural Environment                    "+cret+\ 
"Research Council (NERC) through the RAPID Climate Change programme (grant NER/T/S/2002/00440)"+cret+\
"Keith R. Briffa and Tim J.  Osborn also acknowledge support from the EU project SOAP.        "+cret

    fAtt@reference_2   = cret + \
"Wells N, Goddard S and Hayes MJ (2004)                                                 "+cret+\
"A self-calibrating Palmer Drought Severity Index                                       "+cret+\
"Journal of Climate 17, 2335-2351 (doi:10.1175/1520-0442(2004)017<2335:ASPDSI>2.0.CO;2) "+cret

    fAtt@reference_1   = cret + \
"van der Schrier G, Briffa KR, Osborn TJ and Cook ER (2006b)            "+cret+\
"Summer moisture availability across North America                      "+cret+\
"Journal of Geophysical Research 111, D11102 (doi:10.1029/2005JD006745) "+cret

    fAtt@description   = cret + \
"The scPDSI metric was introduced by Wells et al. (2004), who give detailed information     "+cret+\
"about its calculation. The scPDSI is a variant on the original PDSI of Palmer (1965),      "+cret+\
"with the aim to make results from different climate regimes more comparable. As with the   "+cret+\
"PDSI, the scPDSI is calculated from time series of precipitation and temperature,          "+cret+\
"together with fixed parameters related to the soil/surface characteristics at each location"+cret
    fAtt@title         = "CRU Self Calibrating PDSI: "+yrStrt+"="+yrLast  

    fileattdef( ncdf, fAtt )                 ; copy file attributes      

    filedimdef(ncdf,"time",-1,True)          ; make time an UNLIMITED dimension

    ncdf->yyyymm  = yyyymm
    ncdf->scPDSI  = scpdsi  
