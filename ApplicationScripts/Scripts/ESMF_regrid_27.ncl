;======================================================================
; ESMF_regrid_27.ncl
;
; Concepts illustrated:
;   - Interpolating data from an ECMWF Model Operational grid to a 2.5 degree grid
;   - Using ESMF_regrid to create an interpolation weights file
;   - Interpolating from one grid to another using ESMF_regrid_with_weights
;   - Writing data to a NetCDF file using the efficient method
;======================================================================
; This script creates a weights file for regridding from an ECMWF
; operational model analysis 1280 x 2560 Gaussian grid to a 2.5 
; degree grid using "bilinear" interpolation. The weights file is then
; used to regrid several variables across multiple ECMWF files.
;
; The results are written to individual netCDF files using the
; "efficient" method.
;
; The plots created in this script are main to visually 'validate' 
; the regridding.
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

;----------------------------------------------------------------------
; This procedure compares plots of original data with regridded
; data. This is mostly for debug purposes.
;
; It creates filled contour plots of both the original data and 
; the regridded data, and panels them on one page.
;----------------------------------------------------------------------
procedure plot_data(varname,var,var_regrid,grid_type,interp_method)
local wks, res
begin
  wks = gsn_open_wks("png","ECMWF_to_" + grid_type + "_" + interp_method)
  res                       = True

  res@gsnMaximize           = True

  res@gsnDraw               = False
  res@gsnFrame              = False

  res@cnFillOn              = True
  res@cnLinesOn             = False
  res@cnLineLabelsOn        = False
  res@cnFillMode            = "RasterFill"

  res@lbLabelBarOn          = False    ; Turn on later in panel

  mnmxint = nice_mnmxintvl( min(var), max(var), 18, False)
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       = mnmxint(0)
  res@cnMaxLevelValF       = mnmxint(1)
  res@cnLevelSpacingF      = mnmxint(2)

;---Resources for plotting regridded data
  res@gsnAddCyclic  = False
  dims = tostring(dimsizes(var_regrid))
  res@tiMainString  = grid_type + " grid (" + interp_method + ")" + \
                      " (" + str_join(dims," x ") + ")"
  plot_regrid = gsn_csm_contour_map(wks,var_regrid,res)

;---Resources for plotting original data
  dims = tostring(dimsizes(var))
  res@gsnAddCyclic = True
  res@tiMainString = varname + " (" + str_join(dims," x ") + ")"

  plot_orig = gsn_csm_contour_map(wks,var,res)  

;---Compare the plots in a panel
  pres                   = True
  pres@gsnMaximize       = True
  pres@gsnPanelLabelBar  = True

  gsn_panel(wks,(/plot_orig,plot_regrid/),(/2,1/),pres)
end

;----------------------------------------------------------------------
; This procedure creates an interpolation weights file for
; regridding from given rectilinear variable to the given
; grid type. The assumption here is that the given variable
; contains coordinate arrays, which will be automatically used
; for the source grid.
;----------------------------------------------------------------------
procedure generate_weights(src_filename,varname,interp_method,\
                           grid_type,wgt_filename)
local sfile, x, Opt
begin
  sfile = addfile(src_filename,"r")

;---Variable to regrid
  x = sfile->$varname$

  Opt                   = True
  Opt@InterpMethod      = interp_method
  Opt@WgtFileName       = wgt_filename

  Opt@SrcRegional       = False
  Opt@SrcInputFileName  = src_filename
  Opt@SrcMask2D         = where(.not.ismissing(x),1,0)

  Opt@DstGridType       = grid_type
  Opt@DstLLCorner       = (/ -88.75d, -180.d/)
  Opt@DstURCorner       = (/  88.75d, 177.5d/)
  Opt@DstRegional       = False

  Opt@ForceOverwrite    = True
  Opt@PrintTimings      = False
  Opt@Debug             = False

  x_regrid = ESMF_regrid(x,Opt)   ; Do the regridding and create the weights

  printVarSummary(x_regrid)       ; Check that everything
  printMinMax(x,0)                ; looks okay.
  printMinMax(x_regrid,0)

