;***************************************************************
; binning_1.ncl
;
; Concepts illustrated:
;   - Reading multiple files with data from MODIS satellite
;   - Binning and summing the data from each pass [swath]
;   - Averaging binned data
;   - Creating a netCDF file
;
;***************************************************************

;*****************Load Libraries ************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
     
;********************************************************************
; Utility functions to get (1) date information (2) facilitate netCDF 
;********************************************************************
function parseFileName ( fNam:string )
; parse the file names and extract data information
;           1         2
; 01234567890123456789012345678
; MYDATML2.A2005364.1820.005.nc
local onNam, n, output, tmp_c
begin
   nNam = dimsizes( fNam )

   if (nNam.eq.1) then
       output    = new( 4,integer,"No_FillValue")
       tmp_c     = stringtochar(fNam)
       
       output(0) = stringtointeger((/tmp_c(10:13)/))   ; YYYY 
       output(1) = stringtointeger((/tmp_c(14:16)/))   ; MM
       output(2) = stringtointeger((/tmp_c(18:19)/))   ; HH
       output(3) = stringtointeger((/tmp_c(20:21)/))   ; MN        
   else
       output = new( (/nNam,4/),integer,"No_FillValue")
       do n=0,nNam-1
          tmp_c       = stringtochar(fNam(n))       
          output(n,0) = stringtointeger((/tmp_c(10:13)/))   ; YYYY 
          output(n,1) = stringtointeger((/tmp_c(14:16)/))   ; MM
          output(n,2) = stringtointeger((/tmp_c(18:19)/))   ; HH
          output(n,3) = stringtointeger((/tmp_c(20:21)/))   ; MN        
       end do
   end if
   
   return (output)   
end
;---------------------------------------------------
function create3d (x[*][*]:numeric, time[*]:numeric)
; convert a 2-dimensional to a 3-dimensional variable
; with time as a coordinate variable.
local dimx, ntim, nlat, mlon, x3d
begin
  dimx    = dimsizes(x)

  ntim    = dimsizes(time)
  nlat    = dimx(0)
  mlon    = dimx(1)
          ; perform expansion
  x3d     = conform_dims( (/ntim,nlat,mlon/), x, (/1,2/))
  copy_VarAtts(x, x3d)
  x3d!0   = "time"
  x3d&time=  time
  copy_VarCoords(x, x3d(0,:,:) )
  return(x3d)
end

;**************************************************************
;                     MAIN
;**************************************************************
begin
  vNam  = "Cloud_Water_Path_1621"    
  vNam  = "Cloud_Top_Temperature"    

  PLOT  = True
  netCDF= True

;*****************************************************************
; binned grid definition     
; The grid must be constant spacing in lat and in lon.
; The spacing in the lat and lon directions may be different.
; so: 2x2, 3x5, etc
;*****************************************************************

  nlat  = 72                       ; grid coordinates
  mlon  = 144      
  lat   = latGlobeFo(nlat,"lat","latitude","degrees_north")
  lat   = lat(::-1)         ; North to South
  lon   = lonGlobeFo(mlon,"lon","longitude","degrees_east")
  lon   = (/ lon - 180. /)  ; subtract 180 from all values 
  lon&lon = lon             ; update coordinates

;*****************************************************************
; Variables to hold binned quantities
;*****************************************************************
  GBIN  = new ( (/nlat,mlon/), float ) 
  GKNT  = new ( (/nlat,mlon/), integer ) 

  GBIN  = 0.0                      ; initialization
  GKNT  = 0

;*****************************************************************
; File info                          
;*****************************************************************

  diri = "./"
  fili = systemfunc("cd "+diri+" ; ls MYDATML2.A2005364*005.nc")
  nfil = dimsizes( fili )
  print("nfil="+nfil)  
 
;*****************************************************************
; Loop over the files: Sum the quantities
;*****************************************************************
  tStrt = systemfunc("date")         ; time the loop (wall clock)

  do nf=0,nfil-1
     print(nf+"   "+fili(nf))
     f       = addfile(diri+fili(nf), "r")
                                     ; read data
     lat2d   = short2flt_hdf( f->Latitude )
     lon2d   = short2flt_hdf( f->Longitude)
     x       = short2flt_hdf( f->$vNam$   )
     nx      = product(dimsizes(x))

     bin_sum(GBIN,GKNT,lon,lat   \
            ,ndtooned(lon2d), ndtooned(lat2d),ndtooned(x) )

     delete(  x  )                   ; size may change
     delete(lat2d)  
     delete(lon2d)
  end do
  
  wallClockElapseTime(tStrt, "Main Sum Loop", 0)

