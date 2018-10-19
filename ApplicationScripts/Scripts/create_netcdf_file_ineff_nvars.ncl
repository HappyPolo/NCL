;----------------------------------------------------------------------
; create_netcdf_file_ineff_nvars.ncl
;
; Concepts illustrated:
;   - Writing data to a NetCDF file using the easy but inefficient method
;----------------------------------------------------------------------

;----------------------------------------------------------------------
; This script tests writing several variables to a NetCDF file using 
; the inefficient method, where we don't bother to predefine any 
; variables.
;
; The NetCDF file created will be over 2 GB, so make sure you have
; enough disk space. If you don't, you can decrease the size of one
; or more of these array sizes:
;
;  ntim =   20
;  nlev =   10
;  nlat =  256
;  nlon =  512
;  nvars =  20
;----------------------------------------------------------------------
; Compare the timing of this script with the "efficient" version,
; create_netcdf_file_eff_nvars.ncl. Both scripts should produce identical
; files.
;----------------------------------------------------------------------
; This script is similar to create_netcdf_file_ineff.ncl, except it
; allows you to arbitrarily choose the number of variables you want
; to write to the file. Each variable will have the exact same values,
; because it uses the same dummy array each time.
;----------------------------------------------------------------------
; The timings for this script on a Mac were:
;
;        Writing file: 39.1144
;        Reading file: 16.5557
;
; Note: "Reading file" section should be roughly the same timings on
; both scripts, since the code is identical.
;----------------------------------------------------------------------
load "./create_netcdf_file_utils.ncl"

begin  
  start_write_time = get_cpu_time()
;
; You might need to uncomment this if writing a lot of variables to 
; the file, or large variabes.
;
;  setfileoption("nc","Format","NetCDF4")          

;---Open a new NetCDF file to write to
  fout_name = "netcdf_ineff_nvars.nc"
  system("rm -f " + fout_name)
  fout = addfile(fout_name,"c")

;---Create a bunch of dummy variables with coordinate arrays attached
  ntim =   20
  nlev =   10
  nlat =  256
  nlon =  512
  nvars = 20

  time  = create_dummy_time(ntim)
  lev   = create_dummy_lev(nlev)
  lat   = create_dummy_lat(nlat)
  lon   = create_dummy_lon(nlon)
  data  = new((/nvars,ntim,nlev,nlat,nlon/),float)
  var_names = "var" + sprinti("%02i",ispan(1,nvars,1))
  var_type  = "float"

;
; Write all variables to the NetCDF file. This highly inefficient because
; we haven't predefined anything on the file.
; 
  x = create_dummy_var(var_names(0),time,lev,lat,lon,var_type)
  do nv=0,nvars-1
    x@long_name = var_names(nv)
    x@units     = "units_"+var_names(nv)
    fout->$var_names(nv)$ = x
  end do

  end_write_time = get_cpu_time()

;---Close file. Not necessary, but a good idea.
  delete(fout)

;----------------------------------------------------------------------
; Read the created file back in so we can verify that the values
; look correct.
;----------------------------------------------------------------------
  start_read_time = get_cpu_time()
  fin = addfile(fout_name,"r")
  vnames = getfilevarnames(fin)
  sqsort(vnames)
  do nv=0,dimsizes(vnames)-1
    x := fin->$vnames(nv)$
    print("==================================================")
    printMinMax(x,0)
    print("average = " + avg(x))
  end do
  end_read_time = get_cpu_time()

;----------------------------------------------------------------------
; Print the timing results.
;----------------------------------------------------------------------
  print("==================================================")
  print(get_script_prefix_name() + ".ncl timings")
  print("   Writing file: " + (end_write_time-start_write_time))
  print("   Reading file: " + (end_read_time-start_read_time))
  print("==================================================")

end
  
