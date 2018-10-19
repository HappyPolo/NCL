;======================================================================
; ESMF_regrid_12.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF_regrid
;   - Interpolating data from a curvilinear tripolar grid to an MPAS grid
;======================================================================
; This example is identical to ESMF_all_12.ncl, except it does the
; regridding in one call to "ESMF_regrid".  See ESMF_wgts_12.ncl
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
    srcFileName = "Tripolar.nc"         ; Source grid
    sfile       = addfile(srcFileName,"r")
    sst         = rm_single_dims( sfile->sst )
    sst@lat2d   = sfile->TLAT
    sst@lon2d   = sfile->TLON

    dstFileName = "MPAS.nc"             ; Destination grid
    dfile       = addfile(dstFileName,"r")
    lonCell     = dfile->lonCell
    latCell     = dfile->latCell

    r2d         = 180.0d/(atan(1)*4.0d)
    lonCell     = lonCell*r2d
    latCell     = latCell*r2d

    Opt                   = True                    ; regridding options

    Opt@SrcGridFileName   = "Tripolar_SCRIP.nc"     ; output files
    Opt@DstGridFileName   = "MPAS_ESMF.nc"
    Opt@WgtFileName       = "Tripolar_2_MPAS.nc"
    Opt@ForceOverwrite    = True

    Opt@SrcTitle          = "A curvilinear Tripolar grid"
    Opt@SrcMask2D         = tointeger( sfile->tmask )

;---Only needed for "conserve" method
;   Opt@SrcGridCornerLat  = ndtooned(sfile->latt_bounds)
;   Opt@SrcGridCornerLon  = ndtooned(sfile->lont_bounds)

    Opt@DstGridLat        = latCell            ; Destination grid
    Opt@DstGridLon        = lonCell
    Opt@DstInputFileName  = dstFileName
    Opt@DstGridType       = "unstructured"

    Opt@InterpMethod      = "patch"

    ;;Opt@PrintTimings      = True
    ;;Opt@Debug             = True

    sst_regrid = ESMF_regrid(sst,Opt)          ; Regrid sst
    
;---Fix the 0.0 values.
    sst_regrid = where(sst_regrid.eq.0,sst_regrid@_FillValue,sst_regrid)
    printVarSummary(sst_regrid)

;----------------------------------------------------------------------
; Plotting section
;----------------------------------------------------------------------
    wks = gsn_open_wks("png","ESMF_regrid")        ; send graphics to PNG file

    res                       = True

    res@gsnMaximize           = True

    res@gsnDraw               = False
    res@gsnFrame              = False

    res@cnLevelSelectionMode  = "ManualLevels"
    res@cnMinLevelValF        = 272
    res@cnMaxLevelValF        = 302
    res@cnLevelSpacingF       =   2
     
    res@cnFillOn              = True
    res@cnFillPalette         = "rainbow"            ; set color map
    res@cnFillMode            = "RasterFill"
    res@cnLinesOn             = False
    res@cnLineLabelsOn        = False

    res@lbLabelBarOn          = False

    res@mpMinLatF             = min(latCell)
    res@mpMaxLatF             = max(latCell)
    res@mpMinLonF             = min(lonCell)
    res@mpMaxLonF             = max(lonCell)
    res@mpCenterLonF          = (min(lonCell)+max(lonCell))*0.5

;---Original grid
    res@gsnAddCyclic = True

    dims = tostring(dimsizes(sst@lat2d))
    res@tiMainString = "Original tripolar grid (" + str_join(dims," x ") + ")"

    plot_orig = gsn_csm_contour_map(wks,sst,res)  

;---Regridded data
    res@gsnAddCyclic = False
    res@sfYArray     = latCell
    res@sfXArray     = lonCell
    res@tiMainString = "Regridded to MPAS grid using '" + Opt@InterpMethod \
                       + "' (" + dimsizes(sst_regrid) + " cells)" 

    plot_regrid = gsn_csm_contour_map(wks,sst_regrid,res)  

;---Compare the plots in a panel
    pres                   = True
    pres@gsnMaximize       = True
    pres@gsnPanelLabelBar  = True

    gsn_panel(wks,(/plot_orig,plot_regrid/),(/2,1/),pres)
end

