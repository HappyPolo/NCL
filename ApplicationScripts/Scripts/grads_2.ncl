;  Grads control file
; ---------------
; dset snow.grd
; title snow depth  winter
; options sequential big_endian
; undef -9999.00               
; xdef 29 linear 20. 5.
; ydef 8 linear 35.  5.
; zdef 1 linear 1 1
; tdef 60 linear jan1936 1yr
; vars 1
; p 0 0 precipitation 
; endvars
; ---------------

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
begin
  
  PLOT  = True 
  NC    = True

  diri  = "./"
  fili  = "snow.grd"                      ; DSET
  fName = diri+fili       

  nlat  = 8                               ; YDEF
  mlon  = 29                              ; XDEF

  year  = 1936                            ; TDEF
  ntim  = 60                              ; time steps
  nmos  = 12
                                          ; not required
  time  = new (ntim, float  ,"No_FillValue") ; generate a "time" variable
  date  = new (ntim, integer,"No_FillValue") ; generate a "date" variable
  
  n     = -1
  do nmo=1,nmos
     YRM= year*10000 + nmo*100
     ndm= days_in_month(year, nmo)  
    do ndy=1,ndm  
       n = n+1
       time(n) = n     
       date(n) = YRM + ndy                ; YYYYMMDD
    end do
  end do
  time!0         = "time"
  time@long_name = "time"
  time@units     = "???"           ; "yyyy.fraction_of_year"
  time&time      = time

  date!0         = "time"
  date@long_name = "date"
  date@units     = "??????"
  date&time      = time
                                          ; generate lat/lon
  lon = ispan(0,mlon-1,1)*5. + 20.
  lon!0 = "lon"
  lon@long_name = "longitude"
  lon@units     = "degrees_east"

  lat = ispan(0,nlat-1,1)*5. +  5.
  lat!0 = "lat"
  lat@long_name = "latitude"
  lat@units     = "degrees_north"
 
                                          ; create an array to contain data
  UNDEF = -999.                           ; UNDEF
  x     = new ( (/ntim,nlat,mlon/), float, UNDEF)
  x!0   = "time"
  x!1   = "lat"
  x!2   = "lon"
  x&time=  time
  x&lat =  lat
  x&lon =  lon

  x@long_name = "Snow Depth"         ; VARS
  x@units     = "??"                 
                                    
 ;setfileoption("bin","ReadByteOrder","Native")       ; a033 default
 ;setfileoption("bin","ReadByteOrder","LittleEndian")
  setfileoption("bin","ReadByteOrder","BigEndian")
                                          ; read each record: store in x
  do nt=0,ntim-1                         ; the ::-1 changes the latitude order
     x(nt,:,:) = fbinrecread(fName, nt, (/nlat,mlon/), "float")
  end do

  printVarSummary(x)
  print ("min(x)="+min(x))
  print ("max(x)="+max(x))

  if (NC) then
      nline= inttochar(10)

      diro = "./"
      filo = fili + ".nc"
      system ("/bin/rm -f "+diro+filo)  ; remove any pre-existing file

      ncdf = addfile (diro+filo, "c")
     ;setfileoption(ncdf,"DefineMode",True)               ; a033 [most efficient]
      
      globeAtt         = 1      ; global [file] attributes
      globeAtt@title   = "Snow Depth"
      globeAtt@source  = fili 

      globeAtt@story   = nline + \
                         "An NCL user sent a Grads file and .ctl."+nline
     ;globeAtt@NCL     = nline + \
     ;                   "/fs/cgd/home0/shea/ncld/ncld2/ucla_bordoni/rdGrads.ncl_GPCP1"+nline
      globeAtt@creation_date= systemfunc ("date" ) 

      fileattdef( ncdf, globeAtt )
                                    
      dimNames = (/"time", "lat", "lon" /)  
      dimSizes = (/  -1  ,  nlat,  mlon /) 
      dimUnlim = (/ True , False, False /)   
      filedimdef(ncdf, dimNames  , dimSizes,  dimUnlim )

      filevardef   (ncdf, "time"  , typeof(time) , "time" )
      filevarattdef(ncdf, "time", time)
     
      filevardef   (ncdf, "lat", "float", "lat")
      filevarattdef(ncdf, "lat", lat)
     
      filevardef   (ncdf, "lon", "float", "lon")
      filevarattdef(ncdf, "lon", lon)
     
      filevardef   (ncdf, "date", typeof(date), "time")
      filevarattdef(ncdf, "date", date)
      
      filevardef(ncdf, "GPCP"  , typeof(x) , (/"time", "lat" , "lon"/) )
      filevarattdef(ncdf, "GPCP", x)

      ncdf->time   = (/ time /)
      ncdf->date   = (/ date /)
      ncdf->lat    = (/ lat /)
      ncdf->lon    = (/ lon /)
      ncdf->GPCP   = (/ x /) 
  end if

  if (PLOT) then
      wks    = gsn_open_wks("ps","GPCP_grads")      ; open a ps file
      colors = (/"white","black"             \    
                ,"azure1","beige","lavender" \
                ,"PaleGreen","SeaGreen3","LightYellow" \
                ,"Yellow","HotPink","Red", "Purple"/)      
      gsn_define_colormap(wks, colors)              ; generate new color map
    
      res = True
      res@gsnMaximize          = True               ; make large
      res@cnFillOn             = True               ; turn on color fill
      res@cnLinesOn            = False              ; turn off contour lines
      res@cnLineLabelsOn       = False              ; turn off line labels
      res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
      res@cnLevels             = (/ 0.5, 1.0, 3.0 \ ; set unequal contour levels
                                  , 5.0, 7.0,10.0 \
                                  ,15.0,25.0,50.0 /)
      res@mpFillOn             = False              ; turn off gray continents
      res@mpCenterLonF         = 180                ; Centers the plot at 180 
    
      x = mask(x, x.eq.0. , False)            
     
      do nt=0,1    ; ntim-1
         res@gsnCenterString      = date(nt)
         plot = gsn_csm_contour_map_ce(wks,x(nt,:,:),res)  
      end do

  end if

end