;---Plot the data for verification purposes 
  plot_data(varname,x,x_regrid,grid_type,interp_method)

  delete(Opt)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
  GRID_TYPE     = "2.5deg"
  INTERP_METHOD = "bilinear" 
  wgtFileName   = "ECMWF_rectilinear_to_" + GRID_TYPE + "_" + \
                  INTERP_METHOD + ".nc"     

  GEN_WEIGHTS   = True    ; Set to False if weights already been generated
  PLOT_DATA     = False   ; Whether to create plots of every regridded variable
  DEBUG_PRINT   = True    ; Prints mins/maxs of original and regridded data

;---List of files to regrid variables from.
  dir = "./"
  all_ncfiles = systemfunc("ls " + dir + "od_oper_an_pl_2012*grb*.nc")
  nfiles      = dimsizes(all_ncfiles)
  print("==================================================")
  print("Number of files = " + nfiles)

;----------------------------------------------------------------------
; Section to generate the regridding weights file. Once we have this,
; we can regrid other variables on this and other files. This can be 
; much faster than regenerating the weights file every time. If you
; already have the weights file, you can set GEN_WEIGHTS to False to
; skip this section.
;----------------------------------------------------------------------
  if(GEN_WEIGHTS) then
    print("==================================================")
    print("Generating '" + wgtFileName + "' weights file...")
    generate_weights(all_ncfiles(0),"T_GDS4_ISBL",INTERP_METHOD,GRID_TYPE,\
                     wgtFileName)
  end if

;----------------------------------------------------------------------
; Section to regrid rest of variables in all files and write to a
; series of NetCDF files.
;----------------------------------------------------------------------
  Opt              = True  
  Opt@ReturnDouble = True    ; Default is float if input is float

  do nf=0,nfiles-1 
    srcFileName = all_ncfiles(nf)
    tmpstr  = str_split(srcFileName,"/")
    ntmp    = dimsizes(tmpstr)
    srcname = tmpstr(ntmp-1)    ; File name without directory path
  
;---Get time information from file name
    year   = toint(str_get_cols(srcname,14,17))
    month  = toint(str_get_cols(srcname,18,19))
    day    = toint(str_get_cols(srcname,20,21))
    hour   = toint(str_get_cols(srcname,22,24))
    doy    = day_of_year(year,month,day)
    time   = todouble(doy+hour/24.)

    print("==================================================")
    print("Processing file " + nf + " of " + nfiles)
    print("Input file  = '" + srcname + "'")
    print("Time        = " + time)

;---Open the source data file and get some data to regrid
    sfile = addfile(srcFileName,"r")
    z     = sfile->Z_GDS4_ISBL           
    t     = sfile->T_GDS4_ISBL           

    z_regrid = ESMF_regrid_with_weights(z,wgtFileName,Opt)
    t_regrid = ESMF_regrid_with_weights(t,wgtFileName,Opt)

    if(DEBUG_PRINT) then
      print("------------------Original data------------------------")
      printMinMax(z,0)
      printMinMax(t,0)
      print("------------------Regridded data-----------------------")
      printMinMax(z_regrid,0)
      printMinMax(t_regrid,0)
      print("-------------------------------------------------------")
    end if

    if(PLOT_DATA) then
      plot_data("Z_GDS4_ISBL",z,z_regrid,GRID_TYPE,INTERP_METHOD)
      plot_data("T_GDS4_ISBL",t,t_regrid,GRID_TYPE,INTERP_METHOD)
    end if
    
;---Define dimensions 
  lat   = z_regrid&lat  ; type double
  lon   = z_regrid&lon
  nlat  = dimsizes(lat)
  nlon  = dimsizes(lon)
  ntime = 1
  
; associating atributes with variables  
  lon@_FillValue = -9999.
  lat@_FillValue = -9999.
  
  time@units      = "day of year inc ut"
  time@_FillValue = -9999.
  year@units      = "year"
  year@_FillValue = -9999
  day@units       = "day"
  day@_FillValue  = -9999
  hour@units      = "hour"
  hour@_FillValue = -9999
  doy@units       = "day_of_year"
  doy@_FillValue  = -9999
  
