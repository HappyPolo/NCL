;======================================================================
; ESMF_all_15.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF software
;   - Interpolating swath data to a 0.25 degree grid
;======================================================================
;
; This example is identical to ESMF_regrid_15.ncl, except it does the
; regridding in separate steps.
;
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
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin
;---Input file; read as an HDF-EOS 2 file.
    srcFileName = "MOD06_L2.A2010031.1430.005.2010031221343.hdf.he2"

;---Output (and input) files
    srcGridName = "SrcSCRIP.nc"
    dstGridName = "DstSCRIP.nc"
    wgtFile_b   = "Swath_2_Rect_bilinear.nc"
    wgtFile_p   = "Swath_2_Rect_patch.nc"
    wgtFile_c   = "Swath_2_Rect_conserve.nc"

;---Set to True if you want to skip any of these steps
    SKIP_SRC_SCRIP_GEN = False
    SKIP_DST_SCRIP_GEN = False
    SKIP_WGT_GEN       = False

;----------------------------------------------------------------------
; Step 1, part 1
;     Convert swath grid to SCRIP convention file.
;----------------------------------------------------------------------
    sfile   = addfile(srcFileName,"r")
    lat2d   = sfile->Latitude_mod06
    lon2d   = sfile->Longitude_mod06
    cldfrac = sfile->Cloud_Fraction_mod06

;---Assign map zoom region
    minlon = min(lon2d)
    maxlon = max(lon2d)
    minlat = min(lat2d)
    maxlat = max(lat2d)

    print("min/max cldfrac = " + min(cldfrac) + "/" + max(cldfrac))
    print("min/max lat2d = " + minlat + "/" + maxlat)
    print("min/max lon2d = " + minlon + "/" + maxlon)

    if(.not.SKIP_SRC_SCRIP_GEN) then
    
;--- Convert to a SCRIP Convention file.
      Opt                = True
      Opt@ForceOverwrite = True
      Opt@PrintTimings   = True
      Opt@Title          = srcFileName

      curvilinear_to_SCRIP(srcGridName,lat2d,lon2d,Opt)

;---Clean up
      delete(Opt)
   end if

;----------------------------------------------------------------------
; Step 1, part 2
;     Convert destination grid to SCRIP convention file.
;----------------------------------------------------------------------
    if(.not.SKIP_DST_SCRIP_GEN) then
      Opt                = True
      Opt@ForceOverwrite = True
      Opt@PrintTimings   = True
      Opt@LLCorner       = (/minlat,minlon/)
      Opt@URCorner       = (/maxlat,maxlon/)
      latlon_to_SCRIP(dstGridName,"0.25deg",Opt)

;---Clean up
      delete(Opt)
    end if

;----------------------------------------------------------------------
; Step 2
;     Generate the weights using different interpolation methods.
;----------------------------------------------------------------------
    if(.not.SKIP_WGT_GEN) then
      Opt                      = True
      Opt@SrcRegional          = True
      Opt@DstRegional          = True
      Opt@ForceOverwrite       = True
      Opt@PrintTimings         = True

      Opt@InterpMethod         = "bilinear"
      ESMF_regrid_gen_weights(srcGridName,dstGridName,wgtFile_b,Opt)

      Opt@InterpMethod         = "patch"
      ESMF_regrid_gen_weights(srcGridName,dstGridName,wgtFile_p,Opt)

      Opt@InterpMethod         = "conserve"
      ESMF_regrid_gen_weights(srcGridName,dstGridName,wgtFile_c,Opt)

;---Clean up
      delete(Opt)
    end if

;----------------------------------------------------------------------
; Step 3
;     Apply the weights to a given variable on the weight file
;----------------------------------------------------------------------
    opt                = True
    opt@Debug          = True
    opt@PrintTimings   = True

    cldfrac_regrid_b = ESMF_regrid_with_weights(cldfrac,wgtFile_b,opt)
    cldfrac_regrid_p = ESMF_regrid_with_weights(cldfrac,wgtFile_p,opt)
    cldfrac_regrid_c = ESMF_regrid_with_weights(cldfrac,wgtFile_c,opt)

;---Add attributes and coordinate arrays for plotting
    dstlat       = retrieve_SCRIP_lat(dstGridName)
    dstlon       = retrieve_SCRIP_lon(dstGridName)
    dstlat@units = "degrees_north"
    dstlon@units = "degrees_east"

    copy_VarAtts(cldfrac,cldfrac_regrid_b)
    copy_VarAtts(cldfrac,cldfrac_regrid_p)
    copy_VarAtts(cldfrac,cldfrac_regrid_c)
