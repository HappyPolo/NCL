;----------------------------------------------------------------------
; This script regrids data from a satellite global grid to a regional
; ALADIN grid.  This one compares the bilinear, conserve, and patch
; methods on the same panel plot.
;
; This script requires that you have NCL V6.1.0-beta or later.
;----------------------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin
  srcfile = "MYD08_M3.A200618.nc"    ; Source (satellite) data file
  dstfile = "PLPNM50-1.75.M2006.nc"  ; Destination (model) data file

  sfile   = addfile(srcfile,"r")
  dfile   = addfile(dstfile,"r")

;---Read destination lat/lon arrays
  dlat = dfile->lat
  dlon = dfile->lon
  nlat = dimsizes(dlat(:,0))
  nlon = dimsizes(dlon(0,:))

  dlatmin = min(dlat)
  dlatmax = max(dlat)
  dlonmin = min(dlon)
  dlonmax = max(dlon)

;---Get data to regrid
  xmean = sfile->Optical_Depth_Land_And_Ocean_Mean_Mean

;---Options to set for regridding
  Opt = True

  Opt@SrcRegional    = False    ; the default
  Opt@DstRegional    = True
  Opt@DstGridLat     = dlat
  Opt@DstGridLon     = dlon

  Opt@SrcMask2D      = where(.not.ismissing(xmean),1,0)   ; Very important!

  Opt@ForceOverwrite = True
  Opt@CopyVarCoords  = True
; Opt@Debug          = True

;---Regrid xmean using two different methods.
  Opt@WgtFileName  = "satellite_to_aladin_bilinear"
  Opt@InterpMethod = "bilinear"
  xmean_regrid_b   = ESMF_regrid(xmean,Opt)

  Opt@WgtFileName  = "satellite_to_aladin_conserve"
  Opt@InterpMethod = "conserve"
  xmean_regrid_c   = ESMF_regrid(xmean,Opt)

  Opt@WgtFileName  = "satellite_to_aladin_patch"
  Opt@InterpMethod = "patch"
  xmean_regrid_p   = ESMF_regrid(xmean,Opt)

;---Debug prints
  printVarSummary(xmean_regrid_b)
  printVarSummary(xmean_regrid_c)
  printVarSummary(xmean_regrid_p)
  printMinMax(xmean_regrid_b,0)
  printMinMax(xmean_regrid_c,0)
  printMinMax(xmean_regrid_p,0)

;---Start the graphics
  wks = gsn_open_wks("ps",get_script_prefix_name())

;---Set some resources
  res                   = True

  res@gsnMaximize       = True     ; maximize plot in frame
  res@gsnDraw           = False    ; don't draw
  res@gsnFrame          = False    ; don't advance frame

  res@gsnAddCyclic      = False    ; don't add longitude cyclic point

  res@cnFillOn          = True            ; turn on contour fill
  res@cnLinesOn         = False           ; turn off contour lines
  res@cnLineLabelsOn    = False           ; turn off line labels
  res@cnFillMode        = "RasterFill"    ; faster than default "AreaFill"
  res@lbLabelBarOn      = False           ; will turn on in panel
  res@cnFillPalette     = "BkBlAqGrYeOrReViWh200"

  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels = (/0,0.005,0.01,0.015,0.02,0.025,0.03,0.035,0.04,0.045,\
                   0.05,0.055,0.06,0.065,0.07,0.075,0.08,0.085,0.09,\
                   0.095,0.1,0.105,0.11,0.115,0.12,0.125,0.13,0.135,\
                   0.14,0.145,0.15,0.155,0.16,0.165,0.17,0.175,0.18,\
                   0.185,0.19,0.195,0.2,1.,2.,3./)


  lc = dfile->Lambert_Conformal         ; contains map projection information
  res@mpProjection        = "LambertConformal"
  res@mpLambertParallel1F = lc@latitude_of_projection_origin
  res@mpLambertParallel2F = lc@latitude_of_projection_origin
  res@mpLambertMeridianF  = lc@longitude_of_central_meridian

  res@mpLimitMode          = "Corners"
  res@mpLeftCornerLatF     = dlat(0,0)
  res@mpLeftCornerLonF     = dlon(0,0)
  res@mpRightCornerLatF    = dlat(nlat-1,nlon-1)
  res@mpRightCornerLonF    = dlon(nlat-1,nlon-1)

  res@mpFillOn              = False        ; Turn off gray land fill
  res@pmTickMarkDisplayMode = "Always"     ; Nice tickmarks

;---Create (but don't draw) plot of original data
  dims = tostring(dimsizes(xmean))
  res@gsnLeftString  = "Aerosol Optical Thickness"
  res@gsnRightString = "0.55 microns"
  res@tiMainString   = "Original data on satellite grid (" + \
                        str_join(dims,"x") + ")"

  plot_orig   = gsn_csm_contour_map(wks,xmean,res)

;---Create (but don't draw) plot of regridded (bilinear) data
  dims = tostring(dimsizes(xmean_regrid_b))
  res@tiMainString   = "Regridded (bilinear) to ALADIN grid (" + \
                       str_join(dims,"x") + ")"

  plot_regrid_b = gsn_csm_contour_map(wks,xmean_regrid_b,res)

;---Create (but don't draw) plot of regridded (conserve) data
  dims = tostring(dimsizes(xmean_regrid_c))
  res@tiMainString   = "Regridded (conserve) to ALADIN grid (" + \
                       str_join(dims,"x") + ")"

  plot_regrid_c = gsn_csm_contour_map(wks,xmean_regrid_c,res)

;---Create (but don't draw) plot of regridded (patch) data
  dims = tostring(dimsizes(xmean_regrid_p))
  res@tiMainString   = "Regridded (patch) to ALADIN grid (" + \
                       str_join(dims,"x") + ")"

  plot_regrid_p = gsn_csm_contour_map(wks,xmean_regrid_p,res)

;---Draw a panel of all three plots
  pres                  = True 
  pres@gsnMaximize      = True
  pres@gsnPanelLabelBar = True

;--Control which box lines get a label 
  pres@lbLabelStrings  = "" + res@cnLevels    ; Set some to blank,
  pres@lbLabelStrings(1:40:3) = ""            ; except for last three
  pres@lbLabelStrings(2:40:3) = ""
  pres@lbLabelAutoStride      = False        ; Turn off auto label spacing
  pres@lbLabelFontHeightF     = 0.01         ; Make labels smaller
  pres@pmLabelBarWidthF       = 0.8          ; Make labelbar wider

  gsn_panel(wks,(/plot_orig,plot_regrid_b,plot_regrid_c,plot_regrid_p/),\
                 (/2,2/),pres)
end


