;======================================================================
; ESMF_regrid_33.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF_regrid
;   - Interpolating data from a 'Greenland' grid to a rectilinear grid
;   - Drawing lat/lon grid lines of data
;======================================================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"


;---Read data off source file
    srcDirName  = "./"
    srcFileName = "gland5.input.nc"                  ; source grid
    srcFilePath = srcDirName + srcFileName
    sfile       = addfile(srcFilePath,"r")
    x           = sfile->presusurf(0,:,:)            ; any variable can be used
    lat2d       = sfile->lat(0,:,:)  
    lon2d       = sfile->lon(0,:,:)  
    x@lat2d     = lat2d
    x@lon2d     = lon2d

;---Source grid sizes
    dimx        = dimsizes(x)
    src_nlat    = dimx(0)
    src_mlon    = dimx(1)

;---Assign zoom region
    minlon = min(x@lon2d)
    maxlon = max(x@lon2d)
    minlat = min(x@lat2d)
    maxlat = max(x@lat2d)

   ;print("min/max x     = " + min(x) + "/" + max(x))
   ;print("min/max lat2d = " + minlat + "/" + maxlat)          ; min/max: 58.6293/84.4819
   ;print("min/max lon2d = " + minlon + "/" + maxlon)          ; mon/max:-92.1301/10.3987
   
;---ESMF options
    Opt                      = True
    Opt@DstGridType          = "rectilinear"
    Opt@DstGridLat           = lat
    Opt@DstGridLon           = lon
    Opt@DstRegional          = True

;---Create the destination lat/lon grid 

    Opt@DstGridType       = "1.0deg"
    Opt@DstLLCorner       = (/ 58.5,-92.5 /)                   ; nice rounded numbers
    Opt@DstURCorner       = (/ 84.5, 10.5 /)

    Opt@SrcRegional          = True
    Opt@SrcGridType          = "curvilinear"
    if (isatt(x,"_FillValue")) then
        Opt@SrcMask2D        = where(ismissing(x),0,1)
    end if
    if (isfilepresent("./gland.source_grid_file.nc")) then
        Opt@SkipSrcGrid = True
        Opt@SrcFileName = "./gland.source_grid_file.nc" 
    end if

    Opt@ForceOverwrite = True  
  ;;Opt@RemoveSrcFile  = True                ; remove grid description files
    Opt@RemoveDstFile  = True
    Opt@NoPETLog       = True               ; 6.2.1 onward
    Opt@Debug          = True 

    Opt@InterpMethod = "bilinear"            ; bilinear interpolation 
    Opt@WgtFileName  = "gland_to_Rect_bilinear."+Opt@DstGridType+".nc"
    x_regrid_bil = ESMF_regrid(x,Opt)     ; Do the regridding for TMP
    printVarSummary(x_regrid_bil)

    Opt@InterpMethod = "patch"               ; patch interpolation 
    Opt@WgtFileName  = "gland_to_Rect_patch."+Opt@DstGridType+".nc"
    x_regrid_pat   = ESMF_regrid(x,Opt)
    printVarSummary(x_regrid_pat)

    Opt@InterpMethod = "conserve"            ;  interpolation 
    Opt@WgtFileName  = "gland_to_Rect_conserve."+Opt@DstGridType+".nc"
    x_regrid_con     = ESMF_regrid(x,Opt)
    printVarSummary(x_regrid_con)

;----------------------------------------------------------------------
; Plotting section
;----------------------------------------------------------------------

    wks = gsn_open_wks("png","ESMF_regrid")        ; send graphics to PNG file

    res                       = True               ; Plot modes desired.
    res@gsnDraw               = False
    res@gsnFrame              = False
    res@gsnAddCyclic          = False

    res@mpProjection          = "Stereographic"
    res@mpDataBaseVersion     = "MediumRes"
    res@mpFillOn              = False
   ;res@mpOutlineOn           = True
    res@mpPerimDrawOrder      = "PostDraw"

    res@mpProjection          = "Stereographic"
    res@mpCenterLonF          = sfile->mapping@straight_vertical_longitude_from_pole
    res@mpCenterLatF          = sfile->mapping@standard_parallel
    res@mpLimitMode           = "Corners"  
    res@mpLeftCornerLatF      = lat2d(0,0)
    res@mpLeftCornerLonF      = lon2d(0,0)
    res@mpRightCornerLatF     = lat2d(src_nlat-1,src_mlon-1)
    res@mpRightCornerLonF     = lon2d(src_nlat-1,src_mlon-1)

    res@mpMinLatF             = minlat
    res@mpMaxLatF             = maxlat
    res@mpMinLonF             = minlon
    res@mpMaxLonF             = maxlon

    res@cnFillMode            = "RasterFill"
    res@cnLineLabelsOn        = False
    res@cnFillOn              = True
    res@cnLinesOn             = False
    res@cnLineLabelsOn        = False
    res@cnFillPalette         = "WhiteBlueGreenYellowRed"

   ;res@pmTickMarkDisplayMode = "Always"
    res@gsnAddCyclic          = False   ; don't add cyclic longitude point
    res@tiMainFontHeightF     = 0.02
    res@lbLabelBarOn          = False
    res@gsnLeftString         = ""
    res@gsnRightString        = ""
    res@gsnCenterString       = x@long_name + " (" + x@units + ")"

    res@trGridType           = "TriangularMesh"
    res@tfDoNDCOverlay       = True
    res@tiMainString          = "Original (" + \
                                  str_join(tostring(dimsizes(x))," x ") + ")"
    plot = gsn_csm_contour_map(wks,x,res)     
    delete( [/res@trGridType, res@tfDoNDCOverlay /] )

;---bilinear
    res@tiMainString = "bilinear (" + \
                       str_join(tostring(dimsizes(x_regrid_bil))," x ") + ")"
    plot_b = gsn_csm_contour_map(wks,x_regrid_bil,res)     

;---patch
    res@tiMainString = "patch (" + \
                       str_join(tostring(dimsizes(x_regrid_pat))," x ") + ")"
    plot_p = gsn_csm_contour_map(wks,x_regrid_pat,res)     

;---conserve
    res@tiMainString = "conserve (" + \
                       str_join(tostring(dimsizes(x_regrid_con))," x ") + ")"

    plot_c = gsn_csm_contour_map(wks,x_regrid_con,res)     

;---Panel all four plots
    pres                    = True
    pres@gsnPanelLabelBar   = True
    pres@pmLabelBarWidthF   = 0.5
    pres@lbLabelFontHeightF = 0.01
    pres@gsnMaximize        = True

    gsn_panel(wks,(/plot,plot_b,plot_p,plot_c/),(/2,2/),pres)
