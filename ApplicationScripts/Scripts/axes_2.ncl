;*************************************************
; axes_2.ncl
;************************************************
;
; Concepts illustrated:
;   - Making an axis logarithmic in a contour plot
;   - Reversing the X and Y axes
;
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;************************************************
begin
;************************************************
; variable and file handling
;************************************************
  in  = addfile("atmos.nc","r")
  T   = in->T                                   ; select variable to ave
;************************************************
;  calculate zonal average of 3d variable
;************************************************
  zave = dim_avg_Wrap(T)                        ; calculate zonal ave
;************************************************
;  calculate eta
;************************************************
  a=in->hyam                                    ; select hyam 
  b=in->hybm                                    ; select hybm
  p=in->P0                                      ; select P0
  eta = (a+b)*p                                 ; calc eta
  eta = eta/100                                 ; scale eta by 100
;************************************************
; create contour plot but don't draw it yet
;************************************************
  wks  = gsn_open_wks("png","axes")                ; send graphics to PNG file 
  
  res                       = True                 ; plot mods desired
  res@gsnMaximize           = True                 ; maximize plot
  res@sfYArray              = eta                  ; use eta for y axis
  res@sfXArray              = zave&lat             ; use lat for x axis
  res@tiXAxisString         = "latitude"           ; x-axis label
  res@tiYAxisString         = "eta x 1000"         ; y-axis label
  res@cnInfoLabelOn         = False                ; turn off contour info label
  res@trXReverse            = True                 ; reverse x-axis
  res@trYReverse            = True                 ; reverse y-axis

  res@tiMainString          = "Irregular Y axis"
  plot = gsn_csm_contour(wks,zave(0,:,:),res)          ; creates plot

  res@gsnYAxisIrregular2Log = True                 ; set y-axis to log scale
  res@tiMainString          = "Log Y axis"
  plot = gsn_csm_contour(wks,zave(0,:,:),res)          ; creates plot
  
end