;----------------------------------------------------------------------
; Section to write regridded variables to NetCDF file using
; "efficient" method. This means that all attributes, dimension sizes,
; dimension names, etc. are predefined on the file before we write
; any actual values.
;----------------------------------------------------------------------

;---Open output NetCDF file to write to.
  file_new = str_concat((/str_get_cols(srcname,0,31),"_map",".nc"/))
  print("Output file = '" + file_new + "'") 

  system("/bin/rm -f " + file_new)    ; remove if exists
  fout  = addfile (file_new, "c")     ; open output file
  
;---Go into define mode       
  setfileoption(fout,"DefineMode",True) 
  
;---Define global file attributes   
  fAtt               = True            ; assign file attributes
  fAtt@title_now                  = "ECMWF DS113 mapped to TGCM grid"  
  fAtt@source_file                =  srcname
  fAtt@creation_date              = systemfunc ("date")
  fAtt@original_dataset_reference = "http://rda.ucar.edu/datasets/ds113.0/" 
  fAtt@processing_procedure       = "at hao /home/tgcm/ecmwf_toga/README_2012" ;
  fAtt@remap                      = "NCL: ESMF_regrid_with_weights " + \
                                    "(NCL version " + get_ncl_version() + ")"
  fileattdef( fout, fAtt )	      ; copy file attributes	
  copy_VarAtts(sfile, fout)           ; copy global attributes


;--Define coordinates    
; Note: to get an UNLIMITED record dimension, we set the dimensionality
; to -1 (or the actual size) and set the dimension name to True.
  dimNames = (/"time", "lat", "lon"/)  
  dimSizes = (/ ntime,  nlat,  nlon /) 
  dimUnlim = (/ True , False, False/)   
  filedimdef(fout,dimNames,dimSizes,dimUnlim)
  
;---Predefine the the dimensionality of the variables to be written out 
  filevardef(fout, "time" ,typeof(time),"time") 			   
  filevardef(fout, "lat"  ,typeof(lat), "lat")			  
  filevardef(fout, "lon"  ,typeof(lon), "lon")
  filevardef(fout, "Z"    ,typeof(z_regrid)  ,(/"time", "lat", "lon"/))
  filevardef(fout, "T"    ,typeof(t_regrid)  ,(/"time", "lat", "lon"/))
  filevardef(fout, "year" ,typeof(year),"time")
  filevardef(fout, "day"  ,typeof(day) ,"time")			  
  filevardef(fout, "hour" ,typeof(hour),"time")
  filevardef(fout, "doy"  ,typeof(doy) ,"time")
			  			
;---Copy attributes associated with each variable to the file         
  filevarattdef(fout,"Z",z_regrid)	       ; copy attributes   
  filevarattdef(fout,"T",t_regrid)	       ; copy attributes
  filevarattdef(fout,"time" ,time)	       ; copy time attributes	  
  filevarattdef(fout,"lat"  ,lat)	       ; copy lat attributes
  filevarattdef(fout,"lon"  ,lon)	       ; copy lon attributes
  filevarattdef(fout,"year" ,year)	      
  filevarattdef(fout,"day"  ,day)	     
  filevarattdef(fout,"hour" ,hour)	     
  filevarattdef(fout,"doy"  ,doy)	     

;---End define mode  
  setfileoption(fout,"DefineMode",False)
  
;---Promote 2D arrays to 3D arrays to add time dimension
  zd = conform_dims((/1,nlat,nlon/),z_regrid,(/1,2/))
  td = conform_dims((/1,nlat,nlon/),t_regrid,(/1,2/))
  
;---Output only the data values to the NetCDF file
  fout->time   = (/time/)
  fout->lat    = (/lat/)
  fout->lon    = (/lon/) 
  fout->Z      = (/zd/)
  fout->T      = (/td/)
  fout->year   = (/year/) 
  fout->day    = (/day/) 
  fout->hour   = (/hour/) 
  fout->doy    = (/doy/)   
  
 end do
 
end
