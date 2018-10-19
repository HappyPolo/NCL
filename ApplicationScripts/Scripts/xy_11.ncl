;*************************************************
; xy_11.ncl
;
; Concepts illustrated:
;   - Drawing an XY plot with just Y values
;   - Changing the precision of the tickmark labels
;   - Adding labels to the right Y axis
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
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
  u = a->U(0,:,:)
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","xy")                         ; send graphics to PNG file

  res                        = True                      ; plot mods desired
  res@tiYAxisString          = u@long_name + " "+u@units ; add units to title 
  res@tiMainString          = "Example of gsn_csm_y"     ; title

; to demonstrate how to adjust the precision of labels on an additional
; axis, the following resources are needed:
  res@tmYRLabelsOn         = True           ; turn on right axis labels
  res@tmYUseLeft           = False          ; don't use any left settings
  res@tmYRAutoPrecision    = False          ; no auto precision
  res@tmYRPrecision        = 4              ; set the precision  


  plot = gsn_csm_y(wks,u(:,30),res)
end
