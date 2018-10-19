;************************************************
; era40_2.ncl
;
; Concepts illustrated:
;   - Reading GRIB data
;   - Plotting ERA40 data
;   - Drawing curly vectors
;   - Changing the length of the vectors
;   - Changing the magnitude of the vectors
;   - Thinning vectors using a minimum distance resource
;
;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
;************************************************
begin
;************************************************
; create pointer to file and read in data
;************************************************
  in = addfile("ers40_u01276.grb","r")
  U = in->U_GDS0_ISBL_123
  V = in->V_GDS0_ISBL_123
;************************************************
; create default plot
;************************************************
  wks = gsn_open_wks("ps","ers40")               ; open a ps file

  res                         = True             ; plot mods desired
  res@vcRefMagnitudeF         = 20.0             ; define vector ref mag
  res@vcRefLengthF            = 0.045            ; define length of vec ref
  res@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
  res@vcMinDistanceF          = 0.017

  plot = gsn_csm_vector_map_ce(wks,U(0,0,:,:),V(0,0,:,:),res)

end



