;----------------------------------------------------------------------
; shapefiles_23.ncl
;
; Concepts illustrated:
;   - Creating a mask array using outlines from a shapefile
;   - Masking WRF output data using a mask array
;   - Writing masked variables to a new NetCDF file
;   - Plotting original and masked variables in a panel plot
;   - Using functions for cleaner code
;----------------------------------------------------------------------
; This script:
;
; - Creates a mask array for the WRF XLAT/XLONG grid using a shapefile 
;   outline. The mask array is written to a NetCDF file. This is not
;   required, but makes it easier to access from other scripts.
;   Plus, it is MUCH faster than using shapefile_mask_data to create
;   the mask array every time.
;
; - The mask array is used to mask select WRF variables on the file.
;
; - The masked variables are written to a file.
;
; - The masked variables are plotted along with the original variable
;   in a panel plot.
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;
; This is needed for the shapefile_mask_data function
load "./shapefile_utils.ncl"

;----------------------------------------------------------------------
; Create a mask array by masking a curvilinear lat/lon WRF grid 
; against an outline in a shapefile. Write to a NetCDF file.
;----------------------------------------------------------------------
procedure create_wrf_mask_file(wrf_filename,shp_filename,mask_filename)
local f, t, opt
begin
  print("==================================================")
  print("    Creating mask array and writing to " + mask_filename)

  f = addfile(wrf_filename,"r")

  t       = f->T(0,0,:,:)     ; Pick any variable that is on the XLAT/XLONG grid
; printVarSummary(t)          ; south_north x west_east

  t@lat2d = f->XLAT(0,:,:)    ; Necessary for masking
  t@lon2d = f->XLONG(0,:,:)

;---Create the mask based on the given shapefile
  opt             = True
  opt@return_mask = True    ; This forces the return of a 0s and 1s mask array
  mask_array      = shapefile_mask_data(t,shp_filename,opt)

  system("rm -f " + mask_filename)
  fout = addfile(mask_filename,"c")
  fout->wrf_mask_array = mask_array
end

;----------------------------------------------------------------------
; Given a variable read off a WRF output file and a mask array, 
; use the "mask" function to mask the WRF variable. The mask array
; will be conformed first, if it is not the same rank as the WRF variable.
;----------------------------------------------------------------------
function mask_data(var,mask_array)
local vsizes, vrank, mask_array_conform
begin
  vsizes  = dimsizes(var)
  vrank   = dimsizes(vsizes)
  if(vrank.gt.2)
    mask_array_conform := conform_dims(vsizes,mask_array,(/vrank-2,vrank-1/))
    var_mask           := mask(var,mask_array_conform,1)
   else
    var_mask := mask(var,mask_array,1)
   end if
   copy_VarMeta(var,var_mask)    ; Copy metadata from var to var_mask
  return(var_mask)
end

;------------------------------------------------------------------
; Given a variable and its rank, set plot options for fixing the
; contour levels at a particular range. This is so we can plot
; original data and masked data using the same set of contour levels.
;----------------------------------------------------------------------
function set_contour_levels(var,res,nt,nl)
local mnmxint, vsizes, vrank
begin
  vsizes  = dimsizes(var)
  vrank   = dimsizes(vsizes)

  if(vrank.eq.2) then
    mnmxint = nice_mnmxintvl( min(var), max(var), 18, False)
  else if(vrank.eq.3) then
    mnmxint = nice_mnmxintvl( min(var(nt,:,:)), max(var(nt,:,:)), 18, False)
  else if(vrank.eq.4) then
    mnmxint = nice_mnmxintvl( min(var(nt,nl,:,:)), max(var(nt,nl,:,:)), 18, False)
  end if
  end if
  end if
  res@cnMinLevelValF  = mnmxint(0)
  res@cnMaxLevelValF  = mnmxint(1)
  res@cnLevelSpacingF = mnmxint(2)
  return(res)
end

;----------------------------------------------------------------------
; Set plotting options that will be used for plotting. This is
; assumed to be a WRF output file, so it uses wrf_map_resources to
; set the map projection to the native projection defined on the file.
;----------------------------------------------------------------------
function set_common_resources(f[1]:file)
begin
  res                       = True
  res                      = wrf_map_resources(f,res)  ; Use same map projection as
  res@tfDoNDCOverlay       = True                       ; defined on WRF file.
  res@gsnMaximize          = True
  res@gsnDraw              = False                      ; Comment these if you want to see the
  res@gsnFrame             = False                      ; individual plots before the panel.
  res@cnFillOn             = True  
  res@cnLinesOn            = False
  res@cnLevelSelectionMode = "ManualLevels"             ; Will set min/max/spacing later
  res@lbOrientation        = "Vertical"
  return(res)
