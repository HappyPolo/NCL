;----------------------------------------------------------------------
; create_netcdf_file_eff.ncl
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
;----------------------------------------------------------------------
; Compare the timing of this script with the "inefficient" version,
; create_netcdf_file_ineff.ncl. Both scripts should produce identical
; files.
;----------------------------------------------------------------------
; This script is similar to create_netcdf_file_eff_nvars.ncl, except 
; the variables being written to the file are hard-wired to be "var01"
; through "var20".
;
; See the create_netcdf_file_eff_nvars.ncl script if you want to 
; write an arbitrary number of variables to the file.
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

;---Open a new NetCDF file to write to
  setfileoption("nc","preFill",False)
  setfileoption("nc","defineMode",True)

;---Open a new NetCDF file to write to
  fout_name = "netcdf_eff.nc"
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

;---Define the dimension names and their sizes on the file
  dims          = dimsizes(var01)     ; ntim x nlev x nlat x nlev
  dim_names     = getvardims(var01)   ; "time", "lev", "lat", "lon"
  dim_unlimited = (/False,False,False,False/)
  filedimdef(fout,dim_names,dims,dim_unlimited)

;---Define each variable, its type, its dimension names, and its size
  filevardef(fout,"time",typeof(var01&time),"time")
  filevardef(fout,"lev",typeof(var01&lev),"lev")
  filevardef(fout,"lat",typeof(var01&lat),"lat")
  filevardef(fout,"lon",typeof(var01&lon),"lon")
  filevardef(fout,"var01",typeof(var01),dim_names)
  filevardef(fout,"var02",typeof(var02),dim_names)
  filevardef(fout,"var03",typeof(var03),dim_names)
  filevardef(fout,"var04",typeof(var04),dim_names)
  filevardef(fout,"var05",typeof(var05),dim_names)
  filevardef(fout,"var06",typeof(var06),dim_names)
  filevardef(fout,"var07",typeof(var07),dim_names)
  filevardef(fout,"var08",typeof(var08),dim_names)
  filevardef(fout,"var09",typeof(var09),dim_names)
  filevardef(fout,"var10",typeof(var10),dim_names)
  filevardef(fout,"var11",typeof(var11),dim_names)
  filevardef(fout,"var12",typeof(var12),dim_names)
  filevardef(fout,"var13",typeof(var13),dim_names)
  filevardef(fout,"var14",typeof(var14),dim_names)
  filevardef(fout,"var15",typeof(var15),dim_names)
  filevardef(fout,"var16",typeof(var16),dim_names)
  filevardef(fout,"var17",typeof(var17),dim_names)
  filevardef(fout,"var18",typeof(var18),dim_names)
  filevardef(fout,"var19",typeof(var19),dim_names)
  filevardef(fout,"var20",typeof(var20),dim_names)

;---Define each variable's attributes.
  filevarattdef(fout,"time",var01&time)
  filevarattdef(fout,"lev",var01&lev)
  filevarattdef(fout,"lat",var01&lat)
  filevarattdef(fout,"lon",var01&lon)
  filevarattdef(fout,"var01",var01)
  filevarattdef(fout,"var02",var02)
  filevarattdef(fout,"var03",var03)
  filevarattdef(fout,"var04",var04)
  filevarattdef(fout,"var05",var05)
  filevarattdef(fout,"var06",var06)
  filevarattdef(fout,"var07",var07)
  filevarattdef(fout,"var08",var08)
  filevarattdef(fout,"var09",var09)
  filevarattdef(fout,"var10",var10)
  filevarattdef(fout,"var11",var11)
  filevarattdef(fout,"var12",var12)
  filevarattdef(fout,"var13",var13)
  filevarattdef(fout,"var14",var14)
  filevarattdef(fout,"var15",var15)
  filevarattdef(fout,"var16",var16)
  filevarattdef(fout,"var17",var17)
  filevarattdef(fout,"var18",var18)
  filevarattdef(fout,"var19",var19)
  filevarattdef(fout,"var20",var20)

;---NOW write the variables to the file.
  fout->time  = (/var01&time/)
  fout->lev   = (/var01&lev/)
  fout->lat   = (/var01&lat/)
  fout->lon   = (/var01&lon/)
  fout->var01 = (/var01/)
  fout->var02 = (/var02/)
  fout->var03 = (/var03/)
  fout->var04 = (/var04/)
  fout->var05 = (/var05/)
  fout->var06 = (/var06/)
  fout->var07 = (/var07/)
  fout->var08 = (/var08/)
  fout->var09 = (/var09/)
  fout->var10 = (/var10/)
  fout->var11 = (/var11/)
  fout->var12 = (/var12/)
  fout->var13 = (/var13/)
  fout->var14 = (/var14/)
  fout->var15 = (/var15/)
  fout->var16 = (/var16/)
  fout->var17 = (/var17/)
  fout->var18 = (/var18/)
  fout->var19 = (/var19/)
  fout->var20 = (/var20/)

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
