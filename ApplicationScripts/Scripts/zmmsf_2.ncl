;*************************************************
;
; NCL Graphics: zmmsf_2.ncl
;
;************************************************
external SUBS "./CCMP_ZM_MSPI.so"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   ; functions required to
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    ; plot. Include before
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"  ; begin
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"  ; begin
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
  nlat =   dimsizes(lat)                        ; get size of lat
  lon  =   a->lon                               ; get lon
  nlon =   dimsizes(lon)                        ; get size of lon
  plev =   a->p_level*100                       ; convert plev mb to Pa
  nlev =   dimsizes(plev)                       ; get size of plev
  ps   =   a->PS                                ; surface pressure in Pa
;************************************************
; calculate the meridional stream function
;************************************************
  msg = v@_FillValue                            ; define missing value

; note: unlike zmmsf_1.ncl space must be pre-allocated for psi because it
; is returned from the subroutine indirectly rather than in a direct manner
; e.g. psi=nclfunc() which allocates the memory behind the scenes. 
; also note that the declaration for psi includes and extra factor,msg
; which is the missing value. The default missing value for ncl is -999,
; while the missing value for v is different. Without this added declaration,
; the plotting routine does not know the correct missing value and plots
; them.
 
  psi = new((/nlev,nlat/),float,msg)          ; allocate memory
  SUBS::CCMP_ZM_MSPI(nlon,nlat,nlev,v,lat,plev,ps,msg,psi)
 
  psi!0   = "lev"                             ; name the coordinates since
  psi!1   = "lat"                             ; zmmsf does not copy them.
  psi&lev = plev                              ; cp plev to lev
  psi&lat = lat                               ; cp lat to "lat"  
  psi&lev@units = "Pa"                        ; assign units (required to plot)
  psi@long_name = "Zonal Mean Meridional Stream Function"
  scale=1e9                                   ; scale for convience
  psi=psi/scale                             
;**********************************************
; create plot
;**********************************************
  wks = gsn_open_wks("ncgm","zmmsf")          ; open a ncgm file
  plot= gsn_csm_pres_hgt(wks,psi,False)       ; create plot    
end
