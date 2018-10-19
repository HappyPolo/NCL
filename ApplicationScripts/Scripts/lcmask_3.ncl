;*************************************************
; lcmask_3.ncl
;
; Concepts illustrated:
;   - Drawing curly vectors over a masked Lambert Conformal map
;   - Maximizing the size of the plot
;   - Changing the length of the vectors
;   - Decreasing the number of vectors drawn
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  a = addfile("atmos.nc","r")
  u = a->U
  v = a->V
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","lcmask")            ; open a ps file

  res                       = True              ; plot mods desired
  res@mpProjection          = "LambertConformal"; choose projection

; vector rescoures
  res@vcRefMagnitudeF         = 15.0            ; define vector ref mag
  res@vcRefLengthF            = 0.045           ; define length of vec ref
  res@vcGlyphStyle            = "CurlyVector"   ; turn on curly vectors
  res@vcMinDistanceF          = 0.017

  res@gsnAddCyclic          = False             ; regional plot
  res@gsnMaximize           = True              ; enlarge plot
  res@gsnLeftString         = "Winds"           ; replace long_name title
  res@tiMainString          = "Vectors on Masked Grid"

  res@mpMinLatF             = 20                ; min lat to mask
  res@mpMaxLatF             = 80                ; max lat to mask
 
  res@mpMinLonF             = -90               ; min lon to mask
  res@mpMaxLonF             = 40                ; max lon to mask

  res@gsnMaskLambertConformal = True            ; turn on lc masking
  
  u&lon = u&lon-180                             ; make lon go -180 to 180 
  v&lon = v&lon-180                             ; make lon go -180 to 180 
; subset data going into the plot template so that the ref vec reflects only
; the data viewed vice the entire data set
  plot  = gsn_csm_vector_map(wks,u(0,0,{20:80},{-90:40}),\
  v(0,0,{20:80},{-90:40}),res); create plot
end
