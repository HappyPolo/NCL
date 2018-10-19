;======================================================================
; ESMF_regrid_7.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF_regrid
;   - Interpolating data from an ORCA grid to a 1x1 degree rectilinear grid
;======================================================================
; This example is identical to ESMF_all_7.ncl, except it does the
; regridding in one call to "ESMF_regrid".  See ESMF_wgts_7.ncl
; for a faster example of regridding using an existing weights file.
;======================================================================
; This example uses the ESMF application "ESMF_RegridWeightGen" to 
; generate the weights.
;
; For more information about ESMF:
;
;        http://www.earthsystemmodeling.org/
;======================================================================
; This script regrids an ORCA grid to a 1.0 degree world grid and
; plots sea surface temperature on the new grid.
;
; It uses SCRIP for both the ORCA and 1.0 degree world grid.
;======================================================================

; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin
;---Input file
    srcFileName = "test_CNRM.nc"

;---Retrieve data from ORCA Grid
    sfile     = addfile(srcFileName,"r")
    tos       = sfile->tos(0,:,:)
    tos@lat2d = sfile->lat
    tos@lon2d = sfile->lon

    Opt                = True

    Opt@SrcFileName    = "ORCA_SCRIP.nc"           ; Output files
    Opt@DstFileName    = "World1deg_SCRIP.nc"
    Opt@WgtFileName    = "ORCA_2_World_SCRIP.nc"
    Opt@ForceOverwrite = True

    Opt@SrcMask2D      = where(.not.ismissing(tos),1,0)

    Opt@DstGridType    = "1deg"                     ; Destination grid
    Opt@DstTitle       = "World grid 1x1 degree resolution"
    Opt@DstLLCorner    = (/-89.75d,   0.00d /)
    Opt@DstURCorner    = (/ 89.75d, 359.75d /) 
 
    ;;Opt@PrintTimings = True
    ;;Opt@Debug        = True

    tos_regrid = ESMF_regrid(tos,Opt)               ; Regrid tos
    printVarSummary(tos_regrid)

;----------------------------------------------------------------------
; Plotting section
;----------------------------------------------------------------------
    wks = gsn_open_wks("png","ESMF_regrid")     ; send graphics to PNG file

;---Resources to share between both plots
    res                     = True              ; Plot modes desired.

    res@gsnMaximize         = True              ; Maximize plot

    res@gsnDraw             = False
    res@gsnFrame            = False 

    res@cnFillOn            = True              ; color plot desired
    res@cnFillPalette       = "rainbow"         ; set color map
    res@cnLinesOn           = False             ; turn off contour lines
    res@cnLineLabelsOn      = False             ; turn off contour labels
    res@cnFillMode          = "RasterFill"      ; turn raster on      
    res@cnLevelSelectionMode = "ExplicitLevels"
    res@cnLevels             = ispan(270,300,2)

    res@mpFillOn            = False

    res@trGridType          = "TriangularMesh"  ; allow missing coordinates
    res@gsnAddCyclic        = False

    res@lbLabelBarOn        = False

    res@gsnAddCyclic        = False

;---Regridded data
    res@tiMainString = "ORCA to world 1-degree (" + \
                       str_join(tostring(dimsizes(tos_regrid))," x ") + \
                       ") (bilinear)"

    plot_regrid = gsn_csm_contour_map(wks,tos_regrid,res)

;---Original data
    res@tiMainString = "Original ORCA grid (" + \
                      str_join(tostring(dimsizes(tos))," x ")+")"

    plot_orig = gsn_csm_contour_map(wks,tos,res)  

;---Compare the plots in a panel
    pres                   = True
    pres@gsnMaximize       = True
    pres@gsnPanelLabelBar  = True

    gsn_panel(wks,(/plot_orig,plot_regrid/),(/2,1/),pres)
end
