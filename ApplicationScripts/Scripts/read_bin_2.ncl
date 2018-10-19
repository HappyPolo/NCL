;----------------------------------------------------------------------
; read_bin_2.ncl
;
; Concepts illustrated:
;   - Using fbindirread to read data from record 0 off several binary files
;   - Writing data to a NetCDF file using the easy but inefficient method
;   - Adding meta data (attributes and coordinates) to a variable
;----------------------------------------------------------------------
begin
  nlat = 90
  nlon = 180
  fils = systemfunc("ls /tmp/dailydata/*.dat")

;---Predefine array for one year of daily data
  finarr = new((/dimsizes(fils),nlat,nlon/),"float")   

;---Loop through each file and read
  rec_num = 0     ; record number
  do gg = 0,dimsizes(fils)-1
     finarr(gg,:,:) = fbindirread(fils(gg),rec_num,(/nlat,nlon/),"float")
  end do

  print("Assigning coordinate variable information")
  finarr!0 = "time"
  finarr!1 = "lat"
  finarr!2 = "lon"
  finarr&time = ispan(1,dimsizes(fils),1)
  finarr&lat  = fspan(-89,89,nlat)
  finarr&lon  = fspan(0,359,nlon)
  finarr&lat@units = "degrees_north"
  finarr&lon@units = "degrees_east"

;----------------------------------------------------------------------
; Section to write data to netCDF file
;----------------------------------------------------------------------

;---Make sure file doesn't exist.
  nc_filename = "sample.nc"
  system("rm -f " + nc_filename)

;---Open file and write global attributes
  a = addfile("sample.nc","c")
  a@title = "1 year of daily data"
  a@source = "Your program name/location"

;---Make time an UNLIMITED dimension, always recommended
  filedimdef(a,"time",-1,True)    

;---Write "SLP" data to file
  a->SLP = finarr
end 
    