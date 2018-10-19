;========== WORLD OCEAN ATLAS ==========================================
;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

                           ; aou(A), nitrate(n), o2sat (O), oxygen(o), 
                           ; phosphate(p), salinity(s), 
                           ; silicate(i), temperature(t)
  WOA_VAR = (/ "salinity", "s" , "..." /)   ; 3rd element is the units of the variable

;=======================================================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;============================================
; define WOA coordinate variables
;============================================

  depth   = (/   0,10,20,30,50,75,100,125,150,200,250,300,400,500 \
             , 600,700,800,900,1000,1100,1200,1300,1400,1500,1750 \
             ,2000,2500,3000,3500,4000,4500,5000,5500/)
  klev    = dimsizes(depth)
  depth!0 = "depth"
  depth@long_name = "depth"
  depth@units     = "m"

  nlat = 180
  lat  = latGlobeFo(nlat, "lat", "latitude", "degrees_north")

  mlon = 360
  lon  = lonGlobeFo(mlon, "lon", "longitude", "degrees_east")

;============================================
; Read multiple files
;============================================

  diri = "./"
  diro = "./netCDF/"
  nfil = 17

  do nf=0,nfil-1
     woad = WOA_VAR(0)
     fnam = WOA_VAR(1)+sprinti("%0.2i", nf)+"an1"
     system("wget ftp://ftp.nodc.noaa.gov/pub/WOA09/DATA/"+woad+"/grid/"+fnam+".gz")
     system("gzip -d "+fnam)
     data = asciiread(diri+fnam, (/klev,nlat,mlon/), "float")
     data@_FillValue = -99.9999

     data!0 = "depth"
     data!1 = "lat"
     data!2 = "lon"
     data&depth = depth
     data&lat   = lat
     data&lon   = lon
     data@long_name = woad+": "+fnam
     data@units     = WOA_VAR(2)

     filo  = fnam+".nc"
     patho = diro+filo
     system("/bin/rm -f "+patho)

     fout  = addfile(patho, "c")
                                          ; create global attributes of the file
     fAtt               = True            ; assign file attributes
     fAtt@title         = "WOA09: "+woad  
     fAtt@source_dir    =  "ftp://ftp.nodc.noaa.gov/pub/WOA09/DATA/"+woad+"/grid/"
     fAtt@source_file   =  fnam+".gz"
     fAtt@Conventions   = "None"   
     fAtt@creation_date = systemfunc ("date")        
     fileattdef( fout, fAtt )             ; create file attributes    

     fout->$woad$ = data

     if (nf.eq.0) then                    ; plot one to see if good
         pltType = "x11"
         pltName = "WOA09_"+fnam
         wks  = gsn_open_wks(pltType, pltName)
        ;gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap
         gsn_define_colormap(wks,"amwg") 

         res                      = True
         res@cnFillOn             = True                 ; turn on color
         res@cnFillMode           = "RasterFill"         ; turn on raster mode
         res@cnLinesOn            = False                ; turn off contour lines
         res@gsnSpreadColors      = True                 ; use full colormap
         res@gsnMaximize          = True
        ;res@lbOrientation        = "vertical"

         dlev                     = 0
         res@tiMainString         = "WOA09: "+woad+": depth="+depth(dlev)    
         plot = gsn_csm_contour_map_ce(wks,data(dlev,:,:),res)
     end if

     system("/bin/rm -f "+fnam+"*")
  end do
