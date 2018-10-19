;======================================================================
; ESMF_all_13.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF software
;   - Interpolating data from an EASE grid to a 0.25 degree grid
;======================================================================
; This example is identical to ESMF_regrid_13.ncl, except it does the
; regridding in separate steps.  See ESMF_wgts_13.ncl for a faster 
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
    srcFileName = "EASE.nc"

;---Output (and input) files
    srcGridName = "EASE_ESMF.nc"
    dstGridName = "NH_SCRIP.nc"
    wgtFile     = "EASE_2_NH_patch.nc"

;---Set to True if you want to skip any of these steps
    SKIP_ESMF_GEN  = False
    SKIP_SCRIP_GEN = False
    SKIP_WGT_GEN   = False

;----------------------------------------------------------------------
; Step 1, part 1
;     Convert unstructured EASE NetCDF file to an ESMF convention file.
;----------------------------------------------------------------------
    ease_file = addfile(srcFileName,"r")
    lat2d     = ease_file->latitude
    lon2d     = ease_file->longitude

    if(.not.SKIP_ESMF_GEN) then
;--- Convert to an ESMF Convention file.
      Opt                   = True
      Opt@ForceOverwrite    = True
      Opt@PrintTimings      = True
      Opt@Title             = srcFileName
      Opt@SrcMask2D         = where(ismissing(lat2d),0,1)
      curvilinear_to_SCRIP(srcGridName,lat2d,lon2d,Opt)

;---Clean up
      delete(Opt)
   end if

;----------------------------------------------------------------------
; Step 1, part 2
;     Convert northern hemisphere 0.25 grid to SCRIP convention file.
;----------------------------------------------------------------------
    if(.not.SKIP_SCRIP_GEN) then
      Opt                = True
      Opt@Debug          = True
      Opt@LLCorner       = (/ 0.25d,   0.25d/)
      Opt@URCorner       = (/89.75d, 359.75d/)
      Opt@ForceOverwrite = True
      Opt@PrintTimings   = True
      Opt@Title          = "Northern Hemisphere 0.25 resolution"

      latlon_to_SCRIP(dstGridName,"0.25deg",Opt)

;---Clean up
      delete(Opt)
    end if

;----------------------------------------------------------------------
; Step 2
;     Generate the weights that take you from an EASE grid to an
;     NH 0.25 resolution grid
;----------------------------------------------------------------------
    if(.not.SKIP_WGT_GEN) then
      Opt                = True
      Opt@InterpMethod   = "patch"   ; Careful! Patch method takes a long time
      Opt@ForceOverwrite = True
      Opt@PrintTimings   = True

      ESMF_regrid_gen_weights(srcGridName,dstGridName,wgtFile,Opt)

;---Clean up
      delete(Opt)
    end if

;----------------------------------------------------------------------
; Step 3
;     Apply the weights to a given variable on the EASE file.
;----------------------------------------------------------------------
;---Get date of interest: just regrid one-time step.
    yyyymm    = 200502
    date      = ease_file->date
    nt        = ind(date.eq.yyyymm)          
    swe2d     = ease_file->SWE(nt,:,:)

    Opt                = True
    Opt@Debug          = True
    Opt@PrintTimings   = True

    swe_regrid = ESMF_regrid_with_weights(swe2d,wgtFile,Opt)

;---Clean up
    delete(Opt)

;---Add coordinate arrays
    dstlat       = retrieve_SCRIP_lat(dstGridName)
    dstlon       = retrieve_SCRIP_lon(dstGridName)
    dstlat@units = "degrees_north"
    dstlon@units = "degrees_east"

    swe_regrid!0   = "lat"
    swe_regrid!1   = "lon"
    swe_regrid&lat = dstlat(:,0)    ; This is a rectilinear grid, so
    swe_regrid&lon = dstlon(0,:)    ; we only need a 1D sub-selection.
    
;----------------------------------------------------------------------
; Plotting section
;----------------------------------------------------------------------
    wks = gsn_open_wks("png","ESMF_all")        ; send graphics to PNG file

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
