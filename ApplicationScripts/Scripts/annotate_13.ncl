;********************************************************
; annotate_13.ncl
;
; Concepts illustrated:
;   - Drawing a smaller map on a larger map using viewport resources
;   - Using "getvalues" to retrieve the size of a plot
;   - Resizing a plot
;   - Drawing a box around a lat/lon area of interest
;   - Adding shapefile outlines to an existing map
;   - Adding text to a plot
;   - Using a special symbol from a font table to draw an "up" arrow
;
;********************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  

begin
 wks = gsn_open_wks("png","annotate")

;---Map limits for big map
  minlat_lg              =  41
  maxlat_lg              =  43
  minlon_lg              = -72
  maxlon_lg              = -69

;---Map limits for small map
  minlat_sm              =  35
  maxlat_sm              =  48
  minlon_sm              = -85
  maxlon_sm              = -65

  mpres                        = True

;---Resources for large map
  mpres@gsnDraw                = False
  mpres@gsnFrame               = False
  mpres@gsnMaximize            = True

;---Zoom in on area of interest
  mpres@mpMinLatF              = minlat_lg
  mpres@mpMaxLatF              = maxlat_lg
  mpres@mpMinLonF              = minlon_lg
  mpres@mpMaxLonF              = maxlon_lg

  mpres@mpOutlineOn            = False     ; will draw outlines from shapefile

  mpres@mpFillOn               = True   
  mpres@mpOceanFillColor       = "skyblue"
  mpres@mpLandFillColor        = "skyblue"
  mpres@mpInlandWaterFillColor = "skyblue"
  mpres@pmTickMarkDisplayMode  = "Always"

  lg_map = gsn_csm_map(wks,mpres)    ; Create the larger map
  getvalues lg_map
    "vpXF"        : vpx
    "vpYF"        : vpy
    "vpWidthF"    : vpw
    "vpHeightF"   : vph
  end getvalues

;---Resources for small map
  mpres@gsnMaximize            = False
  mpres@vpWidthF               = 0.2
  mpres@vpHeightF              = 0.2
  mpres@vpXF                   = (vpx+vpw) - mpres@vpWidthF - 0.02
  mpres@vpYF                   = vpy

;--Turn off tickmarks and labels
  mpres@tmXBOn                 = False
  mpres@tmYLOn                 = False

;---Zoom out for smaller map
  mpres@mpMinLatF              = minlat_sm
  mpres@mpMaxLatF              = maxlat_sm
  mpres@mpMinLonF              = minlon_sm
  mpres@mpMaxLonF              = maxlon_sm

  mpres@mpLandFillColor        = "forestgreen"
  mpres@mpDataBaseVersion      = "MediumRes"

;---Draw state outline
  mpres@mpOutlineBoundarySets  = "USStates"
  mpres@mpOutlineOn            = True

  sm_map = gsn_csm_map(wks,mpres)

;---Draw a box around lat/lon location of large map
  lnres = True
  lnres@gsLineThicknessF = 2.5
  lnres@gsLineColor = "yellow"
  lon_box = (/minlon_lg,maxlon_lg,maxlon_lg,minlon_lg,minlon_lg/)
  lat_box = (/minlat_lg,minlat_lg,maxlat_lg,maxlat_lg,minlat_lg/)
  lnid = gsn_add_polyline(wks,sm_map,lon_box,lat_box,lnres)
  
;---Add an arrow and "N" to large map
  txres = True
  txres@txFontHeightF = 0.02
  txid = gsn_add_text(wks,lg_map,"N~C~~F34~-",-70,42.75,txres)

;---Add filled areas and outlines from shapefiles for larger map. 
  gnres = True
  gnres@gsFillColor = "yellow"
  shpid1 = gsn_add_shapefile_polygons(wks,lg_map,"USA_adm/USA_adm2.shp",gnres)
  shpid2 = gsn_add_shapefile_polylines(wks,lg_map,"USA_adm/USA_adm2.shp",False)

  draw(lg_map)           ; Draws map and attached arrow.
; drawNDCGrid(wks)       ; Draws NDC grid; for debugging purposes
  draw(sm_map)
  frame(wks)
end
