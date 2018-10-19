;----------------------------------------------------------------------
; dataonmap_3_sf.ncl
;
; Concepts illustrated:
;   - Plotting contours on a curvilinear grid
;   - Zooming in on a particular area on a map
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
  lat  = a->gridlat_236    ; 113 x 151
  lon  = a->gridlon_236    ; 113 x 151

  printVarSummary(temp)    ; note "coordinates" attribute

  wks = gsn_open_wks("png","dataonmap")

;---Set some resources
  res                = True

  res@gsnMaximize    = True     ; maximize plot in frame

  res@sfXArray       = lon
  res@sfYArray       = lat
  res@gsnAddCyclic   = False    ; for regional data, you must set this
                                ; to avoid lon cyclic point being added

  res@cnFillOn       = True     ; turn on contour fill
  res@cnLinesOn      = False    ; turn off contour lines
  res@cnLineLabelsOn = False    ; turn off contour line labels

  res@mpMinLatF      = min(lat)   ; zoom in on lat/lon area
  res@mpMaxLatF      = max(lat)
  res@mpMinLonF      = min(lon)
  res@mpMaxLonF      = max(lon)

  res@tiMainString   = "Plotting data on curvilinear grid (zoomed in)"

  plot = gsn_csm_contour_map(wks,temp(0,:,:),res)
end