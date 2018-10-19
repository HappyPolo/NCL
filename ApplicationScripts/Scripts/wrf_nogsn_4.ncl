;----------------------------------------------------------------------
; wrf_nogsn_4.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Using wrf_xxxx scripts to plot WRF-ARW data
;----------------------------------------------------------------------
; This script is meant to show the difference between plotting WRF
; data using wrf_xxx scripts, and using gsn_csm_xxx scripts.
;
; See wrf_gsn_4.ncl for an example of using gsn_csm_contour_map to
; plot WRF data.
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;---Open WRF output file
  filename = "wrfout_d01_2005-12-14_13:00:00"
  a        = addfile(filename,"r")

;---Read temperature at first time step
  tc = wrf_user_getvar(a,"tc",0)

  wks = gsn_open_wks("png","wrf_nogsn")

;---Resources for filled contour plot
  res                   = True
  res@cnFillOn          = True  
  res@ContourParameters = 2.      ; Change the spacing

  nl   = 0    ; bottomost level
  plot = wrf_contour(a,wks,tc(nl,:,:),res)

;---Overlay plot on map and draw.
  ov = wrf_map_overlays(a,wks,plot,True,True)

end
