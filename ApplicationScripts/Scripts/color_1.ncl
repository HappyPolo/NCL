;*************************************************
; color_1.ncl
;
; Concepts illustrated:
;   - Drawing color filled contours using the default color map
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
  u = a->U(1,:,:)                                ; read July zonal winds
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","color")             ; send graphics to PNG file
 
  res                      = True               ; plot mods desired
  res@tiMainString         = "Default Color"    ; main title
  res@cnFillOn             = True               ; turn on color fill

  plot = gsn_csm_contour_map(wks,u, res)     ; create plot
  end
