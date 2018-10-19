;***************************************************************************
; narr_3.ncl
;
;***************************************************************************
; [1] Read Grib file
; [2] Using Nearest neighbor function "triple2grid",
;     interpolate to a 2x2 grid
; [3] Plot sample level               [optional]
; [4] Create netCDF of 2x2 variable   [optional]
;**************************************************************
; Only one variable is done here. Howvever, this could readily
; be expanded to multiple variables.
;**************************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  fili   = "merged_AWIP32.1979010100.3D.NARR.grb"    ; input GRIB

  PLOT   = True
  if (PLOT) then
      pltType = "png"                                ; send graphics to PNG file
  end if

  netCDF = True 
  if (netCDF) then
      diro  = "./"                                      ; output directory
      filo  = "merged_AWIP32.1979010100.3D.NARR.2x2.nc" ; output netCDF file
  end if

;*******************************************
; open file and read in data
;*******************************************
  f       = addfile (fili, "r")
  lat2d   = f->gridlat_221                 ; (277,349)
  lon2d   = f->gridlon_221
  lev     = f->lv_ISBL0                    ; (29)

  print("lat2d: min="+min(lat2d)+"   max="+max(lat2d))
  print("lev:   min="+min(lev)  +"   max="+max(lev))
                                          
  x       = f->U_GRD_221_ISBL              ; (29,277,349)    
                                           ; (lv_ISBL0, gridx_221, gridy_221)
  printVarSummary(x)
  print(" min="+min(x)+"   max="+max(x))     

  dimx    = dimsizes( x )
  klev    = dimx(0)
  nlat    = dimx(1)
  mlon    = dimx(2)

;********************************************
; Before interpolating make all lon >= 0.0
; The reason is to get around the dateline longitude sign switch
; going from positive [eg 150E] to negative [eg -170]
;********************************************
; use the "where" function when version 4.3.0 is available
;********************************************

;;lon2d   = where(lon2d.ge.0, lon2d, lon2d+360.)   ; 4.3.0

  LON1D   = ndtooned(lon2d)
  ii      = ind(LON1D.lt.0.)
  LON1D(ii) = LON1D(ii) + 360.
  lon2d   = onedtond( LON1D, dimsizes(lon2d) )

  print(" min="+min(lat2d)+"   max="+max(lat2d))   ; min=0.89728   max=85.3335
  print(" min="+min(lon2d)+"   max="+max(lon2d))   ; min=148.64    max=357.433

;********************************************
; interpolate: specify region, set up new lat/lon grid that original data will be regridded to
;********************************************
  NLAT          = 44
  MLON          = 105

  dlat          = 2.
  lat           = ispan ( 0,NLAT-1,1 )*dlat          ; 0 to 86
  lat!0         = "lat"
  lat@units     = "degrees_north"
  lat&lat       = lat

  dlon          = 2.
  lon           = ispan ( 0,MLON-1,1 )*dlon + 148.   ; 148 to 358
  lon!0         = "lon"
  lon@units     = "degrees_east"
  lon&lon       = lon

  lev!0         = "lev"
;                           0    1    2
  xNEW           = new ((/klev,NLAT,MLON/), typeof(x), getFillValue(x))
  xNEW!0         = "lev"
  xNEW&lev       =  lev  
  xNEW!1         = "lat"
  xNEW&lat       =  lat
  xNEW!2         = "lon"
  xNEW&lon       =  lon
  xNEW@units     = x@units
  xNEW@long_name = x@long_name
  xNEW@time      = x@initial_time
                                  ; triple2grid can be slow
  do kl=0,klev-1
     xNEW(kl,:,:) = triple2grid(ndtooned(lon2d), ndtooned(lat2d), ndtooned( x(kl,:,:) ) \
                               ,lon, lat, False)
  end do
  printVarSummary(xNEW)

  if (PLOT) then  
