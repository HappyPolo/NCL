; =================================================;
; gsn_stream_2.ncl
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
  wks  = gsn_open_wks("png","gsn_stream")         ; send graphics to PNG file

  res                    = True          ; plot mods desired
  res@tiMainString       = "Example of a streamline plot"
  res@stArrowLengthF     = 0.015         ; changes the size of the arrows.
  res@stLineThicknessF   = 1.5           ; changes the line thickness
  res@stLineColor        = "orange"      ; changes color
  plot = gsn_streamline(wks,u(::2,::2),v(::2,::2),res)
end
