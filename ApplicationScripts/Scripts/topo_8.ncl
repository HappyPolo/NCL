;----------------------------------------------------------------------
; topo_8.ncl
;
; Concepts illustrated:
;   - Drawing a topographic map of Colorado using 2' data
;   - Zooming in on a topographic map
;   - Using shapefile data to draw rivers of Colorado
;   - Using "MeshFill" for faster contouring
;   - Using cnFillPalette to assign a color palette to contours
;----------------------------------------------------------------------
; The shapefile containing rivers of U.S was downloaded from
;   http://www.nws.noaa.gov/geodata/catalog/hydro/html/rivers.htm
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

;----------------------------------------------------------------------
; This function creates a topo map using a 2' topographic file read in
; from a NetCDF file, and map limits read in from a WRF output file.
;----------------------------------------------------------------------
undef("create_topo_map")
function create_topo_map(wks,minlat,maxlat,minlon,maxlon)
local topo_file, a, elev, res, cmap
begin
;---Subsetting the data is not necessary, but it will make plotting go much faster.
  topo_file = "ETOPO1_Bed_c_gmt4.grd.nc"
  a         = addfile(topo_file,"r")
  elev      = a->z({minlat:maxlat},{minlon:maxlon})

;---Will use this later for coloring the contours
  cmap = read_colormap_file("OceanLakeLandSnow")

;---Set some resources for contouring and mapping
  res                    = True

  res@gsnMaximize        = True         ; maximize plot in frame

  res@gsnDraw            = False
  res@gsnFrame           = False

  res@cnFillOn           = True         ; turn on contour fill
  res@cnFillMode         = "MeshFill"   ; for faster draw
  res@cnFillPalette      = cmap(2:,:)
 
  res@cnLinesOn          = False        ; turn off contour lines
  res@cnLineLabelsOn     = False        ; turn off line labels
  res@cnInfoLabelOn      = False        ; turn off info label
  res@lbBoxLinesOn       = False        ; turn off labelbar box lines
  res@lbTitleString      = "elevation (meters)"    ; add a labelbar title
  res@lbTitleFontHeightF = 0.015
  res@lbTitlePosition    = "Bottom"
  res@pmLabelBarOrthogonalPosF = 0.15

;---Pick "nice" contour levels
  mnmxint = nice_mnmxintvl( min(elev), max(elev), 18, False)
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       = mnmxint(0)
  res@cnMaxLevelValF       = mnmxint(1)
  res@cnLevelSpacingF      = mnmxint(2)/8.   ; Increase the number of levels 
                                             ; by choosing a smaller spacing.
;---Zoom in on map
  res@mpMinLatF            = minlat
  res@mpMaxLatF            = maxlat
  res@mpMinLonF            = minlon
  res@mpMaxLonF            = maxlon
  res@mpCenterLonF         = (res@mpMinLonF + res@mpMaxLonF) / 2.

  res@mpDataBaseVersion    = "MediumRes"

  res@mpFillOn             = False
  res@mpOutlineOn          = True
  res@mpOutlineBoundarySets = "AllBoundaries"
  res@gsnAddCyclic         = False           ; don't add longitude cyclic point

  res@tiMainString          = "Rivers of Colorado"
  res@gsnLeftString         = ""
  res@gsnRightString        = ""
  res@pmTickMarkDisplayMode = "Always"
  res@pmTitleZone           = 4              ; move main title down a little

;---Create map and return it.
  plot = gsn_csm_contour_map(wks,elev,res)
  return(plot)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
  wks = gsn_open_wks("png","topo")          ; send graphics to PNG file

;---Lat/lon limits for Colorado
  minlat   = 36.9
  maxlat   = 41.2
  minlon   = -109.1
  maxlon   = -102

;---Create topo map of Colorado
  topo_map = create_topo_map(wks,minlat,maxlat,minlon,maxlon)

;---Attach rivers from shapefile
  lnres                  = True
  lnres@gsLineColor      = "navyblue"
  lnres@gsFillColor      = "navyblue"
  lnres@gsLineThicknessF = 1.5

;---Setting lat/lon limits helps drawing go faster
  lnres@minlat           = minlat
  lnres@maxlat           = maxlat
  lnres@minlon           = minlon
  lnres@maxlon           = maxlon

  dum = gsn_add_shapefile_polylines(wks,topo_map,"rv14fe02.shp",lnres)

;---Drawing the topo map will also draw shapefile outlines
  draw(topo_map)
  frame(wks)
end
