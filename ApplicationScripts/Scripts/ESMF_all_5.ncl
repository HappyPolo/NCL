;======================================================================
; ESMF_all_5.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF software
;   - Interpolating data from a WRF grid to a rectilinear grid
;   - Using functions for cleaner code
;======================================================================
; This example is identical to ESMF_regrid_5.ncl, except it does the
; regridding in separate steps.  See ESMF_wgts_5.ncl for a faster 
; example of regridding using an existing weights file.
;======================================================================
; This example uses the ESMF application "ESMF_RegridWeightGen" to 
; generate the weights.  The weights are generated once, and then
; used to regrid two different variables.
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
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

;======================================================================
; This procedure plots both the original data and regridded data
; as a panel plot, given the data, variable name, level(s) to
; plot, and the contour levels.
;======================================================================
undef("plot_data")
procedure plot_data(wks,data_orig,data_regrid,VARNAME,LEVEL,cnlevels)
local start_level, end_levels, tdims, n, res, pres, plot_orig, plot_r
begin
   print("--------------------------------------------------")
   print("Generating plot(s) for variable '" + VARNAME + "'...")

;---Set some common resources
    res                   = True

    res@gsnMaximize       = True

    res@cnFillOn          = True
    res@cnFillPalette     = "WhViBlGrYeOrReWh"  ; set color map
    res@cnLinesOn         = False
    res@cnLineLabelsOn    = False

    res@cnLevelSelectionMode = "ExplicitLevels"
    res@cnLevels             = cnlevels

    res@mpFillOn          = False

    res@mpMinLatF         = min(data_regrid&lat)
    res@mpMaxLatF         = max(data_regrid&lat)
    res@mpMinLonF         = min(data_regrid&lon)
    res@mpMaxLonF         = max(data_regrid&lon)
    res@mpCenterLonF      = (min(data_regrid&lon)+max(data_regrid&lon))*0.5
    res@mpCenterLatF      = (min(data_regrid&lat)+max(data_regrid&lat))*0.5

    res@lbBoxLinesOn      = False

    res@gsnAddCyclic      = False

    res@gsnDraw         = False
    res@gsnFrame        = False
    res@lbLabelBarOn    = False

    res@pmTickMarkDisplayMode = "always" ; map tickmarks
    res@pmTitleZone     = 4  ; Move main title down

;---Set some panel resources
    pres                    = True
    pres@gsnMaximize        = True
    pres@gsnPanelLabelBar   = True
    pres@lbLabelFontHeightF = 0.01
    pres@lbBoxLinesOn       = False

    if(LEVEL.eq.-1) then
      start_level = 0
      end_level   = dimsizes(data_orig(:,0,0))-1
      tdims       = dimsizes(data_orig(0,:,:))
    else
      start_level = LEVEL
      end_level   = LEVEL
      tdims       = dimsizes(data_orig)
    end if

;---Loop across the desired levels and plot TMP and U
    do n=start_level,end_level
      if(LEVEL.eq.-1) then
;---Plotting all levels
        print("level(" + n + ") = " + data_orig&lv_ISBL2(n))

;---Create plot for original data

        res@tiMainString    = "Original WRF grid"
        res@gsnRightString  = "level = " + data_orig&lv_ISBL2(n)

        res@gsnLeftString   = VARNAME + " (" + \
                              str_join(tostring(tdims)," x ") + ")"

        plot_orig = gsn_csm_contour_map(wks,data_orig(n,:,:),res)  

;---Create plot for regridded data
        res@tiMainString = "Regridded to rectilinear grid"

        res@gsnLeftString = VARNAME + " regridded (" + \
                            str_join(tostring(tdims)," x ") + ")"

        plot_regrid = gsn_csm_contour_map(wks,data_regrid(n,:,:),res)  

      else
;---Plotting one level
        print("level(" + n + ") = " + data_orig@lv_ISBL2)

;---Create plot for original data_orig
        res@tiMainString   = "Original WRF grid"
        res@gsnRightString = "level = " + data_orig@lv_ISBL2

        res@gsnLeftString  = VARNAME + " (" + \
                             str_join(tostring(tdims)," x ") + ")"

        plot_orig = gsn_csm_contour_map(wks,data_orig,res)  

;---Create plot for regridded data_orig
        res@tiMainString  = "Regridded to rectilinear grid"

        res@gsnLeftString = VARNAME + " regridded (" + \
                            str_join(tostring(tdims)," x ") + ")"

        plot_regrid = gsn_csm_contour_map(wks,data_regrid,res)  

      end if

;---Panel both sets of plots
      gsn_panel(wks,(/plot_orig,plot_regrid/),(/2,1/),pres)
    end do
end

;----------------------------------------------------------------------
; The main code
;----------------------------------------------------------------------

begin
;---Input file
    srcFileName = "WRF.grb"

