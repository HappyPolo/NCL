;
; tsdiagram_2.ncl
;
; Read potential temp (TEMP), salinity (SALT)
; Compute potential density (PD) for specified range PD(t,s)
; (use ncl function based on Yeager's algorithm for rho computation)
; Assumes annual and zonally avgeraged input data set (i.e, one time slice)
; Used K.Lindsay's "za" for zonal avg -- already binned into basins
; Plots temp vs salt (scatter plot), pd overlay
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"  


begin

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; ================================>  ; PARAMETERS
  case    = "PHC2_gx1v3"
  ocnfile= "za_PHC2_T_S_gx1v3.nc"

  depth_min = 14895.82   ; in cm, depth of first layer to be included 
  depth_max =  537499.9
; plot limits
  smincn = 32.5 
  smaxcn = 37.0
  tmincn = -2.
  tmaxcn = 22.

;=====> initial resource settings
  label = "PHC2_ann_avg_test" 
  wks = gsn_open_wks("png","tsdiagram") ; send graphics to PNG file

;===== data 
  focn    = addfile(ocnfile, "r")
  salt    = focn->SALT(0,:,{depth_min:depth_max},:)   ;(basins, z_t, lat_t)
  temp    = focn->TEMP(0,:,{depth_min:depth_max},:)
  lat_t   = focn->lat_t
  z_t     = focn->z_t({depth_min:depth_max})
  nzt     = dimsizes(z_t)
  nlat    = dimsizes(lat_t)

;====make basin arrays
; 0 = global  1 = southern ocean 2 = pacific 3 = indian 6 = atlantic 
; 8 = labrador 9 = GIN 10 = arctic
  temp_gl = temp(0,:,:)
  salt_gl = salt(0,:,:)
  temp_so = temp(1,:,:)
  salt_so = salt(1,:,:)
  temp_pa = temp(2,:,:)
  salt_pa = salt(2,:,:)
  temp_in = temp(3,:,:)
  salt_in = salt(3,:,:)
  temp_at = temp(6,:,:)
  salt_at = salt(6,:,:)
  temp_la = temp(8,:,:)
  salt_la = salt(8,:,:)
  temp_gi = temp(9,:,:)
  salt_gi = salt(9,:,:)
  temp_ar = temp(10,:,:)
  salt_ar = salt(10,:,:)

;===== put into scatter array format
  tdata_gl = ndtooned(temp_gl)
  tdata_so = ndtooned(temp_so)
  tdata_pa = ndtooned(temp_pa)
  tdata_in = ndtooned(temp_in)
  tdata_at = ndtooned(temp_at)
  tdata_la = ndtooned(temp_la)
  tdata_gi = ndtooned(temp_gi)
  tdata_ar = ndtooned(temp_ar)

  sdata_gl = ndtooned(salt_gl)
  sdata_so = ndtooned(salt_so)
  sdata_pa = ndtooned(salt_pa)
  sdata_in = ndtooned(salt_in)
  sdata_at = ndtooned(salt_at)
  sdata_la = ndtooned(salt_la)
  sdata_gi = ndtooned(salt_gi)
  sdata_ar = ndtooned(salt_ar)

  npts_gl = dimsizes(tdata_gl)
  npts_so = dimsizes(tdata_so)
  npts_pa = dimsizes(tdata_pa)
  npts_in = dimsizes(tdata_in)
  npts_at = dimsizes(tdata_at)
  npts_la = dimsizes(tdata_la)
  npts_gi = dimsizes(tdata_gi)
  npts_ar = dimsizes(tdata_ar)
  points = (/npts_gl,npts_so,npts_pa,npts_in,npts_at,npts_la,npts_gi,npts_ar/) 
  npts = max(points)

  xdata = new((/8,npts/),float)
  ydata = new((/8,npts/),float)
  ydata(0,:) = tdata_gl
  ydata(1,:) = tdata_so
  ydata(2,:) = tdata_pa
  ydata(3,:) = tdata_in
  ydata(4,:) = tdata_at
  ydata(5,:) = tdata_la
  ydata(6,:) = tdata_gi
  ydata(7,:) = tdata_ar

  xdata(0,:) = sdata_gl
  xdata(1,:) = sdata_so
  xdata(2,:) = sdata_pa
  xdata(3,:) = sdata_in
  xdata(4,:) = sdata_at
  xdata(5,:) = sdata_la
  xdata(6,:) = sdata_gi
  xdata(7,:) = sdata_ar

  basin = (/"Global","Southern Ocean","Pacific Ocean","Indian Ocean", \
            "Atlantic Ocean","Labrador Sea", "GIN Sea","Arctic Ocean"/)

;============== compute potenial density (PD), using rho_mwjf
; for potential density, depth = 0. (i.e. density as if brought to surface)
;
;===========================================================================
; WARNING: T-S diagrams use POTENTIAL DENSITY... if set depth to something
; other then 0, then you will be plotting density contours computed for the
; specified depth layer.
;===========================================================================

  depth = 0.  ;in meters
  tspan = fspan(tmincn,tmaxcn,51)
  sspan = fspan(smincn,smaxcn,51)
  t_range = conform_dims((/51,51/),tspan,0)
  s_range = conform_dims((/51,51/),sspan,1)

  pd      = rho_mwjf(t_range,s_range,depth)
  pd!0    = "temp"
  pd!1    = "salt"
  pd&temp = tspan
  pd&salt = sspan
  pd      = 1000.*(pd-1.)   ;put into kg/m3 pot den units

;=================GRAPHICS
  plot   = new(8,graphic)
  plotpd = new(8,graphic)

;--- scatter plot
  res                    = True
  res@gsnDraw            = False
  res@gsnFrame           = False
  res@xyMarkLineModes    = (/"Markers"/)
  res@xyMarkers          = (/16/)
  res@xyMarkerColors     = (/"black"/)
  res@pmLegendDisplayMode= "Never"
  res@txFontHeightF      = 0.025
  res@tiXAxisString      = salt@units
  res@tiXAxisFontHeightF = 0.02
  res@tiYAxisString      = temp@units
  res@tiYAxisFontHeightF = 0.02
  res@trXMinF            = smincn
  res@trXMaxF            = smaxcn
  res@trYMinF            = tmincn
  res@trYMaxF            = tmaxcn
  res@gsnRightString     = depth_min/100. + "-"+depth_max/100. +"m"

  do n = 0,dimsizes(basin)-1
    res@gsnLeftString = basin(n)
    plot(n) = gsn_csm_xy(wks,xdata(n,:),ydata(n,:),res)
  end do

;----- pd overlay
  resov = True
  resov@gsnDraw                  = False
  resov@gsnFrame                 = False
  resov@cnLevelSelectionMode     = "AutomaticLevels"
  resov@cnInfoLabelOn            = "False"
  resov@cnLineLabelPlacementMode = "Computed"
  resov@cnLineLabelPlacementMode = "Constant"
  resov@cnLineLabelFontHeightF   = ".02"

  do n = 0,dimsizes(basin)-1
    res@gsnLeftString = basin(n)
    plotpd(n) = gsn_csm_contour(wks,pd,resov)
    overlay(plot(n),plotpd(n))
  end do
  
  
; panel resources
  pan                     = True
  pan@gsnMaximize         = True
  pan@txFontHeightF       = 0.025
  pan@txString            = case + " T-S  ANN AVG "
  gsn_panel (wks,plot,(/4,2/),pan)

end

