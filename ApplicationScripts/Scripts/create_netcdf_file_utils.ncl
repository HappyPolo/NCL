;----------------------------------------------------------------------
; These are utility scripts used by the create_netcdf_file_xxxx.ncl 
; suite of examples.
;----------------------------------------------------------------------

;----------------------------------------------------------------------
; This function creates a dummy time coordinate array.
;----------------------------------------------------------------------
function create_dummy_time(ntim)
begin
  time = ispan(1,ntim,1)*1.
  time!0 = "time"
  time@long_name = "index values"
  time@units     = "none"
  return(time)
end

;----------------------------------------------------------------------
; This function creates a dummy level coordinate array.
;----------------------------------------------------------------------
function create_dummy_lev(nlev)
begin
  lev   = fspan(1000,10,nlev)
  lev!0 = "lev"
  lev@long_name = "hybrid level"
  lev@units     = "level"
  return(lev)
end

;----------------------------------------------------------------------
; This function creates a dummy latitude coordinate array.
;----------------------------------------------------------------------
function create_dummy_lat(nlat)
begin
  lat   = fspan(-90,90,nlat)
  lat!0 = "lat"
  lat@long_name = "latitude"
  lat@units     = "degrees_north"
  return(lat)
end

;----------------------------------------------------------------------
; This function creates a dummy longitude coordinate array.
;----------------------------------------------------------------------
function create_dummy_lon(nlon)
begin
  lon   = fspan(-180,180,nlon)
  lon!0 = "lon"
  lon@long_name = "longitude"
  lon@units     = "degrees_east"
  return(lon)
end

;----------------------------------------------------------------------
; Given a 1D array of time, level, lat, and lon values, create a
; dummy 4D variable with these arrays attached as coordinate variables.
;----------------------------------------------------------------------
function create_dummy_var(uniq_name,time,lev,lat,lon,dtype)
local ntim, nlev, nlat, nlon, dims
begin
;---Get some dimensions
  ntim = dimsizes(time)
  nlev = dimsizes(lev)
  nlat = dimsizes(lat)
  nlon = dimsizes(lon)
  dims = (/ntim,nlev,nlat,nlon/)

  var4d = totype(random_uniform(-100,100,dims),dtype)
  var4d!0    = time!0    ; Name the dimensions
  var4d!1    = lev!0
  var4d!2    = lat!0
  var4d!3    = lon!0
  var4d&$time!0$ = time  ; Assign the coordinate
  var4d&$lev!0$  = lev   ; variables
  var4d&$lat!0$  = lat
  var4d&$lon!0$  = lon
  var4d@long_name = "variable_"+uniq_name
  var4d@units     = "units_"+uniq_name
  return(var4d)
end
