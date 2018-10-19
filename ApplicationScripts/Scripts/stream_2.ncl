;----------------------------------------------------------------------
; stream_2.ncl 
;
; Concepts illustrated:
;   - Drawing a black-and-white streamline plot over a map
;   - Changing the length of streamlines
;   - Setting the spacing for streamline arrowheads
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

begin
  f = addfile("uvt.nc","r")
  u    = f->U(0,0,:,:)    ; read in example data [2D only here]
  v    = f->V(0,0,:,:)

;---Create plots
  wks  = gsn_open_wks("png","stream")               ; send graphics to PNG file

  res                    = True                     ; plot mods desired
  res@tiMainString       = "Streamlines"            ; title

  res@stArrowLengthF     = 0.004                    ; size of the arrows.
  res@stMinArrowSpacingF = 0.004                    ; arrow spacing.
  res@stArrowStride      = 3                        ; arrows start every third

  plot = gsn_csm_streamline_map_ce(wks,u,v,res)
end
