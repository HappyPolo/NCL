;----------------------------------------------------------------------
; contour1d_old_1.ncl
;----------------------------------------------------------------------
;
; Concepts illustrated:
;   - Reading an ASCII file with several columns of data
;   - Contouring one-dimensional X, Y, Z data
;   - Drawing lat/lon locations as filled dots using gsn_coordinates
;   - Comparing smooth contours with raster contours
;----------------------------------------------------------------------
; This example reads in station data represented by 1D arrays,
; 1D arrays, and generates a filled contour plot over a map.
;
; It uses an older method (pre NCL V6.4.0) for specifying the
; lat/lon information via sfXArray and sfYArray. This method
; will always work, but you can also use a newer method
; of attaching special lat1d/lon1d attributes to your data. 
; See contour1d_1.ncl.
;----------------------------------------------------------------------
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
; Use "str_get_field" to indicate which fields to read in.
; Each field is separated by an arbitrary number of spaces.
;
  pwv = tofloat(str_get_field(lines(1:),4," "))
  lat = tofloat(str_get_field(lines(1:),2," "))
  lon = tofloat(str_get_field(lines(1:),3," "))

  wks = gsn_open_wks("png","contour1d_old")    ; send graphics to PNG file

  res                             = True
  res@gsnMaximize                 = True
  res@gsnFrame                    = False   ; Want to draw markers later.
  res@gsnDraw                     = False

  res@cnLevelSelectionMode        = "ManualLevels"
  res@cnMinLevelValF              = 15         	; 15.25
  res@cnMaxLevelValF              = 50		; 49.75
  res@cnLevelSpacingF             = 1.125

  res@cnFillOn                    = True
  res@cnLinesOn                   = False

  res@lbBoxLinesOn                = False
;
; These resources are required if plotting 1D data over a map
; In newer versions of NCL, you can use the special lat1d/lon1d
; attributes. See contour1d_1.ncl
;
  res@sfXArray                    = lon
  res@sfYArray                    = lat

;---Zoom in on map area of interest
  res@mpMinLatF                   = min(lat)-.5
  res@mpMinLonF                   = min(lon)-.5
  res@mpMaxLatF                   = max(lat)+.5
  res@mpMaxLonF                   = max(lon)+.5

  res@mpFillOn                    = False
  res@pmTickMarkDisplayMode       = "Always"   ; nicer map tickmarks

;---Create the plot; it won't get drawn because gsnFrame was set to False.
  res@cnFillMode   = "AreaFill"    ; "AreaFill" is the default
  res@tiMainString = "GPS PWV (18Z) (smooth contours)"
  plot = gsn_csm_contour_map(wks,pwv,res)

;---Add some markers to show where the original 1D points are.
  mkres               = True
  mkres@gsMarkerIndex = 16    ; Filled dots
  mkres@gsnCoordsLat  = lat
  mkres@gsnCoordsLon  = lon
  gsn_coordinates(wks,plot,pwv,mkres)

;---Create the plot again using raster contours
  res@cnFillMode   = "RasterFill"
  res@tiMainString = "GPS PWV (18Z) (raster contours)"
  plot = gsn_csm_contour_map(wks,pwv,res)
  gsn_coordinates(wks,plot,pwv,mkres)

end 
