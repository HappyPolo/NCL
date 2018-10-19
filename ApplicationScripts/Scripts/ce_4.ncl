;************************************************
; ce_4.ncl
;
; Concepts illustrated:
;   - Drawing curly vectors over a cylindrical equidistant map
;   - Changing the length of the vectors
;   - Decreasing the number of vectors drawn
;   - Moving the vector reference annotation into the plot
;   - Thinning vectors using a minimum distance resource
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
;************************************************
begin
;************************************************
; read in data
;************************************************
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
  u = a->U(1,:,:)                                ; read July zonal winds
  v = a->V(1,:,:)                                ; read July zonal winds
;************************************************
; plot resources
;************************************************
  wks = gsn_open_wks("png" ,"ce")                ; send graphics to PNG file

  vcres                         = True           ; plot mods desired

  vcres@vcRefAnnoOrthogonalPosF = -1.0           ; move ref vector up
  vcres@vcRefMagnitudeF         = 10.0           ; define vector ref mag
  vcres@vcRefLengthF            = 0.045          ; define length of vec ref
  vcres@vcGlyphStyle            = "CurlyVector"  ; turn on curly vectors
  vcres@vcMinDistanceF          = 0.017          ; thin the vectors

  vector = gsn_csm_vector_map(wks,u,v,vcres)

end
