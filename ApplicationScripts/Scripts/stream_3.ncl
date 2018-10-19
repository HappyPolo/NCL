;----------------------------------------------------------------------
; stream_3.ncl 
;
; Concepts illustrated:
;   - Drawing single-color streamlines over a map
;   - Changing the color of streamlines
;   - Increasing the thickness of streamlines
;   - Changing the length of streamlines
;   - Zooming in on a particular area on a map
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
  wks  = gsn_open_wks("png","stream")     ; send graphics to PNG file

  res  = True                             ; plot mods desired

  res@mpMinLonF          = -150           ; choose a subregion
  res@mpMaxLonF          = 20.
 
  res@stMinArrowSpacingF = 0.006          ; arrow spacing.
  res@stArrowLengthF     = 0.01           ; changes the size of the arrows.
  res@stLineThicknessF   = 1.5            ; changes the line thickness
  res@stLineColor        = "orange"       ; changes color

  plot = gsn_csm_streamline_map_ce(wks,u,v,res)
end
