;----------------------------------------------------------------------
; wrf_nogsn_5.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Using wrf_xxxx scripts to plot WRF-ARW data
;   - Overlaying line contours, filled contours, and vectors on a map
;----------------------------------------------------------------------
; This script is meant to show the difference between plotting WRF
; data using wrf_xxx scripts, and using gsn_csm_xxx scripts.
;
; See wrf_gsn_5.ncl for an example of using gsn_csm_contour_map to
; plot WRF data.
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
  filename = "wrfout_d01_2005-12-14_13:00:00"
  a = addfile(filename,"r")

;---Read several WRF variables at first time step
  it  = 0
  slp = wrf_user_getvar(a,"slp",it)   ; sea level pressure
  wrf_smooth_2d( slp, 3 )             ; smooth slp
  tc  = wrf_user_getvar(a,"tc",it)    ; 3D temperature
  u   = wrf_user_getvar(a,"ua",it)    ; 3D U at mass points
  v   = wrf_user_getvar(a,"va",it)    ; 3D V at mass points

;---Now get the lowest (bottommost) level
  nl  = 0
  tc2 = tc(nl,:,:)
  u10 = u(nl,:,:)
  v10 = v(nl,:,:)

  tf2 = 1.8*tc2+32.                    ; Convert temperature to Fahrenheit
  u10 = u10*1.94386                    ; Convert wind into knots
  v10 = v10*1.94386

;---Change the metadata
  tf2@description = "Surface Temperature"
  tf2@units       = "degF"
  u10@units       = "kts"
  v10@units       = "kts"

  wks = gsn_open_wks("png","wrf_nogsn")

;---Set common resources
  res                = True

;---Temperature filled contour plot
  tf_res                   = res                         
  tf_res@cnFillOn          = True  
  tf_res@ContourParameters = (/ -20., 90., 5./)

  contour_tf = wrf_contour(a,wks,tf2,tf_res)

;---SLP line contour plot
  slp_res                                = res         
  slp_res@cnLineColor                    = "NavyBlue"
  slp_res@cnHighLabelsOn                 = True
  slp_res@cnLowLabelsOn                  = True
  slp_res@ContourParameters              = (/ 900, 1100, 4 /)
  slp_res@cnLineLabelBackgroundColor     = -1
  slp_res@gsnContourLineThicknessesScale = 2.0

  contour_psl = wrf_contour(a,wks,slp,slp_res)

;---Wind vector plot
  vec_res            = res         
  vec_res@FieldTitle = "Wind"       ; overwrite Field Title
  vec_res@NumVectors = 47           ; density of wind barbs

  vector = wrf_vector(a,wks,u10,v10,vec_res)
  
;---Overlay plots on map and draw.
  map_res = True
  ov = wrf_map_overlays(a,wks,(/contour_tf,contour_psl,vector/),True,map_res)

end
