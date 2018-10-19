;**************************************
; mcsst_4.ncl
;
; Concepts illustrated:
;   - Plotting NAVO MCSST data
;   - Creating a composite image of a night and day pass
;   - Using fbindirread to read in fortran binary data
;   - Calling a Fortran subroutine using a shared object created by WRAPIT
;   - Adding meta data (attributes and coordinates) to a variable
;   - Adding gray to an existing color map
;   - Spanning all but the last two colors in a color map for contour fill
;   - Converting "byte" data to "float"
;
;*****************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
external SUBS "./composit.so"
;***************************************
; type of data available on file
;***************************************
; ipar=0  Weekly Binned Sea Surface Temperature 
; ipar=1  Number of Points in Bin 
; ipar=2  Weekly Binned Sea Surface Temperature Anomaly 
; ipar=3  Interpolated Sea Surface Temperature 
; ipar=4  Interpolated Sea Surface Temperature Anomaly 
;***************************************
begin
  ipar  = 0
  fnameD = "2001311d18N16.dat"
  fnameN = "2001311n18N16.dat"
  
  tmpD   = fbindirread(fnameD,ipar,(/1024,2048/),"byte")
  tmpN   = fbindirread(fnameN,ipar,(/1024,2048/),"byte")
;***************************************
; convert to float and then change to true SST
;***************************************
  xslope = 0.15
  if(ipar.eq.4.or.ipar.eq.2)then               ; anom has different intercept
    yint = -20.0
  end if
  if(ipar.eq.3.or.ipar.eq.0)then
    yint = -3.0 
  end if
  sstN  = new((/1024,2048/),"float")            ; create float var
  sstD  = new((/1024,2048/),"float")            ; create float var
  sstN  = tmpN*xslope+yint                       ; convert to float
  sstD  = tmpD*xslope+yint                       ; convert to float
  delete(tmpN)                                  ; delete unecessary array
  delete(tmpD)                                  ; delete unecessary array
;***************************************
; assign missing values. The original missing value was zero, but since it was
; not assigned in NCL, it was not recognized. The new missing values are 
; listed below. These will be changed later.
;***************************************
  if(ipar.eq.4)then
     sstN@_FillValue = -20                    
     sstD@_FillValue = -20                    
  end if
  if(ipar.eq.3.or.ipar.eq.0)then
     sstN@_FillValue = -3                     
     sstD@_FillValue = -3                     
  end if
;***************************************
;   create coordinate variables
;***************************************
  nlat      = 1024
  dy        = 180./nlat
  lat       = (90. -(ispan(0,1023,1)*dy))-dy/2
  lat!0     = "lat"
  lat&lat   = lat
  lat@units = "degrees_north"

  nlon      = 2048
  dx        = 360./nlon
  lon       = (ispan(0,2047,1)*dx)+dx/2-180. ; note -180. added by sjm to align
  lon!0     = "lon"
  lon&lon   = lon
  lon@units = "degrees_east"
;***********************************************************************
;  composite day and night images
;***********************************************************************
  sst = new((/1024,2048/),"float",sstD@_FillValue)
  SUBS::composit(sstD,sstN,lat,lon,nlat,nlon,sstN@_FillValue,sst)
;***************************************
;   fill out the netCDF data model
;***************************************
  sst!0          = "lat"               ; name dimensions
  sst!1          = "lon"               ; ditto
  sst            = sst(::-1,:)         ; reverse lat orientation
  sst@long_name  = "NAVO MCSST"        ; assign long_name
  sst@units      = "deg C"             ; assign units
  sst&lat        = lat                 ; assign lat cv
  sst&lon        = lon	               ; assign lon cv
  sst@_FillValue = -999.               ; assign missing value   
;***************************************
;   fill out the netCDF data model
;***************************************
  sstN!0          = "lat"               ; name dimensions
  sstN!1          = "lon"               ; ditto
  sstN            = sstN(::-1,:)        ; reverse lat orientation
  sstN@long_name  = "NAVO MCSST"        ; assign long_name
  sstN@units      = "deg C"             ; assign units
  sstN&lat        = lat                 ; assign lat cv
  sstN&lon        = lon	                ; assign lon cv
  sstN@_FillValue = -999.               ; assign missing value   
;***************************************
;   fill out the netCDF data model
;***************************************
  sstD!0          = "lat"               ; name dimensions
  sstD!1          = "lon"               ; ditto
  sstD            = sstD(::-1,:)        ; reverse lat orientation
  sstD@long_name  = "NAVO MCSST"        ; assign long_name
  sstD@units      = "deg C"             ; assign units
  sstD&lat        = lat                 ; assign lat cv
  sstD&lon        = lon	                ; assign lon cv
  sstD@_FillValue = -999.               ; assign missing value   
;***************************************
;   get year and day from filename
;***************************************
  res   = True                          ; plot mods desired
  title = stringtochar(fnameN)           ; parse file name to get date
  year  = title(0:3)
  jday  = title(4:6)
  res@gsnCenterString = year+" "+jday   ; create center string
;***************************************
;   create plot
;***************************************
  wks  = gsn_open_wks("png","mcsst")    ; send graphics to PNG file

  res@cnFillOn             = True        ; turn on color
  res@cnFillPalette        = "BlGrYeOrReVi200"  ; set color map
  res@cnLinesOn            = False       ; no contour lines
  res@cnFillDrawOrder      = "PreDraw"   ; draw contours before continents
  res@lbOrientation        = "Vertical"  ; vertical label bar

  res@gsnDraw              = False       ; don't draw individual plots
  res@gsnFrame             = False       ; don't advance frame yet

; For a grid this size, it is better to use raster mode. It will be 
; significantly faster, and will not go over NCL's 16mb default plot size.
  res@cnFillMode           = "RasterFill"  ; turn on raster mode


  res@tiMainString         = "Day Pass"
  plot(0) = gsn_csm_contour_map(wks,sstD,res) ; contour day pass
  res@tiMainString         = "Night Pass"
  plot(1) = gsn_csm_contour_map(wks,sstN,res) ; contour night pass
  res@tiMainString         = "Composite"
  plot(2) = gsn_csm_contour_map(wks,sst,res)  ; contour composite

  pres                      = True
  pres@gsnMaximize          = True        ; maximize plot
  gsn_panel(wks,plot,(/3,1/),pres)
  

end
