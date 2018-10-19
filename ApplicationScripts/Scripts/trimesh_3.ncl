;*****************************************************
; trimesh_1.ncl
;
; Concepts illustrated:
;   - Contouring one-dimensional X, Y, Z data
;   - Selecting a "rainbow" color map that also contains "gray"
;   - Spanning part of a color map for contour fill
;   - Drawing a map using the high resolution map outlines

;*****************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;
;  This data is from the Chesapeake Community Model Program Quoddy
;  model:
;
;    http://ccmp.chesapeake.org
;
;  using the NOAA/NOS standardized hydrodynamic model NetCDF format:
;
;    https://sourceforge.net/projects/oceanmodelfiles
;
  f = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/ctcbay.nc","r")

  wks = gsn_open_wks("x11","trimesh")
  cmap = read_colormap_file("rainbow")

  res                     = True
  res@gsnMaximize         = True

  res@sfXArray            = f->lon
  res@sfYArray            = f->lat
  res@sfElementNodes      = f->ele
  res@sfFirstNodeIndex    = 1

  res@cnFillOn            = True        ; Turn on contour fill.
  res@mpFillOn            = False       ; Turn off map fill.
  res@cnFillPalette       = cmap(13:,:) ; set color map
  res@cnLinesOn           = False       ; Turn off contour lines

  res@lbOrientation       = "Vertical"  ; Change location of labelbar.

  res@mpDataBaseVersion     = "MediumRes"
  res@mpLimitMode           = "LatLon"
  res@mpMinLonF             = -77.32
  res@mpMaxLonF             = -75.53
  res@mpMinLatF              = 36.63
  res@mpMaxLatF             = 39.62
  res@trGridType = "TriangularMesh"

  res@tiMainString          = "Chesapeake Bay"
  res@tiMainOffsetYF        = -0.02           ; Move the title down.

  res@pmTickMarkDisplayMode = "Always"        ; Turn on map tickmarks.

  map = gsn_csm_contour_map(wks,f->depth,res)

  mkres = True
  mkres@gsnCoordsLat = f->lat
  mkres@gsnCoordsLon = f->lon
  gsn_coordinates(wks,map,f->depth,mkres)
end
