;----------------------------------------------------------------------
; latlon_subset_2.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Using getind_latlon2d to extract a lat/lon region
;   - Subsetting a curvilinear grid
;   - Drawing a lat/lon grid using gsn_coordinates
;   - Attaching polymarkers to a map
;   - Zooming in on a particular area on a map
;----------------------------------------------------------------------
; The data file for this example can be downloaded from
; http://www.ncl.ucar.edu/Applications/Data/#grb
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;---Read data. Note that it is represented by 2D lat/lon arrays
  a     = addfile("ruc.grb","r")
  temp  = a->TMP_236_SPDY
  lat2d = a->gridlat_236
  lon2d = a->gridlon_236

;---Print information about file variables
  printVarSummary(temp)     ; 6 x 113 x 151
  printVarSummary(lat2d)    ; 113 x 151
  printVarSummary(lon2d)    ; 113 x 151
  printMinMax(lat2d,0)
  printMinMax(lon2d,0)

  wks = gsn_open_wks("png","latlon_subset")

;---Set some resources
  res                       = True

  res@gsnMaximize           = True     ; maximize plot in frame

  res@cnFillOn              = True     ; turn on contour fill
  res@cnLinesOn             = False    ; turn off contour lines
  res@cnLineLabelsOn        = False    ; turn off contour line labels
  res@gsnAddCyclic          = False    ; don't add longitude cyclic point

  res@sfYArray              = lat2d    ; this will help NCL plot data
  res@sfXArray              = lon2d    ; correctly over the map

  res@mpMinLatF             = min(lat2d)   ; zoom in on lat/lon area
  res@mpMaxLatF             = max(lat2d)
  res@mpMinLonF             = min(lon2d)
  res@mpMaxLonF             = max(lon2d)
  res@mpCenterLonF          = (res@mpMinLonF + res@mpMaxLonF) / 2.

  res@mpDataBaseVersion     = "MediumRes"    ; better map resolution
  res@mpOutlineBoundarySets = "USStates"
  res@pmTickMarkDisplayMode = "Always"       ; better looking tickmarks

;---Create filled contour plot over a map
  res@tiMainString          = "Plotting full range of data"
  res@pmTitleZone           = 4   ; move title closer to plot
  plot = gsn_csm_contour_map(wks,temp(0,:,:),res)

;----------------------------------------------------------------------
; Zoom in on New Mexico and Colorado by using getind_latlon2d to
; retrieve closest index values to the given lat/lon box that encloses
; these two states.
;
; You cannot use "{" and "}" for coordinate subscripting, because
; lat2d and lon2d are not 1D coordinate arrays.
;----------------------------------------------------------------------
  lat_min =   31
  lat_max =   42
  lon_min = -110
  lon_max = -102
  ij      = getind_latlon2d(lat2d,lon2d,(/lat_min,lat_max/),(/lon_min,lon_max/))

;---Store to local variables for better code readability
  ilat1 = ij(0,0)
  ilat2 = ij(1,0)
  ilon1 = ij(0,1)
  ilon2 = ij(1,1)

;---Subscript variables using these index values
  temp_sub  = temp(:,ilat1:ilat2,ilon1:ilon2)     ; 6 x 30 x 21
  lat2d_sub = lat2d(ilat1:ilat2,ilon1:ilon2)      ; 30 x 21
  lon2d_sub = lon2d(ilat1:ilat2,ilon1:ilon2)      ; 30 x 21

;---Print information about the new variables
  printVarSummary(temp_sub)
  printVarSummary(lat2d_sub)
  printVarSummary(lon2d_sub)
  printMinMax(lat2d_sub,0)
  printMinMax(lon2d_sub,0)

;---Plot this "zoomed in data"
  res@sfYArray          := lat2d_sub
  res@sfXArray          := lon2d_sub

; Leaving this commented so you can more easily see the subsetted data.
;  res@mpMinLatF         = min(lat2d_sub)
;  res@mpMaxLatF         = max(lat2d_sub)
;  res@mpMinLonF         = min(lon2d_sub)
;  res@mpMaxLonF         = max(lon2d_sub)
;  res@mpCenterLonF      = (res@mpMinLonF + res@mpMaxLonF) / 2.

  res@tiMainString          = "Plotting lat/lon subset of data"
  res@gsnCenterString       = "getind_latlon2d"
  plot = gsn_csm_contour_map(wks,temp_sub(0,:,:),res)

;---Now zoom in on map and add some primitives so to see the grid and lat/lon points.
  res@gsnDraw           = False 
  res@gsnFrame          = False
  res@mpMinLatF         = min(lat2d_sub)-2
  res@mpMaxLatF         = max(lat2d_sub)+2
  res@mpMinLonF         = min(lon2d_sub)-2
  res@mpMaxLonF         = max(lon2d_sub)+2
  res@mpCenterLonF      = (res@mpMinLonF + res@mpMaxLonF) / 2.
  plot = gsn_csm_contour_map(wks,temp_sub(0,:,:),res)

;---Attach lat/lon grid lines of subsetted data.
  gsres                  = True
  gsres@gsnCoordsLat     = lat2d_sub
  gsres@gsnCoordsLon     = lon2d_sub
  gsres@gsnCoordsAsLines = True
  gsres@gsnCoordsAttach  = True
  gsn_coordinates(wks,plot,temp_sub(0,:,:),gsres)

;---Attach two markers showing two lat,lon corners of interest
  mkres               = True
  mkres@gsMarkerIndex = 16     ; filled dot
  mkres@gsMarkerColor = "brown"
  mkres@gsMarkerSizeF = 5
  mkid = gsn_add_polymarker(wks,plot,(/lon_min,lon_max/),(/lat_min,lat_max/),mkres)

;---Drawing the plot will draw the attached lines and markers.
  draw(plot)
  frame(wks)

end

