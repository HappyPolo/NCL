======================================================================
; ESMF_regrid_35.ncl
;
; Concepts illustrated:
;   - Interpolating from high-to-low resolution using 3 ESMF_regrid methods 
;   - Determine the number of _FillValue (nmsg); use 'mask' if nmsg>0
;   - Panel plot
;   - Create netCDF
;======================================================================
;No need to load these after 6.1.2
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; must load the 'ESMF-regridding.ncl' library
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
begin
    PLOT = True
    NC   = True

;---Read data off source file
    hfcVarName  = "E_HFC_1234"                 ; variable name

    hfcDirName  = "./"                         ; source file directory
    hfcFileName = "HFC.nc"                     ; source grid
    hfcPathName = hfcDirName+hfcFileName
    hfile       = addfile(hfcPathName,"r")
    x           = hfile->$hfcVarName$

    printVarSummary(x)
    printMinMax(x,0)

    nmsg        = num(ismissing(x))            ; Check to see id any _FillValue
    print("nmsg="+nmsg)

;---Look at statistics; help with plotting range
    
   opt = True
   opt@PrintStat = True
   statb = stat_dispersion(x, opt )

;---Create destination 1x1 grid
;   latitude: [33.04999923706055..72.94999694824219]
;   longitude: [-12.45001220703125..44.95000076293945]

    nlat = 41
    lat  = fspan(33, 73, nlat) 
    lat@units = "degrees_north"
    lat!0 = "lat"
    lat&lat = lat

    mlon = 58
    lon  = fspan(-12, 45, mlon) 
    lon@units = "degrees_north"
    lon!0  = "lon"
    lon&lon = lon

;---Assign zoom region for graphics
    minlon = min(x&longitude)
    maxlon = max(x&longitude)
    minlat = min(x&latitude)
    maxlat = max(x&latitude)

    print("min/max lat = " + minlat + "/" + maxlat)
    print("min/max lon = " + minlon + "/" + maxlon)

;---Options for regridding
    Opt                 = True

    Opt@ForceOverwrite  = True

    Opt@SrcTitle        = hfcFileName                  ; source grid
    if (nmsg.gt.0) then
        Opt@SrcMask2D   = where(ismissing(x),0,1)
    end if
    Opt@SrcRegional     = True

    Opt@DstTitle        = "HFC 1x1 Rectilinear Grid" ; destination grid
    Opt@DstGridLat      = lat
    Opt@DstGridLon      = lon
    Opt@DstRegional     = True

    ;;Opt@PrintTimings  = True

;---Regrid
    Opt@InterpMethod = "bilinear"            ; bilinear interpolation 
    Opt@WgtFileName  = "HFC_1x1_bilinear.nc"
    x_regrid_b   = ESMF_regrid(x,Opt)

    Opt@InterpMethod = "patch"               ; patch interpolation 
    Opt@WgtFileName  = "HFC_1x1_patch.nc"
    x_regrid_p   = ESMF_regrid(x,Opt)

    Opt@InterpMethod = "conserve"            ;  interpolation 
    Opt@WgtFileName  = "HFC_1x1_conserve.nc"
    x_regrid_c   = ESMF_regrid(x,Opt)

;----------------------------------------------------------------------
; Plotting section
;----------------------------------------------------------------------

if (PLOT) then
    wks = gsn_open_wks("png","esmf_regrid")

    res                       = True               ; Plot modes desired.
    res@gsnDraw               = False
    res@gsnFrame              = False

    res@mpDataBaseVersion     = "MediumRes"
    res@mpDataSetName         = "Earth..4"
    res@mpFillOn              = False
    res@mpOutlineOn           = True
    res@mpOutlineBoundarySets = "AllBoundaries"

    res@mpMinLatF             = min(lat) 
    res@mpMaxLatF             = max(lat)
    res@mpMinLonF             = min(lon)
    res@mpMaxLonF             = max(lon)

    res@cnLinesOn             = False
    res@cnFillMode            = "RasterFill"
    res@cnLineLabelsOn        = False
    res@cnFillOn              = True
    res@cnFillPalette         = "WhiteBlueGreenYellowRed"

    res@cnLevelSelectionMode  = "ExplicitLevels"
    res@cnLevels              = (/0.001, 0.050, 0.060, 0.070, 0.080, 0.090, 0.100, 0.125, 0.150\
                                 ,0.200, 0.250,  0.50, 1, 5, 10, 15, 20,  25, 50 /)

    res@pmTickMarkDisplayMode = "Always"
    res@gsnAddCyclic          = False   ; don't add cyclic longitude point
    res@tiMainFontHeightF     = 0.02
    res@lbLabelBarOn          = False

    res@gsnLeftString         = "Original data (" + \
                                  str_join(tostring(dimsizes(x))," x ") + ")"
    plot = gsn_csm_contour_map_ce(wks,x,res)     

;---bilinear
    res@gsnLeftString         = "Regridded data (bilinear) (" + \
                       str_join(tostring(dimsizes(x_regrid_b))," x ") + ")"

    plot_b = gsn_csm_contour_map_ce(wks,x_regrid_b,res)     

;---patch
    res@gsnLeftString         = "Regridded data (patch) (" + \
                       str_join(tostring(dimsizes(x_regrid_p))," x ") + ")"

    plot_p = gsn_csm_contour_map_ce(wks,x_regrid_p,res)     

;---conserve
    res@gsnLeftString         = "Regridded data (conserve) (" + \
                       str_join(tostring(dimsizes(x_regrid_c))," x ") + ")"

    plot_c = gsn_csm_contour_map_ce(wks,x_regrid_c,res)     

;---Panel all four plots
    pres                    = True
    pres@gsnMaximize        = True
    pres@gsnPanelLabelBar   = True
    pres@pmLabelBarWidthF   = 0.8
    pres@lbLabelFontHeightF = 0.01
    gsn_panel(wks,(/plot,plot_b,plot_p,plot_c/),(/2,2/),pres)
end if    ; PLOT

if (NC) then                              ; Create netCDF
    diro   = "./"
    filo   = "HFC_ESMF_REGRID.nc"
    system("/bin/rm -f "+diro+filo)       ; remove any pre-existing file
    ncdf   = addfile(diro+filo ,"c")      ; open output netCDF file
    ncdf@title  = "HFC: ESMF Regrid"
    ncdf@source = hfcFileName
    ncdf@creation_date = systemfunc("date")
  
    name = hfcVarName+"_bilinear" 
    ncdf->$name$ = x_regrid_b
  
    name = hfcVarName+"_patch" 
    ncdf->$name$ = x_regrid_p
  
    name = hfcVarName+"_conserve" 
    ncdf->$name$ = x_regrid_c

end if

end
