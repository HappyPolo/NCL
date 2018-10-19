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
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin
;---Retrieve data
    srcFileName = "MPAS.nc"
    sfile = addfile(srcFileName,"r")
    sp    = sfile->surface_pressure(0,:)
    sp    = sp/1000.   ; Not sure what the pressure units are, there's
                       ; not much metadata info on this file

    lonCell = sfile->lonCell    ; Cell centers
    latCell = sfile->latCell

    r2d     = 180.0d/(atan(1)*4.0d)  ; Radian to Degree
    lonCell = lonCell*r2d
    latCell = latCell*r2d

    Opt                 = True                     ; Regridding optioins

    Opt@SrcFileName     = "MPAS_ESMF.nc"           ; output files
    Opt@DstFileName     = "World_0.25deg_SCRIP.nc"
    Opt@WgtFileName     = "MPAS_2_World.nc"
    Opt@ForceOverwrite  = True

    Opt@SrcGridLat      = latCell                  ; source grid
    Opt@SrcGridLon      = lonCell
    Opt@InputFileName   = srcFileName              ; optional

    Opt@DstGridType     = "0.25deg"                ; destination grid
    Opt@DstTitle        = "World Grid 0.25 degree resolution"
    Opt@DstLLCorner     = (/-89.75d,   0.00d /)
    Opt@DstURCorner     = (/ 89.75d, 359.75d /) 

    Opt@Debug           = True
    ;;Opt@PrintTimings  = True

    sp_regrid = ESMF_regrid(sp,Opt)
    printVarSummary(sp_regrid)

;----------------------------------------------------------------------
; Plotting section
;----------------------------------------------------------------------
    wks = gsn_open_wks("png","ESMF_regrid")     ; send graphics to PNG file

;---Resources to share between both plots
    res                     = True              ; Plot modes desired.

    res@gsnDraw             = False
    res@gsnFrame            = False

    res@gsnMaximize         = True              ; Maximize plot

    res@cnFillOn            = True              ; color plot desired
    res@cnFillPalette       = "rainbow"         ; set color map
    res@cnLinesOn           = False             ; turn off contour lines
    res@cnLineLabelsOn      = False             ; turn off contour labels
    res@cnFillMode          = "RasterFill"      ; turn raster on      

    res@cnLevelSelectionMode = "ManualLevels"
    res@cnMinLevelValF       =  55
    res@cnMaxLevelValF       = 100
    res@cnLevelSpacingF      =   2.5

    res@lbLabelBarOn        = False    ; Will turn on in panel later.

    res@mpFillOn            = False

    res@trGridType         = "TriangularMesh"  ; allow missing coordinates
    res@gsnAddCyclic       = False

;---Resources for plotting regridded data
    res@gsnAddCyclic       = False

    dims = tostring(dimsizes(sp_regrid))
    res@tiMainString          = "Data regridded to 0.25 degree grid (" + \
                                str_join(dims," x ") + ")"

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
