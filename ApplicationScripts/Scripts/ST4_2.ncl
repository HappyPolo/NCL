;*************************************************************** 
; ST4_2.ncl 
; 
; Concepts illustrated: 
;   - Reading a GRIB file that has no file extension identifier
;   - Explore the varibale via 'stat_dispersion'
;   - Use ESMF conservative regridding to interpolate the 4x4km to a 12x12km grid 
;   - Show lat/lon lines in light gray 
;   - Explicitly setting contour levels and colors
;   - Use resources to explicitly color regions of missing values as 'gray'
;   - Create a panel plot
;***************************************************************
; These library files are loaded by default in NCL V6.2.0 and newer
;
;;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
;;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
;**************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"



begin
;---Specify interpolation method
    method = "conserve"  

;---Open ST4 file
    diri  = "./"   
    fili  = "ST4.2004060100.01h.grb"
    sfile = addfile(diri+fili,"r")            ; source grid and data

;---Read in precipitation             
    prec_src = sfile->A_PCP_GDS5_SFC_acc1h    ; (g5_x_0, g5_y_1 ) => (881,1121)
    prec_src@units = "mm"                     ; kg/m2 => mm 
    printVarSummary(prec_src)

;---Explore variable
    opt = True
    opt@PrintStat = True
    statb = stat_dispersion(prec_src, opt )

;---Read lat/lon of 4km grid
    lat_src = sfile->g5_lat_0                ;  ( g5_x_0, g5_y_1 )
    lon_src = sfile->g5_lon_1     

;---Create lat/lon of 12km grid (decimate source lat/lon)
    lat_dst = lat_src(2::3,2::3)
    lon_dst = lon_src(2::3,2::3)   

;---Options to pass to ESMF_regrid
    opt                = True

    opt@SrcGridLat     = lat_src
    opt@SrcGridLon     = lon_src
    opt@DstGridLat     = lat_dst
    opt@DstGridLon     = lon_dst

    opt@SrcRegional    = True    ; Default is False
    opt@DstRegional    = True

    opt@InterpMethod = method
    opt@WgtFileName  = "ST4_"+method+".4km_to_12km.nc"

    opt@CopyVarCoords  = True    
    opt@ForceOverwrite = True

;---Debug information
    opt@PrintTimings   = True
    opt@Debug          = True

;---Do the regridding
    prec_dst = ESMF_regrid(prec_src, opt)

    prec_dst@lat2d     = lat_dst    ; Needed for plotting. "prec_dst"
    prec_dst@lon2d     = lon_dst    ; already has these attrs attached.
    printVarSummary(prec_dst)

;----------------------------------------------------------------------
; Code to plot the original and regridded data in a panel plot.
;----------------------------------------------------------------------
    prec_src@lat2d = lat_src    ; Needed for plotting. "prec_src"
    prec_src@lon2d = lon_src    ; already has these attrs attached.

  ;;prec_src = where(prec_src.lt.1e-3, prec_src@_FillValue, prec_src)
  ;;prec_dst = where(prec_dst.lt.1e-3, prec_dst@_FillValue, prec_dst)

    wks = gsn_open_wks("png","ST4_2")
    gsn_define_colormap(wks,"WhViBlGrYeOrRe")

    res                     = True          ; Plot mods desired.

;---General resources
    res@gsnDraw             = False         ; We will panel later.
    res@gsnFrame            = False
    res@gsnMaximize         = True          ; Maximize plot
    
;---Contour and labelbar resources
    res@cnFillOn            = True          ; Color plot desired.
   ;res@cnFillMode          = "RasterFill"
    res@cnFillMode          = "CellFill"
    res@cnLinesOn           = False         ; Turn off contour lines.
    res@cnLineLabelsOn      = False         ; Turn off contour labels.
    res@cnMissingValFillPattern= 0
    res@cnMissingValFillColor  = "Gray"

    res@lbLabelBarOn        = False         ; Labelbar will be in panel.
    res@gsnAddCyclic        = False         ; Data is regional.

   ;res@tiMainFontHeightF = 0.015

;---For precipitation, use non-equally-spaced contour levels
    res@cnLevelSelectionMode = "ExplicitLevels"
    res@cnLevels             = (/ 0.10, 0.25, 0.50, 0.75, 1.00, 1,25, 1.50, \
                                  2.00, 2.50, 3, 4, 5, 7.5, 10, 15,         \
                                    20,   25, 37.5, 50, 75 /) 
;---Map
    res@mpMinLatF            = min(lat_src)  
    res@mpMaxLatF            = max(lat_src)
    res@mpMinLonF            = min(lon_src)     
    res@mpMaxLonF            = max(lon_src)     
    res@mpCenterLonF         = 0.5*(min(lon_src)+max(lon_src))
    res@mpFillOn             = False

    res@mpGridAndLimbOn      = True
    res@mpGridLatSpacingF    = 2
    res@mpGridLonSpacingF    = 2
    res@mpGridLineColor      = "LightGray"
    res@mpGridLineDashPattern= 6 ;http://www.ncl.ucar.edu/Document/Graphics/Images/dashpatterns.png

;---Create plot of original data
    dims = tostring(dimsizes(lat_src))
    res@tiMainString = "Original data on  4km grid (" + str_join(dims," x ") + ")"

    plot_orig = gsn_csm_contour_map(wks,prec_src,res)

;---Create plot of interpolated data
    dims = tostring(dimsizes(lat_dst))
    res@tiMainString = "Regridded data on 12km grid (" + str_join(dims," x ") + ")"

    plot_regrid = gsn_csm_contour_map(wks,prec_dst,res)

;---Create panel of both plots
    pres                    = True
    pres@txString           = fili+": "+method+" regrid"
    pres@gsnMaximize        = True
    pres@gsnPanelLabelBar   = True
    pres@pmLabelBarWidthF   = 0.8
    pres@lbLabelFontHeightF = 0.01

    gsn_panel(wks,(/plot_orig,plot_regrid/),(/2,1/),pres)
end
