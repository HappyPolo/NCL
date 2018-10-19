;***************************************************************
; cpc_uni_1.ncl
;
; Concepts illustrated:
;   - Read one or more little endian binary files containing CPC_UNI 0.50 data
;   - Add _FillValue attribute and then scale the values
;   - Adding meta data (attributes and coordinates [time, lat, lon])
;   - Explicitly setting contour levels
;   - Create a netCDF-3 file for each binary file
;     Option to create netCDF-4 for compression (HDF-5)
;   - Optionally, create a single file by concatenating all individual nc files
;     This is accomplished by invoking the netCDF Operator ' ncrcat' 
;     via NCL's system procedure. Further, all individual nc files are removed.
;**************************************************************
;  A GrADS ctl file is not needed or used. This is FYI only.
;
;  dset PRCP_CU_GAUGE_V1.0GLB_0.50deg.lnx.%y4%m2%d2.RT
;  options  little_endian template
;  title global daily analysis (grid box mean, the grid shown is the center of the grid box)
;  undef -999.0
;  xdef 720 linear    0.25 0.50
;  ydef 360  linear -89.75 0.50
;  zdef 1 linear 1 1
;  tdef 2050 linear 01jan2007 1dy
;  vars 2
;  rain     1  00 the grid analysis (0.1mm/day)
;  gnum     1  00 the number of stn
;  ENDVARS
;
;*********** Load Libraries ************************************
;; Libraries automatically loaded after NCL 6.2.1 onward
;; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
;; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
;; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
;**************************************************************
begin
;***************************************************************
; User Input
;***************************************************************
                                             ; INPUT
   diri   = "./"                             ; input directory
   fili   = systemfunc("cd "+diri+" ; ls PRCP_CU_GAUGE_V1.0GLB_0.50deg.lnx.*")
   nfili  = dimsizes(fili)
   print(fili)
   print("nfili="+nfili)
                                             ; OUTPUT
   netCDF = True                             ; generate one netCDF file for each binary file
   netCDF4= True                             ; default is the classic netCDF-3
   netCDF_ncrcat = False                     ; concatenate all individual nc file into onec
                                             ; delete individual nc file

   PLOT   = True                             ; generate plots

   if (netCDF) then
       ncDir   = "./"                        ; directory for netCDF output
       ncNameRoot = "cpc_cu_gauge_v1."       ; arbitrary name
       if (netCDF4) then
          ;setfileoption("nc","Format","NetCDF4Classic")  ; files > 2GB
           setfileoption("nc","Format","NetCDF4")         ; compression
       end if
   end if

   if (PLOT) then
       pltDir  = "./"                        ; directory for plot output
       pltType = "png"                       ; ps, eps, png, x11, pdf, ...
       pltNameRoot = "cpcuni"                ; arbitrary name
   end if

;***************************************************************
; End User Input
;***************************************************************
; Create spatial coordinate variables. See above GrADS ctl   
;***************************************************************
   scale     = 0.1                      ; see documentation or GrADS ctl
   ntim      = 1                        ; added for netCDF purposes only
   nlat      = 360   
   mlon      = 720 

   lat       = -89.75 + ispan(0,nlat-1,1)*0.50  
   lon       =   0.25 + ispan(0,mlon-1,1)*0.50 
                                        ;latitude
   lat!0     = "lat"
   lat&lat   =  lat
   lat@long_name = "latitude"
   lat@units     = "degrees_north"
                                        ;longitude
   lon!0     = "lon"
   lon&lon   =  lon
   lon@long_name = "longitude"
   lon@units     = "degrees_east"
     
   if (PLOT) then
       res                      = True        ; plot mods desired
       res@gsnMaximize          = True        ; make ps/eps/pdf large [no effect x11]
       
       res@cnFillOn             = True        ; turn on color fill
       res@cnLinesOn            = False       ; turn of contour lines
       res@cnFillMode           = "RasterFill"; Raster Mode
       res@cnLinesOn            = False       ; Turn off contour lines
       res@cnLineLabelsOn       = False       ; Turn off contour line labels

       res@cnLevelSelectionMode = "ExplicitLevels"              
       res@cnLevels             = (/0.1,1,5,10,15,20,25,50,75,100,150/) ; "mm/day" ; colors 
 
       res@mpCenterLonF         = 150.
       res@mpFillOn             = False

       colors  = (/"white","black","Snow"     \ ; "WhiteSmoke"  \          
                  ,"PaleTurquoise","PaleGreen","SeaGreen3" ,"Yellow"  \
                  ,"Orange","HotPink","Red","Violet", "Purple"        \
                  ,"burlywood3",  "Brown", "Black"/) 
   end if

;***************************************************************
; Read (little endian) binary file
; Possibly, write netCDF4 for compression
;***************************************************************
   setfileoption("bin","ReadByteOrder","LittleEndian")

  do nf=0,nfili-1
