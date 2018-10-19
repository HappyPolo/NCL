; =================================================;
; gsn_vector_2.ncl
; =================================================;
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; =================================================;
begin
  f = addfile("uvt.nc","r")
  u    = f->U(0,0,:,:)    ; read in example data [2D only here]
  v    = f->V(0,0,:,:)
; =================================================;
; create plots
; =================================================;
  wks  = gsn_open_wks("png","gsn_vector")          ; send graphics to PNG file
  res  = True                                      ; plot mods desired
  res@tiMainString          = "Basic Vector Plot"  ; title

  res@vcRefMagnitudeF       = 5.0                 ; add a reference vector
  res@vcRefLengthF          = 0.045                ; what the ref length is
  res@vcLevelPalette        = "gui_default"        ; set color map
  res@vcMonoLineArrowColor  = False                ; vec's colored by their mag
  res@vcGlyphStyle          = "CurlyVector"        ; turn on curly vectors



  res@pmLabelBarDisplayMode    = "Always"          ; Turn on a label bar.
  res@pmLabelBarWidthF         = 0.08              ; make it thinner
  res@lbPerimOn                = False             ; no box around it
  plot = gsn_vector(wks,u(::2,::2),v(::2,::2),res)
end
