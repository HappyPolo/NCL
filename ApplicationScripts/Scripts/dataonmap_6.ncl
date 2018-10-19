;----------------------------------------------------------------------
; dataonmap_6.ncl
;
; Concepts illustrated:
;   - Plotting contours on an unstructured (triangular) mesh
;----------------------------------------------------------------------
; The data is from the Chesapeake Community Model Program Quoddy
; model:
;
;    http://ccmp.chesapeake.org
;
;  using the NOAA/NOS standardized hydrodynamic model NetCDF format:
;
;    https://sourceforge.net/projects/oceanmodelfiles
;
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  f = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/ctcbay.nc","r")

  depth = f->depth    ; 7258 cells
  lat   = f->lat      ; ditto
  lon   = f->lon      ; ditto
  ele   = f->ele      ; 13044 x 3 (triangles that connect the cells)

  printVarSummary(depth)
  printVarSummary(lat)
  printVarSummary(ele)


  wks = gsn_open_wks("png","dataonmap")

  res                     = True
  res@gsnMaximize         = True

  res@sfYArray            = lat
  res@sfXArray            = lon
  res@sfElementNodes      = ele
  res@sfFirstNodeIndex    = 1          ; indexing starts at 1, not 0

  res@cnFillOn            = True        ; Turn on contour fill.
  res@cnLinesOn           = False       ; Turn off contour lines
  res@lbOrientation       = "Vertical"  ; Looks better this way

  res@mpMinLatF           = 36.5        ; zoom in on map
  res@mpMaxLatF           = 40.
  res@mpMinLonF           = -77.5
  res@mpMaxLonF           = -75.5

  res@mpDataBaseVersion     = "MediumRes"
  res@pmTickMarkDisplayMode = "Always"

  res@tiMainString          = "Chesapeake Bay"

;---Move titles closer to plot
  res@tiMainOffsetYF               = -0.02
  res@gsnRightStringOrthogonalPosF = 0.02
  res@gsnLeftStringOrthogonalPosF  = 0.02

  map = gsn_csm_contour_map(wks,depth,res)
end