;********************************************
; create plots
;********************************************
    wks  = gsn_open_wks ("png", "narr")        
    cmap = read_colormap_file("gui_default")        ; read color data
    
    res                        = True               ; plot mods desired for original grid
    res@cnFillOn               = True               ; color fill  
    res@cnFillPalette          = cmap(2:,:)         ; set color map
    res@cnLinesOn              = False              ; no contour lines
    res@cnLineLabelsOn         = False              ; no contour labels
    res@cnInfoLabelOn          = False              ; no contour info label
    
    res@mpGridAndLimbOn        = True
    res@mpGridLineDashPattern  = 2                  ; lat/lon lines as dashed
    res@pmTickMarkDisplayMode  = "Always"           ; turn on tickmarks
    res@tmXTOn                 = False
    
    res@gsnAddCyclic           = False              ; regional data
    res@gsnFrame               = False
    res@gsnDraw                = False

    res@mpLimitMode            = "Corners"            ; choose range of map
    res@mpLeftCornerLatF       = lat2d(0,0)
    res@mpLeftCornerLonF       = lon2d(0,0)
    res@mpRightCornerLatF      = lat2d(nlat-1,mlon-1)
    res@mpRightCornerLonF      = lon2d(nlat-1,mlon-1)

    res@tfDoNDCOverlay         = True
    res@mpProjection           = "LambertConformal" 
    res@mpLambertParallel1F    = lat2d@mpLambertParallel1F
    res@mpLambertParallel2F    = lat2d@mpLambertParallel2F
    res@mpLambertMeridianF     = lat2d@mpLambertMeridianF
    res@lbLabelBarOn           = False
                                                     ; cylindrical equidistant plot
    sres                        = True               ; plot mods desired for 2x2 array
    sres@cnFillOn               = True               ; color fill  
    sres@cnFillPalette          = cmap(2:,:)         ; set color map
    sres@cnLinesOn              = False              ; no contour lines
    sres@cnLineLabelsOn         = False              ; no contour labels
    sres@cnInfoLabelOn          = False              ; no contour info label

    sres@mpGridAndLimbOn        = True
    sres@mpGridLineDashPattern  = 10                 ; lat/lon lines as dashed
    sres@gsnAddCyclic           = False              ; not global

    sres@mpMinLatF              = min(lat)
    sres@mpMaxLatF              = max(lat)
    sres@mpMinLonF              = min(lon)
    sres@mpMaxLonF              = max(lon)
    sres@mpCenterLonF           = 270
    sres@mpFillOn               = False

    sres@gsnFrame               = False			 
    sres@gsnDraw                = False
    sres@lbLabelBarOn           = False
       	
    panres = True                                    ; set up panel resources
    panres@gsnPaperOrientation  = "portrait"         ; force portrait
    panres@gsnMaximize = True
    panres@gsnPanelLabelBar = True
    panres@gsnPanelYWhiteSpacePercent= 3.0

    plot = new(2,graphic) 

   ;do kl=0,klev-1              
    do kl=10,10                    ; plot only one level for example
       res@gsnCenterString         = "U@"+x&lv_ISBL0(kl) + "hPa"
       res@gsnLeftString           = "Original grid"
       plot(0) = gsn_csm_contour_map(wks,x(kl,:,:),res)     ; Draw original grid
       
       sres@gsnLeftString          = "Regridded to 2x2"
       sres@gsnCenterString        = "U@"+lev(kl) + "hPa"
       plot(1) = gsn_csm_contour_map(wks,xNEW(kl,:,:),sres)     ; Draw new 2x2 grid
       
       gsn_panel(wks,plot,(/2,1/),panres)
    end do
  end if


; **************************************************************
; Create netCDF: http://www.ncl.ucar.edu/Applications/method_2.shtml
; **************************************************************
  if (netCDF) then

      system ("'rm' -f "+diro+filo)
      ncdf  = addfile(diro+filo,"c")
; **************************************************************
; create global attributes of the file
; **************************************************************
     fAtt               = True            ; assign file attributes
     fAtt@title         = "NARR: Example 3: Interpolated to 2x2 grid"
     fAtt@source        = "The North American Regional Reanalysis (NARR) Project"
     fAtt@analysis_time = x@initial_time
     fAtt@input_file    = fili
     fAtt@Conventions   = "None"
     fAtt@creation_date = systemfunc ("date")

     fileattdef( ncdf, fAtt )            ; copy file attributes

; **************************************************************
; dimension names/sizes/attributes
; **************************************************************

     dimNames = (/ "lev","lat", "lon" /)
     dimSizes = (/  klev , NLAT,  MLON /)
     dimUnlim = (/ False,False,False/)
     filedimdef(ncdf,dimNames,dimSizes,dimUnlim)

     filevardef(ncdf, "lev"   ,typeof(lev)  , getvardims(lev))
     filevardef(ncdf, "lat"   ,typeof(lat)  , getvardims(lat))
     filevardef(ncdf, "lon"   ,typeof(lon)  , getvardims(lon))
     filevardef(ncdf, "U"     ,typeof(xNEW)  , getvardims(xNEW))

; **************************************************************
; Copy attributes associated with each variable to the file
; All attributes associated with each variable will be copied.
; **************************************************************
     filevarattdef(ncdf,"lev"  ,lev  )                   ; copy lev attributes
     filevarattdef(ncdf,"lat"  ,lat  )                   ; copy lat attributes
     filevarattdef(ncdf,"lon"  ,lon  )                   ; copy lon attributes
     filevarattdef(ncdf,"U"    ,xNEW )

; **************************************************************
; Write values to the file
; **************************************************************
     ncdf->lev    = (/ lev   /)
     ncdf->lat    = (/ lat   /)
     ncdf->lon    = (/ lon   /)
     ncdf->U      = (/ xNEW   /)
  end if

end
