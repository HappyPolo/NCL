;----------------------------------------------------------------------
; shapefiles_15.ncl
;
; Concepts illustrated:
;   - Comparing Colorado county NCL map outlines to shapefile map outlines
;   - Zooming in on Colorado on a cylindrical equidistant map
;   - Using functions for cleaner code
;   - Changing the size of a PNG image
;   - Drawing partially transparent markers
;----------------------------------------------------------------------
; This example shows the difference between map outlines in NCL and
; map outlines added from a shapefile.
;
; The purpose of this example is to illustrate how to draw shapefile
; outlines instead of NCL's map outlines.
;
; IMPORTANT NOTE: in NCL V6.4.0, the USA/Colorado counties were updated
; to include the county of Broomfield and updated Denver area counties. 
;
; You will not see the updates if you run this script with NCL V6.3.0 
; or earlier.
;
; The USA_adm files were downloaded from gadm.org/country.
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"


;----------------------------------------------------------------------
; This function creates a cylindrical equidistant map of Colorado.
;----------------------------------------------------------------------
function create_colorado_map(wks,res,draw_ncl_outlines)
local a, mpres
begin
  mpres                       = res

  mpres@gsnMaximize           = True
  mpres@gsnPaperOrientation   = "portrait"

  mpres@gsnDraw               = False
  mpres@gsnFrame              = False

  mpres@mpFillOn              = False  

;---Turn on fancier tickmark labels.
  mpres@pmTickMarkDisplayMode = "Always"
  mpres@tmXBLabelFontHeightF  = 0.008      ; smaller tickmark labels

;---Zoom in on area of interest
  mpres@mpLimitMode           = "LatLon"
  mpres@mpMinLatF             =   37
  mpres@mpMaxLatF             =   41
  mpres@mpMinLonF             = -109.05
  mpres@mpMaxLonF             = -102.05
  mpres@mpFillOn              = False

  if(draw_ncl_outlines) then
    mpres@mpOutlineOn           = True
    mpres@mpOutlineBoundarySets    = "AllBoundaries"
    mpres@mpDataBaseVersion        = "MediumRes"
    mpres@mpDataSetName            = "Earth..4"      ; U.S. counties
  else
    mpres@mpOutlineOn              = False
  end if

;---Create map.
  map = gsn_csm_map(wks,mpres)

  return(map)
end

;--------------------------------------------------
; Main code
;--------------------------------------------------
begin
  wtype          = "png"              ; send graphics to PNG file
  wtype@wkWidth  = 2000
  wtype@wkHeight = 2000
  wks = gsn_open_wks(wtype,"shapefiles")

  ncl_version = get_ncl_version()

;---Create two maps of Colorado
  res                   = True
  res@tiMainFontHeightF = 0.015
  
  res@tiMainString  = "Colorado counties - shapefile"
  map_shp = create_colorado_map(wks,res,False)

  res@tiMainString = "Colorado counties - NCL (version " + ncl_version + ")"
  map_ncl  = create_colorado_map(wks,res,True)

;---Add shapefiles to one of the maps
  lnres             = True
  lnres@gsLineColor = "black"

  id = gsn_add_shapefile_polylines(wks,map_shp,"./USA_adm2.shp",lnres)

;---Add a slightly transparent marker to both maps to show location of county updates
  mkres                  = True
  mkres@gsMarkerIndex    = 16        ; filled dot
  mkres@gsMarkerOpacityF = 0.5       ; make the marker half transparent
  mkres@gsMarkerColor    = "red"
  mkres@gsMarkerSizeF    = 50.

  counties_lat_center =   39.8
  counties_lon_center = -104.9

  mkid_ncl = gsn_add_polymarker(wks,map_ncl,counties_lon_center,counties_lat_center,mkres)
  mkid_shp = gsn_add_polymarker(wks,map_shp,counties_lon_center,counties_lat_center,mkres)

;---Panel both plots. Markers and lines will be drawn too.
  pres             = True
  pres@gsnMaximize = True
  gsn_panel(wks,(/map_ncl,map_shp/),(/1,2/),pres)
end
