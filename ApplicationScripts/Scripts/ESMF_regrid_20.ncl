;======================================================================
; ESMF_regrid_20.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF software
;   - Interpolating data from a curvilinear grid to another curvilinear grid
;   - Interpolating data from a 27km WRF grid to a 81km WRF grid
;======================================================================
; This script regrids a selected variable from a 27km WRF domain,
; to a coarser 81km WRF grid.
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
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin
;
; Whether to use the colors that the WRF online tutorial suggests for
; precipitation. If you set this to True, then a different set
; of contour levels and colors are used.
;
   USE_WRF_COLORS = True

;---Open WRF files (Pres-level Temp files)
   sfile = addfile("27km_wrfout_d01_2010-01-22_18_00_00.nc","r")    ; contains source grid
   dfile = addfile("81km_wrfout_d01_2010-01-22_18_00_00.nc","r")    ; contains destination grid

;---Read in rainc and rainnc, combine
   rainnc_src = sfile->RAINNC    ; 3D
   rainnc_dst = dfile->RAINNC

   rainc_src = sfile->RAINC
   rainc_dst = dfile->RAINC

   prec_src = rainc_src+rainnc_src
   prec_dst = rainc_dst+rainnc_dst
   copy_VarMeta(rainc_src,prec_src)
   copy_VarMeta(rainc_dst,prec_dst)

;---Read lat/lon of 27km grid
    lat_src = sfile->XLAT(0,:,:)
    lon_src = sfile->XLONG(0,:,:)

;---Read lat/lon of 81km grid
    lat_dst = dfile->XLAT(0,:,:)
    lon_dst = dfile->XLONG(0,:,:)

;---Options to pass to ESMF_regrid
    opt                = True

    opt@SrcGridLat     = lat_src
    opt@SrcGridLon     = lon_src
    opt@DstGridLat     = lat_dst
    opt@DstGridLon     = lon_dst

    opt@SrcRegional    = True    ; Default is False
    opt@DstRegional    = True

    opt@CopyVarCoords  = True    ; This is the default in V6.1.0 (not 6.1.0-beta)
    opt@ForceOverwrite = True

;---Debug information
    opt@PrintTimings   = True
    opt@Debug          = True

;---Do the regridding
    prec_src_interp = ESMF_regrid(prec_src,opt)
    printVarSummary(prec_src_interp)

;----------------------------------------------------------------------
; Code to plot the original and regridded data in a panel plot.
;----------------------------------------------------------------------
    prec_src@lat2d = lat_src    ; Needed for plotting. "prec_src_interp"
    prec_src@lon2d = lon_src    ; already has these attrs attached.

    wks = gsn_open_wks("png","ESMF_regrid")  ; send graphics to PNG file

    if(.not.USE_WRF_COLORS) then
      prec_src        = prec_src/100.    ; mm to km
      prec_src_interp = prec_src_interp/100.
      prec_src@units  = "mm"
      prec_dst@units  = "mm"
    end if

    res                     = True          ; Plot mods desired.

;---General resources
    res@gsnDraw             = False         ; We will panel later.
    res@gsnFrame            = False
    res@gsnMaximize         = True          ; Maximize plot
    
;---Contour and labelbar resources
    res@cnFillOn            = True          ; Color plot desired.
    res@cnLinesOn           = False         ; Turn off contour lines.
    res@cnLineLabelsOn      = False         ; Turn off contour labels.
    res@lbLabelBarOn        = False         ; Labelbar will be in panel.
    res@gsnAddCyclic        = False         ; Data is regional.

;---Set some map resources to get the map projection correct.
    res = wrf_map_resources(dfile,res)
    delete(res@mpNestTime)   ; Clean up. Don't need these for gsn_csm...
    delete(res@start_lat)
    delete(res@start_lon)
    delete(res@end_lat)
    delete(res@end_lon)

;---Remove subtitles.
    res@gsnLeftString     = ""
    res@gsnRightString    = ""
    res@tiMainFontHeightF = 0.015

;---For precipitation, use non-equally-spaced contour levels
    if(USE_WRF_COLORS) then
      res@cnLevelSelectionMode = "ExplicitLevels"
      res@cnLevels             = (/ .1, .2, .4, .8, 1.6, 3.2, 6.4, \
                                    12.8, 25.6, 51.2, 102.4, 200./)

      res@cnFillColors         = (/"White","White","DarkOliveGreen1", \
                                   "DarkOliveGreen3","Chartreuse", \
                                   "Chartreuse3","Green","ForestGreen", \
                                   "Yellow","Orange","Red","Violet","White"/)
    else
      res@cnLevelSelectionMode = "ExplicitLevels"
      res@cnLevels             = (/ .01, 0.25, 0.50, 0.75, \
                                   1.00, 1.25, 1.50, 1.75, \
                                   2.00, 2.25/)
      res@cnFillPalette        = "WhViBlGrYeOrRe"
   end if

;---Create plot of original data
    dims = tostring(dimsizes(lat_src))
    res@tiMainString = "Original data on 27km grid (" + str_join(dims," x ") + ")"

    plot_orig = gsn_csm_contour_map(wks,prec_src(0,:,:),res)

;---Create plot of interpolated data
    dims = tostring(dimsizes(lat_dst))
    res@tiMainString = "Regridded data on 81km grid (" + str_join(dims," x ") + ")"

    plot_regrid = gsn_csm_contour_map(wks,prec_src_interp(0,:,:),res)

;---Create panel of both plots
    pres                    = True
    pres@gsnPanelMainString = prec_dst@description + " (" + prec_dst@units + ")"
    pres@gsnMaximize        = True
    pres@gsnPanelLabelBar   = True
    pres@pmLabelBarWidthF   = 0.8
    pres@lbLabelFontHeightF = 0.01

    gsn_panel(wks,(/plot_orig,plot_regrid/),(/1,2/),pres)
end
