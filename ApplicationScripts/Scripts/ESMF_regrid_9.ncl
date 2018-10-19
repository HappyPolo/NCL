;======================================================================
; ESMF_regrid_9.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF_regrid
;   - Interpolating data from a CCSM4 grid to an EASE grid
;======================================================================
; This example is identical to ESMF_all_9.ncl, except it does the
; regridding in one call to "ESMF_regrid".
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
    srcFileName = "CCSM4.nc"
    dstFileName = "EASE.nc"

    sfile       = addfile(srcFileName,"r")
    psl         = sfile->PSL                    ; 192 x 288

    dfile       = addfile(dstFileName,"r")
    lat2d       = dfile->latitude
    lon2d       = dfile->longitude

;---Output (and input) files
    Opt           = True

    Opt@SrcFileName      = "CCSM4_SCRIP.nc"         ; output file names
    Opt@DstFileName      = "EASE_ESMF.nc"
    Opt@WgtFileName      = "CCSM4_2_EASE_patch.nc"
    Opt@ForceOverwrite   = True

    Opt@SrcInputFileName = srcFileName           ; optional, but good idea
    Opt@DstInputFileName = dstFileName

    ;;Needed if you want to regrid without generating these files again.
    Opt@SkipSrcGrid    = False
    Opt@SkipDstGrid    = False
    Opt@SkipWgtGen     = False

    Opt@DstGridLat       = lat2d
    Opt@DstGridLon       = lon2d
;---lat/lon missing in same locations (doesn't seem to have an effect)
;   Opt@DstMask2D        = where(.not.ismissing(lat2d),1,0)   

    Opt@InterpMethod     = "patch"

    Opt@Debug        = True
    Opt@PrintTimings = True

    Opt@CopyVarCoords    = False       ; we can't copy the coords because
                                       ; the weights on the file are only
                                       ; for the non-missing lat/lon values.

    psl_regrid = ESMF_regrid(psl,Opt)   ; Regrid psl
;
; Once you have the weights file, you can completely skip the 
; ESMF_regrid step, and just call ESMF_regrid_with_weights.
;
;   psl_regrid = ESMF_regrid_with_weights(psl,"CCSM4_2_EASE_patch.nc",False)


    psl_regrid       = psl_regrid/100.  ; Convert to hPa for cleaner
    psl              = psl/100.         ; contour levels.
    psl@units        = "hPa"
    psl_regrid@units = "hPa"
    printVarSummary(psl_regrid)

;----------------------------------------------------------------------
; Plotting section
;----------------------------------------------------------------------
    wks = gsn_open_wks("png","ESMF_regrid")     ; send graphics to PNG file

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
    res@cnLineLabelsOn      = False             ; turn off contour line labels
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
