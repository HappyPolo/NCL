;*************************************************
; wind_4.ncl
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;*************************************************
begin
;*************************************************
; open file and read in data: data are on a gaussian grid
;*************************************************
  f    = addfile ("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc", "r")
  u    = f->U                      ; (time,lat,lon)
  v    = f->V
;*************************************************
; calculate divergence: use Wrap version to maintain meta data
;*************************************************
  div = uv2dvG_Wrap(u,v)           ; u,v ==> divergence

;*************************************************
; calculate divergence
;*************************************************
  chi = ilapsG_Wrap ( div , 0)
  chi = (/chi/1e6/)
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
  wks  = gsn_open_wks("png","wind")                ; send graphics to PNG file

  res                      = True

  res@vcRefMagnitudeF         = 3.                 ; make vectors larger
  res@vcRefLengthF            = 0.050              ; ref vector length
  res@vcGlyphStyle            = "CurlyVector"      ; turn on curly vectors
  res@vcMinDistanceF          = 0.012              ; thin the vectors
  res@vcRefAnnoOrthogonalPosF = -1.0               ; move ref vector up

  res@gsnScalarContour     = True               ; vectors over contours
  res@gsnDraw              = False              ; don't draw
  res@gsnFrame             = False              ; don't advance frame

  res@cnLineLabelPerimOn         = True           ; line label box on
  res@cnLineLabelFontHeightF     = .013           ; label font height
  res@cnInfoLabelOn              = False          ; no contour info label

  res@tiMainString         = "Velocity Potential" ; title
  res@gsnCenterString      = "Chi scaled by 1e6"  ; center string
  res@gsnLeftString        = "Divergent Wind"     ; left string


  res@cnHighLabelsOn             = True           ; high labels on
  res@cnHighLabelBackgroundColor = "white"        ; background white
  res@cnHighLabelPerimOn         = True           ; box on

  res@cnLowLabelsOn             = True            ; low label on
  res@cnLowLabelBackgroundColor = "white"         ; background white
  res@cnLowLabelPerimOn         = True            ; box on

  plot=gsn_csm_vector_scalar_map(wks,ud(0,:,:),vd(0,:,:),chi(0,:,:),res)
  plot = ZeroNegDashLineContour(plot)             ; neg lines dashed 
						  ; zero line double thick
  draw(plot) 
  frame(wks)

end

