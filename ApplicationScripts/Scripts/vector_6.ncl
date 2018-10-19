;----------------------------------------------------------------------
; vector_6.ncl
;
; Concepts illustrated:
;   - Drawing a black-and-white vector plot
;   - Clipping vectors outside a viewport
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;---Generate dummy vector data.
  M  = 30
  N  = 25
  PI = 3.14159
  U  = 10.0 * cos(onedtond((2.0 * PI / N) * ispan(0,N-1,1),(/M,N/)))
  V  = 10.0 * cos(onedtond((2.0 * PI / M) * ispan(0,M-1,1),(/N,M/)))

;---We need to transpose U, so dimension names are needed.
  U!0    = "x"
  U!1    = "y"
  Utrans = U(y|:,x|:)

  wks  = gsn_open_wks ("png", "vector" )       ; send graphics to PNG file

  res              = True
  res@gsnMaximize  = True     ; Maximize plot in frame.

  res@tiMainString = "Vector plot with default clipping"
  plot = gsn_csm_vector(wks, Utrans, V, res)

  res@tiMainString = "Vector plot with clipping turned off"
  res@vpClipOn     = False

  plot = gsn_csm_vector(wks, Utrans, V, res)
end
