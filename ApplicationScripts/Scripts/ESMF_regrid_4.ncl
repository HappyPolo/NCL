;======================================================================
; ESMF_regrid_4.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF_regrid
;   - Interpolating data from a subset of a high-res topo grid to a low-res 0.5 grid
;======================================================================
; This example is identical to ESMF_all_4.ncl, except it does the
; regridding in one call to "ESMF_regrid".  See ESMF_wgts_4.ncl
; for a faster example of regridding using an existing weights file.
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
    interp_method = "conserve"    ; Default is bilinear

    latS  = 25    ; rough box that encloses the Tibet Plateau
    latN  = 42    ; this is larger than the 'final' Tibet region
    lonW  = 72    ; common TIBET region: 28N-40N and 75-104E
    lonE  = 108

;---Read data to regrid
    srcFileName = "ETOPO2_GLOBAL_2_ELEVATION.nc"
    sfile = addfile(srcFileName,"r")
    zcrit = 1500  ; user specifed elevation boundary for Tibet 
    topo  = short2flt(sfile->ELEV({latS:latN},{lonW:lonE}))
    topo  = where(topo .lt.zcrit, topo@_FillValue , topo )

    Opt                  = True

    Opt@InterpMethod     = interp_method
    Opt@WgtFileName      = "Rect_2_1deg.nc"

    Opt@SrcInputFileName = srcFileName      ; optional, but good idea
    Opt@SrcTitle         = "TOPO Grid"
    Opt@SrcMask2D        = where(.not.ismissing(topo),1,0) 

    Opt@DstGridType      = "0.5deg"         ; Destination grid description
    Opt@DstTitle         = "Global 0.5 degree resolution"
    Opt@DstLLCorner      = (/ latS, lonW /)
    Opt@DstURCorner      = (/ latN, lonE /)

    Opt@SrcRegional      = True             ; These are necessary
    Opt@DstRegional      = True

    Opt@ForceOverwrite   = True             ; remove grid and wgt files

    ;;Opt@PrintTimings   = True

    topo_regrid = ESMF_regrid(topo,Opt)   ; Do the regridding
    printVarSummary(topo_regrid)

;----------------------------------------------------------------------
; Plotting section
;----------------------------------------------------------------------
    wks = gsn_open_wks("png","ESMF_regrid")     ; send graphics to PNG file

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
    res@cnFillMode          = "RasterFill"      
    res@cnLinesOn           = False             ; turn off contour lines
    res@cnLineLabelsOn      = False             ; turn off contour lines

    res@cnFillPalette        = "BlAqGrYeOrReVi200"
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
                       " (" + interp_method + ")"

    plot_regrid = gsn_csm_contour_map(wks,topo_regrid,res)     

;---Resources for paneling
    pres                  = True
    pres@gsnMaximize      = True
    pres@gsnPanelLabelBar = True

    gsn_panel(wks,(/plot_orig,plot_regrid/),(/2,1/),pres)
end
