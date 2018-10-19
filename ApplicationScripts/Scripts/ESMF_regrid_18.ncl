;======================================================================
; ESMF_regrid_18.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF_regrid
;   - Interpolating data from HOMME unstructured grid to a CAM finite volume grid
;======================================================================
; See ESMF_wgts_18.ncl for a faster example of regridding using an 
; existing weights file.
;======================================================================
; This example uses ESMF regridding software to regrid two variables 
; on a HOMME unstructured grid to a finite volume rectilinear grid 
; (96 x 144).
;======================================================================
; This script uses ESMF regridding functions that are only available in 
; NCL V6.1.0-beta and later.
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
;---Names of various input/output files
    src_file = "camrun.cam2.h0.1995-01-01-00000.nc"
    dst_file = "fv_sstghgcl_aero_01.cam2.h0.1999-01.nc"
    wgt_file = "HOMME_to_FV.nc"

    interp_method = "bilinear"     ; interpolation method

;---Open files containing source HOMME and destination FV grids
    sfile = addfile(src_file,"r")
    dfile = addfile(dst_file,"r")

;---Get two variables to regrid and the source lat/lon grid
    psl      = sfile->PSL(0,:)            ; time (1) x ncol
    temp     = sfile->T(0,:,:)            ; time (1) x nlev x ncol
    src_lat  = sfile->lat                 ; ncol
    src_lon  = sfile->lon                 ; ncol

;---Set up regridding options
    Opt                = True

;---"bilinear" is the default. "patch" and "conserve" are other options.
    Opt@InterpMethod     = interp_method
    Opt@WgtFileName      = wgt_file

    Opt@SrcGridLat       = src_lat
    Opt@SrcGridLon       = src_lon
    Opt@SrcInputFileName = src_file

    Opt@DstGridLat       = dfile->lat
    Opt@DstGridLon       = dfile->lon

    Opt@ForceOverwrite   = True
    Opt@Debug            = True
    Opt@PrintTimings     = True

    psl_regrid  = ESMF_regrid(psl,Opt)     ; Do the regridding
    printVarSummary(psl_regrid)
;
; For the second variable, since it is on the same grid, we 
; can use weights generated from the previous ESMF_regrid
; call to do the regridding.
;
    Opt         = True
    temp_regrid = ESMF_regrid_with_weights(temp,wgt_file,Opt)
    printVarSummary(temp_regrid)

;----------------------------------------------------------------------
; Plotting section
;
; This section creates filled contour plots of both the original
; data and the regridded data, and panels them.
;----------------------------------------------------------------------
    wks = gsn_open_wks("png","ESMF_regrid")      ; send graphics to PNG file

;---Resources to share between both plots
    res                      = True              ; Plot mods desired

    res@gsnDraw              = False
    res@gsnFrame             = False

    res@gsnMaximize          = True              ; Maximize plot

    res@cnFillOn             = True              ; color plot desired
    res@cnFillPalette        = "amwg"            ; set color map
    res@cnLinesOn            = False             ; turn off contour lines
    res@cnLineLabelsOn       = False             ; turn off contour labels

    res@lbLabelBarOn         = False      ; Will turn on in panel later

    res@mpFillOn             = False

    res@gsnAddCyclic = True

;---For titles and level selection
    dims_regrid = tostring(dimsizes(psl_regrid))
    plvl        = 867

;---Main title for regriddded data
    res@tiMainString = "FV grid (" + str_join(dims_regrid," x ") + \
                       ") (" + interp_method + ")"

;---For PSL
    res@cnLevelSelectionMode = "ManualLevels"
    res@cnMinLevelValF       =  97500
    res@cnMaxLevelValF       = 104000
    res@cnLevelSpacingF      =    500

    plot_psl_regrid  = gsn_csm_contour_map(wks,psl_regrid,res)

;---For TEMP
    res@cnLevelSelectionMode = "ManualLevels"
    res@cnMinLevelValF       = 262
    res@cnMaxLevelValF       = 290
    res@cnLevelSpacingF      =   2
    plot_temp_regrid = gsn_csm_contour_map(wks,temp_regrid({plvl},:,:),res)

;---Resources for plotting original data
    res@gsnAddCyclic = False
    res@sfXArray     = src_lon
    res@sfYArray     = src_lat
    res@tiMainString = "Original HOMME grid (" + \
                        dimsizes(src_lon) + " cells)"

;---For PSL
    res@cnLevelSelectionMode = "ManualLevels"
    res@cnMinLevelValF       =  97500
    res@cnMaxLevelValF       = 104000
    res@cnLevelSpacingF      =    500

    plot_psl_orig = gsn_csm_contour_map(wks,psl,res)  

;---For TEMP
    res@cnLevelSelectionMode = "ManualLevels"
    res@cnMinLevelValF       = 262
    res@cnMaxLevelValF       = 290
    res@cnLevelSpacingF      =   2

    plot_temp_orig = gsn_csm_contour_map(wks,temp({plvl},:),res)  

;---Draw both sets plots in a panel
    pres                   = True
    pres@gsnMaximize       = True
    pres@gsnPanelLabelBar  = True

    gsn_panel(wks,(/plot_psl_orig,plot_psl_regrid/),(/2,1/),pres)
    gsn_panel(wks,(/plot_temp_orig,plot_temp_regrid/),(/2,1/),pres)
end