;*****************************************************************
; Perform averaging
;*****************************************************************
                                    ; avoid division by 0.0
  GKNT     = where(GKNT.eq.0 , GKNT@_FillValue, GKNT)

  GBIN     = GBIN/GKNT
 
  GBIN!0   = "lat"
  GBIN!1   = "lon"
  GBIN&lat =  lat
  GBIN&lon =  lon

  copy_VarCoords(GBIN, GKNT)        ; copy coords

  if (isfilevaratt(f, vNam, "long_name")) then
      GBIN@long_name = "BINNED: "+vNam
      GKNT@long_name = "BINNED COUNT: "+vNam
  end if

  if (isfilevaratt(f, vNam, "units")) then
      GBIN@units     = f->$vNam$@units
  end if

;*****************************************************************
; time/date
;*****************************************************************
 ydhm = parseFileName( fili(0) ) 

 yyyy    = ydhm(0)
 ddd     = ydhm(1)
 hh      = ydhm(2)
 mn      = ydhm(3)

 yyyyddd = yyyy*1000 + ddd
 monday  = monthday(yyyy, ddd) 
 month   = monday/100
 day     = monday - month*100          ; day of month

;*****************************************************************
; netCDF  
;*****************************************************************
  if (netCDF) then
      sec     = 0.0
                                       ; COARDS/CF time
      tunits  = "hours since 1990-1-1 00:00:0.0"
      time    = cd_inv_calendar(yyyy,month,day,hh,mn,sec,tunits, 0)
      time!0  = "time"
      time@units = tunits 
                                       ; gregorian date
      date    = yyyy*10000 + month*100 + day
      date!0  = "time"
      date@units = "yyyymmdd"

      diro    = "./"                   ; output directory
      filo    = "ModisBin_"+yyyyddd+"_bin_sum"    ; output file name
      fout    = diro+filo+".nc"

      system("/bin/rm -f "+fout)       ; remove any pre-existing file
      ncdf    = addfile(fout ,"c")     ; open output netCDF file

    ;================================================================
    ; create global attributes of the file (not required)
    ;================================================================
      fAtt               = True        ; assign file attributes
      fAtt@title         = "MODIS Swath Binned: " + yyyyddd
      fAtt@source_file   = "MYDATML2.A"+yyyyddd+".hhmn.005.nc"
     ;fAtt@Conventions   = "CF 1.0"   
      fAtt@creation_date = systemfunc ("date")        
      fileattdef( ncdf, fAtt )         ; copy file attributes    

                                       ; recommended (generally) 
      filedimdef(ncdf,"time",-1,True)  ; make time UNLIMITED dimension 
      ncdf->time     = time
      ncdf->date     = date

      ncdf->$vNam$   = create3d( GBIN, time)               
      kNam = vNam+"_knt"
      ncdf->$kNam$   = create3d( GKNT, time)               
  end if

;*****************************************************************
; PLOTS   
;*****************************************************************

  if (PLOT) then
      plot    = new ( 2, "graphic")

      ydhm    = parseFileName( fili(0) ) 
     
     ; wks    = gsn_open_wks("ps" ,"ModisBin_"+yyyyddd+"_bin_sum")
      wks     = gsn_open_wks("png", "binning"); send graphics to PNG file
      
      res                     = True          ; Use plot options
      res@gsnDraw             = False
      res@gsnFrame            = False

      res@cnFillOn            = True          ; Turn on color fill
      res@cnFillPalette       = "BlAqGrYeOrReVi200"  ; set color map
      res@cnFillMode          = "RasterFill"  ; Turn on raster color
      res@cnLinesOn           = False         ; Turn off contourn lines

      res@mpCenterLonF        = 180           ; set map center at 180
      res@lbOrientation       = "vertical"

      plot(0) = gsn_csm_contour_map(wks,GBIN, res)
      plot(1) = gsn_csm_contour_map(wks,GKNT, res)

;*****************************************************************
; Panel   
;*****************************************************************

      resP                     = True
      resP@txString            = "MODIS: MYD06_L2: "+yyyy+"/"+month+"/"+day
      res@gsnMaximize          = True          ; max size 
      resP@gsnPaperOrientation = "portrait"
      gsn_panel(wks,plot,(/2,1/),    resP)

  end if

end
