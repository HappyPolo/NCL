;================================================
;  lb_8.ncl
;================================================
; Concepts illustrated:
;   - Keeping labelbar labels from overlapping
;   - Changing the contour level spacing
;   - Setting color maps using the new standard
;================================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
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

  res                   =   True          ; plot mods desired
  res@cnFillOn          =   True          ; turn on color  
  res@cnLevelSpacingF   =   1             ; set finer contour spacing

  plot = gsn_csm_contour_map_ce(wks,v(0,3,:,:),res)  ; create the plot
end
