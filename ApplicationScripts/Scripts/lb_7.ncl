;================================================
;  lb_7.ncl
;================================================
; Concepts illustrated:
;   - Reading data from binary files
;   - Adding meta data (attributes and coordinates) to a variable
;   - Making the labelbar be vertical
;   - Using draw order resources to draw contours under land
;   - Formatting labelbar labels using "sprintf"
;   - Paneling two plots vertically on a page
;   - Using "getvalues" to retrieve contour levels
;================================================
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
  ipar  = 3
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
;   create plot
;***************************************
  wks  = gsn_open_wks("png","lb")        ; send graphics to PNG file 
;
; This will not be necessary in V6.1.0 and later. Named colors can
; be used without having to first add them to the color map.
;

  res                      = True        ; plot mods desired
  res@cnFillOn             = True        ; turn on color
  res@cnFillPalette        = "BlGrYeOrReVi200"  ; set color map
  res@cnLinesOn            = False       ; no contour lines
  res@cnFillDrawOrder      = "PreDraw"   ; draw contours before continents
  res@lbOrientation        = "vertical"  ; vertical label bar
  res@gsnFrame             = False       ; don't draw yet
  res@gsnDraw              = False       ; don't advance frame yet

; For a grid this size, it is better to use raster mode. It will be 
; significantly faster, and will not go over NCL's 16mb default plot size.
  res@cnFillMode           = "RasterFill"        ; turn on raster mode


  
  plot = new(2,graphic)                  ; create array to hold plots
 
  res@tiMainString         = "Default label bar label format"
  plot(0) = gsn_csm_contour_map_ce(wks,sst,res) ; contour the variable
;***************************************
;   adjust label bar
;***************************************
;
; Retrieve contour levels.
;
  getvalues plot@contour
    "cnLevels" : levels
  end getvalues

  res@lbLabelStrings       = sprintf("%3.1f",levels)   ; Format the labels
  res@tiMainString         = "label bar label format using sprintf"
  plot(1) = gsn_csm_contour_map_ce(wks,sst,res) ; contour the variable

  gsn_panel(wks,plot,(/2,1/),False)
end
