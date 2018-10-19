;----------------------------------------------------------------------
;  mapoutlines_5.ncl
;----------------------------------------------------------------------
;
; Concepts illustrated:
;   - Compares different map resolutions for a world map
;   - Drawing a world map using the low resolution map outlines
;   - Drawing a world map using the medium resolution map outlines
;   - Drawing a world map using shapefiles
;   - Reading shapefiles
;   - Plotting data from shapefiles
;----------------------------------------------------------------------
; The shapefile in this example was downloaded from:
;
;    http://www.ngdc.noaa.gov/mgg/shorelines/data/gshhg/latest/
;
; It contains many shapefiles, so you need to look at the 
; GSHHS_SHP/README.txt file to see which one is best for you.
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

begin

  wks  = gsn_open_wks("png","mapoutlines") ; send graphics to PNG file

  res              = True
  res@gsnMaximize  = True
  res@mpFillOn     = False

;----------------------------------------------------------------------
; First plot
;----------------------------------------------------------------------
  res@tiMainString = "NCL's default map outlines"
  plot = gsn_csm_map_ce(wks,res)


;----------------------------------------------------------------------
; Second plot
;----------------------------------------------------------------------
  res@tiMainString      = "NCL's medium resolution map outlines"
  res@mpDataBaseVersion = "MediumRes"

  plot = gsn_csm_map_ce(wks,res)

;----------------------------------------------------------------------
; Third plot
;----------------------------------------------------------------------
; GSHHS shapefiles downloaded from
;
;    http://www.ngdc.noaa.gov/mgg/shorelines/data/gshhg/latest/
;
; There are several *.shp files, so look at the README file 
; to decide which one you want
;----------------------------------------------------------------------
  dir      = "GSHHS_shp/"
  filename = "l/GSHHS_l_L1.shp"

  res@gsnDraw           = False    ; Set to False so we can add 
  res@gsnFrame          = False    ; shapefile outlines.

  res@mpOutlineOn       = False
  res@tiMainString      = dir+filename

  plot = gsn_csm_map_ce(wks,res)
  dum  = gsn_add_shapefile_polylines(wks,plot,dir+filename,True)

  draw(plot)   ; This will draw the map and the shapefile outlines.
  frame(wks)
end
