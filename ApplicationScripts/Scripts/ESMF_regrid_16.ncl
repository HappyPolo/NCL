;======================================================================
; ESMF_regrid_16.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF software
;   - Interpolating data from a curvilinear grid to another curvilinear grid
;   - Interpolating data from a WRF grid to a smaller MM5 grid
;======================================================================
; This script regrids a selected variable from a full WRF domain,
; to a smaller MM5 grid over Lake Tahoe. It regrids the variable 
; for all levels.
;
; This script works for 2D or 3D variables on the WRF file. It 
; can be easily modified to handle more dimensions.
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
;---WRF file that contains data and lat/lon source grid
    srcFileName = "wrfout_d03_2012-04-22_23_00_00.nc"

;---MM5 file that contains lat/lon destination grid
    dstFileName = "2010-04-30-12.nc"

;---Open both files
    sfile = addfile(srcFileName,"r")
    dfile = addfile(dstFileName,"r")

;---Get some data off source file
;   var = wrf_user_getvar(sfile,"tk",0)      ; Variable to regrid, 3D
;   var = wrf_user_getvar(sfile,"ua",0)      ; Variable to regrid, 3D

    var = wrf_user_getvar(sfile,"td2",0)     ; Variable to regrid, 2D
    wrf_lat2d = sfile->XLAT(0,:,:)           ; Source grid to
    wrf_lon2d = sfile->XLONG(0,:,:)          ; regrid from.
    var_ndims = dimsizes(dimsizes(var))
    if(var_ndims.ne.2.and.var_ndims.ne.3) then
      print("ESMF_regrid_16.ncl: Warning: this script only works with 2D or 3D variables.")
     print("You should be able to modify it to handle more dimensions if necessary.")
    end if

;---Read destination lat/lon values
    dst_lat2d = dfile->Band126
    dst_lon2d = dfile->Band127
    dst_nlat  = dimsizes(dst_lat2d(:,0))
    dst_nlon  = dimsizes(dst_lat2d(0,:))

    dst_minlat = min(dst_lat2d)   ; Used for plotting later.
    dst_maxlat = max(dst_lat2d)
    dst_minlon = min(dst_lon2d)
    dst_maxlon = max(dst_lon2d)

;---Debug prints
    print("-----wrf_lat2d----")
    print("min/max wrf_lat2d = " + min(wrf_lat2d) + "/" + max(wrf_lat2d))
    print("min/max wrf_lon2d = " + min(wrf_lon2d) + "/" + max(wrf_lon2d))
    print("min/max dst_lat2d = " + dst_minlat + "/" + dst_maxlat)
    print("min/max dst_lon2d = " + dst_minlon + "/" + dst_maxlon)

    wrf_dims = tostring(dimsizes(wrf_lat2d))
    mm5_dims = tostring(dimsizes(dst_lat2d))

    if(var_ndims.eq.2) then 
      nlev = 1
      print("This is a 2D variable.")
    else
; 
; The assumption is that if the variable is 3D, then the leftmost
; dimension is associated with levels. I haven't looked at all
; variables on the file to make sure this is the case, so this
; may need to be fixed if other variables are desired.
;
      p    = wrf_user_getvar(sfile,"pressure",0)
      nlev = dimsizes(p(:,0,0))
      print("This is a 3D variable.")
      print("There are " + nlev + " levels.")
    end if

;---Set up options for regridding
    Opt                = True

    Opt@WgtFileName    = "WRF_to_MM5.nc"

    Opt@SrcGridLat     = wrf_lat2d     ; source grid
    Opt@SrcGridLon     = wrf_lon2d
    Opt@DstGridLat     = dst_lat2d     ; destination grid
    Opt@DstGridLon     = dst_lon2d

    Opt@SrcRegional    = True          ; Necessary if grids
    Opt@DstRegional    = True          ; are regional

    Opt@InterpMethod   = "bilinear"    ; "patch", "conserve"

    Opt@ForceOverwrite = True          ; Optional, but recommended.
    Opt@PrintTimings   = True          ; Optional.
    Opt@Debug          = True          ; Optional

    var_regrid = ESMF_regrid(var,Opt)      ; Do the regridding

