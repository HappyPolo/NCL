;*************************************************
; barb_2.ncl
;
; Concepts illustrated:
;   - Drawing colored wind barbs vectors over a cylindrical equidistant map
;   - Changing the length of the wind barbs
;   - Changing the size of the wind barbs
;   - Decreasing the number of vectors drawn
;   - Adding gray to an existing color map
;   - Using the full color map for colored wind barbs
;   - Thinning vectors using a minimum distance resource
;
;;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  a = addfile("83.nc","r")
;************************************************
; read in zonal [u] and meridional [v] winds 
;************************************************
  u = a->U(0,12,:,:) 
  v = a->V(0,12,:,:)   
  t = a->T(0,12,:,:)   
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","barb")                 ; send graphics to PNG file

  vcres                         = True             ; plot mods desired

  vcres@vcRefMagnitudeF         = 10.              ; make vectors larger
  vcres@vcLevelPalette          = "BlAqGrYeOrReVi200" ; set color map
  vcres@vcRefLengthF            = 0.050            ; ref vec length
  vcres@vcMinDistanceF          = 0.017            ; thin out vectors
  vcres@vcGlyphStyle            = "WindBarb"       ; choose wind barbs
  vcres@vcMonoWindBarbColor     = False            ; color barbs by scalar 
  vcres@vcMinDistanceF          = 0.025            ; thin out windbarbs

  vcres@tiMainString            = "WindBarbs colored by a scalar map"
  plot=gsn_csm_vector_scalar_map_ce(wks,u,v,t,vcres)  ; create plot

end