end

;----------------------------------------------------------------------
; Given the original and masked variables, create filled contour plots
; of both and panel.
;----------------------------------------------------------------------
procedure plot_data(wks,var,var_mask,res,nt,nl)
local vsizes, vrank, plot_orig, plot_mask, pres
begin
  vsizes  = dimsizes(var)
  vrank   = dimsizes(vsizes)
  if(vrank.eq.2) then
    res@tiMainString = "Original variable"
    plot_orig = gsn_csm_contour_map(wks,var,res) 
    res@tiMainString = "Masked variable"
    plot_mask = gsn_csm_contour_map(wks,var_mask,res)
  else if(vrank.eq.3) then
    res@tiMainString = "Original variable"
    plot_orig = gsn_csm_contour_map(wks,var(nt,:,:),res)
    res@tiMainString = "Masked variable"
    plot_mask = gsn_csm_contour_map(wks,var_mask(nt,:,:),res)
  else if(vrank.eq.4) then
    res@tiMainString = "Original variable"
    plot_orig = gsn_csm_contour_map(wks,var(nt,nl,:,:),res)
    res@tiMainString = "Masked variable"
    plot_mask = gsn_csm_contour_map(wks,var_mask(nt,nl,:,:),res)
  end if
  end if
  end if
  pres = True
  pres@gsnMaximize = True
  gsn_panel(wks,(/plot_orig,plot_mask/),(/1,2/),pres)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
;---Initialize parameters and file names
  WRITE_NETCDF_FILE = True
  PLOT_DATA         = True
  wrf_filename      = "wrfout_d01_2005-12-14_13:00:00"
  shp_filename      = "mrb.shp"
  mask_filename     = "WRF_mask.nc"
  out_filename      = wrf_filename + "_MASKED.nc"
  nt                = 0       ; time step to plot if > 2D
  nl                = 0       ; level to plot if > 3D

;---Create mask array and write to file, if doesn't exist.
  if(.not.isfilepresent(mask_filename)) then
    create_wrf_mask_file(wrf_filename,shp_filename,mask_filename)
  end if

;---Read mask array off NetCDF file
  mf = addfile(mask_filename,"r")
  mask_array = mf->wrf_mask_array

;---Open WRF output file to read from later.
  wf = addfile(wrf_filename,"r")

;---Create resource lists for plotting
  if(PLOT_DATA)
    wks = gsn_open_wks("png","shapefiles")
    res = set_common_resources(wf)
  end if

;---Open new NetCDF file to write masked variables to.
  if(WRITE_NETCDF_FILE) then
    system("rm -f " + out_filename)
    fout = addfile(out_filename,"c")
  end if

;----------------------------------------------------------------------
; Loop through each variable on the file and check if this is one of
; the ones we want to mask.
;
; If we do, then mask it and write to the new NetCDF file.
;
; If we don't, then write original variable to the new NetCDF file.
;----------------------------------------------------------------------
  notes_string = "This variable was masked using the " + shp_filename + " shapefile"
  vars_to_mask = (/"T","TSLB"/)        ; List the variables to mask
  varnames     = getfilevarnames(wf)   ; Get all variable names from the file
  nvars        = dimsizes(varnames)

  do nv=0,nvars-1
    if(any(varnames(nv).eq.(vars_to_mask))) then
      print("==================================================")
      print("    Masking variable '" + varnames(nv) + "'")
      var      := wf->$varnames(nv)$
      var_mask := mask_data(var,mask_array)

       if(WRITE_NETCDF_FILE) then
         var_mask@NOTES = notes_string                ; Not necessary, but useful
         fout->$varnames(nv)$ = var_mask              ; Write masked var to file
       end if

       if(PLOT_DATA)
         res = set_contour_levels(var,res,nt,nl)
         plot_data(wks,var,var_mask,res,nt,nl)
       end if
     else
      if(WRITE_NETCDF_FILE) then
        fout->$varnames(nv)$ = wf->$varnames(nv)$  ; Write original var to file
      end if
    end if
  end do
end

