;================================================
;  topo_6.ncl
;================================================
; Concepts illustrated:
;   - Drawing a topographic map of Poland using 1' data
;   - Zooming in on a topographic map
;   - Drawing topographic data using a custom color map read from a file
;   - Using "MeshFill" for faster contouring
;   - Using functions for cleaner code
;   - Using the "List" type to return multiple variables from a function
;   - Using shapefile data to draw outlines of Poland
;----------------------------------------------------------------------
; This script draws data from a 1' topo grid downloaded from:
;
; http://www.ngdc.noaa.gov/mgg/global/relief/ETOPO1/data/bedrock/cell_registered/netcdf/
;
; A rather colorful palette and set of contour levels suggested for
; Poland was downloaded from this website:
;
;    http://netgis.geo.uw.edu.pl/srtm/wizualizacja.shtml
;
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;----------------------------------------------------------------------
; This function reads in a color table and levels provided by:
;    http://netgis.geo.uw.edu.pl/srtm/wizualizacja.shtml
;
; Since both levels and a color map are returned by this function,
; we use the special List type to return both variables.
;----------------------------------------------------------------------
undef("earth_model_color_map")
function earth_model_color_map()
local lines, nlines
begin
  lines  = asciiread("Poland_map_and_levels.txt",-1,"string")
  nlines = dimsizes(lines)

  levels = tofloat(str_get_field(lines,1,":"))
  cmap   = new((/2+nlines,3/),float)

  cmap(0,:)   = (/1.,1.,1./)
  cmap(1,:)   = (/0.,0.,0./)
  cmap(2::,0) = tofloat(str_get_field(lines,2,":"))/255.
  cmap(2::,1) = tofloat(str_get_field(lines,3,":"))/255.
  cmap(2::,2) = tofloat(str_get_field(lines,4,":"))/255.
  return([/cmap,levels/])
end

;----------------------------------------------------------------------
; This function creates a topo map by reading a NetCDF file
; contain topographic data, and drawing filled contours.
;
; The min/max lat/lon values are provided so we can zoom in on
; the global grid.  If you try to plot the whole grid, it can
; be very slow!
;----------------------------------------------------------------------
undef("draw_topo_map")
procedure draw_topo_map(wks,levels,cmap,minlat,maxlat,minlon,maxlon)
local topo_file, a, elev, res
begin
;---Read data from a 1' file.
  topo_file = "ETOPO1_Bed_c_gmt4.grd.nc"
  a         = addfile(topo_file,"r")
  elev      = a->z({minlat:maxlat},{minlon:maxlon})

;---Set some resources
  res                   = True

  res@gsnMaximize       = True     ; maximize plot in frame
  res@gsnDraw           = False
  res@gsnFrame          = False

  res@cnFillOn          = True     ; turn on contour fill
  res@cnFillPalette     = cmap(2:,:)     ; set color map
  res@cnLinesOn         = False    ; turn off contour lines
  res@cnLineLabelsOn    = False    ; turn off line labels
  res@cnInfoLabelOn     = False    ; turn off info label

;
; If you zoom in on the grid via coordinate subscripting above, 
; it doesn't take as long to draw. Hence, we can use the 
; default AreaFill to draw the filled contours. Use MeshFill
; here if you want to look at a larger grid.
;
; res@cnFillMode        = "MeshFill"   ; don't need this, unless you look at larger area

;---Set contour levels read from file above.
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = levels
  res@gsnAddCyclic         = False

;---Zoom in on map
  res@mpMinLatF         = minlat
  res@mpMaxLatF         = maxlat
  res@mpMinLonF         = minlon
  res@mpMaxLonF         = maxlon
  res@mpCenterLonF      = (res@mpMinLonF + res@mpMaxLonF) / 2.

  res@mpFillOn          = False    ; turn off map fill
  res@mpOutlineOn       = False    ; will use shapefile outlines

  res@pmTickMarkDisplayMode = "Always"   ; turn on "nice" tickmark labels

  res@tiMainString          = topo_file
  res@pmTitleZone           = 4            ; Move main title down a little
  res@gsnLeftString         = "elevation"
  res@gsnRightString        = "m"

  plot = gsn_csm_contour_map(wks,elev,res)  ; Create the map, but don't draw it just yet

;---Attach Poland shapefile outlines, downloaded from gadm.org/country
  lnres                  = True
  lnres@gsLineThicknessF = 3.0

;---Attach shapefile outlines to plot.
  dum = gsn_add_shapefile_polylines(wks,plot,"POL_adm1.shp",lnres)

  draw(plot)
  frame(wks)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
  ret    = earth_model_color_map()   ; This function returns two variables as a List object
  cmap   = ret[0]
  levels = ret[1]

  wks = gsn_open_wks("png","topo")        ; send graphics to PNG file
; gsn_draw_colormap(wks)                  ; draw color map if desired

;---Draw a topographic map of Poland given the lat/lon limits desired.
  draw_topo_map(wks,levels,cmap,48.5,55,14,24.5)
end
