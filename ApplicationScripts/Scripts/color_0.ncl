;*************************************************
; NCL Graphics: color_0.ncl
;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
;************************************************
; read in zonal winds
;************************************************
  u = a->U(1,:,:)                                ; read July zonal winds
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("ps","color")              ; open a ps file
 
  res = True                                    ; plot mods desired
  res@gsnCenterString      = "300 mb"           ; plot center string
  res@tiMainString         = "Default Color"    ; main title
  res@cnFillOn             = True               ; turn on color fill
  res@mpFillOn             = False              ; turn off continent gray
  res@mpCenterLonF         = 180                ; centers plot at 180 vice 0
  plot = gsn_csm_contour_map(wks,u, res)     ; create plot
  end
