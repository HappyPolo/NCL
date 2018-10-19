;======================================================================
; ESMF_regrid_17.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF_regrid
;   - Interpolating data from a CAM-SE grid to a CAM finite volume grid
;   - Regridding to a subset of the destination grid.
;======================================================================
; See ESMF_wgts_17.ncl for a faster example of regridding using an 
; existing weights file.
;======================================================================
; This example uses ESMF regridding software to regrid from an
; unstructured CAM-SE grid to a CAM finite volume (FV) grid (96 x 144).
;
; If you want regrid to a subregion of the FV grid, then set SUBREGION
; to True, and set minlat/maxlat/minlon/maxlon to the desired region.
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
    SUBREGION = False   ; Whether to regrid to a subregion of the FV grid

    if(SUBREGION) then
      wgt_file = "CAMSE_2_FV_subregion.nc"
      minlat   =  20       ; Select your subregion here
      maxlat   =  60
      minlon   = 235
      maxlon   = 295

      print("------------------------------------------------------------")
      print("Will be regridding to a subregion of the finite volume grid")
      print("------------------------------------------------------------")
    else
      wgt_file = "CAMSE_2_FV.nc"
      print("------------------------------------------------------------")
      print("Will be regridding to the full finite volume grid")
      print("------------------------------------------------------------")
    end if 

;---Data file containing source grid
    CAMSE_file = "b.e10.B1850CN.ne30_g16.001_ANN_climo.nc"
    sfile      = addfile(CAMSE_file,"r")

;---Get variable to regrid
    var_name = "PRECT"
    vscale   = 86400.*1000.
    var_in   = sfile->$var_name$(0,:)              ; (time,ncol)
    var_in   = (/var_in*vscale/)
    src_lat  = sfile->lat
    src_lon  = sfile->lon

;---Data file containing destination grid
    FV_file = "fv_sstghgcl_aero_01.cam2.h0.1999-01.nc"
    dfile   = addfile(FV_file,"r")

;---Set up regridding options
    Opt                = True

    Opt@InterpMethod  = "bilinear"   ; "patch", "conserve"

    Opt@WgtFileName  = wgt_file

    Opt@SrcGridLat     = src_lat
    Opt@SrcGridLon     = src_lon
    Opt@SrcRegional    = False

    Opt@ForceOverwrite = True
    Opt@Debug          = True
    Opt@PrintTimings   = True

;---Subregion to regrid to.
    if(SUBREGION) then
      Opt@DstRegional = True         ; default is False
      Opt@DstGridLat  = dfile->lat({minlat:maxlat})
      Opt@DstGridLon  = dfile->lon({minlon:maxlon})
    else
      Opt@DstGridLat = dfile->lat
      Opt@DstGridLon = dfile->lon
    end if

;---Call the regridding function
    var_regrid = ESMF_regrid(var_in,Opt)
    printVarSummary(var_regrid)
 
;----------------------------------------------------------------------
; Plotting section
;
; This section creates filled contour plots of both the original
; data and the regridded data, and panels them.
;----------------------------------------------------------------------
    wks = gsn_open_wks("png","ESMF_regrid")      ; send graphics to PNG file

;---Resources to share between both plots
    res                      = True              ; Plot mods desired.

    res@gsnDraw              = False
    res@gsnFrame             = False

    res@gsnMaximize          = True              ; Maximize plot

    res@cnFillOn             = True              ; color plot desired
    res@cnLinesOn            = False             ; turn off contour lines
    res@cnLineLabelsOn       = False             ; turn off contour labels
    res@cnFillMode           = "RasterFill"      ; turn raster on      

    res@cnLevelSelectionMode = "ManualLevels"
    res@cnMinLevelValF       =  1.0
    res@cnMaxLevelValF       = 16.0
    res@cnLevelSpacingF      =  0.5

    res@lbLabelBarOn         = False      ; Will turn on in panel later

    res@mpFillOn            = False

    if(SUBREGION) then
      res@mpMinLatF         = minlat
      res@mpMaxLatF         = maxlat
      res@mpMinLonF         = minlon
      res@mpMaxLonF         = maxlon
    end if

    res@gsnLeftString       = var_name    ; long_name is too long!

    res@gsnAddCyclic        = False
 
;---Resources for plotting regridded data
    if(SUBREGION) then
      res@gsnAddCyclic = False
    else
      res@gsnAddCyclic = True     ; Add a longitude cyclic point
    end if
    dims = tostring(dimsizes(var_regrid))

    res@tiMainString  = "FV grid (" + Opt@InterpMethod + ")"

    plot_regrid = gsn_csm_contour_map(wks,var_regrid,res)

;---Resources for plotting original data
    res@gsnAddCyclic = False
    res@sfXArray     = src_lon
    res@sfYArray     = src_lat
    res@tiMainString = "Original CAM-SE grid"

    plot_orig = gsn_csm_contour_map(wks,var_in,res)  

;---Draw both plots in a panel
    pres                   = True
    pres@gsnMaximize       = True
    pres@gsnPanelLabelBar  = True

    gsn_panel(wks,(/plot_orig,plot_regrid/),(/2,1/),pres)
end
