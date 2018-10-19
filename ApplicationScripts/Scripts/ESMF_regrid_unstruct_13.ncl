;======================================================================
; ESMF_regrid_unstruct_13.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF_regrid
;   - Interpolating data from an EASE grid to a 0.25 degree grid
;   - Interpolating data from a curvilinear grid to an unstructured grid
;======================================================================
; This example is identical to ESMF_regrid_13.ncl, except it converts
; the 2D EASE grid to an unstructured grid, with all the missing
; lat/lon points removed. The point of this example is just to show
; an alternative way for regridding data that contains missing values
; in the lat/lon grid.
;
; It plots three versions of the EASE data as a panel plot:
;   - on the original curvilinear grid
;   - on an unstructured grid with missing values removed
;   - regridded to 0.25 degree grid
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
;
; Convert 2D curvilinear grid to 1D unstructured grid, and
; remove all the missing values.
;
    lat1d       = ndtooned(lat2d)
    lon1d       = ndtooned(lon2d)
    swe1d       = ndtooned(swe2d)
    ind_nomsg   = ind(.not.ismissing(lat1d))
    lat1d_nomsg = lat1d(ind_nomsg)
    lon1d_nomsg = lon1d(ind_nomsg)
    swe1d_nomsg = swe1d(ind_nomsg)
    copy_VarAtts(swe2d,swe1d_nomsg)

;---Options for regridding
    Opt                   = True            ; Options for regridding

    Opt@SrcFileName       = "EASE_ESMF.nc"  ; Output files
    Opt@DstFileName       = "NH_SCRIP.nc"
    Opt@WgtFileName       = "EASE_2_NH_patch.nc"
    Opt@ForceOverwrite    = True

    Opt@SrcGridLat        = lat1d_nomsg  ; This is a 1D
    Opt@SrcGridLon        = lon1d_nomsg  ; unstructured grid.
  
;---Set these to True if you already have the weights file.
;    Opt@SkipSrcGrid = True 
;    Opt@SkipDstGrid = True 
;    Opt@SkipWgtGen  = True 
     Opt@SkipSrcGrid = False
     Opt@SkipDstGrid = False
     Opt@SkipWgtGen  = False

  
    Opt@DstGridType       = "0.25deg"       ; Destination grid
    Opt@DstTitle          = "Northern Hemisphere 0.25 resolution"
    Opt@DstLLCorner       = (/ 0.25d,   0.25d/)
    Opt@DstURCorner       = (/89.75d, 359.75d/)

    Opt@InterpMethod      = "patch"   ; Careful! Patch method takes a long time

    Opt@Debug             = True

    swe_regrid = ESMF_regrid(swe1d_nomsg,Opt)    ; Regrid 1D swe variable
    printVarSummary(swe_regrid)

;---Partial clean up
    delete([/lat1d,lon1d,swe1d,ind_nomsg/])

;----------------------------------------------------------------------
; Plotting section
;----------------------------------------------------------------------
    wks = gsn_open_wks("png","ESMF_regrid_unstruct")  ; send graphics to PNG file

    res                     = True              ; Plot mods desired.

    res@gsnDraw             = False
    res@gsnFrame            = False

    res@cnFillOn            = True              ; color plot desired
    res@cnFillPalette       = "amwg"            ; set color map
    res@cnLinesOn           = False             ; turn off contour lines
    res@cnLineLabelsOn      = False             ; turn off line labels
    res@cnFillMode          = "RasterFill"      ; turn raster on       

    res@cnLevelSelectionMode= "ExplicitLevels" ; set explicit contour levels
    res@cnLevels            = (/-300,-250,-200,-150,-100,   \
                                0,1,5,10,25,100,200,300,400/)

    res@lbLabelBarOn        = False              ; turn on in panel

    res@trGridType          = "TriangularMesh"   ; allow missing coordinates


    res@gsnPolar            = "NH"               ; specify the hemisphere
    res@mpMinLatF           = 35

    res@gsnAddCyclic      = False
    res@trGridType        = "TriangularMesh"
    res@cnFillMode        = "RasterFill"
    res@tiMainFontHeightF = 0.015
    res@tiMainOffsetYF    = -0.005

;---Remove labels for cleaner plot.
    res@gsnTickMarksOn    = False
    res@gsnLeftString     = ""
    res@gsnRightString    = ""

;---Plot original data on curvilinear grid.
    res@sfXArray     = lon2d
    res@sfYArray     = lat2d
    res@tiMainString = "Original EASE grid (" + \
                       str_join(dimsizes(lat2d),",") + ")"
    plot_orig = gsn_csm_contour_map_polar(wks,swe2d,res)     

;---Plot original data as unstructured grid with missing values removed.
    res@sfXArray     := lon1d_nomsg
    res@sfYArray     := lat1d_nomsg
    res@tiMainString = "EASE grid w/msg vals removed (" + \
                       dimsizes(lat1d_nomsg) + " points)"
    plot_orig_1d = gsn_csm_contour_map_polar(wks,swe1d_nomsg,res)     

    delete(res@sfXArray)
    delete(res@sfYArray)

;---Plot regridded data.
    res@gsnAddCyclic = True

    dims = tostring(dimsizes(swe_regrid))
    res@tiMainString = "Regridded to 0.25 deg grid (" + \
                       str_join(dims," x ") + ")"

    plot_regrid = gsn_csm_contour_map_polar(wks,swe_regrid,res)     

;---Compare the plots in a panel
    pres                    = True
    pres@gsnMaximize        = True
    pres@gsnPanelLabelBar   = True
    pres@lbLabelFontHeightF = 0.01
    pres@pmLabelBarWidthF   = 0.8
    gsn_panel(wks,(/plot_orig,plot_orig_1d,plot_regrid/),(/2,2/),pres)

end