;---More debug prints
    print("---------var----------")
    printMinMax(var,0)
    print("-------var_regrid---------")
    printVarSummary(var_regrid)
    printMinMax(var_regrid,0)

;----------------------------------------------------------------------
; Code to plot the original and regridded data in a panel plot.
;----------------------------------------------------------------------
    var@lat2d = wrf_lat2d     ; Needed for plotting. "var_regrid" 
    var@lon2d = wrf_lon2d     ; already has these attrs attached.

    wks = gsn_open_wks("png","ESMF_regrid") ; send graphics to PNG file

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

;---Map resources
    res@mpDataBaseVersion      = "MediumRes"
    res@mpFillOn               = False
    res@mpOutlineBoundarySets  = "AllBoundaries"
    res@mpUSStateLineColor     = "gray"
    res@mpGeophysicalLineColor = "gray"
    res@mpNationalLineColor    = "gray"

;---Zoom in on map
    res@mpMinLatF              = dst_minlat-0.03   ; Leave a little bit
    res@mpMinLonF              = dst_minlon-0.03   ; of a margin.
    res@mpMaxLatF              = dst_maxlat+0.03
    res@mpMaxLonF              = dst_maxlon+0.03

;---Titles and tickmarks
    res@pmTickMarkDisplayMode  = True              ; Better tickmarks
    res@tmYROn                 = False
    res@tmXTOn                 = False

    res@tmXBLabelFontHeightF   = 0.01
    res@tmYLLabelFontHeightF   = 0.01

    res@gsnLeftString          = ""
    res@gsnRightString         = ""
    res@tiMainFontHeightF      = 0.020
    res@tiMainOffsetYF         = -0.02   ; move closer to plot
    res@gsnStringFontHeightF   = 0.015

;---Resources for paneling
    pres                  = True
    pres@gsnMaximize      = True
    pres@gsnPanelLabelBar = True
    pres@pmLabelBarWidthF = 0.8
;
; Loop through each level and create a panel plot comparing
; the original data against the regridded data.
;
; Note that each set of plots has a different colorbar,
; depending on the min/max of the data at that level.
; 
; If you are plotting across time, or, if you want the same
; color bar for each level, set SAME_COLORBAR = True.
;
    SAME_COLORBAR = False

    if(SAME_COLORBAR) then
      mnmxint = nice_mnmxintvl( min(var_regrid), max(var_regrid), 18, False)
      res@cnLevelSelectionMode = "ManualLevels"
      res@cnMinLevelValF       = mnmxint(0)
      res@cnMaxLevelValF       = mnmxint(1)
      res@cnLevelSpacingF      = mnmxint(2)
    end if

    do i=0,nlev-1
      res@tiMainString = "Regridded data (" + \
                         str_join(mm5_dims," x ") + ")"
      if(var_ndims.eq.2) then 
        plot_regrid = gsn_csm_contour_map(wks,var_regrid,res)
      else if(var_ndims.eq.3) then 
        level = p(i,0,0)
        print("level = " + level)
        plot_regrid = gsn_csm_contour_map(wks,var_regrid(i,:,:),res)
      end if
      end if

;---Make sure same contours levels are used for both plots.
      if(.not.SAME_COLORBAR) then
        getvalues plot_regrid@contour
          "cnLevels" : levels
        end getvalues

        res@cnLevels             = levels
        res@cnLevelSelectionMode = "ExplicitLevels"
      end if

      res@tiMainString = "Original data (" + \
                          str_join(wrf_dims," x ") + ")"
      if(var_ndims.eq.2) then 
        plot_orig = gsn_csm_contour_map(wks,var,res)     
      else if(var_ndims.eq.3) then 
        plot_orig = gsn_csm_contour_map(wks,var(i,:,:),res)     
      end if
      end if

      if(var_ndims.eq.2) then 
        pres@txString = var@description + " (" + var@units + ")"
      else
        pres@txString = var@description + " (" + var@units + ")" + \
                        " (level=" + level + " " + p@units + ")"
      end if
      gsn_panel(wks,(/plot_orig,plot_regrid/),(/1,2/),pres)

;---Clean up before next time in loop.
      if(.not.SAME_COLORBAR) then
        delete(levels)
        delete(res@cnLevelSelectionMode)
        delete(res@cnLevels)
      end if
    end do
end
