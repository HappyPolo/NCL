;*************************************************
; ice_2.ncl
;
; Concepts illustrated:
;   - Plotting ice data
;   - Adding a missing value (_FillValue)
;   - Drawing curly vectors over a polar stereographic map
;   - Coloring vectors based on magnitude
;   - Changing the length of the vectors
;   - Changing the magnitude of the vectors
;   - Thinning vectors using a minimum distance resource
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  a = addfile("ice001608.nc","r")

;************************************************
; read in components
;************************************************
  u = a->uiceh(0,:,:)                            
  v = a->uiceh(0,:,:)
;************************************************
; this data only has an missing_value, so we are
; copying this to _FillValue for plotting purposes
;************************************************
  assignFillValue(v,u)                           ; in contributed      
  assignFillValue(u,v)
;************************************************
; create plot
;************************************************
  wks  = gsn_open_wks("png" ,"ice")              ; send graphics to PNG file
  cmap = read_colormap_file("BlAqGrYeOrReVi200") ; choose colormap

  res            = True                         ; plot mods desired
  res@gsnPolarNH = True                         ; specify the hemisphere
  res@mpMinLatF  = 75                           ; minimum lat to plot

  res@vcLevelPalette        = cmap(18:191,:)   ; subset color map
  res@vcRefMagnitudeF       = 5.0              ; vec magnitude
  res@vcRefLengthF          = 0.04             ; size of ref vector
  res@vcMonoLineArrowColor  = False             ; vectors color by magnitude
  res@vcMinDistanceF        = 0.02              ; thins arrows near pole
  res@vcGlyphStyle          = "CurlyVector"    ; curly vectors on

; because this is ice data, which has a gap in the tropics, we need to
; explicitly pass the range of the data to plot.  Since we are coloring 
; the vectors, this range should also match the MinLatF above, since the
; range for the colors is chosen over the full data passed, and not the
; map limits.

  plot = gsn_csm_vector_map_polar(wks,u({75.:90.},:),v({75.:90.},:),res)

end
