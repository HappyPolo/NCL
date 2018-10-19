;================================================
;  lb_1.ncl
;================================================
;
; Concepts illustrated:
;   - Generating the default labelbar on a contour plot
;   - Setting color maps using the new standard
;
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
  wks = gsn_open_wks("png","lb")           ; send graphics to PNG file

  res               =   True
  res@cnFillOn      =   True               ; turn on color
  res@cnFillPalette =   "wgne15"           ; set color map
  contour = gsn_csm_contour_map_ce(wks,v(0,3,:,:),res)  ; create the plot
end
