;*************************************************
; wind_3.ncl
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
;*************************************************
begin
;*************************************************
; open file and read in data: data are on a gaussian grid
;*************************************************
  f    = addfile ("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc", "r")
  u    = f->U                 ; (time,lat,lon)
  v    = f->V
;*************************************************
; calculate divergence on a gaussian grid
;*************************************************
  div = uv2dvG_Wrap(u,v)                ; u,v ==> divergence

;*************************************************
; calculate velocity potential
;*************************************************
  chi = ilapsG_Wrap ( div , 0)
  chi = (/chi/1e6/)                     ; arbitrary scale
  chi@long_name = "velocity potential"
  chi@units     = "m/s" 
;*************************************************
; calculate divergent wind component 
; --
; note: the calculation uses a procedure, so memory 
; must be preallocated.
;*************************************************    
  ud    = new ( dimsizes(u), typeof(u), u@_FillValue )
  vd    = new ( dimsizes(v), typeof(v), v@_FillValue )

  dv2uvg(div,ud,vd) ; div  ==> divergent  wind components

  copy_VarCoords(u, ud ) 
  copy_VarCoords(u, vd ) 
  ud@long_name  = "Zonal Divergent Wind"
  ud@units      = u@units
  vd@long_name  = "Meridional Divergent Wind"
  vd@units      = v@units
;*************************************************
; plot results
;*************************************************    
  wks  = gsn_open_wks("png","wind")             ; send graphics to PNG file
  cmap = read_colormap_file("BlAqGrYeOrReVi200")
  nc   = dimsizes(cmap(:,0))

  res                      = True

  res@cnFillOn             = True               ; color on
  res@cnLinesOn            = False              ; turn off contour lines

  res@gsnScalarContour     = True               ; vectors over contours
  res@cnFillPalette        = cmap(:nc-4,:)

  res@vcRefMagnitudeF      = 3.                 ; make vectors larger
  res@vcRefLengthF         = 0.050              ; ref vector length
  res@vcGlyphStyle         = "CurlyVector"      ; turn on curly vectors
  res@vcMinDistanceF       = 0.012              ; thin the vectors
  res@vcRefAnnoOrthogonalPosF  = -0.13         ; Move ref anno into plot

  res@mpLandFillColor       = "gray"            ; change continent color 

  res@tiMainString         = "Velocity Potential via Spherical Harmonics"
  res@gsnCenterString      = "Chi scaled by 1e6"
  res@gsnLeftString        = "Divergent Wind"

  plot=gsn_csm_vector_scalar_map(wks,ud(0,:,:),vd(0,:,:),chi(0,:,:),res)
end

