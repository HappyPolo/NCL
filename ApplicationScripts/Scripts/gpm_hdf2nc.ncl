;----------------------------------------------------------------------
; gpm_hdf2nc.ncl
;
; Requires NCL 6.3.0 onward
;
; Concepts illustrated:
;   - Reading multiple GPM Monthly HDF5 files for precipitation located in a group named "/Grid"
;   - Transpose dimension order (lon,lat) => (lat,lon)
;   - Creating a time dimension
;   - Writing to netCDF
;----------------------------------------------------------------------

 diri = "./"
 fili = systemfunc("cd "+diri+" ; ls 3B-MO.MS.MRG.3IMERG.*HDF5")
 print(fili)
 nfil = dimsizes(fili)
 
 ntim = 1       ; all files have one time step
 dirnc= "./"    ; dir for netCDF
 
 do nf=0,nfil-1
    f   = addfile(diri+fili(nf),"r")
    print(f)
                                ; create 'time'
    yyyymmdd = toint( str_get_field(fili(nf), 6, "-.") )
    yyyy     = yyyymmdd/10000
    mmdd     = yyyymmdd - (yyyy*10000)
    mm       = mmdd/100
    dd       = mmdd - (mm*100)
    
    tunits   = "hours since 2000-01-01 00:00:00"
    time     = cd_inv_calendar(yyyy,mm,dd,0,0,0,tunits, 0)
    time!0   = "time"
    
    yyyymmdd@long_name = "Current date as YYYYMMDD"   ; for netCDF
    yyyymmdd!0    = "time"
    yyyymmdd&time =  time
       
    grp  = f=>/Grid
    p    = grp->precipitation    ; [lon | 3600] x [lat | 1800]
    
    dimp = dimsizes(p)
    mlon = dimp(0)
    nlat = dimp(1)
    
    P    = new( (/ntim,nlat,mlon/), typeof(p), p@_FillValue)
    P(0,:,:) = p(lat|:,lon|:)    ; conventional [lat,lon] order
    
    P!0    = "time"              ; create 'time' coordinate variable
    P&time =  time
    printVarSummary(P)
                                 ; HDF stuff we do not need
    delete( [/ P@DIMENSION_LIST, P@CodeMissingValue, P@Units, P@DimensionNames /] )  ; extraneous
    delete( [/ P&lat@REFERENCE_LIST, P&lat@Units, P&lat@CodeMissingValue, P&lat@CLASS /] )
    delete( [/ P&lon@REFERENCE_LIST, P&lon@Units, P&lon@CodeMissingValue, P&lon@CLASS /] )

 ; write to file
 
    fsfx   = get_file_suffix(fili(nf),0)
    filnc  = fsfx@fBase +".nc"
    fpthnc = dirnc+filnc
    
    system("/bin/rm -f "+fpthnc)   ; remove any pre-existing file
    ncdf = addfile(fpthnc ,"c")  ; open output netCDF file

;===================================================================
; create global attributes of the file (optional)
;===================================================================
    fAtt               = True            ; assign file attributes
    fAtt@title         = "GPM: H5 to netCDF"      
    fAtt@source_file   = fili(nf)
    fAtt@Conventions   = "None"
    fAtt@creation_date = systemfunc ("date")
    fileattdef( ncdf, fAtt )            ; copy file attributes

;===================================================================
; make time an UNLIMITED dimension; recommended  for most applications
;===================================================================
    filedimdef(ncdf,"time",-1,True) 

;===================================================================
; output variables directly; NCL will call appropriate functions
; to write the meta data associated with each variable
;===================================================================
    ncdf->PRECIPITATION  = P
    ncdf->yyyymmdd       = yyyymmdd        
 end do
    
