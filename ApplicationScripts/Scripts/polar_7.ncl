;*************************************************
; polar_7.ncl
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  a = addfile("ice001608.nc","r")
;************************************************
; read in components
;************************************************
  u = a->uiceh(0,:,:)                            
  v = a->uiceh(0,:,:)
;************************************************
; this data only has an missing_value, so we are
; copying this to _FillValue for plotting purposes
;************************************************
  assignFillValue(v,u)                             ; in contributed.ncl  
  assignFillValue(u,v)
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","polar")             ; send graphics to PNG file
;
  res            = True                         ; plot mods desired
  res@gsnPolar   = "NH"                         ; specify the hemisphere
  res@mpMinLatF  = 75                           ; minimum lat to plot

  res@vcLevelPalette        = "gui_default"     ; set color map
  res@vcRefMagnitudeF       = 10.0              ; vec magnitude
  res@vcRefLengthF          = 0.050             ; size of ref vector
  res@vcMonoLineArrowColor  = False             ; multiple colors desired
  res@vcMinDistanceF        = 0.02              ; thins arrows near pole

  res@gsnLeftString       = "Ice Velocity"

; because this is ice data, which has a gap in the tropics, we need to
; explicitly pass the range of the data to plot.  Since we are coloring 
; the vectors, this range should also match the MinLatF above, since the
; range for the colors is chosen over the full data passed, and not the
; map limits.
  plot = gsn_csm_vector_map_polar(wks,u({75.:90.},:),v({75.:90.},:),res)
end
