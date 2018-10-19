
; Read in the data as an nlat*nlon x 3 array (not nlat x nlon x 3)

  nlat =  89
  nlon = 240
  data = asciiread("asc6.txt",(/nlat*nlon,3/),"float")  

; Extract the lat coordinates from the data array.
;
; Since the latitude values are repeated, we only need to
; grab every nlon-th value.

  lat1d = data(::nlon,0)

; Extract the lon coordinates. Since the first "nlon" longitudes
; are unique, and then repeat themselves afterwards, we can just
; grab these first "nlon" values and ignore the rest.

  lon1d  = data(0:nlon-1,1)

; Convert data to a 2D grid.
; 
; The size of grid: (/89,240/) (Note 89 * 240 = 2130)

  temp1D = data(:,2)                      ; 1st create a 1d array
  temp2D = onedtond(temp1D,(/nlat,nlon/)) ; convert 1D array to a 2D array

; Assign named dimensions 

  temp2D!0 = "lat"
  temp2D!1 = "lon"

; Assign coordinate variables

  temp2D&lat = lat1d
  temp2D&lon = lon1d

  printVarSummary(temp2D)
