;******************************************************
; homme_1.ncl
;******************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;******************************************************
;  Open a netCDF file containing the grid and data from the HOMME
;  (High-Order Multiscale Modeling Environment) model, formerly
;  called SEAM (Spectral Element Atmosphere Model).
;******************************************************
  f     = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/seam.nc","r")
  lat1d = ndtooned(f->lat2d)          ; Pull off lat/lon variable and
  lon1d = ndtooned(f->lon2d)          ; convert both to 1D.
  ps1d  = ndtooned(f->ps(0,:,:))      ; Read some data; convert to 1D.
  ps1d@long_name = "surface pressure" ; orig has no meta data
;******************************************************
; create plot
;******************************************************
  wks = gsn_open_wks("png","homme")              ; send graphics to PNG file

  res                     = True         ; plot modifications desired
;  res@gsnMaximize         = True         ; Maximize size of plot in frame

  res@sfXArray            = lon1d        ; Required to tell NCL where to
  res@sfYArray            = lat1d        ; overlay data on globe.

  res@cnFillOn            = True         ; Turn on contour fill
  res@cnFillPalette       = "BlAqGrYeOrReVi200"  ; set color map
;  res@cnFillMode          = "AreaFill"   ; Style of fill. You can also
                                         ; use "CellFill" and "RasterFill"
  res@cnLinesOn           = False        ; Turn off contour lines
  res@cnLineLabelsOn      = False        ; Turn off contour line labels

  res@tiMainString        = "HOMME grid using triangular mesh conversion"    ; Title

  map = gsn_csm_contour_map_ce(wks,ps1d,res)

end
