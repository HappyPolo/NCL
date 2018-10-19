;----------------------------------------------------------------------
; This script reads an original WRF output file and a masked
; WRF output file and plots a couple of the variables for 
; comparison.
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


begin
;---Open WRF output file
  wrf_orig_filename = "wrfout_d01_2005-12-14_13:00:00"
  wrf_mask_filename = "wrfout_d01_2005-12-14_13:00:00_MASKED.nc"
  wf = addfile(wrf_orig_filename,"r")
  mf = addfile(wrf_mask_filename,"r")

;---Read variables we know were masked.
  t         = wf->T(0,0,:,:)
  t_mask    = mf->T(0,0,:,:)
  tslb      = wf->TSLB(0,0,:,:)
  tslb_mask = mf->TSLB(0,0,:,:)

  lat2d     = wf->XLAT(0,:,:)
  lon2d     = wf->XLONG(0,:,:)

;---This is necessary for plotting only!
  t@lat2d         = lat2d    
  t@lon2d         = lon2d
  t_mask@lat2d    = lat2d    
  t_mask@lon2d    = lon2d
  tslb@lat2d      = lat2d    
  tslb@lon2d      = lon2d
  tslb_mask@lat2d = lat2d    
  tslb_mask@lon2d = lon2d


;---Plot original data and masked data.
  wks = gsn_open_wks("png","wrf_plots")

  res                = True
  res@gsnMaximize    = True
  res@gsnDraw        = False  ; comment these if you want to see the
  res@gsnFrame       = False  ; individual plots before the panel
  res@cnFillOn       = True  
  res@lbOrientation  = "Vertical"
  res@cnLevelSelectionMode = "ExplicitLevels"
  res = wrf_map_resources(wf,res)    ; use same map projection as defined on WRF file.

;---Create plots of original and masked T data
  res@cnLevels      = ispan(-48,-4,2)
  res@cnFillPalette = "BlueYellowRed"
  plot_orig_t = gsn_csm_contour_map(wks,t,res)
  plot_mask_t = gsn_csm_contour_map(wks,t_mask,res)

;---Create plots of original and masked TSLB data
  res@cnLevels      := ispan(258,292,2)
  res@cnFillPalette = "BlAqGrYeOrReVi200"
  plot_orig_tslb = gsn_csm_contour_map(wks,tslb,res)
  plot_mask_tslb = gsn_csm_contour_map(wks,tslb_mask,res)

;---Panel all four plots
  pres = True
  pres@gsnPanelMainString = "WRF data masked by Mississippi River Basin shapefile"
  pres@gsnMaximize = True
  gsn_panel(wks,(/plot_orig_t,plot_mask_t,plot_orig_tslb,plot_mask_tslb/),(/2,2/),pres)
end
