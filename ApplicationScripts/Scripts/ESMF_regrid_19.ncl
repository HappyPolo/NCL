;======================================================================
; ESMF_regrid_19.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF_regrid
;   - Interpolating data from HOMME unstructured grid to a POP grid
;======================================================================
; This example uses ESMF regridding software to regrid data on a
; HOMME unstructured grid to a POP gx1v3 grid (384 x 320).
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
    dst_file = "map_1x1d_to_gx1v3_bilin_da_010808.nc"
    wgt_file = "HOMME_to_POP_gx1v3.nc"

    interp_method = "bilinear"     ; interpolation method

;---Open files containing source HOMME and destination POP grids
    sfile = addfile(src_file,"r")
    dfile = addfile(dst_file,"r")

;---Get variable to regrid and the source lat/lon grid
    var      = sfile->PSL(0,:)            ; time (1) x ncol
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
;
; The POP grid was obtained from an existing weight file.
; The lat/lon grid on this file is written as a 1D 
; array, so you have to reshape it. You also need to
; apply the mask grid that is provided on the file.
;
    dst_dims             = dfile->dst_grid_dims(::-1)     ; Fortran ordering
    Opt@DstGridLat       = reshape(dfile->yc_b,dst_dims)
    Opt@DstGridLon       = reshape(dfile->xc_b,dst_dims)
    Opt@DstMask2D        = reshape(dfile->mask_b,dst_dims)

    Opt@ForceOverwrite   = True
    Opt@Debug            = True
    Opt@PrintTimings     = True

    var_regrid = ESMF_regrid(var,Opt)     ; Do the regridding
    printVarSummary(var_regrid)
 
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

    res@cnLevelSelectionMode = "ManualLevels"
    res@cnMinLevelValF       =  97500
    res@cnMaxLevelValF       = 104000
    res@cnLevelSpacingF      =    500

    res@lbLabelBarOn         = False      ; Will turn on in panel later

    res@mpFillOn             = False

;---Resources for plotting regridded data
    dims_regrid      = tostring(dimsizes(var_regrid))
    res@gsnAddCyclic = True
    res@tiMainString = "POP grid (" + str_join(dims_regrid," x ") + \
                       ") (" + interp_method + ")"

    plot_regrid = gsn_csm_contour_map(wks,var_regrid,res)

;---Resources for plotting original data
    res@gsnAddCyclic = False
    res@sfXArray     = src_lon
    res@sfYArray     = src_lat
    res@tiMainString = "Original HOMME grid (" + \
                        dimsizes(src_lon) + " cells)"

    plot_orig = gsn_csm_contour_map(wks,var,res)  

;---Draw both plots in a panel
    pres                   = True
    pres@gsnMaximize       = True
    pres@gsnPanelLabelBar  = True

    gsn_panel(wks,(/plot_orig,plot_regrid/),(/2,1/),pres)
end

