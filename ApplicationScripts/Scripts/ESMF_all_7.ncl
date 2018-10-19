;======================================================================
; ESMF_all_7.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF software
;   - Interpolating data from an ORCA grid to a 1x1 degree rectilinear grid
;======================================================================
; This example is identical to ESMF_regrid_7.ncl, except it does the
; regridding in separate steps.  See ESMF_wgts_7.ncl for a faster 
; example of regridding using an existing weights file.
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
; This script regrids an ORCA grid to a 1.0 degree world grid and
; plots sea surface temperature on the new grid.
;
; It uses SCRIP for both the ORCA and 1.0 degree world grid.
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
;---Input file
    srcFileName = "test_CNRM.nc"

;---Output (and input) files
    srcGridName = "ORCA_SCRIP.nc"
    dstGridName = "World1deg_SCRIP.nc"
    wgtFile     = "ORCA_2_World_SCRIP.nc"

;---Retrieve data from ORCA Grid
    sfile = addfile(srcFileName,"r")
    tos   = sfile->tos(0,:,:)

;---Set to True if you want to skip any of these steps
    SKIP_ORCA_SCRIP_GEN  = False
    SKIP_WORLD_SCRIP_GEN = False
    SKIP_WGT_GEN         = False
    
;----------------------------------------------------------------------
; Convert ORCA to SCRIP file.
;----------------------------------------------------------------------
    nav_lat = sfile->lat
    nav_lon = sfile->lon

    if(.not.SKIP_ORCA_SCRIP_GEN) then
;---Convert to an SCRIP Convention file.
      Opt                = True
      Opt@ForceOverwrite = True
      Opt@PrintTimings   = True
      Opt@Mask2D         = where(.not.ismissing(tos),1,0)

      curvilinear_to_SCRIP(srcGridName,nav_lat,nav_lon,Opt)

;---Clean up
      delete(Opt)
    end if

;----------------------------------------------------------------------
; Convert 1 degree world grid to SCRIP file
;----------------------------------------------------------------------
    if(.not.SKIP_WORLD_SCRIP_GEN)
      Opt                = True
      Opt@LLCorner       = (/-89.75d,   0.00d /)
      Opt@URCorner       = (/ 89.75d, 359.75d /) 
      Opt@ForceOverwrite = True
      Opt@PrintTimings   = True
      Opt@Title          = "World grid 1x1 degree resolution"

      latlon_to_SCRIP(dstGridName,"1deg",Opt)

;---Clean up
      delete(Opt)
    end if

;----------------------------------------------------------------------
; Generate interpolation weights for ORCA Grid to World Grid    
;----------------------------------------------------------------------
    if(.not.SKIP_WGT_GEN) then
      Opt                      = True
      Opt@SrcESMF              = False
      Opt@DstESMF              = False
      Opt@ForceOverwrite       = True
      Opt@PrintTimings         = True

      ESMF_regrid_gen_weights(srcGridName, dstGridName, wgtFile, Opt)

;---Clean up
      delete(Opt)
    end if

;----------------------------------------------------------------------
; Interpolate data from ORCA to World 1-degree grid.
;----------------------------------------------------------------------

    Opt              = True
;   Opt@Debug        = True
    Opt@PrintTimings = True

    tos_regrid = ESMF_regrid_with_weights(tos,wgtFile,Opt)
    printVarSummary(tos_regrid)

;---Clean up
    delete(Opt)

;----------------------------------------------------------------------
; Plotting section
;----------------------------------------------------------------------
    wks = gsn_open_wks("png","ESMF_all")        ; send graphics to PNG file

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

    res@trGridType         = "TriangularMesh"  ; allow missing coordinates
    res@gsnAddCyclic       = False

    res@lbLabelBarOn       = False

    res@gsnAddCyclic       = False

;---Regridded data
    res@tiMainString = "ORCA to world 1-degree (" + \
                       str_join(tostring(dimsizes(tos_regrid))," x ") + \
                       ") (bilinear)"

    plot_regrid = gsn_csm_contour_map(wks,tos_regrid,res)

;---Original data
    res@sfXArray     = nav_lon
    res@sfYArray     = nav_lat
    res@tiMainString = "Original ORCA grid (" + \
                      str_join(tostring(dimsizes(tos))," x ")+")"

    plot_orig = gsn_csm_contour_map(wks,tos,res)  

;---Compare the plots in a panel
    pres                   = True
    pres@gsnMaximize       = True
    pres@gsnPanelLabelBar  = True

    gsn_panel(wks,(/plot_orig,plot_regrid/),(/2,1/),pres)
end
