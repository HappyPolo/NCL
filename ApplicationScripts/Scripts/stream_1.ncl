;----------------------------------------------------------------------
; stream_1.ncl 
;
; Concepts illustrated:
;   - Drawing a black-and-white streamline plot over a map
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

begin
;---Read in 2D data only
  f = addfile("uvt.nc","r")
  u = f->U(0,0,:,:)                ; read in example data [2D only here]
  v = f->V(0,0,:,:)

;---Graphics
  wks  = gsn_open_wks("png","stream")                  ; send graphics to PNG file

  res                 = True                           ; plot mods desired
  res@tiMainString    = "Example of a streamline plot" ; title

  plot = gsn_csm_streamline_map_ce(wks,u,v,res)
end
