;----------------------------------------------------------------------
; wrf_gsn_6.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Using gsn_csm scripts to plot WRF-ARW data
;   - Overlaying filled contours, and vectors on a map
;   - Setting the correct WRF map projection using wrf_map_resources
;   - Setting lots of resources to customize a WRF plot
;----------------------------------------------------------------------
; This script is meant to show the difference between plotting WRF
; data using wrf_xxx scripts, and using gsn_csm_xxx scripts.
;----------------------------------------------------------------------
; In NCL Versions 6.3.1 and earlier, you will get these warnings which
; you can safely ignore:
;
; warning:start_lat is not a valid resource in wrf_gsn_contour at this time
; warning:start_lon is not a valid resource in wrf_gsn_contour at this time
; warning:end_lat is not a valid resource in wrf_gsn_contour at this time
; warning:end_lon is not a valid resource in wrf_gsn_contour at this time
; warning:mpNestTime is not a valid resource in map at this time
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

  wks = gsn_open_wks("png","wrf_gsn")

;---Set common resources for all plots
  res                = True
  res@gsnFrame       = False
  res@gsnDraw        = False
  res@gsnLeftString  = ""
  res@gsnRightString = ""

;---Necessary for contours to be overlaid correctly on WRF projection
  res@tfDoNDCOverlay = True
   
;---Temperature filled contour plot
  tf_res                      = res
  tf_res@cnFillOn             = True  
  tf_res@cnLevelSelectionMode = "ExplicitLevels"
  tf_res@cnLevels             = ispan(-20,90,5)
  tf_res@cnInfoLabelOn        = False
  tf_res@cnLineLabelsOn       = False
  tf_res@cnLinesOn            = False
  tf_res@cnFillDrawOrder      = "PreDraw"
  tf_res@lbOrientation        = "Vertical"
  tf_res@lbLabelFontHeightF   = 0.01

  contour_tf = gsn_csm_contour(wks,tf2,tf_res)

;---Wind vector plot
  vec_res                       = res
  vec_res@vcMinDistanceF        = 0.025
  vec_res@vcRefLengthF          = 0.038
  vec_res@vcMinFracLengthF      = 0.2
  vec_res@vcLineArrowThicknessF = 3.0
  vec_res@vcGlyphStyle          = "CurlyVector"
  vec_res@vcRefAnnoOn           = False

  vector = gsn_csm_vector(wks,u10,v10,vec_res)
  
;---Map plot
  map_res                      = True
  map_res@gsnFrame             = False
  map_res@gsnDraw              = False
  map_res@tiMainString         = filename
  map_res@gsnLeftString        = tf2@description + " (" + tf2@units + ")"
  map_res@gsnRightString       = "Wind (" + u10@units + ")"
  map_res@gsnStringFontHeightF = 0.015

;---Set map resources based on projection on WRF output file
  map_res = wrf_map_resources(a,map_res)
  map_res@mpFillOn                    = False
  map_res@mpOutlineOn                 = True
  map_res@mpDataBaseVersion           = "HighRes"
  map_res@mpOutlineDrawOrder          = "PostDraw"
  map_res@mpUSStateLineColor          = "Black"
  map_res@mpPerimLineColor            = "Black"
  map_res@mpNationalLineColor         = "Black"
  map_res@mpLimbLineColor             = "Black"
  map_res@mpGridLineColor             = "Black"
  map_res@mpGeophysicalLineColor      = "Black"
  map_res@mpUSStateLineThicknessF     = 3.0
  map_res@mpNationalLineThicknessF    = 3.0
  map_res@mpGeophysicalLineThicknessF = 3.0

  map = gsn_csm_map(wks,map_res)

;---Overlay plots on map and draw.
  overlay(map,contour_tf)
  overlay(map,vector)

  draw(map)   ; This will draw all overlaid plots and the map
  frame(wks)
end

