;----------------------------------------------------------------------
; stream_5.ncl 
;
; Concepts illustrated:
;   - Drawing a black-and-white streamline plot
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

begin
  f = addfile("uvt.nc","r")
  u    = f->U(0,0,:,:)    ; read in example data [2D only here]
  v    = f->V(0,0,:,:)
; =================================================;
; create plots
; =================================================;
wtype = "png"
;
; These lines have been commented out due to the fact that they generate
; an excessively large plot.
; wtype@wkWidth = 2500
; wtype@wkHeight = 2500
  wks = gsn_open_wks(wtype,"stream")
; The following line is not needed, and has been commented out.
;  wks  = gsn_open_wks("ps","stream")             ; open a ps plot
  res = True
  res@stLineThicknessF      = 5.0         ; default is 1.0
  res@stLineColor = "NavyBlue"
  plot = gsn_csm_streamline(wks,u,v,res)
end
