;----------------------------------------------------------------------
; create_netcdf_file_eff_nvars.ncl
;
; Concepts illustrated:
;   - Writing data to a NetCDF file using the efficient method
;----------------------------------------------------------------------

;----------------------------------------------------------------------
; This script tests writing several variables to a NetCDF file using 
; the efficient method, where all the variables' information is 
; predefined on the the output file before *any* variables' values are 
; written to the file.
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
; Compare the timing of this script with the "inefficient" version,
; create_netcdf_file_ineff.ncl. Both scripts should produce identical
; files.
;----------------------------------------------------------------------
; This script is similar to create_netcdf_file_eff.ncl, except it
; allows you to arbitrarily choose the number of variables you want
; to write to the file. Each variable will have the exact same values,
; because it uses the same dummy array each time.
;----------------------------------------------------------------------
; The timings for this script on a Mac were:
;
;        Writing file: 21.8061
;        Reading file: 16.7363
;
; Note: "Reading file" section should be roughly the same timings on
; both scripts, since the code is identical.
;----------------------------------------------------------------------
load "./create_netcdf_file_utils.ncl"

begin  
  start_write_time = get_cpu_time()

;---Set some NetCDF options before we open the file
  setfileoption("nc","preFill",False)
  setfileoption("nc","defineMode",True)
;
; You might need to uncomment this if writing a lot of variables to 
; the file, or large variabes.
;
;  setfileoption("nc","Format","NetCDF4")          

;---Open a new NetCDF file to write to
  fout_name = "netcdf_eff_nvars.nc"
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

;---Define the dimension names and their sizes on the file
  dims          = (/ntim,nlev,nlat,nlon/)
  dim_names     = (/time!0,lev!0,lat!0,lon!0/)
  dim_unlimited = (/False,False,False,False/)
  filedimdef(fout,dim_names,dims,dim_unlimited)

;---Define each variable, its type, its dimension names, and its size
  filevardef(fout,time!0,typeof(time),time!0)
  filevardef(fout,lev!0,typeof(lev),lev!0)
  filevardef(fout,lat!0,typeof(lat),lat!0)
  filevardef(fout,lon!0,typeof(lon),lon!0)
  do nv=0,nvars-1
    filevardef(fout,var_names(nv),var_type,dim_names)
  end do

;---Define each variable's attributes.
  filevarattdef(fout,time!0,time)
  filevarattdef(fout,lev!0, lev)
  filevarattdef(fout,lat!0, lat)
  filevarattdef(fout,lon!0, lon)

  fatt = True
  do nv=0,nvars-1
    fatt@long_name = var_names(nv)
    fatt@units     = "units_"+var_names(nv)
    filevarattdef(fout,var_names(nv),fatt)
  end do

;---NOW write the variables to the file.
  fout->time  = (/time/)
  fout->lev   = (/lev/)
  fout->lat   = (/lat/)
  fout->lon   = (/lon/)
  x = create_dummy_var(var_names(0),time,lev,lat,lon,var_type)
  do nv=0,nvars-1
    fout->$var_names(nv)$ = (/x/)
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
