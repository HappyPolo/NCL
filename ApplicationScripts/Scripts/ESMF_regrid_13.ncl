;======================================================================
; ESMF_regrid_13.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF_regrid
;   - Interpolating data from an EASE grid to a 0.25 degree grid
;======================================================================
; This example is identical to ESMF_all_13.ncl, except it does the
; regridding in one call to "ESMF_regrid".  See ESMF_wgts_13.ncl
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
    srcFileName = "EASE.nc"                   ; Source file
    ease_file   = addfile(srcFileName,"r")
    lat2d       = ease_file->latitude
    lon2d       = ease_file->longitude
;---Get date of interest: we will just regrid one time step.
    yyyymm    = 200502
    date      = ease_file->date
    nt        = ind(date.eq.yyyymm)          
    swe2d     = ease_file->SWE(nt,:,:)

    Opt                   = True            ; Options for regridding

    Opt@SrcFileName       = "EASE_SCRIP.nc"  ; Output files
    Opt@DstFileName       = "NH_SCRIP.nc"
    Opt@WgtFileName       = "EASE_2_NH_patch.nc"
    Opt@ForceOverwrite    = True
    Opt@SrcMask2D         = where(ismissing(lat2d),0,1)
    Opt@SrcGridLat        = lat2d
    Opt@SrcGridLon        = lon2d

    Opt@DstGridType       = "0.25deg"       ; Destination grid
    Opt@DstTitle          = "Northern Hemisphere 0.25 resolution"
    Opt@DstLLCorner       = (/ 0.25d,   0.25d/)
    Opt@DstURCorner       = (/89.75d, 359.75d/)

    Opt@InterpMethod      = "patch"   ; Careful! Patch method takes a long time

    Opt@Debug           = True

    swe_regrid = ESMF_regrid(swe2d,Opt)    ; Regrid swe
    printVarSummary(swe_regrid)

;----------------------------------------------------------------------
; Plotting section
;----------------------------------------------------------------------
    wks = gsn_open_wks("png","ESMF_regrid")     ; send graphics to PNG file

    res                     = True              ; Plot mods desired.
    res@gsnMaximize         = True              ; Maximize plot

    res@gsnDraw             = False
    res@gsnFrame            = False

    res@cnFillOn            = True              ; color plot desired
    res@cnFillPalette       = "amwg"            ; set color map
    res@cnLinesOn           = False             ; turn off contour lines
    res@cnLineLabelsOn      = False             ; turn off contour labels
    res@cnFillMode          = "RasterFill"      ; turn raster on       

    res@cnLevelSelectionMode= "ExplicitLevels" ; set explicit contour levels
    res@cnLevels            = (/-300,-250,-200,-150,-100,   \
                                0,1,5,10,25,100,200,300,400/)

    res@lbLabelBarOn        = False              ; turn on in panel

    res@trGridType          = "TriangularMesh"   ; allow missing coordinates


    res@gsnPolar            = "NH"               ; specify the hemisphere
    res@mpMinLatF           = 35

;---Plot original data.
    res@gsnAddCyclic = False
    res@sfXArray     = lon2d
    res@sfYArray     = lat2d
    res@tiMainString = "Original EASE grid (" + str_join(dimsizes(lat2d),",") + ")"
    res@trGridType = "TriangularMesh"
    res@cnFillMode = "RasterFill"

    plot_orig   = gsn_csm_contour_map_polar(wks,swe2d,res)     

    delete(res@sfXArray)
    delete(res@sfYArray)

;---Plot regridded data.
    res@gsnAddCyclic = True

    dims = tostring(dimsizes(swe_regrid))
    res@tiMainString = "Regridded to 0.25 degree grid (" + \
                       str_join(dims," x ") + ")"

    plot_regrid = gsn_csm_contour_map_polar(wks,swe_regrid,res)     

;---Compare the plots in a panel
    pres                    = True
    pres@gsnMaximize        = True
    pres@gsnPanelLabelBar   = True
    pres@lbLabelFontHeightF = 0.01
    pres@pmLabelBarWidthF   = 0.8

    gsn_panel(wks,(/plot_orig,plot_regrid/),(/1,2/),pres)
end
