;======================================================================
; ESMF_wgts_11.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF_regrid_with_weights
;   - Interpolating from one grid to another using an existing weights file
;   - Interpolating data from an MPAS grid to a curvilinear tripolar grid
;======================================================================
; This example is identical to ESMF_regrid_11.ncl, except it assumes
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
    sfile = addfile("MPAS.nc","r")            ; Source grid
    sp    = ndtooned(sfile->surface_pressure)
    sp    = sp/1000.   ; Not sure what the pressure units are, there's
                       ; not much metadata info on this file

    r2d     = 180.0d/(atan(1)*4.0d)     ; Source lat/lon
    lonCell = sfile->lonCell
    latCell = sfile->latCell
    lonCell = lonCell*r2d
    latCell = latCell*r2d

    sp_regrid = ESMF_regrid_with_weights(sp,"MPAS_2_Tripolar.nc",False)
    printVarSummary(sp_regrid)

;----------------------------------------------------------------------
; Plotting section
;----------------------------------------------------------------------
    wks = gsn_open_wks("png","ESMF_wgts")          ; send graphics to PNG file

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
    
    res@mpMinLatF             = min(latCell)
    res@mpMaxLatF             = max(latCell)
    res@mpMinLonF             = min(lonCell)
    res@mpMaxLonF             = max(lonCell)
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
