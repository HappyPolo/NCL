;----------------------------------------------------------------------
; mapoutlines_2.ncl
;
; Concepts illustrated:
;   - Reading shapefiles
;   - Plotting data from shapefiles
;   - Drawing outlines of Switzerland from a shapefile
;----------------------------------------------------------------------
; The shapefile for this example was obtained from the
; "Global Administrative Areas" website:
;
;      http://www.gadm.org/country
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;--- Open workstation.
  wks = gsn_open_wks("png","mapoutlines") ; send graphics to PNG file

  res                       = True
  res@gsnDraw               = False
  res@gsnFrame              = False

  res@mpDataBaseVersion     = "MediumRes"
  res@mpOutlineBoundarySets = "AllBoundaries"

;---Turn on fancier tickmark labels.
  res@pmTickMarkDisplayMode = "Always"

;---Zoom in on area of interest
  res@mpMinLatF             = 45.80
  res@mpMaxLatF             = 47.82
  res@mpMinLonF             =  5.90
  res@mpMaxLonF             = 10.50

  res@mpOutlineOn           = True
  res@mpFillOn              = False  
  res@mpNationalLineThicknessF = 3.0

  res@tiMainString          = "Original NCL map outlines"

  dir       = "CHE_adm/"
  filename  = "CHE_adm0.shp"

  map1 = gsn_csm_map(wks,res)

  res@mpOutlineOn           = False         ; Use outlines from shapefile
  res@tiMainString          = "Shapefile outlines from " + filename
  map2 = gsn_csm_map(wks,res)

;---Attach shapefile polylines to map

  lnres                  = True
  lnres@gsLineColor      = "NavyBlue"
  lnres@gsLineThicknessF = 3.0
  poly = gsn_add_shapefile_polylines(wks,map2,dir+filename,lnres)

  pres              = True
  pres@gsnMaximize  = True
  gsn_panel(wks,(/map1,map2/),(/2,1/),pres)

end
