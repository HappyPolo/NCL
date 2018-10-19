;*****************************************************
; mcsst_2.ncl
;
; Concepts illustrated:
;   - Plotting NAVO MCSST data
;   - Using fbindirread to read in fortran binary data
;   - Converting "byte" data to "float"
;   - Adding meta data (attributes and coordinates) to a variable
;   - Adding gray to an existing color map
;   - Spanning all but the last two colors in a color map for contour fill
;   - Drawing raster contours

;*****************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
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
  fname = "2001311d18N16.dat"
  tmp   = fbindirread(fname,ipar,(/1024,2048/),"byte")
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
  sst  = new((/1024,2048/),"float")            ; create float var
  sst  = tmp*xslope+yint                       ; convert to float
  delete(tmp)                                  ; delete unecessary array
;***************************************
; assign missing values. The original missing value was zero, but since it was
; not assigned in NCL, it was not recognized. The new missing values are 
; listed below. These will be changed later.
;***************************************
  if(ipar.eq.4)then
     sst@_FillValue = -20                    
  end if
  if(ipar.eq.3.or.ipar.eq.0)then
     sst@_FillValue = -3                     
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
;   get year and day from filename
;***************************************
  res   = True                          ; plot mods desired
  title = stringtochar(fname)           ; parse file name to get date
  year  = title(0:3)
  jday  = title(4:6)
  res@gsnCenterString = year+" "+jday   ; create center string
;***************************************
;   create plot
;***************************************
  wks  = gsn_open_wks("png","mcsst")    ; send graphics to PNG file


  res@cnFillOn             = True        ; turn on color
  res@cnFillPalette        = "BlGrYeOrReVi200" ; set color map
  res@cnLinesOn            = False       ; no contour lines
  res@cnFillDrawOrder      = "PreDraw"   ; draw contours before continents
  res@gsnMaximize          = True        ; maximize plot


; For a grid this size, it is better to use raster mode. It will be 
; significantly faster, and will not go over NCL's 16mb default plot size.
;
  res@cnFillMode           = "RasterFill"        ; turn on raster mode

  plot = gsn_csm_contour_map(wks,sst,res) ; contour the variable

end
