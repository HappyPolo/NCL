;======================================================================
; ESMF_regrid_10.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF_regrid
;   - Interpolating data from an MPAS grid to 0.25 degree grid
;======================================================================
; This example is identical to ESMF_all_10.ncl, except it does the
; regridding in one call to "ESMF_regrid".  See ESMF_wgts_10.ncl
; for a faster example of regridding using an existing weights file.
;======================================================================
; This example uses the ESMF application "ESMF_RegridWeightGen" to 
; generate the weights.
;
; For more information about ESMF:
;
;        http://www.earthsystemmodeling.org/
;
; This script uses built-in functions that will be in NCL version
; 6.1.0.
;======================================================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin
;---Retrieve data
    srcFileName = "MPAS.nc"
;    dstFileName = "MPASOcean60km.nc"
    dstFileName = "t2m-duda-mpas.nc"
    sfile = addfile(srcFileName,"r")
    dfile = addfile(dstFileName,"r")
    sp    = sfile->surface_pressure(0,:)
    sp    = sp/1000.   ; Not sure what the pressure units are, there's
                       ; not much metadata info on this file

    src_lon = sfile->lonCell    ; Cell centers
    src_lat = sfile->latCell

    dst_lon = dfile->lonCell    ; Cell centers
    dst_lat = dfile->latCell

    r2d     = 180.0d/(atan(1)*4.0d)  ; Radian to Degree
    src_lon = src_lon*r2d
    src_lat = src_lat*r2d
    dst_lon = dst_lon*r2d
    dst_lat = dst_lat*r2d

    Opt                 = True                     ; Regridding optioins

    Opt@SrcESMF         = True                     ; Tell NCL you have an unstructured
    Opt@DstESMF         = True                     ; source and destination grids

    Opt@SrcFileName     = "MPAS_ESMF.nc"           ; output files
    Opt@DstFileName     = "Duda_MPAS_ESMF.nc"
    Opt@WgtFileName     = "MPAS_to_Duda_MPAS.nc"
    Opt@ForceOverwrite  = True


    Opt@SkipSrcGrid     = True
    Opt@SkipDstGrid     = True
    Opt@SkipWgtGen      = True

    Opt@SrcGridLat      = src_lat                  ; source grid
    Opt@SrcGridLon      = src_lon

    Opt@DstGridType     = "unstructured"
    Opt@DstGridLat      = dst_lat                  ; source grid
    Opt@DstGridLon      = dst_lon

    Opt@Debug           = True
    ;;Opt@PrintTimings  = True

    sp_regrid = ESMF_regrid(sp,Opt)
    printVarSummary(sp_regrid)

;----------------------------------------------------------------------
; Regrid from the Duda back to the original MPAS just for fun.
;----------------------------------------------------------------------
;    Opt@SkipWgtGen      = False       ; need to create a new weights file

    Opt@SrcGridLat      := dst_lat    ; these are now swapped
    Opt@SrcGridLon      := dst_lon
    Opt@DstGridLat      := src_lat
    Opt@DstGridLon      := src_lon


    Opt@DstFileName     = "MPAS_ESMF.nc"          ; swap these!
    Opt@SrcFileName     = "Duda_MPAS_ESMF.nc"
    Opt@WgtFileName     = "Duda_MPAS_2_MPAS.nc"

    sp_regrid_orig      = ESMF_regrid(sp_regrid,Opt)

;----------------------------------------------------------------------
; Plotting section
;----------------------------------------------------------------------
    wks = gsn_open_wks("x11","ESMF_regrid")

;---Resources to share between both plots
    res                     = True              ; Plot modes desired.

    res@gsnDraw             = False
    res@gsnFrame            = False

    res@gsnMaximize         = True              ; Maximize plot

    res@cnFillOn            = True              ; color plot desired
    res@cnLinesOn           = False             ; turn off contour lines
    res@cnLineLabelsOn      = False             ; turn off contour labels
    res@cnFillMode          = "RasterFill"      ; turn raster on      

    mnmxint = nice_mnmxintvl( min(sp_regrid), max(sp_regrid), 18, False)
    res@cnLevelSelectionMode = "ManualLevels"
    res@cnMinLevelValF       = mnmxint(0)
    res@cnMaxLevelValF       = mnmxint(1)
    res@cnLevelSpacingF      = mnmxint(2)

    res@lbLabelBarOn        = False    ; Will turn on in panel later.

    res@mpFillOn            = False

    res@trGridType         = "TriangularMesh"  ; allow missing coordinates
    res@gsnAddCyclic       = False

;---Resources for plotting regridded data
    res@gsnAddCyclic       = False

    dims = tostring(dimsizes(sp_regrid))
    res@tiMainString       = "Data regridded to an MPAS grid (" + dimsizes(dst_lon) + " cells)"
    res@sfXArray           = dst_lon
    res@sfYArray           = dst_lat

    plot_regrid = gsn_csm_contour_map(wks,sp_regrid,res)

    res@sfXArray           := src_lon
    res@sfYArray           := src_lat
    res@gsnAddCyclic       = False

    res@tiMainString       = "Original MPAS grid (" + dimsizes(sp) + " cells)"
    plot_orig   = gsn_csm_contour_map(wks,sp,res)  

    res@tiMainString       = "Regridded back to original"
    plot_orig_2 = gsn_csm_contour_map(wks,sp_regrid_orig,res)  

;---Compare the plots in a panel
    pres                   = True
    pres@gsnMaximize       = True
    pres@gsnPanelLabelBar  = True

;    gsn_panel(wks,(/plot_orig,plot_regrid,plot_orig_2/),(/3,1/),pres)


;---Create  difference plot
;    delete(res@lbLabelBarOn)

    sp_diff = sp - sp_regrid_orig
    copy_VarMeta(sp,sp_diff)

    res@lbOrientation   = "Vertical"    
    res@cnFillPalette   = "GreenYellow"
    res@cnMinLevelValF  = -2.4
    res@cnMaxLevelValF  = 2.4
    res@cnLevelSpacingF = 0.2
    res@tiMainString    = "Difference of original, and regridded back to original"
    plot_diff = gsn_csm_contour_map(wks,sp_diff,res)  

;---Some some new panel resources
    pres@pmLabelBarHeightF = 0.6
    pres@gsnFrame          = False             ; don't advance frame yet
    pres@gsnPanelBottom    = 1./3.              ; top 2/3 of frame
    pres@lbOrientation     = "vertical"
;    pres@pmLabelBarWidthF  = 0.075             ; make thinner
;    pres@pmLabelBarHeightF = 0.40
    gsn_panel(wks,(/plot_orig,plot_orig_2/),(/2,1/),pres)


;---Panel the diff plots at the bottom
    pres@gsnPanelTop       = pres@gsnPanelBottom
    pres@gsnPanelBottom    = 0.
    pres@pmLabelBarHeightF = 0.28

    gsn_panel(wks,plot_diff,(/1,1/),pres)
    frame(wks)

end
