;======================================================================
; ESMF_all_11.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF software
;   - Interpolating data from an MPAS grid to a curvilinear tripolar grid
;======================================================================
; This example is identical to ESMF_regrid_11.ncl, except it does the
; regridding in separate steps.  See ESMF_wgts_11.ncl for a faster 
; example of regridding using an existing weights file.
;======================================================================
; This example uses the ESMF application "ESMF_RegridWeightGen" to 
; generate the weights.
;
; For more information about ESMF:
;
;        http://www.earthsystemmodeling.org/
;
; This script uses built-in functions that are only available in 
; NCL V6.1.0 and later.
;======================================================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin
;---Input files
    srcFileName = "MPAS.nc"
    dstFileName = "Tripolar.nc" 

;---Output (and input) files
    srcGridName = "MPAS_ESMF.nc"
    dstGridName = "Tripolar_SCRIP.nc"
    wgtFile     = "MPAS_2_Tripolar.nc"

;---Set to True if you want to skip any of these steps
    SKIP_MPAS_ESMF_GEN  = False
    SKIP_TRI_SCRIP_GEN  = False
    SKIP_WGT_GEN        = False

;----------------------------------------------------------------------
; Step 1 part 1
;    Convert source MPAS grid to an unstructured ESMF File.
;----------------------------------------------------------------------

;---Open MPAS file
    sfile = addfile(srcFileName,"r")

;---Read in lat/lon cell centers and convert to degrees from radians
    r2d     = 180.0d/(atan(1)*4.0d)
    lonCell = sfile->lonCell
    latCell = sfile->latCell
    lonCell = lonCell*r2d
    latCell = latCell*r2d

    if(.not.SKIP_MPAS_ESMF_GEN) then
;---Convert to unstructured ESMF grid
      Opt                = True
      Opt@ForceOverwrite = True
      Opt@PrintTimings   = True
      Opt@InputFileName  = srcFileName

      print("Converting MPAS grid to an unstructured ESMF convention file ...")
      unstructured_to_ESMF(srcGridName,latCell,lonCell,Opt)

;---Clean up
      delete(Opt)
    end if

;----------------------------------------------------------------------
; Step 1 part 2
;    Convert destination tripolar grid to a SCRIP File.
;----------------------------------------------------------------------
;
; Open tripolar file and get lat/lon grid.
;
; We need this for both the ESMF file and 
; plotting.
;
    dfile = addfile(dstFileName,"r")
    lat2d = dfile->TLAT
    lon2d = dfile->TLON

    if(.not.SKIP_TRI_SCRIP_GEN) then
      Opt                = True
      Opt@ForceOverwrite = True
      Opt@PrintTimings   = True
      Opt@Title          = "A curvilinear Tripolar grid"
 
      print("Converting tripolar grid to a SCRIP convention file ...")
      curvilinear_to_SCRIP(dstGridName,lat2d,lon2d,Opt)

;---Clean up
      delete(Opt)
    end if
    
    if(.not.SKIP_WGT_GEN) then
      Opt                = True
      Opt@InterpMethod   = "patch"
      Opt@SrcESMF        = True
      Opt@ForceOverwrite = True
      Opt@PrintTimings   = True

      print("Generating interpolation weights from MPAS to Tripolar grid ...")
      ESMF_regrid_gen_weights(srcGridName, dstGridName, wgtFile, Opt)

;---Clean up
      delete(Opt)
    end if

;----------------------------------------------------------------------
; Step 3
; Interpolate data from MPAS to Tripolar grid.
;----------------------------------------------------------------------
    sp = ndtooned(sfile->surface_pressure)
    sp = sp/1000.   ; Not sure what the pressure units are, there's
                    ; not much metadata info on this file

    Opt                = True
    Opt@Debug          = True
    Opt@PrintTimings   = True

    sp_regrid = ESMF_regrid_with_weights(sp,wgtFile,Opt)
    printVarSummary(sp_regrid)

;---Clean up
    delete(Opt)

;----------------------------------------------------------------------
; Plotting section
;----------------------------------------------------------------------

    wks = gsn_open_wks("png","ESMF_all")           ; send graphics to PNG file

    res                       = True

    res@gsnMaximize           = True

    res@gsnDraw               = False
    res@gsnFrame              = False

    res@cnFillOn              = True
    res@cnFillPalette         = "rainbow"          ; set color map
    res@cnFillMode            = "RasterFill"
    res@cnLinesOn             = False
    res@cnLineLabelsOn        = False

    res@lbLabelBarOn          = False    ; Turn on later in panel

    res@gsnAddCyclic          = True
    
    res@mpMinLatF             = min(lat2d)
    res@mpMaxLatF             = max(lat2d)
    res@mpMinLonF             = min(lon2d)
    res@mpMaxLonF             = max(lon2d)
    res@mpCenterLonF          = 0.

    res@cnLevelSelectionMode  = "ManualLevels"
    res@cnMinLevelValF        =  55
    res@cnMaxLevelValF        = 100
    res@cnLevelSpacingF       =   2.5

    res@pmTickMarkDisplayMode = "Always"

    dims = tostring(dimsizes(sp_regrid))
    res@tiMainString          = "Data regridded to tripolar grid (" + \
                                str_join(dims," x ") + ") (patch)"

    plot_regrid = gsn_csm_contour_map(wks,sp_regrid,res)  

    res@sfXArray           = lonCell
    res@sfYArray           = latCell
    res@gsnAddCyclic       = False
    res@tiMainString       = "Original MPAS grid (" + dimsizes(sp) + " cells)"

    plot_orig = gsn_csm_contour_map(wks,sp,res)  

;---Compare the plots in a panel
    pres                   = True
    pres@gsnMaximize       = True
    pres@gsnPanelLabelBar  = True

    gsn_panel(wks,(/plot_orig,plot_regrid/),(/2,1/),pres)
end
