load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
;---Open two files: one containing the data, the other containing the grid
  afilename = "longhcs_avg_Y2000M01.nc"
  gfilename = "longhcs_grd_modified.nc"
  af        = addfile(afilename, "r")
  gf        = addfile(gfilename, "r")

;---Read temperature, lat, lon
  temp  = af->temp           ; (time, s_rho, eta_rho, xi_rho)
  lat2d = gf->lat_rho        ; (eta_rho, xi_rho)
  lon2d = gf->lon_rho        ; (eta_rho, xi_rho)

;---Replace all 0.0 values with missing, just for a different plot
  temp@_FillValue = default_fillvalue("float")
  temp = where(temp.eq.0,temp@_FillValue,temp)

;---Start the graphics
  wks = gsn_open_wks("ps" ,"ROMS_avgtemp")
  gsn_define_colormap(wks,"rainbow")          ; Change color map

;---Set some resources
  res              = True
  res@gsnMaximize  = True               ; Maximize size of plot

  res@sfXArray        = lon2d
  res@sfYArray        = lat2d
  res@gsnAddCyclic    = False

  res@mpDataBaseVersion = "MediumRes"    ; Better map outlines

  res@mpMinLatF       = min(lat2d)
  res@mpMaxLatF       = max(lat2d)
  res@mpMinLonF       = min(lon2d)
  res@mpMaxLonF       = max(lon2d)
  res@mpCenterLonF    = (res@mpMinLonF+res@mpMaxLonF)/2.

  res@cnFillOn        = True
  res@cnLinesOn       = False
  res@cnLevelSpacingF = 0.5
  res@lbOrientation   = "vertical"

  res@tiMainString      = temp@long_name + " (C)"
  res@tiMainFontHeightF = 0.02
  res@gsnLeftString     = ""
  res@gsnRightString    = ""

  nt = 0     ; time index
  ns = 31    ; s_rho index (32-1)
  printMinMax(temp(nt,ns,:,:),0)    ; For debugging purposes

  plot = gsn_csm_contour_map(wks,temp(nt,ns,:,:),res)
end
