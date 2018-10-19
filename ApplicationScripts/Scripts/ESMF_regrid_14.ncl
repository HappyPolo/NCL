;======================================================================
; ESMF_regrid_14.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF_regrid
;   - Interpolating data from an ICON grid to a 5 degree grid
;======================================================================
; This example is identical to ESMF_all_14.ncl, except it does the
; regridding in one call to "ESMF_regrid".  See ESMF_wgts_14.ncl
; for a faster example of regridding using an existing weights file.
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
    srcFileName = "MRWB4N5_DOM01_R2B04L31_0001.nc"

    sfile   = addfile(srcFileName,"r")        ; Source file
    rad2deg = get_r2d("float")                ; radians to degrees
    scale   = 1e6
    div     = sfile->DIV(1,0,:)               ; (time,lev,cell)
    div     = div*scale
    lon1d   = sfile->clon *rad2deg            ; cell center, lon
    lat1d   = sfile->clat *rad2deg            ; cell center, lat

    Opt                 = True                ; regridding options

    Opt@SrcFileName     = "ICON_ESMF.nc"      ; output files
    Opt@DstFileName     = "5deg_SCRIP.nc"
    Opt@WgtFileName     = "ICON_2_5deg.nc"
    Opt@ForceOverwrite  = True

    Opt@SrcGridLat      = lat1d               ; source grid
    Opt@SrcGridLon      = lon1d
    
    Opt@DstGridType     = "5deg"              ; destination grid
 
    Opt@InterpMethod    = "patch"

    ;;Opt@PrintTimings   = True

    div_regrid = ESMF_regrid(div,Opt)            ; regrid div
    printVarSummary(div_regrid)

;----------------------------------------------------------------------
; Plotting section
;----------------------------------------------------------------------
    wks = gsn_open_wks("png","ESMF_regrid")        ; send graphics to PNG file

    res                       = True

    res@gsnMaximize           = True

    res@gsnDraw               = False
    res@gsnFrame              = False

    res@cnLevelSelectionMode  = "ManualLevels"
    res@cnMinLevelValF        = -1.0
    res@cnMaxLevelValF        =  1.8
    res@cnLevelSpacingF       =  0.2
     
    res@cnFillOn              = True
    res@cnFillPalette         = "BlAqGrYeOrReVi200"  ; set color map
    res@cnFillMode            = "RasterFill"
    res@cnLinesOn             = False
    res@cnLineLabelsOn        = False

    res@lbLabelBarOn          = False

;---Original grid
    res@sfXArray              = lon1d
    res@sfYArray              = lat1d

    res@tiMainString = "Original ICON grid (" + dimsizes(div) + " cells)"

    plot_orig = gsn_csm_contour_map(wks,div,res)  
    delete(res@sfXArray)
    delete(res@sfYArray)

;---Regridded data
    res@gsnAddCyclic = False
    dims = tostring(dimsizes(div_regrid))
    res@tiMainString = "Regridded to 5 degree grid (" + \
                       str_join(dims,",") + ") (" + Opt@InterpMethod + ")"

    plot_regrid = gsn_csm_contour_map(wks,div_regrid,res)  

;---Compare the plots in a panel
    pres                   = True
    pres@gsnMaximize       = True
    pres@gsnPanelLabelBar  = True

    gsn_panel(wks,(/plot_orig,plot_regrid/),(/2,1/),pres)
end

