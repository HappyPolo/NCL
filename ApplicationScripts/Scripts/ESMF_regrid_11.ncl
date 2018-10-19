;======================================================================
; ESMF_regrid_11.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF_regrid
;   - Interpolating data from an MPAS grid to a curvilinear tripolar grid
;======================================================================
; This example is identical to ESMF_all_11.ncl, except it does the
; regridding in one call to "ESMF_regrid".  See ESMF_wgts_11.ncl
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
    srcFileName = "MPAS.nc"
    dstFileName = "Tripolar.nc" 

    sfile = addfile(srcFileName,"r")            ; Source grid
    sp    = ndtooned(sfile->surface_pressure)
    sp    = sp/1000.   ; Not sure what the pressure units are, there's
                       ; not much metadata info on this file

    r2d     = 180.0d/(atan(1)*4.0d)     ; Source lat/lon
    lonCell = sfile->lonCell
    latCell = sfile->latCell
    lonCell = lonCell*r2d
    latCell = latCell*r2d

    dfile = addfile(dstFileName,"r")                   ; destination grid
    lat2d = dfile->TLAT
    lon2d = dfile->TLON

    Opt                   = True

    Opt@SrcFileName       = "MPAS_ESMF.nc"             ; output files
    Opt@WgtFileName       = "MPAS_2_Tripolar.nc"
    Opt@DstFileName       = "Tripolar_SCRIP.nc"
    Opt@ForceOverwrite    = True

    Opt@SrcGridLat        = latCell                    ; source grid
    Opt@SrcGridLon        = lonCell
    Opt@SrcInputFileName  = srcFileName                ; optional, but good idea

    Opt@DstGridLat        = lat2d                      ; destination grid
    Opt@DstGridLon        = lon2d
    Opt@DstTitle          = "Curvilinear tripolar grid"

;---Only needed for "conserve" method
;    Opt@DstGridCornerLat  = ndtooned( dfile->latt_bounds )
;    Opt@DstGridCornerLon  = ndtooned( dfile->lont_bounds )
 
    Opt@InterpMethod      = "patch"

    ;;Opt@PrintTimings    = True
    ;;Opt@Debug           = True

    sp_regrid = ESMF_regrid(sp,Opt)
    printVarSummary(sp_regrid)

;----------------------------------------------------------------------
; Plotting section
;----------------------------------------------------------------------
    wks = gsn_open_wks("png","ESMF_regrid")        ; send graphics to PNG file

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
;    res@mpCenterLonF         = 180
    res@mpCenterLonF          = 0

    res@cnLevelSelectionMode  = "ManualLevels"
    res@cnMinLevelValF        =  55
    res@cnMaxLevelValF        = 100
    res@cnLevelSpacingF       =   2.5

    res@pmTickMarkDisplayMode = "Always"

    dims = tostring(dimsizes(sp_regrid))
    res@tiMainString          = "Data regridded to tripolar grid (" + \
                                str_join(dims," x ") + ") (" \
                                + Opt@InterpMethod + ")"

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
