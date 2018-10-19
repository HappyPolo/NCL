;----------------------------------------------------------------------
; ESMF_regrid_22.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF_regrid
;   - Interpolating data from a curvilinear grid that contains missing values
;   - Interpolating data from a large region to a smaller region
;   - Applying a quantisation factor to data
; ----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

;----------------------------------------------------------------------
; main code
;----------------------------------------------------------------------
begin
  start_time = get_cpu_time()

;---Files containing data to regrid, and source/destination grids
  vfilename = "G2_SEV1_L20_HR_SOL_TH_20060712_150000_V003.hdf.h5"
  sfilename = "G2_SEV1_L20_HR_GEO_20060323_131500_V003.hdf.h5"
  dfilename = "lffd2006010100c.nc"

  vfile = addfile(vfilename, "r")
  sfile = addfile(sfilename, "r")
  dfile = addfile(dfilename,"r")

;---Read source lat/lon values
  lontmp = (sfile->Longitude)
  lattmp = sfile->Latitude

;---Apply factor to source lat/lon values
  qfactor           = "Quantisation Factor"
  latfactor         = lontmp@$qfactor$
  lonfactor         = lattmp@$qfactor$
  lattmp@_FillValue = toshort(-32767) ;  min(lattmp)
  lontmp@_FillValue = toshort(-32767) ; min(lontmp)
  src_lat2d         = lattmp * latfactor
  src_lon2d         = lontmp * lonfactor
  delete([/lattmp,lontmp/])

;
; Read destination lat/lon values. These values are on
; a rotated grid. The rlat/rlon arrays on the file
; are the pre-rotated values.
;
  dst_lat = dfile->lat
  dst_lon = dfile->lon

;---Set up regridding options
  Opt                   = True

  Opt@InterpMethod      = "bilinear"    ; "patch", "conserve"

  Opt@SrcGridLat        = src_lat2d
  Opt@SrcGridLon        = src_lon2d
;
; This step is important because src_lat2d and
; src_lon2d contain missing values.
;
  Opt@SrcMask2D         = where(ismissing(src_lat2d).or.\
                                ismissing(src_lon2d),0,1)
  Opt@SrcRegional       = True

  Opt@DstGridLat        = dst_lat
  Opt@DstGridLon        = dst_lon
  Opt@DstRegional       = True

  Opt@ForceOverwrite    = True
  Opt@PrintTimings      = True
  Opt@Debug             = True

;---Get variable to regrid and regrid it
  thermrad   = vfile->Thermal_Radiance
  thermrad@_FillValue = toshort(-32767) 

  thermrad_regrid = ESMF_regrid(thermrad,Opt)     ; Do the regridding

  printVarSummary(thermrad_regrid)
  printMinMax(thermrad,0)
  printMinMax(thermrad_regrid,0)

;---Start the graphics
  wks  = gsn_open_wks("png","ESMF_regrid")  ; send graphics to PNG file

  res                     = True

  res@gsnDraw             = False         ; will panel later
  res@gsnFrame            = False

  res@gsnMaximize         = True            ; use maximum image size
  res@cnFillOn            = True            ; turn on color fill
  res@cnFillMode          = "RasterFill"    ; use raster

  res@cnLinesOn           = False           ; turn off contour lines
  res@cnLineLabelsOn      = False

  res@gsnAddCyclic        = False

  mnmxint = nice_mnmxintvl( min(thermrad_regrid), \
                            max(thermrad_regrid), 18, False)
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       = mnmxint(0)
  res@cnMaxLevelValF       = mnmxint(1)
  res@cnLevelSpacingF      = mnmxint(2)

  res@lbLabelBarOn         = False     ; Will add in panel plot later

  res@mpMinLatF           = floor(min(dst_lat))
  res@mpMaxLatF           = ceil(max(dst_lat))
  res@mpMinLonF           = floor(min(dst_lon))
  res@mpMaxLonF           = ceil(max(dst_lon))

  res@gsnLeftString       = "Thermal Radiance"

;---This is where the two resource lists differ
  res_orig                = res
  res_regrid              = res

  dims = dimsizes(src_lon2d)
  res_orig@trGridType     = "TriangularMesh"   ; Necessary b/c lat/lon arrays
  res_orig@sfXArray       = src_lon2d          ; contain missing values.
  res_orig@sfYArray       = src_lat2d
  res_orig@tiMainString   = "Data on original lat/lon grid (" + \
                             str_join(tostring(dims)," x ") + ")"

  dims = dimsizes(dst_lon)
  res_regrid@sfXArray       = dst_lon
  res_regrid@sfYArray       = dst_lat
  res_regrid@tiMainString   = "Data on rotated lat/lon grid (" + \
                            str_join(tostring(dims)," x ") + ")"


;---Create (but don't draw) both plots.
  plot_orig   = gsn_csm_contour_map(wks,thermrad,res_orig)
  plot_regrid = gsn_csm_contour_map(wks,thermrad_regrid,res_regrid)

;---Resources for paneling
  pres                  = True
  pres@gsnMaximize      = True
  pres@gsnPanelLabelBar = True

;---Now draw both plots on same page.
  gsn_panel(wks,(/plot_orig,plot_regrid/),(/2,1/),pres)

  diff_time = get_cpu_time() - start_time
  print("=====> CPU Elapsed Time: " + diff_time + " seconds <=====")
end
