;----------------------------------------------------------------------
; dataonmap_2.ncl
;
; Concepts illustrated:
;   - Plotting vectors on a rectilinear grid
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;----------------------------------------------------------------------

begin
  filename = "$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc"
  a = addfile(filename,"r")    ; open file
  u = a->U(0,:,:)              ; read data (64 x 128)
  v = a->V(0,:,:)              ; ditto
  
  printVarSummary(u)           ; print info about variables
  printVarSummary(v)

;---Plot data
  wks = gsn_open_wks("png","dataonmap")

  res                 = True
  res@gsnMaximize     = True     ; maximize plot in frame

  res@vcGlyphStyle    = "CurlyVector"  ; turn on curly vectors
  res@vcRefMagnitudeF = 10.0           ; define vector ref mag
  res@vcRefLengthF    = 0.045          ; define length of vec ref
  res@vcMinDistanceF  = 0.017          ; thin vectors

  res@tiMainString    = "Plotting rectilinear data"

  plot = gsn_csm_vector_map(wks,u,v,res)
end