;***************************************************************
; Read each file. Parse the file name to extract date
;***************************************************************
     cpc      = fbindirread(diri+fili(nf),0, (/ntim,nlat,mlon/),"float")
     cpc@_FillValue = -999.0                           ; GrADS ctl: undef -999.0

     date_str = str_get_field(fili(nf), 5, ".")        ; yyyymmdd as a string

     if (scale.ne.1.0) then
         cpc = cpc*scale                               ; scale (if appropriate)
     end if

     if (nf.eq.0) then                                 ; save 1st and last date
          date_str_start = date_str                    ; save 1st date
     end if
     date_str_last = date_str                          ; last date
  
;***************************************************************
; Add meta data; prin min & max for each file
;***************************************************************
     cpc@_FillValue  = -999.0
     cpc@units       = "mm/day"
     cpc@long_name   = "CPC_UNI_precip"
  
     print(fili(nf)+": min="+sprintf("%6.3f", min(cpc)) \
                   +"  max="+sprintf("%6.3f", max(cpc)) )
;***************************************************************
; Associate the spatial coordinates with variable for plot & netCDF
;***************************************************************
  
     cpc!0    = "time"                  ; netCDF purposes only
     cpc!1    = "lat"                   ; name the dimensions
     cpc!2    = "lon"
     cpc&lat  =  lat                    ; create coordinate variable
     cpc&lon  =  lon                    ; create coordinate variable
  
;************************************************
; Create plot 
;************************************************
     if (PLOT) then
         pltName = pltNameRoot
         wks     = gsn_open_wks(pltType, pltDir+pltName)
         res@tiMainString         = fili
         res@cnFillPalette        = colors                  ; set color map
         res@gsnCenterString      = date_str
         plot = gsn_csm_contour_map(wks,cpc(0,:,:), res)    ;  nt=0
     end if    ; PLOT
    
     if (netCDF) then
         yyyy     = toint(str_get_cols(date_str,  0, 3))    ; yyyymmdd as integer 
         mm       = toint(str_get_cols(date_str,  4, 5))    ; mm
         dd       = toint(str_get_cols(date_str,  6, 7))    ; dd
         hh       = 12             ; center of 'mass' for the day
         mn       = 0
  
         tunits   = "hours since 1979-01-01 00:00:0.0"   ; arbitrary start time
         time    := cd_inv_calendar(yyyy,mm,dd,hh,mn,0d0,tunits, 0)
         time!0   = "time"
         cpc&time = time           ; associate 'time' with the variable
  
         date    := yyyy*10000 + mm*100 + dd
         date@units = "yyyymmdd"
         date!0   = "time"
         date&time=  time
  
         datesec := hh*3600                              ; match model 
         datesec@units = "current seconds of current date"
         datesec!0     = "time"
         datesec&time  =  time
         
         nline  = inttochar(10)
  
         globeAtt              = True
         globeAtt@title        = "CPC Unified 0.50 Daily"    

         if (netCDF4) then
             globeAtt@netCDF   = "netCDF-4"
         else
             globeAtt@netCDF   = "netCDF-3"
         end if
  
         globeAtt@ftp          = nline + \
         "http://ftp.cpc.ncep.noaa.gov/precip/CPC_UNI_PRCP/"
  
         globeAtt@description  = nline + \
         "https://climatedataguide.ucar.edu/guidance/cpc-unified-gauge-based-analysis-global-daily-precipitation"
  
         globeAtt@references   = "A list of references is at: " + nline + \
         "http://ftp.cpc.ncep.noaa.gov/precip/CPC_UNI_PRCP/GAUGE_GLB/DOCU/"
       
         globeAtt@creation_date= systemfunc ("date" )
       
         NCPATH = ncDir + ncNameRoot+date_str+ ".nc"
         system ("/bin/rm -f " +  NCPATH)    ; remove any pre-exist file 
         ncdf   = addfile(NCPATH,"c")     
  
         fileattdef(ncdf, globeAtt )         ; create the global [file] attributes
         filedimdef(ncdf,"time",-1,True)     ; make time and UNLIMITED dimension 
                                             ; recommended  for most applications
         ncdf->date    = date
         ncdf->datesec = datesec
         ncdf->CPC_UNI_PRECIP = cpc
     end if    ; netCDF

    end do     ; nf
  end

  if (netCDF_ncrcat) then
      nco = "ncrcat -h -O "+ncDir+"cpc_cu_gauge_v1.*nc"+" "+ncDir+"CPC_CU_GAUGE_V1."+date_str_start+"-"+date_str_last+".nc"
      print("nco="+nco)    ; eco command for verification that it was create correctly
      system(nco)

               ; remove individual daily files
      rm_cpc = "/bin/rm -f "+ncDir+"cpc_cu_gauge_v1.*nc"
      print("rm_cpc="+rm_cpc)
      system(rm_cpc)
  end if

 

 
 
