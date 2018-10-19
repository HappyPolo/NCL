;*************************************************
; gsn_xy_5.ncl
;************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
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
  wks = gsn_open_wks("png","gsn_xy")                       ; send graphics to PNG file   

  res                        = True                        ; plot mods desired
  res@tiYAxisString          = u@long_name + " "+u@units   ; add units to title 
  res@tiMainString          = "Example of gsn_y"      ; title
  plot=gsn_y(wks,u(:,30),res)

end
