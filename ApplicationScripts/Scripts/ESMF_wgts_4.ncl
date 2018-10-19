;======================================================================
; ESMF_wgts_4.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF_regrid_with_weights
;   - Interpolating from one grid to another using an existing weights file
;   - Interpolating data from a subset of a high-res topo grid to a low-res 0.5 grid
;======================================================================
; This example is identical to ESMF_regrid_4.ncl, except it assumes
; the weights file already exists, and does regridding using 
; "ESMF_regrid_with_weights".  This is the best method to use if you 
; already have the weights.
;======================================================================
; This is based on regrid_13.ncl, which regrids from a high-resolution
; regular grid to a lower resolution 0.5 degree grid.
;
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
    latS  = 25    ; rough box that encloses the Tibet Plateau
    latN  = 42    ; this is larger than the 'final' Tibet region
    lonW  = 72    ; common TIBET region: 28N-40N and 75-104E
    lonE  = 108

;---Read data to regrid
    sfile = addfile("ETOPO2_GLOBAL_2_ELEVATION.nc","r")
    zcrit = 1500  ; user specifed elevation boundary for Tibet 
    topo  = short2flt(sfile->ELEV({latS:latN},{lonW:lonE}))
    topo  = where(topo .lt.zcrit, topo@_FillValue , topo )

;---Do the regridding
    topo_regrid = ESMF_regrid_with_weights(topo,"Rect_2_1deg.nc",False)
    printVarSummary(topo_regrid)

;----------------------------------------------------------------------
; Plotting section
;----------------------------------------------------------------------
    wks = gsn_open_wks("png","ESMF_wgts")       ; send graphics to PNG file

    res                     = True              ; Plot modes desired.
    res@gsnDraw             = False
    res@gsnFrame            = False

    res@gsnMaximize         = True              ; Maximize plot
    
    res@mpFillOn            = False
    res@mpMinLatF           = latS 
    res@mpMaxLatF           = latN
    res@mpMinLonF           = lonW
    res@mpMaxLonF           = lonE
    res@mpCenterLonF        = (lonW+lonE)*0.5

    res@cnFillOn            = True              ; color plot desired
    res@cnFillPalette       = "BlAqGrYeOrReVi200" ; set color map
    res@cnFillMode          = "RasterFill"      
    res@cnLinesOn           = False             ; turn off contour lines
    res@cnLineLabelsOn      = False             ; turn off contour lines

    res@cnLevelSelectionMode =  "ManualLevels"   ; manual levels
    res@cnMinLevelValF       = zcrit              ; set min contour level
    res@cnMaxLevelValF       = 5750               ; set max contour level
    res@cnLevelSpacingF      =  250 

    res@lbLabelBarOn        = False

    res@gsnAddCyclic        = False

    res@tiMainString = "TOPO: Original data " + \
                       str_join(tostring(dimsizes(topo))," x ")

    plot_orig = gsn_csm_contour_map(wks,topo,res) 

    res@gsnAddCyclic        = False
    res@tiMainString = "TOPO: Regridded to 0.5 degree " + \
                       str_join(tostring(dimsizes(topo_regrid))," x ") + \
                       " (conserve)"

    plot_regrid = gsn_csm_contour_map(wks,topo_regrid,res)     

;---Resources for paneling
    pres                  = True
    pres@gsnMaximize      = True
    pres@gsnPanelLabelBar = True

    gsn_panel(wks,(/plot_orig,plot_regrid/),(/2,1/),pres)
end
