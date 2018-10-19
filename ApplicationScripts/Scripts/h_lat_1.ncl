;----------------------------------------------------------------------
; h_lat_1.ncl
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
;----------------------------------------------------------------------

begin
;************************************************
; read in netCDF file
;************************************************
  a = addfile("atmos.nc","r")
;************************************************
; read in data required for calculation
;************************************************
  v    =   a->V  
  hyam =   a->hyam         
  hybm =   a->hybm
  P0mb =   a->P0*0.01
  ps   =   a->PS           
  lat  =   a->lat                              
  lev_p           = (/600,700,800,900,1000/)
  lev_p@units     = "hPa"                        ; required for vinth2p
;************************************************
; interpolate data to pressure levels
;************************************************
  vp   = vinth2p (v(0,:,:,:), hyam,hybm, lev_p ,ps(0,:,:), 2, P0mb, 1, False )
;************************************************
; calculate the meridional stream function
;************************************************
  psi = zonal_mpsi(vp,lat,lev_p,ps(0,:,:))   ; calculate the zonal mean msf
  psi = psi * 1.e-11
  psi!0   = "lev"                             ; name the coordinates since
  psi!1   = "lat"                             ; zmmsf does not copy them.
  psi&lev = lev_p
  psi&lat = lat                               ; cp lat to "lat"  
  psi@long_name = "Zonal Mean Meridional Stream Function"
;************************************************
; create plot
;************************************************
  wks  = gsn_open_wks ("png", "h_lat" )          ; send graphics to PNG file
  plot = gsn_csm_pres_hgt(wks,psi,False)         ; create plot    
end
