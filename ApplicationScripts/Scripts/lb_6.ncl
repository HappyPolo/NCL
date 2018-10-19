;================================================
;  lb_6.ncl
;================================================
; Concepts illustrated:
;   - Spanning the full color map in reverse for contour fill
;   - Setting color maps using the new standard
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
  wks = gsn_open_wks("png","lb")                ; send graphics to PNG file
  cmap_data = read_colormap_file("wgne15")      ; save map to be reversed

  res                     = True                ; plot mods desired
  res@cnFillOn            = True                ; turn on color 
  res@cnFillPalette       = cmap_data(::-1,:)   ; set color and reverse with subscripting

  plot = gsn_csm_contour_map_ce(wks,v(0,3,:,:),res)  ; create the plot
end
