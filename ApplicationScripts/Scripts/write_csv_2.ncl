;----------------------------------------------------------------------
; write_csv_2.ncl
;
; Concepts illustrated:
;   - Writing a CSV file with a header using write_table
;----------------------------------------------------------------------
; This example reads three 4D arrays off a NetCDF file and writes
; the contents to a CSV file with a header that contains the
; long_name and units of each field.
;----------------------------------------------------------------------

begin
;---NetCDF file to read in.
  filename = "80.nc"
  fin      = addfile(filename,"r")

;---Pick three 4D arrays to write to CSV file
  t = fin->T
  u = fin->U
  v = fin->V

;
; Read the 1D coordinate arrays, conform them to 4D,
; then convert to 1D so we can write them to CSV 
; file along with data.
;
  dims   = dimsizes(t)
  time1d = ndtooned(conform_dims(dims,t&time,0))
  lev1d  = ndtooned(conform_dims(dims,t&lev, 1))
  lat1d  = ndtooned(conform_dims(dims,t&lat, 2))
  lon1d  = ndtooned(conform_dims(dims,t&lon, 3))

;---Construct header line
  field_names = (/ t&time@long_name + " ["  + t&time@units + "]", \
                   t&lev@long_name  + " ["  + t&lev@units  + "]", \
                   t&lat@long_name  + " ["  + t&lat@units  + "]", \
                   t&lon@long_name  + " ["  + t&lon@units  + "]", \
                   t@long_name      + " ["  + t@units      + "]", \
                   u@long_name      + " ["  + u@units      + "]", \
                   v@long_name      + " ["  + v@units      + "]"/)

  header = [/str_join(field_names,",")/]

;---Write header to CSV file.
  csv_filename = "80.csv"
  system("rm -rf " + csv_filename)
  write_table(csv_filename, "w", header, "%s")

;---Convert 4D arrays to 1D for writing to CSV file
  t1d  = ndtooned(t)
  u1d  = ndtooned(u)
  v1d  = ndtooned(v)

;---Write data to file
  alist  = [/time1d,lev1d,lat1d,lon1d,t1d,u1d,v1d/]
  format = "%g,%g,%g,%g,%g,%g,%g"
  write_table(csv_filename, "a", alist, format)
end
