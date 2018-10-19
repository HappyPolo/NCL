;*************************************************
;
; NCL Graphics: zmmsf_1.ncl
;
;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   ; functions required to
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    ; plot. Include before
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" ; begin
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl" ; begin
load "./zmmsf.ncl"                              ; Dave Step's function
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  a = addfile("~/WORK/Data/ATMOS/T638610MM.nc","r")
;************************************************
; read in data required for calculation
;************************************************
  v    =   a->V                                 ; get V
  lat  =   a->lat                               ; get lat  
  plev =   a->p_level*100                       ; convert plev mb to Pa
  ps   =   a->PS                                ; surface pressure in Pa
;************************************************
; calculate the meridional stream function
;************************************************
  msg = v@_FillValue                          ; define missing value
  psi = zmmsf( v, plev, lat, ps, msg )        ; calculate the zonal mean msf
  psi!0   = "lev"                             ; name the coordinates since
  psi!1   = "lat"                             ; zmmsf does not copy them.
  psi&lev = plev                              ; cp plev to lev
  psi&lat = lat                               ; cp lat to "lat"  
  psi&lev@units = "Pa"                        ; assign units (required to plot)
  psi@long_name = "Zonal Mean Meridional Stream Function"
  scale = 1e9
  psi   = psi/scale
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("ncgm","zmmsf")            ; open a ncgm file
  plot= gsn_csm_pres_hgt(wks,psi,False)         ; create plot    
end
