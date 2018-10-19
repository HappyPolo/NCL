;======================================================================
; ESMF_regrid_5.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF_regrid
;   - Interpolating data from a WRF grid to a rectilinear grid
;   - Using functions for cleaner code
;======================================================================
; This example is identical to ESMF_all_5.ncl, except it does the
; regridding in one call to "ESMF_regrid".  See ESMF_wgts_5.ncl
; for a faster example of regridding using an existing weights file.
;======================================================================
; This example uses the ESMF application "ESMF_RegridWeightGen" to 
; generate the weights.  The weights are generated once, and then
; used to regrid two different variables.
;
; For more information about ESMF:
;
;        http://www.earthsystemmodeling.org/
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

;======================================================================
; The main code
;======================================================================

begin
;---Input file
    srcFileName = "WRF.grb"

;---Retrieve either one level, or all levels. Use '-1' for all.
    sfile = addfile(srcFileName,"r")

    Opt                = True
    Opt@SrcTitle       = "WRF grid"   ; optional

    Opt@WgtFileName    = "WRF_to_Rect.nc"

    Opt@ForceOverwrite = True
    ;;Opt@PrintTimings = True

    LEVEL       = 18   ; Use -1  for all levels
    TMP_VARNAME = "TMP_GDS5_ISBL"
    U_VARNAME   = "U_GRD_GDS5_ISBL"
    if(LEVEL.eq.-1) then
      TMP = sfile->$TMP_VARNAME$
      U   = sfile->$U_VARNAME$
    else
      TMP = sfile->$TMP_VARNAME$(LEVEL,:,:)
      U   = sfile->$U_VARNAME$(LEVEL,:,:)
    end if

;---Get the source lat/lon grid
    lat2d = sfile->g5_lat_0
    lon2d = sfile->g5_lon_1
    dims  = dimsizes(lat2d)
    nlat  = dims(0)
    nlon  = dims(1)

    lon2d = where(lon2d.lt.0,360+lon2d,lon2d)

    TMP@lat2d = lat2d              ; This information will be used by
    TMP@lon2d = lon2d              ; ESMF_regrid for the source grid
    U@lat2d   = lat2d
    U@lon2d   = lon2d

    Opt@SrcFileName     = "WRF_SCRIP.nc"      ; Name of source and
    Opt@DstFileName     = "Rectilinear.nc"    ; destination files

;---Create the destination lat/lon grid
    lat = fspan( 53.2420, 85.4022,nlat)
    lon = fspan(135.7750,258.1880,nlon)

    Opt@DstGridType          = "rectilinear"
    Opt@DstGridLat           = lat
    Opt@DstGridLon           = lon

    Opt@InterpMethod         = "bilinear"
    Opt@SrcRegional          = True
    Opt@DstRegional          = True

    TMP_regrid = ESMF_regrid(TMP,Opt)     ; Do the regridding for TMP
;
; The source and destination grid description files and
; weight file will be the same for the next call to 
; ESMF_grid, so no need to regenerate them.
;
    Opt@SkipSrcGrid   = True
    Opt@SkipDstGrid   = True
    Opt@SkipWgtGen    = True
 
    U_regrid          = ESMF_regrid(U,Opt)   ; Do the regridding for U

;---Reset 0 values to missing values.
    TMP_regrid@_FillValue = default_fillvalue(typeof(TMP_regrid))
    U_regrid@_FillValue   = default_fillvalue(typeof(U_regrid))

    TMP_regrid            = where(TMP_regrid.eq.0.0,TMP_regrid@_FillValue,\
                                  TMP_regrid)
    U_regrid              = where(U_regrid.eq.0.0,U_regrid@_FillValue,\
                                  U_regrid)

    printVarSummary(TMP_regrid)
    printVarSummary(U_regrid)

;----------------------------------------------------------------------
; Plotting section
;----------------------------------------------------------------------
    wks = gsn_open_wks("png","ESMF_regrid")  ; send graphics to PNG file

    tmp_levels = ispan(200,293,3)
    u_levels   = ispan(-50,64,2)
;
; If plotting multiple levels, you might want to use two
; different workstations here.
;
    plot_data(wks, TMP,TMP_regrid,TMP_VARNAME, LEVEL,tmp_levels)
    plot_data(wks, U,    U_regrid,  U_VARNAME, LEVEL,  u_levels)
end
