;******************************************
undef("nogaps_lat")
function nogaps_lat(latmin:integer,latmax:integer)
begin
    lat       = ispan(latmin,latmax,1)*1.
    lat!0     = "lat"
    lat@units = "degrees_north"
    lat&lat   = lat
    return(lat)
end
;******************************************
undef("nogaps_lon")
function nogaps_lon(lonmin:integer,lonmax:integer)
begin
  lon       = ispan(lonmin,lonmax,1)*1.
  lon!0     = "lon"
  lon@units = "degrees_east"
  lon&lon   = lon
  return(lon)
end
;******************************************
undef("create_meta")
function create_meta(var_name:string,x[*][*]:numeric,lat[*]:float,lon[*]:float)
begin
   x@_FillValue = -999.                    ; assign fill value
;   x = x/1.                                ; to make nearly zero = 0.0
   if(var_name.eq."pres" .or. var_name.eq."air_temp")then
	x = mask(x,x.lt.0.000001,False)
   end if

   if(var_name .eq. "pres")then
      x = x/100.                           ; convert to mb from Pa
   end if

   x!0   = "lat"                           ; name dimensions
   x!1   = "lon"

   x&lat = lat                             ; assign cv's
   x&lon = lon 

; check for bad data values
   error = new(3,string)
   error = (/"pres","air_temp","grnd_sea_temp"/)
   if any(var_name .eq. error)then
       x = mask(x, x .eq. 0.0, False)
   end if
;*****************************************************
; assign attributes
;***************************************************** 
   if(var_name.eq."air_temp")then
     x@long_name  = "Temperature"
     x@units      = "deg K"
   end if
  if(var_name.eq."grnd_sea_temp")then
     x@long_name  ="Ground or SST"
     x@units      = "deg K"
   end if
   if(var_name.eq."dwpt_dprs_surface")then
     x@long_name  = "Dew Pt Depression"
     x@units      = "deg K"
   end if
   if(var_name.eq."pres")then
     x@long_name  = "Surface Pressure"
     x@units      = "mb"
   end if
  if(var_name.eq."vpr_pres")then
     x@long_name  = "Vapor Pressure"
     x@units      = "Pa"
   end if
 if(var_name.eq."ttl_prcp")then
     x@long_name  = "Total Precipitation"
     x@units      = "kg/m/m"
   end if
;***************
; fluxes
;***************
   if(var_name.eq."sol_rad")then
     x@long_name  = "Solar_Radiation"
     x@units      = "W/m**2"
   end if
   if(var_name.eq."ttl_heat_flux")then
     x@long_name  = "Total Heat Flux"
     x@units      = "W/m**2"
   end if
   if(var_name.eq."snsb_heat_flux")then
     x@long_name  = "Sensible Heat Flux"
     x@units      = "W/m**2"
   end if
   if(var_name.eq."snsb_ltnt_heat_flux")then
     x@long_name  = "Sensible Latent Heat Flux"
     x@units      = "W/m**2"
   end if
   if(var_name.eq."ir_flux")then
     x@long_name  = "IR Flux"
     x@units      = "W/m**2"
   end if


   return(x)
end
;******************************************

    