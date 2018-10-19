;----------------------------------------------------------------------
; wrf_gsn_6.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Using wrf_xxxx scripts to plot WRF-ARW data
;   - Overlaying filled contours, and vectors on a map
;   - Setting the correct WRF map projection using wrf_map_resources
;   - Setting lots of resources to customize a WRF plot
;----------------------------------------------------------------------
; This script is meant to show the difference between plotting WRF
; data using wrf_xxx scripts, and using gsn_csm_xxx scripts.
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;---Open WRF output file
  filename = "wrfout_d01_2005-12-14_13:00:00"
  a        = addfile(filename,"r")

;---Read several WRF variables at first time step
  it  = 0
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

;---Temperature filled contour plot
  tf_res                      = True
  tf_res@cnFillOn             = True  
  tf_res@ContourParameters    = (/ -20, 90, 5 /)   ; This is a special wrf_contour resource

  contour_tf = wrf_contour(a,wks,tf2,tf_res)

;---Wind vector plot
  vec_res                       = True
  vec_res@vcLineArrowThicknessF = 3.0
  vec_res@vcGlyphStyle          = "CurlyVector"

  vector = wrf_vector(a,wks,u10,v10,vec_res)
  
;---Overlay plots on map and draw.
  map = wrf_map_overlays(a,wks,(/contour_tf,vector/),False,False)

end

