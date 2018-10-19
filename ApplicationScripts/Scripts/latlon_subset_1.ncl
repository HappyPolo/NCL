;----------------------------------------------------------------------
; latlon_subset_1.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Using coordinate subscripting to extract a lat/lon region
;   - Subsetting a rectilinear grid
;   - Drawing a lat/lon grid using gsn_coordinates
;   - Attaching polymarkers to a map
;   - Using lonFlip to convert 0 to 360 longitudes to -180 to 180
;   - Zooming in on a particular area on a map
;----------------------------------------------------------------------
; The data file for this example can be downloaded from
; http://www.ncl.ucar.edu/Applications/Data/#cdf
;
; For an example of subsetting data represented by 2D lat/lon arrays,
; see latlon_subset_2.ncl and the "getind_latlon2d" function.
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;---Read in netCDF file.
  a  = addfile("ts_Amon_CESM1-CAM5_historical_r1i1p1_185001-200512.nc","r")
  ts = a->ts(0,:,:)

;---Print information about ts
  printVarSummary(ts)       ; 192 x 288

  wks = gsn_open_wks("png","latlon_subset")

;---Set some resources
  res                       = True

  res@gsnMaximize           = True     ; maximize plot in frame

  res@cnFillOn              = True     ; turn on contour fill
  res@cnLinesOn             = False    ; turn off contour lines
  res@cnLineLabelsOn        = False    ; turn off contour line labels
  res@tiMainString          = "Plotting full range of data"

;---Draw plot of full data
  plot = gsn_csm_contour_map(wks,ts,res)

;----------------------------------------------------------------------
; Zoom in on area of interest using coordinate subscripting 
; via special syntax "{" and "}". You can only use this syntax 
; when your data is represented by one-dimensional coordinate arrays.
; (see "printVarSummary" output)
;----------------------------------------------------------------------
  lat_min = 20
  lat_max = 50
  lon_min = 60
  lon_max = 120
  ts_sub  = ts({lat_min:lat_max},{lon_min:lon_max})
  printVarSummary(ts_sub)        ; 32 x 49

  res@tiMainString          = "Plotting lat/lon subset of data"
  res@pmTitleZone           = 4          ; Moves title down
  res@gsnAddCyclic          = False      ; This is very important!

;---Draw plot of subsetted data
  plot = gsn_csm_contour_map(wks,ts_sub,res)

;---Zoom in on map and add some lines and markers to see the grid and lat/lon points.
  res@gsnDraw               = False 
  res@gsnFrame              = False
  res@mpMinLatF             = min(ts_sub&lat)-2
  res@mpMaxLatF             = max(ts_sub&lat)+2
  res@mpMinLonF             = min(ts_sub&lon)-2
  res@mpMaxLonF             = max(ts_sub&lon)+2
  res@mpCenterLonF          = (res@mpMinLonF + res@mpMaxLonF) / 2.
  res@pmTickMarkDisplayMode = "Always"  ; nicer map tickmarks

  plot = gsn_csm_contour_map(wks,ts_sub,res)

;---Attach lat/lon grid lines of subsetted data.
  gsres                  = True
  gsres@gsnCoordsAsLines = True
  gsres@gsnCoordsAttach  = True
  gsn_coordinates(wks,plot,ts_sub,gsres)

;---Attach two markers showing two lat,lon corners of interest
  mkres               = True
  mkres@gsMarkerIndex = 16     ; filled dot
  mkres@gsMarkerColor = "black"
  mkres@gsMarkerSizeF = 15
  mkid1 = gsn_add_polymarker(wks,plot,(/lon_min,lon_max/),(/lat_min,lat_max/),mkres)

;---Drawing the plot will draw the attached lines and markers.
  draw(plot)
  frame(wks)

;---To subscript with longitude values < 0, you must "flip" the longitudes
  ts = lonFlip(ts)     ; convert from 0:360 to -180:180

;---Print information about ts
  printVarSummary(ts)       ; lon: [-180..178.75]

  lat_min =   20
  lat_max =   60
  lon_min = -130      ; Now we can subscript using 
  lon_max =  -60      ; negative longitudes
  ts_sub  := ts({lat_min:lat_max},{lon_min:lon_max})
  printVarSummary(ts_sub)        ; 43 x 57

;---Recalculate values for new min/max lon/lon and create new plot 
  res@mpMinLatF         = min(ts_sub&lat)-2
  res@mpMaxLatF         = max(ts_sub&lat)+2
  res@mpMinLonF         = min(ts_sub&lon)-2
  res@mpMaxLonF         = max(ts_sub&lon)+2
  res@mpCenterLonF      = (res@mpMinLonF + res@mpMaxLonF) / 2.

  plot = gsn_csm_contour_map(wks,ts_sub,res)
  gsn_coordinates(wks,plot,ts_sub,gsres)
  mkid2 = gsn_add_polymarker(wks,plot,(/lon_min,lon_max/),(/lat_min,lat_max/),mkres)
  draw(plot)
  frame(wks)

end

