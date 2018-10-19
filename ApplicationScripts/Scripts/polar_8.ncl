;*************************************************
; polar_8.ncl
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
;************************************************
begin
;************************************************
; read in atmospheric data
;************************************************
  a = addfile("atmos.nc","r")
  u = a->U(0,1,:,:)
  v = a->V(0,1,:,:)
  t = a->TS(0,:,:)
;************************************************
; this data only has an missing_value, so we are
; copying this to _FillValue for plotting purposes
;************************************************
  assignFillValue(v,u)                           ; in contributed.ncl   
  assignFillValue(u,v)
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","polar")             ; send graphics to PNG file
  gsn_define_colormap(wks, "wgne15")

  res            = True                         ; plot mods desired
  res@gsnPolar   = "NH"                         ; specify the hemisphere
  res@mpMinLatF  = 60                           ; minimum lat to plot
  res@mpFillOn   = False

  res@cnFillOn          = True                  ; color fill
  res@cnLevelSpacingF   = 3.                    ; interval spacing
  res@cnLinesOn         = False                 ; no contour lines

  res@gsnSpreadColorEnd     = -3
  res@gsnScalarContour      = True              ; vectors over scalars
  res@vcRefMagnitudeF       = 20.0              ; vec magnitude
  res@vcRefLengthF          = 0.04              ; size of ref vector
  res@vcLineArrowColor      = "white"           ; white vectors
  res@vcMinDistanceF        = 0.02              ; thins arrows near pole  
  res@vcGlyphStyle          = "CurlyVector"     ; turns on curley vectors

  res@vcRefAnnoArrowLineColor   = "black"       ; black ref vector
  res@vcRefAnnoArrowUseVecColor = False

;  res@gsnLeftString       = "Wind Velocity over Surface Temperature"

; because this is ice data, which has a gap in the tropics, we need to
; explicitly pass the range of the data to plot.  Since we are coloring 
; the vectors, this range should also match the MinLatF above, since the
; range for the colors is chosen over the full data passed, and not the
; map limits.
  plot = gsn_csm_vector_scalar_map_polar(wks,u({60.:90.},:),v({60.:90.},:), \
         t({60.:90.},:),res)

end
