;*************************************************
; wind_2.ncl
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
  u    = f->U               ; (time,lat,lon)
  v    = f->V
;*************************************************
; calculate vorticity: Wrap version maintains meta data
;*************************************************
  vrt = uv2vrG_Wrap(u,v)         

;*************************************************
; calculate rotational wind component 
; --
; note: the calculation uses a procedure, so memory 
; must be preallocated.
;*************************************************    
  ur    = new ( dimsizes(u), typeof(u), u@_FillValue )
  vr    = new ( dimsizes(v), typeof(v), v@_FillValue )

  vr2uvg(vrt, ur,vr)          
  ur@long_name  = "Zonal Rotational Wind"
  ur@units      = u@units
  vr@long_name  = "Meridional Rotational Wind"
  vr@units      = v@units
  copy_VarCoords(u, ur ) 
  copy_VarCoords(u, vr ) 
;*************************************************
; plot results
;*************************************************    
  wks  = gsn_open_wks("png","wind")             ; send graphics to PNG file
                                             
  res                         = True

  res@vcRefMagnitudeF         = 5.              ; make vectors larger
  res@vcRefLengthF            = 0.050           ; reference vector
  res@vcGlyphStyle            = "CurlyVector"   ; turn on curly vectors
  res@vcMinDistanceF          = 0.022           ; thin the vectors
  res@vcRefAnnoOrthogonalPosF = -1.0            ; move ref vector up
  res@gsnLeftString           = "Rotational Wind" 
                                                ; plot 1st time step
  plot= gsn_csm_vector_map(wks,ur(0,:,:),vr(0,:,:),res)

end

