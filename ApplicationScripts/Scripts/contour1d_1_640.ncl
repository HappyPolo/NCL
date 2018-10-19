;*************************************************
; contour1d_1_640.ncl
;
; This script is identical to contour1d_1.ncl,
; except it uses the special lat1d/lon1d
; attributes added in V6.4.0 for contouring.
;*************************************************
;
; Concepts illustrated:
;   - Contouring one-dimensional X, Y, Z data
;   - Using the special "lat1d" / "lon1d" attributes for plotting
;   - Reading an ASCII file with several columns of data
;   - Drawing filled dots on a map
;   - Drawing filled contours over a Lambert Conformal map
;   - Turning off map fill
;   - Zooming in on a particular area on a Lambert Conformal map
;   - Reversing a color map
;   - Setting a nice stride for labelbar labels
;
; This example reads in station data represented by
; 1D arrays, and generates a filled contour plot.
;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;
; Data is stored in four columns:  station_name  lat  lon  pwv
; Read in each line as a string, and use "str_get_field" to 
; read in the fields of interest.
;
  fname = "pw.dat"
  lines = asciiread(fname,-1,"string")

;
; Use "str_get_field" to indicate which fields to read in. Each field
; is separated by spaces.
;
  pwv       = tofloat(str_get_field(lines(1:),4," "))
  pwv@lat1d = tofloat(str_get_field(lines(1:),2," "))     ; Recognition of the lat1d/lon1d attributes
  pwv@lon1d = tofloat(str_get_field(lines(1:),3," "))     ; were added in NCL V6.4.0

;
; This second file is not so tricky.  The 2D lat/lon data is sorted with 
; lat values first, and then lon values.
;
  nlat     = 70
  nlon     = 70
  latlon2d = asciiread("stn_latlon.dat",(/2,nlat,nlon/),"float")
  lat2d    = latlon2d(0,:,:)
  lon2d    = latlon2d(1,:,:)

  delete(lines)        ; Remove arrays we don't need anymore.
  delete(latlon2d)

  tlat1 = 60.0
  tlat2 = 30.0
  clon  = -98.5
  clat  =  36.3

  wks = gsn_open_wks("png","contour1d")  ; send graphics to PNG file

  cmap = read_colormap_file("WhViBlGrYeOrRe") ; read color map
  cmap = cmap(::-1,:)                         ; reverse the color map

  res                             = True

  res@cnFillPalette               = cmap(:90,:) ; set color map

  res@gsnMaximize                 = True


  res@cnLevelSelectionMode        = "ManualLevels"
  res@cnMinLevelValF              = 15         	; 15.25
  res@cnMaxLevelValF              = 50		; 49.75
  res@cnLevelSpacingF             = 1.125

  res@cnFillOn                    = True
  res@cnLinesOn                   = False

  res@lbBoxLinesOn                = False
  res@tiMainString                = "GPS PWV (18Z)"

;---This was required in NCL V6.3.0 and earlier.
;  res@sfXArray                    = lon
;  res@sfYArray                    = lat

  res@mpProjection                = "LambertConformal"
  res@mpLambertParallel1F         = tlat1
  res@mpLambertParallel2F         = tlat2
  res@mpLambertMeridianF          = clon

  res@mpLimitMode                 = "Corners"
  res@mpLeftCornerLatF            = lat2d(20,18)
  res@mpLeftCornerLonF            = lon2d(20,18)
  res@mpRightCornerLatF           = lat2d(58,52)
  res@mpRightCornerLonF           = lon2d(58,52)

  res@mpFillOn                    = False
  res@mpOutlineDrawOrder          = "PostDraw"
  res@mpFillDrawOrder             = "PreDraw"
  res@mpOutlineBoundarySets       = "GeophysicalAndUSStates"
  res@mpUSStateLineColor          = "Gray10"
  res@mpUSStateLineDashPattern    = 2

  res@pmTickMarkDisplayMode       = "Always"

  map = gsn_csm_contour_map(wks,pwv,res)

;---Add some markers to show where the original 1D points are.
  gsn_coordinates(wks,map,pwv,False)

end 
