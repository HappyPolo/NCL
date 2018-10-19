begin
;---Open WRF output file and read variables
  a = addfile("wrfout_d01_2008-09-30_00:00:00.nc","r")

  tk2 = wrf_user_getvar(a,"T2",-1)     ; Calculate T2 in Kelvin 
                                       ; across all timesteps

;---Start the graphics
  wks = gsn_open_wks("png","wrf_plot_t2")

;---Plotting options for T (filled contours)
  res                   = True
  res@cnFillOn          = True  
  res@cnFillPalette     = "BlAqGrYeOrReVi200"
;  res@ContourParameters = (/ -20., 90., 5./)

  nt = 0  ; plot first time step  
  contour = wrf_contour(a,wks,tk2(nt,:,:),res)
  delete(res)

;---Overlay contours on a map
  pltres = True
  pltres@PanelPlot = True
  plot = wrf_map_overlays(a,wks,contour,pltres,True)

  mkres = True
  mkres@gsMarkerIndex = 16
  mkres@gsMarkerSizeF = 1.2
  mkres@gsnCoordsLat = a->XLAT(0,:,:)
  mkres@gsnCoordsLon = a->XLONG(0,:,:)
  gsn_coordinates(wks,plot,tk2,mkres)
end
