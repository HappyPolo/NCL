;----------------------------------------------------------------------
; create_netcdf_file_ineff.ncl
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
;----------------------------------------------------------------------
; Compare the timing of this script with the "efficient" version,
; create_netcdf_file_eff.ncl. Both scripts should produce identical
; files.
;----------------------------------------------------------------------
; This script is similar to create_netcdf_file_ineff_nvars.ncl, except 
; the variables being written to the file are hard-wired to be "var01"
; through "var20".
;
; See the create_netcdf_file_ineff_nvars.ncl script if you want to 
; write an arbitrary number of variables to the file.
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

;---Open a new NetCDF file to write to
  fout_name = "netcdf_ineff.nc"
  system("rm -f " + fout_name)
  fout = addfile(fout_name,"c")

;---Create a bunch of dummy variables with coordinate arrays attached
  var_type  = "float"
  ntim =   20
  nlev =   10
  nlat =  256
  nlon =  512

  time  = create_dummy_time(ntim)
  lev   = create_dummy_lev(nlev)
  lat   = create_dummy_lat(nlat)
  lon   = create_dummy_lon(nlon)
  var01 = create_dummy_var("var01",time,lev,lat,lon,var_type)
  var02 = create_dummy_var("var02",time,lev,lat,lon,var_type)
  var03 = create_dummy_var("var03",time,lev,lat,lon,var_type)
  var04 = create_dummy_var("var04",time,lev,lat,lon,var_type)
  var05 = create_dummy_var("var05",time,lev,lat,lon,var_type)
  var06 = create_dummy_var("var06",time,lev,lat,lon,var_type)
  var07 = create_dummy_var("var07",time,lev,lat,lon,var_type)
  var08 = create_dummy_var("var08",time,lev,lat,lon,var_type)
  var09 = create_dummy_var("var09",time,lev,lat,lon,var_type)
  var10 = create_dummy_var("var10",time,lev,lat,lon,var_type)
  var11 = create_dummy_var("var11",time,lev,lat,lon,var_type)
  var12 = create_dummy_var("var12",time,lev,lat,lon,var_type)
  var13 = create_dummy_var("var13",time,lev,lat,lon,var_type)
  var14 = create_dummy_var("var14",time,lev,lat,lon,var_type)
  var15 = create_dummy_var("var15",time,lev,lat,lon,var_type)
  var16 = create_dummy_var("var16",time,lev,lat,lon,var_type)
  var17 = create_dummy_var("var17",time,lev,lat,lon,var_type)
  var18 = create_dummy_var("var18",time,lev,lat,lon,var_type)
  var19 = create_dummy_var("var19",time,lev,lat,lon,var_type)
  var20 = create_dummy_var("var20",time,lev,lat,lon,var_type)

;---Write all variables to the NetCDF file. This is inefficient!
  fout->var01 = var01
  fout->var02 = var02
  fout->var03 = var03
  fout->var04 = var04
  fout->var05 = var05
  fout->var06 = var06
  fout->var07 = var07
  fout->var08 = var08
  fout->var09 = var09
  fout->var10 = var10
  fout->var11 = var11
  fout->var12 = var12
  fout->var13 = var13
  fout->var14 = var14
  fout->var15 = var15
  fout->var16 = var16
  fout->var17 = var17
  fout->var18 = var18
  fout->var19 = var19
  fout->var20 = var20

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
  
