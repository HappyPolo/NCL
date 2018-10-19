;======================================================================
; ESMF_all_9.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF software
;   - Interpolating data from a CCSM4 grid to an EASE grid
;======================================================================
; This example is identical to ESMF_regrid_9.ncl, except it does the
; regridding in separate steps.
;======================================================================
; This example is more complicated because the output destination
; lat/lon grid (the EASE grid) actually has missing values. We
; have to strip off these missing values before we regrid, and then
; we have to place the regridded values back in the correct positions
; on the original EASE grid.
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
; This file still needs to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin
;---Input files
    srcFileName = "CCSM4.nc"
    dstFileName = "EASE.nc"

;---Output (and input) files
    srcGridName = "CCSM4_SCRIP.nc"
    dstGridName = "EASE_ESMF.nc"
    wgtFile     = "CCSM4_2_EASE_patch.nc"

;---Set to True if you want to skip any of these steps
    SKIP_ESMF_GEN  = False
    SKIP_SCRIP_GEN = False
    SKIP_WGT_GEN   = False

;----------------------------------------------------------------------
; Step 1, part 1
;     Convert rectilinear CCSM4 file to SCRIP convention file.
;----------------------------------------------------------------------
    sfile = addfile(srcFileName,"r")
    psl   = sfile->PSL                    ; 192 x 288

    if(.not.SKIP_SCRIP_GEN) then
      Opt                = True
      Opt@ForceOverwrite = True
      Opt@PrintTimings   = True
      Opt@Title          = "CCSM4 Grid"

      rectilinear_to_SCRIP(srcGridName,psl&lat,psl&lon,Opt)

;---Clean up
      delete(Opt)
    end if

;----------------------------------------------------------------------
; Step 1, part 2
;     Convert unstructured EASE NetCDF file to an ESMF convention file.
;----------------------------------------------------------------------
    dfile       = addfile(dstFileName,"r")
    lat2d       = dfile->latitude
    lon2d       = dfile->longitude

;---Convert to an ESMF convention file.
    if(.not.SKIP_ESMF_GEN) then
      Opt                = True
      Opt@ForceOverwrite = True
      Opt@PrintTimings   = True
      Opt@InputFileName  = dstFileName

;---lat/lon missing in same locations (doesn't seem to have an effect)
;     Opt@Mask2D         = where(.not.ismissing(lat2d),1,0)   

      curvilinear_to_SCRIP(dstGridName,lat2d,lon2d,Opt)

;---Clean up
      delete(Opt)
    end if

;----------------------------------------------------------------------
; Step 2
;     Generate the weights that take you from a CCSM4 grid to an
;     EASE grid.
;----------------------------------------------------------------------
    if(.not.SKIP_WGT_GEN) then
      Opt                = True
      Opt@InterpMethod   = "patch"
      Opt@ForceOverwrite = True
      Opt@PrintTimings   = True

      ESMF_regrid_gen_weights(srcGridName,dstGridName,wgtFile,Opt)

;---Clean up
      delete(Opt)
    end if

;----------------------------------------------------------------------
; Step 3
;     Apply the weights to a given variable on the CCSM4 file.
;----------------------------------------------------------------------
    Opt                = True
;   Opt@Debug          = True
    Opt@PrintTimings   = True

    psl_regrid = ESMF_regrid_with_weights(psl,wgtFile,Opt)

;----------------------------------------------------------------------
; Graphics section
;----------------------------------------------------------------------
;---Convert to hPa for cleaner contour levels.
    psl_regrid       = psl_regrid/100.
    psl              = psl/100.
    psl@units        = "hPa"
    psl_regrid@units = "hPa"

    wks = gsn_open_wks("png","ESMF_all")        ; send graphics to PNG file

    res                     = True

    res@gsnMaximize         = True              ; Maximize plot
    res@gsnDraw             = False
    res@gsnFrame            = False

    res@cnLevelSelectionMode = "ManualLevels"
    res@cnMinLevelValF       =  970
    res@cnMaxLevelValF       = 1050
    res@cnLevelSpacingF      =    5
    res@cnFillPalette        = "BlueYellowRed"  ; set color map

    res@cnFillOn            = True              ; color plot desired
    res@cnLinesOn           = False             ; turn off contour lines
    res@cnLineLabelsOn      = False             ; turn off contour labels
    res@cnFillMode          = "RasterFill"      ; turn raster on      

    res@lbLabelBarOn        = False

    res@gsnPolar            = "NH"              ; specify the hemisphere
    res@mpMinLatF           = 35

    res@trGridType          = "TriangularMesh"  ; allow missing coordinates


;---Plot original data
    res@tiMainString = "Original CCSM4 grid (" + \
                       str_join(tostring(dimsizes(psl))," x ") + ")"

    plot_orig = gsn_csm_contour_map_polar(wks,psl,res)   


;---Plot regridded data
    res@gsnAddCyclic = False
    res@sfXArray     = lon2d
    res@sfYArray     = lat2d
    res@tiMainString = "Regridded to EASE grid (" + \
                       str_join(tostring(dimsizes(psl_regrid))," x ") + ")"

    plot_regrid = gsn_csm_contour_map_polar(wks,psl_regrid,res)   


;---Panel these two plots
    pres                    = True
    pres@gsnMaximize        = True
    pres@gsnPanelLabelBar   = True
    pres@pmLabelBarWidthF   = 0.9
    pres@lbLabelFontHeightF = 0.01

    gsn_panel(wks,(/plot_orig,plot_regrid/),(/1,2/),pres)
end
