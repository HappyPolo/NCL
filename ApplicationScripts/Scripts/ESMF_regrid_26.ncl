;======================================================================
; ESMF_regrid_26.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF_regrid
;   - Interpolating data from a ROMS grid to a 0.05 degree grid
;   - Writing data to a NetCDF file using the efficient method
;======================================================================
; This script regrids the "temp" array to a 0.05 degree grid, 
; using "bilinear" interpolation. The 0.05 was chosen because
; it roughy approximated the 5km spacing of the source ROMS grid.
;
; The grid information and model output are on two separate files.
;
; A weights file called "ROMS_to_0.05deg_bilinear.nc" is created when
; you run this script, which you can then use to regrid any other time 
; or level, or even another variable, as long as it's on the same grid.
; See the roms_to_0.05deg_wgts.ncl script.
;
; The plots are created only to visually 'validate' the regridding.
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
    interp_method = "bilinear"           ; "bilinear", "conserve", "patch"
    grid_size     = 0.05                 ; degree
    grid_string   = grid_size + "deg"
    regrid_string = "ROMS_to_" +  grid_string + "_" + interp_method

;---Data file containing source grid
    grd_file = "coral_grd.nc"
    gfile    = addfile(grd_file,"r")

;---Data file containing variable to regrid
    src_file = "coral_avg_00105.nc"
    sfile    = addfile(src_file,"r")
;
; Get variable to regrid. Do for first level and timestep.
; Weights can be used for other levels and timesteps.
;
     nt      = 0             ; timestep
     kl      = 0             ; level
     varname = "temp" 

     var     = sfile->$varname$(nt,kl,:,:)
     src_lat = gfile->lat_rho
     src_lon = gfile->lon_rho

;---convert time to readable format for plot (-3 means yyyymmddhh )
     newtime = cd_calendar(sfile->ocean_time,-3)

;--Debug prints
     printMinMax(var,0)
     printMinMax(src_lat,0)
     printMinMax(src_lon,0)

;--Grid limits
     minLat  = min(src_lat)    ; -22.90 
     maxLat  = max(src_lat)    ;  27.20   
     minLon  = min(src_lon)    ;  94.90  
     maxLon  = max(src_lon)    ; 168.20 

;---Set up regridding options
    Opt                   = True

;---"bilinear" is the default. "patch" and "conserve" are other options.
    Opt@InterpMethod      = interp_method
    Opt@WgtFileName       = regrid_string + ".nc"

    Opt@SrcGridLat        = src_lat
    Opt@SrcGridLon        = src_lon
    Opt@SrcRegional       = True
    Opt@SrcMask2D         = where(.not.ismissing(var),1,0)

    Opt@DstGridType       = grid_string
    Opt@DstRegional       = True

;---This will make regridding go faster.
    Opt@DstLLCorner       = (/minLat, minLon/)
    Opt@DstURCorner       = (/maxLat, maxLon/)

    Opt@ForceOverwrite    = True
    Opt@PrintTimings      = True
    Opt@Debug             = True

;---Do the regridding
    var_regrid = ESMF_regrid(var,Opt)     

    printVarSummary(var_regrid)

;----------------------------------------------------------------------
; Plotting section
;
; This section creates filled contour plots of both the original
; data and the regridded data, and panels them.
;----------------------------------------------------------------------
    var@lat2d = src_lat
    var@lon2d = src_lon

  ;;wks = gsn_open_wks("ps",regrid_string)
    wks = gsn_open_wks("png","ESMF_regrid")        ; send graphics to PNG file

    res                       = True

;   res@gsnMaximize           = True               ; Will do this in panel

    res@gsnDraw               = False
    res@gsnFrame              = False

    res@gsnAddCyclic          = False              ; don't add cyclic point

    res@cnFillOn              = True
    res@cnLinesOn             = False
    res@cnLineLabelsOn        = False

    res@cnFillMode            = "RasterFill"       ; These two resources
    res@trGridType            = "TriangularMesh"   ; increase plotting speed.

    res@lbLabelBarOn          = False              ; Turn on later in panel

    res@mpMinLatF             = minLat
    res@mpMaxLatF             = maxLat
    res@mpMinLonF             = minLon
    res@mpMaxLonF             = maxLon
    res@pmTickMarkDisplayMode = "Always"           ; use NCL default lat/lon labels

;---Generate nice contour levels
    mnmxint = nice_mnmxintvl( min(var), max(var), 18, False)
    res@cnLevelSelectionMode  = "ManualLevels"
    res@cnMinLevelValF        = mnmxint(0)
    res@cnMaxLevelValF        = mnmxint(1)
    res@cnLevelSpacingF       = mnmxint(2)/4.   ; force 4x as many levels

    res@pmTitleZone           = 3               ; default makes title move up
    res@tiMainFont            = "helvetica"     ; default is "helvetica-bold"
    res@gsnLeftString         = ""
    res@gsnCenterString       = ""
    res@gsnRightString        = ""

;---Resources for plotting original data
    dims = tostring(dimsizes(var))
    res@tiMainString = "Original curvilinear grid (" +  \
                        str_join(dims," x ") + ")"

    plot_orig = gsn_csm_contour_map(wks,var,res)  

;---Resources for plotting regridded data
    dims = tostring(dimsizes(var_regrid))
    res@tiMainString = "Rectilinear 0.05deg grid (" + \
                        str_join(dims," x ") + ")"

    plot_regrid = gsn_csm_contour_map(wks,var_regrid,res)

;---Compare the plots in a panel
    pres                    = True
    pres@gsnMaximize        = True
    pres@txString           = "Pot Temp (C) at srho=" + var@s_rho + \
                              ", time=" + newtime(nt)
    pres@txFont             = "helvetica-bold"
    pres@txFontHeightF      = 0.02
    pres@gsnPanelLabelBar   = True
    pres@pmLabelBarWidthF   = 0.8
    pres@lbLabelFontHeightF = 0.015

    gsn_panel(wks,(/plot_orig,plot_regrid/),(/1,2/),pres)
end