;
; We have to force the _FillValue because original and 
; regridded data are different types.
;
    cldfrac_regrid_b@_FillValue = cldfrac@_FillValue
    cldfrac_regrid_p@_FillValue = cldfrac@_FillValue
    cldfrac_regrid_c@_FillValue = cldfrac@_FillValue

    cldfrac_regrid_b!0   = "lat"
    cldfrac_regrid_b!1   = "lon"
    cldfrac_regrid_b&lat = dstlat(:,0)    ; This is a rectilinear grid, so
    cldfrac_regrid_b&lon = dstlon(0,:)    ; we only need a 1D sub-selection.

    cldfrac_regrid_p!0   = "lat"
    cldfrac_regrid_p!1   = "lon"
    cldfrac_regrid_p&lat = dstlat(:,0)    ; This is a rectilinear grid, so
    cldfrac_regrid_p&lon = dstlon(0,:)    ; we only need a 1D sub-selection.

    cldfrac_regrid_c!0   = "lat"
    cldfrac_regrid_c!1   = "lon"
    cldfrac_regrid_c&lat = dstlat(:,0)    ; This is a rectilinear grid, so
    cldfrac_regrid_c&lon = dstlon(0,:)    ; we only need a 1D sub-selection.

;    printVarSummary(cldfrac_regrid_b)
;    printVarSummary(cldfrac_regrid_p)
;    printVarSummary(cldfrac_regrid_c)

;----------------------------------------------------------------------
; Plotting section
;----------------------------------------------------------------------

    wks = gsn_open_wks("png","ESMF_all")   ; send graphics to PNG file

    colors = (/"white"         \        ; cloudy
              ,"azure"         \        ; uncertain
              ,"cadetblue"     \        ; probably clear
              ,"blue4"         /)       ; clear

    res                       = True              ; Plot mods desired.

    res@gsnMaximize           = True           ; make plot large 

    res@gsnDraw               = False
    res@gsnFrame              = False

    res@mpProjection          = "Satellite"   ; choose map projection

    res@mpDataBaseVersion     = "MediumRes"
    res@mpDataSetName         = "Earth..4"
    res@mpFillOn              = False
    res@mpOutlineOn           = True
    res@mpOutlineBoundarySets = "AllBoundaries"

    res@mpLimitMode           = "LatLon"           ; required
    res@mpMinLatF             = min(lat2d)-1       ; min lat
    res@mpMaxLatF             = max(lat2d)+1       ; max lat
    res@mpMinLonF             = min(lon2d)-1       ; min lon
    res@mpMaxLonF             = max(lon2d)+1       ; max lon
    res@mpCenterLonF          = (min(lon2d)+max(lon2d))*0.5
    res@mpCenterLatF          = (min(lat2d)+max(lat2d))*0.5

    res@cnLinesOn             = False
    res@cnFillMode            = "RasterFill"
    res@cnLineLabelsOn        = False
    res@cnFillOn              = True
    res@cnFillPalette         = colors              ; set color map

    res@cnLevelSelectionMode  = "ManualLevels"     ; set manual contour levels
    res@cnMinLevelValF        =  10                ; min contour level
    res@cnMaxLevelValF        = 100                ; max contour level
    res@cnLevelSpacingF       =  10                ; contour spacing

    res@trGridType            = "TriangularMesh"   ; faster graphic rendering

    res@pmTickMarkDisplayMode = "Always"

    res@gsnAddCyclic          = False   ; don't add cyclic longitude point

    res@tiMainFontHeightF     = 0.02

    res@lbLabelBarOn          = False   ; turn off labelbar, we will add
                                        ; later in panel plot.
    res@sfYArray              = lat2d
    res@sfXArray              = lon2d

    res@gsnRightString        = ""      ; clean up plot labels

;---Create plot of original data
;    res@tmYROn                = False
;    res@tmYRLabelsOn          = False

    dims = dimsizes(cldfrac)
    res@tiMainString = "Original data (" + \
                       str_join(tostring(dims)," x ") + ")"
    plot = gsn_csm_contour_map(wks,cldfrac,res)     

;---Regridded data has coordinate arrays, so don't want to use sfX/YArray.
    delete(res@sfYArray)
    delete(res@sfXArray)

    dims = dimsizes(cldfrac_regrid_b)

;---Create plots of regridded data
    res@tiMainString = "Regridded to 0.25 degree grid (bilinear) (" + \
                       str_join(tostring(dims)," x ") + ")"
    plot_regrid_b = gsn_csm_contour_map(wks,cldfrac_regrid_b,res)     

    res@tiMainString = "Regridded to 0.25 degree grid (patch) (" + \
                       str_join(tostring(dims)," x ") + ")"
    plot_regrid_p = gsn_csm_contour_map(wks,cldfrac_regrid_p,res)     

    res@tiMainString = "Regridded to 0.25 degree grid (conserve) (" + \
                       str_join(tostring(dims)," x ") + ")"
    plot_regrid_c = gsn_csm_contour_map(wks,cldfrac_regrid_c,res)     

;---Panel three plots
    pres                     = True
    pres@gsnMaximize         = True    ; The default for PS/PDF
    pres@gsnPanelLabelBar    = True
    pres@lbTitleString       = "percent"        ; title
    pres@lbTitlePosition     = "Bottom"         ; location of title
    pres@lbLabelFontHeightF  = 0.01
    pres@lbTitleFontHeightF  = 0.01

    gsn_panel(wks,(/plot,plot_regrid_b/),(/2,1/),pres)
    gsn_panel(wks,(/plot,plot_regrid_p/),(/2,1/),pres)
    gsn_panel(wks,(/plot,plot_regrid_c/),(/2,1/),pres)
end
