;----------------------------------------------------------------------
; dataonmap_8.ncl
;
; Concepts illustrated:
;   - Plotting contours on a rectilinear grid
;   - Reordering data to be lat x lon
;   - Drawing raster contours for faster results
;   - Reading group data off an HDF5 file
;----------------------------------------------------------------------
; Requires NCL version 6.3.0 or later.
;----------------------------------------------------------------------

begin
  fname = "3B-MO.MS.MRG.3IMERG.20140701-S000000-E235959.07.V03D.HDF5"
  f     = addfile(fname, "r")
  p     = f->/Grid/precipitation

  printVarSummary(p)    ; Note that this is ordered lon x lat
  printMinMax(p,0)

  wks = gsn_open_wks("png", "dataonmap")

  res                      = True
  res@gsnMaximize          = True

  res@cnFillOn             = True
  res@cnFillMode           = "RasterFill" ; "AreaFill" is the default and can be slow for large grids.
  res@cnLinesOn            = False
  res@cnLineLabelsOn       = False
 
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = (/ 0.01, 0.02, 0.04, 0.08, 0.16, \
                                0.32, 0.64, 0.96/)
  res@cnFillColors         = (/"white","cyan", "green","yellow",\
                               "darkorange","red","magenta","purple",\
                               "black"/)

  res@gsnLeftString        = "precipitation"

;
; IMPORTANT: The data is ordered lon x lat; you must reorder before plotting using the "|"
; operator.
;
; We included "timing" results in case you want to compare raster fill with
; the default "area fill" (see cnFillMode above)"
;
  start_time = get_cpu_time()
  plot = gsn_csm_contour_map(wks, p(lat|:,lon|:), res)
  end_time = get_cpu_time()
  print("Elapsed time = " + (end_time - start_time) + " CPU seconds.")
end
