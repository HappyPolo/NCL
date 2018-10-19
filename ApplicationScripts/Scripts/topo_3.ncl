;================================================
;  topo_3.ncl
;================================================
; Concepts illustrated:
;   - Drawing a topographic map using 2' data
;   - Drawing topographic data using the OceanLakeLandSnow color map
;   - Using "MeshFill" for faster contouring
;   - Using functions for cleaner code
;   - Explicitly setting the fill colors for land and ocean
;----------------------------------------------------------------------
; This script draws the full 2' (now deprecated according to the
; website) topo grid downloaded from:
;
;    http://www.ngdc.noaa.gov/mgg/fliers/01mgg04.html
;
; Other topo files can be found at: http://www.ngdc.noaa.gov/mgg/topo/
;
; The 2' file takes about 109 seconds to run on a Mac using
; "MeshFill" (see cnFillMode below).
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;----------------------------------------------------------------------
; This procedure draws a global 2' topographic map read in from a 
; netCDF file.
;----------------------------------------------------------------------
undef("draw_topo_map")
procedure draw_topo_map(wks,minlat,maxlat,minlon,maxlon)
begin
  if(minlat.eq.-999) then
    minlat = -90
  end if
  if(maxlat.eq.-999) then
    maxlat = 90
  end if
  if(minlon.eq.-999) then
    minlon = -180
  end if
  if(maxlon.eq.-999) then
    maxlon = 180
  end if

;---Read data
  topo_file = "ETOPO2_GLOBAL_2_ELEVATION.nc"
  a         = addfile(topo_file,"r")
  elev      = short2flt(a->ELEV({minlat:maxlat},{minlon:maxlon}))
;
; Set all values below -100 to missing, hence removing all
; the ocean elevation values. The ocean will be filled in
; a light blue (see mpOceanFillColor below).
;
  elev = where(elev.lt.-100.,elev@_FillValue,elev)


  cmap = read_colormap_file("OceanLakeLandSnow") ; read color data

;---Set some resources for contouring and mapping
  res                    = True

  res@gsnMaximize        = True     ; maximize plot in frame

  res@cnFillOn           = True     ; turn on contour fill
  res@cnFillPalette      = cmap(2:,:) ; set color map
  res@cnLinesOn          = False    ; turn off contour lines
  res@cnLineLabelsOn     = False    ; turn off line labels
  res@cnInfoLabelOn      = False    ; turn off info label
  res@lbBoxLinesOn       = False    ; turn off labelbar box lines

  res@cnFillMode         = "MeshFill"   ; for faster draw

;---Pick "nice" contour levels
  mnmxint = nice_mnmxintvl( min(elev), max(elev), 18, False)
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       = 0.
  res@cnMaxLevelValF       = mnmxint(1)
  res@cnLevelSpacingF      = mnmxint(2)/8.   ; Increase the number of levels 
                                             ; by choosing a smaller spacing.
  res@gsnAddCyclic         = False           ; don't add longitude cyclic point

;---Zoom in on map
  res@mpMinLatF            = minlat
  res@mpMaxLatF            = maxlat
  res@mpMinLonF            = minlon
  res@mpMaxLonF            = maxlon
  res@mpCenterLonF         = (res@mpMinLonF + res@mpMaxLonF) / 2.

  res@mpFillOn             = True
  res@mpOceanFillColor     = "LightBlue"
  res@mpLandFillColor      = "transparent"
  res@mpFillDrawOrder      = "PostDraw"

  res@pmTickMarkDisplayMode       = "Always"
  res@mpGeophysicalLineThicknessF = 2

  plot = gsn_csm_contour_map(wks,elev,res)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
;---Open workstation and change color map
  wks = gsn_open_wks("png","topo")           ; send graphics to PNG file
;
; Increase memory for contours. This is necessary if you are 
; contouring a large grid. Otherwise, you might get this error:
;
;     fatal:ContourPlotDraw: Workspace reallocation would exceed maximum size 262144
;
  setvalues NhlGetWorkspaceObjectId() 
    "wsMaximumSize" : 100000000000000
  end setvalues
;
; Using -999 here indicates using default lat/lon range
;    (-90 to 90 and -180 to 180)
;
  draw_topo_map(wks,-999,-999,-999,-999)

;---An example of zooming in on the U.S.
;  draw_topo_map(wks,20,60,-130,-60)
end
