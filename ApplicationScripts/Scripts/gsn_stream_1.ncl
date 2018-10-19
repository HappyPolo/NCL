; =================================================;
; stream_1.ncl
; =================================================;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; ==============================================================
begin
  f = addfile("uvt.nc","r")
  u    = f->U(0,0,:,:)    ; read in example data [2D only here]
  v    = f->V(0,0,:,:)
; =================================================;
; create plots
; =================================================;
  wks  = gsn_open_wks("png","gsn_stream")          ; send graphics to PNG file
  res  = True                                      ; plot mods desired
  res@tiMainString    = "Example of a streamline plot"

  plot = gsn_streamline(wks,u,v,res)
end