;---Output (and input) files
    srcGridName = "WRF_SCRIP.nc"
    dstGridName = "Rectilinear.nc"
    wgtFile     = "WRF_to_Rect.nc"

;---Set to True if you want to skip any of these steps
    SKIP_SRC_SCRIP_GEN = False
    SKIP_DST_SCRIP_GEN = False
    SKIP_WGT_GEN       = False
    
;---Retrieve either one level, or all levels. Use '-1' for all.
    sfile = addfile(srcFileName,"r")

    LEVEL       = 18     ; use -1 for all levels, there are 19 levels
    TMP_VARNAME = "TMP_GDS5_ISBL"
    U_VARNAME   = "U_GRD_GDS5_ISBL"
    if(LEVEL.eq.-1) then
      TMP = sfile->$TMP_VARNAME$
      U   = sfile->$U_VARNAME$
    else
      TMP = sfile->$TMP_VARNAME$(LEVEL,:,:)
      U   = sfile->$U_VARNAME$(LEVEL,:,:)
    end if

;---Get the lat/lon grid associated with these variables
    lat2d = sfile->g5_lat_0
    lon2d = sfile->g5_lon_1
    dims  = dimsizes(lat2d)
    nlat  = dims(0)
    nlon  = dims(1)

;----------------------------------------------------------------------
; Step 1, part 1
;   Write WRF grid description to SCRIP file
;----------------------------------------------------------------------
    if(.not.SKIP_SRC_SCRIP_GEN) then
      lon2d = where(lon2d.lt.0,360+lon2d,lon2d)

      Opt                = True
      Opt@ForceOverwrite = True
      Opt@PrintTimings   = True
      Opt@Title          = "WRF grid"

      curvilinear_to_SCRIP(srcGridName,lat2d,lon2d,Opt)

;---Clean up
      delete(Opt)
    end if

;----------------------------------------------------------------------
; Step 1, part 2
;   Write rectilinear grid description to SCRIP file
;   Use same size as WRF grid dimensions
;----------------------------------------------------------------------
    lat1d = fspan( 53.2420, 85.4022,nlat)
    lon1d = fspan(135.7750,258.1880,nlon)

    if(.not.SKIP_DST_SCRIP_GEN) then
      Opt                = True
      Opt@ForceOverwrite = True
      Opt@PrintTimings   = True
    
      rectilinear_to_SCRIP(dstGridName,lat1d,lon1d,Opt)

;---Clean up
      delete(Opt)
    end if

;----------------------------------------------------------------------
; Step 2
;    Generate interpolation weights for WRF grid to Rectilinear grid    
;----------------------------------------------------------------------
    if(.not.SKIP_WGT_GEN) then
      Opt                      = True
      Opt@InterpMethod         = "bilinear"
      Opt@SrcRegional          = True
      Opt@DstRegional          = True
      Opt@PrintTimings         = True
      Opt@ForceOverwrite       = True

      ESMF_regrid_gen_weights(srcGridName, dstGridName, wgtFile, Opt)

;---Clean up
      delete(Opt)
   end if

;----------------------------------------------------------------------
; Step 3
;    Interpolate data from WRF to regional rectilinear grid.
;    Regrid two datasets: TMP and U_GRD.
;----------------------------------------------------------------------

;---Interpolate temperature and u
    Opt                = True
    Opt@PrintTimings   = True
;   Opt@Debug          = True

    TMP_regrid = ESMF_regrid_with_weights(TMP,wgtFile,Opt)
    U_regrid   = ESMF_regrid_with_weights(U,wgtFile,Opt)

;---Reset 0 values to missing values.
    TMP_regrid@_FillValue = default_fillvalue(typeof(TMP_regrid))
    U_regrid@_FillValue   = default_fillvalue(typeof(U_regrid))

    TMP_regrid            = where(TMP_regrid.eq.0.0,TMP_regrid@_FillValue,\
                                  TMP_regrid)
    U_regrid              = where(U_regrid.eq.0.0,U_regrid@_FillValue,\
                                  U_regrid)
    printVarSummary(TMP_regrid)
    printVarSummary(U_regrid)

    TMP@lat2d = lat2d
    TMP@lon2d = lon2d
    U@lat2d   = lat2d
    U@lon2d   = lon2d

;----------------------------------------------------------------------
; Plotting section
;----------------------------------------------------------------------
    wks = gsn_open_wks("png","ESMF_all")  ; send graphics to PNG file

    tmp_levels = ispan(200,293,3)
    u_levels   = ispan(-50,64,2)
;
; If plotting multiple levels, you might want to use two
; different workstations here.
;
    plot_data(wks, TMP,TMP_regrid,TMP_VARNAME, LEVEL,tmp_levels)
    plot_data(wks, U,    U_regrid,  U_VARNAME, LEVEL,  u_levels)
end
