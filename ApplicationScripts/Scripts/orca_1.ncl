;======================================================================
; orca_1.ncl
;
; Concepts illustrated:
;   - Drawing area and raster filled contours of ORCA data
;   - Using triangular meshes to create contours
;======================================================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  orca = addfile("ctorca.nc","r")
  sst  = orca->sosstsst(0,:,:)      ; Read data
  lon  = orca->nav_lon
  lat  = orca->nav_lat

  wks = gsn_open_wks("png","orca")   ; send graphics to PNG file

  res                     = True
  res@gsnMaximize         = True     ; Maximize plot in frame

  res@trGridType          = "TriangularMesh"    ; Define the mesh type.

  res@sfXArray            = lon
  res@sfYArray            = lat
  res@sfMissingValueV     = sst@missing_value
  res@gsnAddCyclic        = False      ; don't add cyclic point

; Define colors for filled contours

  res@cnFillOn            = True
  res@cnFillPalette       = "gui_default" ; set color map
  res@cnLinesOn           = False         ; Turn lines off
  res@cnLineLabelsOn      = False         ; Turn labels off

  res@mpProjection         = "Orthographic"
  res@mpCenterLatF         =  50
  res@mpGridLineColor      =  -1       ; Turn off grid lat/lon lines
  res@mpGridAndLimbOn      =  True

  res@cnFillMode           = "AreaFill"       ; The default.
  res@tiMainString         = "Orca Grid - Default fill mode"

  map = gsn_csm_contour_map(wks,sst,res)

  res@tiMainString           = "ORCA Grid - Raster fill"
  res@cnFillMode             = "RasterFill"
  res@mpPerimDrawOrder       = "PostDraw"

  map = gsn_csm_contour_map(wks,sst,res)

end
