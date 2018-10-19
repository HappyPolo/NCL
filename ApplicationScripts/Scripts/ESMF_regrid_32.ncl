;======================================================================
; ESMF_regrid_32.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF_regrid
;   - Interpolating data from a WRF grid to two different rectilinear grids
;   - Drawing a lat/lon grid using gsn_coordinates
;======================================================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin
;---Open WRF output file
  filename = "wrfout_d01_2005-12-14_13:00:00"
  a        = addfile(filename,"r")

;---Read temperature at first time step
  tc = wrf_user_getvar(a,"tc",0)
  tc@units = "degC"    ; was "C"

;---Attach 2D coordinates
  tc@lat2d = a->XLAT(0,:,:)
  tc@lon2d = a->XLONG(0,:,:)

  minlon  = min(tc@lon2d)-1
  minlat  = min(tc@lat2d)-1
  maxlon  = max(tc@lon2d)+1
  maxlat  = max(tc@lat2d)+1

;----------------------------------------------------------------------
; Start the regridding
;----------------------------------------------------------------------
  interp_method         = "bilinear"

  Opt                   = True

  Opt@InterpMethod      = interp_method

  Opt@SrcRegional       = True

  Opt@DstRegional       = True
  Opt@DstLLCorner       = (/ minlat,minlon /)
  Opt@DstURCorner       = (/ maxlat,maxlon /)

  Opt@ForceOverwrite    = True
  Opt@PrintTimings      = True
  Opt@Debug             = True

;---Regrid using two different resolutions
  Opt@DstGridType = "1.0deg"
  tc_regrid_1_0deg = ESMF_regrid(tc,Opt)     ; Do the regridding

  Opt@DstGridType = "0.5deg"
  tc_regrid_0_5deg = ESMF_regrid(tc,Opt)     ; Do the regridding

  printVarSummary(tc_regrid_1_0deg)
  printVarSummary(tc_regrid_0_5deg)

;----------------------------------------------------------------------
; Start the graphics
;----------------------------------------------------------------------
  wks = gsn_open_wks("png","ESMF_regrid")  ; send graphics to PNG file

  res                        = True

  res@gsnDraw                = False   ; Will panel later
  res@gsnFrame               = False

  res@cnFillOn               = True  
  res@cnLinesOn              = False
  res@cnLineLabelsOn         = False
  res@cnLevelSelectionMode   = "ManualLevels"
  res@cnLevelSpacingF        =   2
  res@cnMinLevelValF         = -22
  res@cnMaxLevelValF         =  22

  res@lbLabelBarOn           = False

  res@pmTitleZone            = 4
  res@pmTickMarkDisplayMode  = "Always"
  res@mpOutlineBoundarySets  = "GeophysicalAndUSStates"
  res@mpGeophysicalLineColor = "gray"
  res@mpUSStateLineColor     = "gray"
  res@mpNationalLineColor    = "gray"

  res@mpDataBaseVersion      = "MediumRes"
  res@mpLandFillColor        = "tan"
  res@mpOceanFillColor       = "lightblue"
  res@mpInlandWaterFillColor = "lightblue"

  res@mpMinLonF              = minlon
  res@mpMinLatF              = minlat
  res@mpMaxLonF              = maxlon
  res@mpMaxLatF              = maxlat

  res@gsnAddCyclic           = False

  res@gsnRightString         = ""

;---Create contours of original data
  nl   = 0    ; bottomost level
  res@gsnLeftString  = "Original data (" + str_join(""+dimsizes(tc(nl,:,:))," x ") +")"
  plot_orig = gsn_csm_contour_map(wks,tc(nl,:,:),res)

;---Create contours of regridded data
  res@gsnLeftString  = "Regridded to 1deg"
  plot_regrid_1_0deg = gsn_csm_contour_map(wks,tc_regrid_1_0deg(nl,:,:),res)

  res@gsnLeftString  = "Regridded to 0.5deg"
  plot_regrid_0_5deg = gsn_csm_contour_map(wks,tc_regrid_0_5deg(nl,:,:),res)

;---Add grid lines at lat/lon locations to all three plots
  lnres                  = True
  lnres@gsLineColor      = "Gray25"
  lnres@gsLineThicknessF = 1.0
  lnres@gsnCoordsAsLines = True
  lnres@gsnCoordsAttach  = True 
  gsn_coordinates(wks,plot_orig,tc(nl,:,:),lnres)
  gsn_coordinates(wks,plot_regrid_1_0deg,tc_regrid_1_0deg(nl,:,:),lnres)
  gsn_coordinates(wks,plot_regrid_0_5deg,tc_regrid_0_5deg(nl,:,:),lnres)

;----------------------------------------------------------------------
; Draw both plots in one panel.
;----------------------------------------------------------------------
  pres                  = True
  pres@gsnMaximize      = True
  pres@txString         = "WRF output data - " + tc@description + " (" + tc@units + ")"
  pres@gsnPanelLabelBar = True
  pres@gsnPanelRowSpec  = True
  pres@pmLabelBarWidthF = 0.7

  gsn_panel(wks,(/plot_orig,plot_regrid_1_0deg,plot_regrid_0_5deg/),(/1,2/),pres)

end

