;----------------------------------------------------------------------
; vector_4.ncl
;
; Concepts illustrated:
;   - Coloring vectors based on temperature data
;   - Drawing curly vectors
;   - Thinning vectors using a minimum distance resource
;   - Changing the length of the smallest vector as a fraction of the reference vector
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    

begin

;---Read in netCDF file
  a = addfile("83.nc","r")

;---Read in zonal [u] and meridional [v] winds 
  u = a->U(0,12,:,:) 
  v = a->V(0,12,:,:)   
  t = a->T(0,12,:,:)   

;---Create plot
  wks = gsn_open_wks("png","vector")               ; send graphics to PNG file

  cmap = read_colormap_file("BlAqGrYeOrReVi200")

  vcres                     = True      ; plot mods desired
  vcres@lbLabelStride       = 2         ; plot every other colar bar label
  vcres@vcRefMagnitudeF         = 5.0              ; make vectors larger
  vcres@vcRefLengthF            = 0.050            ; ref vec length
  vcres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
  vcres@vcMinDistanceF          = 0.017            ; thin out vectors
  vcres@vcLevelPalette      = cmap(6:193,:)

  vcres@tiMainString            = "Vectors colored by a scalar map"

  plot=gsn_csm_vector_scalar_map_ce(wks,u,v,t,vcres)  ; create plot



end
