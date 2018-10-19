;======================================================================
; ESMF_wgts_12.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF_regrid_with_weights
;   - Interpolating from one grid to another using an existing weights file
;   - Interpolating data from a curvilinear tripolar grid to an MPAS grid
;======================================================================
; This example is identical to ESMF_regrid_12.ncl, except it assumes
; the weights file already exists, and does regridding using 
; "ESMF_regrid_with_weights".  This is the best method to use if you 
; already have the weights.
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
    sfile       = addfile("Tripolar.nc","r")
    sst         = rm_single_dims( sfile->sst )
    sst@lat2d   = sfile->TLAT
    sst@lon2d   = sfile->TLON

;---Regrid using existing weights file.
    opt = True
    opt@Debug = True
    sst_regrid = ESMF_regrid_with_weights(sst,"Tripolar_2_MPAS.nc",opt)
    
;---Fix the 0.0 values.
    sst_regrid = where(sst_regrid.eq.0,sst_regrid@_FillValue,sst_regrid)
    printVarSummary(sst_regrid)

;----------------------------------------------------------------------
; Plotting section
;----------------------------------------------------------------------
    wks = gsn_open_wks("png","ESMF_wgts")          ; send graphics to PNG file

    res                       = True

    res@gsnMaximize           = True

    res@gsnDraw               = False
    res@gsnFrame              = False

    res@cnLevelSelectionMode  = "ManualLevels"
    res@cnMinLevelValF        = 272
    res@cnMaxLevelValF        = 302
    res@cnLevelSpacingF       =   2
     
    res@cnFillOn              = True
    res@cnFillPalette         = "rainbow"          ; set color map
    res@cnFillMode            = "RasterFill"
    res@cnLinesOn             = False
    res@cnLineLabelsOn        = False

    res@lbLabelBarOn          = False

    res@mpMinLatF             = min(sst_regrid@lat1d)
    res@mpMaxLatF             = max(sst_regrid@lat1d)
    res@mpMinLonF             = min(sst_regrid@lon1d)
    res@mpMaxLonF             = max(sst_regrid@lon1d)
    res@mpCenterLonF          = (min(sst_regrid@lon1d)+max(sst_regrid@lon1d))*0.5

;---Original grid
    res@gsnAddCyclic = True

    dims = tostring(dimsizes(sst@lat2d))
    res@tiMainString = "Original tripolar grid (" + str_join(dims," x ") + ")"

    plot_orig = gsn_csm_contour_map(wks,sst,res)  

;---Regridded data
    res@gsnAddCyclic = False
    res@sfYArray     = sst_regrid@lat1d
    res@sfXArray     = sst_regrid@lon1d
    res@tiMainString = "Regridded to MPAS grid using 'patch' (" + \
                       dimsizes(sst_regrid) + " cells)" 

    plot_regrid = gsn_csm_contour_map(wks,sst_regrid,res)  

;---Compare the plots in a panel
    pres                   = True
    pres@gsnMaximize       = True
    pres@gsnPanelLabelBar  = True

    gsn_panel(wks,(/plot_orig,plot_regrid/),(/2,1/),pres)
end

