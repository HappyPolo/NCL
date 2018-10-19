undef("pixel_interp")
function pixel_interp(x[*][*]:numeric)
begin
;*******************************************
; calculate magnification factor
;*******************************************
 dims = dimsizes(x)
 size = max(dims)

 if(size .gt. 1000) then
    factor = 1
 end if
 if(size .le. 1000) then
    factor = 3
 end if
 if(size .le. 500) then
    factor = 5
 end if
 if(size .le. 300) then
    factor = 7
 end if
 if(size .le. 150) then
    factor = 9
 end if
;*******************************************
; create coordinate variables for new grid
;*******************************************
 newlat       = fspan(min(x&Latitude),max(x&Latitude),\
                      factor*dimsizes(x&Latitude))*1.
 newlat!0     = "lat"
 newlat&lat   = newlat
 newlat@units = "degrees_north"

 newlon       = fspan(min(x&Longitude),max(x&Longitude),\
                          factor*dimsizes(x&Longitude))*1.
 newlon!0     = "lon"
 newlon&lon   = newlon
 newlon@units = "degrees_east"
;*******************************************
; calculate some parameters
;*******************************************
 nlat= dimsizes(newlat)
 nlon= dimsizes(newlon)
;*******************************************
; do interpolation
;*******************************************
 if all(ismissing(x))then                               ; all land
    print("all land: exiting")
    exit
 end if

 if any(ismissing(x))then                               ; some land
   int_x = linint2(x&Longitude,x&Latitude,x,False,newlon,newlat,0)
   SUBS::pixel(int_x,nlon,nlat,int_x@_FillValue,factor)
 end if

 if .not.any(ismissing(x))then                          ; all ocean
   int_x = linint2(x&Longtude,x&Latitude,x,False,newlon,newlat,0)
 end if
;*******************************************
; determine which coastline to apply by range of lat/long
;*******************************************
  lat_range = abs(floattointeger(max(x&Latitude))-\
                  floattointeger(min(x&Latitude)))  
  lon_range = abs(floattointeger(max(x&Longitude))-\
                  floattointeger(min(x&Longitude)))

  coast   = "LowRes"                              ; low res default
  if(lat_range.le.20 .or. lon_range.le.20)then
    coast = "MediumRes"                              ; medium res 
  end if

  if(lat_range .le.5 .or.lon_range.le.5)then
    coast = "HighRes"                               ; high res
  end if
  int_x@coast  = coast                              ; assign coast as attribute
;********************************************
; determine if labels need adjusting
;********************************************
  int_x@labels    = "null"
  if(lat_range.le.20 .or. lon_range.le.20)then
     int_x@labels = "blowup"
  end if
;********************************************
; assign meta data to new array
;********************************************
 int_x!0   = "lat"
 int_x!1   = "lon"
 int_x&lat = newlat
 int_x&lon = newlon
 copy_VarAtts(x,int_x)                               ; copy attributes
 return(int_x)
end

