load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  filename = "FRCCORE2_e_1m_19980101_20071231_thetao.nc"
  f        = addfile (filename, "r")
  thetao   = f->thetao              ; (time_counter, deptht, y, x) 
  lat2d    = f->nav_lat             ; (y,x)
  lon2d    = f->nav_lon             ; (y,x)

;---Start the graphics
  wks = gsn_open_wks("ps" ,"IPSL_thetao")
  gsn_define_colormap(wks,"rainbow")             ; Change color map

;---Set some resources
  res              = True

  res@gsnMaximize  = True               ; Maximize size of plot
  res@tiMainString = filename           ; Use filename as main title

;---This will position data correctly on map.
  res@sfXArray     = lon2d
  res@sfYArray     = lat2d

  res@gsnAddCyclic = False      ; Cyclic point already added

  res@cnFillOn        = True          ; Turn on contour fill
  res@cnLinesOn       = False         ; Turn off contour lines
  res@cnLevelSpacingF = 1.25          ; NCL was using 2.5

;---Draw the plot
  nt = 0                      ; time index to plot
  nd = 0                      ; depth index to plot
  plot = gsn_csm_contour_map(wks,thetao(nt,nd,:,:),res)
end
