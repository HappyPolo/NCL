;================================================
;  lb_10.ncl
;================================================
; Concepts illustrated:
;   - Adding labels to both ends of a labelbar
;   - Adding min/max values to the end of a labelbar
;================================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
;************************************************
begin
;************************************************
; open netCDF file and read in data
;************************************************
  in = addfile("atmos.nc","r")
  v  = in->V
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","lb")          ; send graphics to PNG file

  res                       = True                   ; plot mods desired
  res@gsnMaximize           = True                   ; maximize plot
  res@cnFillOn              = True                   ; turn on color 
  res@cnFillPalette         = "wgne15"   
  res@cnLabelBarEndStyle    = "IncludeMinMaxLabels"  ; turn on end labels

  plot = gsn_csm_contour_map_ce(wks,v(0,3,:,:),res)  ; create the plot
end

