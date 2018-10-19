;----------------------------------------------------------------------
; dataonmap_grid_3.ncl
;
; Concepts illustrated:
;   - Plotting contours on a curvilinear grid
;   - Zooming in on a particular area on a map
;   - Using the special "lat2d" / "lon2d" attributes for plotting
;   - Drawing a variable's lat/lon grid using gsn_coordinates
;----------------------------------------------------------------------
; The data file for this example can be downloaded from
;    http://www.ncl.ucar.edu/Applications/Data/#grb
;
; wget http://www.ncl.ucar.edu/Applications/Data/ruc.grb
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;---Read data
  a    = addfile("ruc.grb","r")
  temp = a->TMP_236_SPDY   ; 6 x 113 x 151

  printVarSummary(temp)    ; note "coordinates" attribute
  printVarSummary(a->gridlat_236)
  printVarSummary(a->gridlon_236)

;---Read lat/lon arrays and attach as special "lat2d" / "lon2d" attributes
  temp@lat2d = a->gridlat_236    ; 113 x 151
  temp@lon2d = a->gridlon_236

;---Start the graphics
  wks = gsn_open_wks("png","dataonmap_grid")

;---Set some resources
  res                = True

  res@gsnDraw        = False    ; Don't draw plot or 
  res@gsnFrame       = False    ; advance frame

  res@gsnMaximize    = True     ; maximize plot in frame

  res@cnFillOn       = True     ; turn on contour fill
  res@cnLinesOn      = False    ; turn off contour lines
  res@cnLineLabelsOn = False    ; turn off contour line labels

  res@mpMinLatF      = min(temp@lat2d)   ; zoom in on lat/lon area
  res@mpMaxLatF      = max(temp@lat2d)
  res@mpMinLonF      = min(temp@lon2d)
  res@mpMaxLonF      = max(temp@lon2d)

  res@mpDataBaseVersion = "MediumRes"

  res@tiMainString   = "Lat/lon grid for curvilinear variable"

  plot = gsn_csm_contour_map(wks,temp(0,:,:),res)

;---Draw the lat/lon locations as grid lines
  lnres = True
  lnres@gsnCoordsAsLines = True
  gsn_coordinates(wks,plot,temp,lnres)
end