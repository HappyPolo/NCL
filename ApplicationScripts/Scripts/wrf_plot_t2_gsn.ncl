load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

;----------------------------------------------------------------------
; Function to regrid data on a WRF grid to a set of random
; lat / lon points.
;----------------------------------------------------------------------
function regrid_wrf_to_rdm(var,lat_pts,lon_pts)
local opt
begin
  opt                   = True
  opt@InterpMethod      = "bilinear"
  opt@WgtFileName       = "wrf_to_obs"

  opt@SrcRegional       = True

  opt@DstGridLat        = lat_pts
  opt@DstGridLon        = lon_pts
  opt@DstRegional       = True
  opt@DstGridType       = "unstructured"

  opt@ForceOverwrite    = True
  opt@PrintTimings      = True
  opt@Debug             = True

  var_regrid = ESMF_regrid(var,opt)     ; Do the regridding
  return(var_regrid)
end

;----------------------------------------------------------------------
; Function to regrid random data to a WRF grid.
;----------------------------------------------------------------------
function regrid_rdm_to_wrf(var,lat_pts,lon_pts,lat2d,lon2d)
local opt
begin
  opt                   = True
  opt@InterpMethod      = "bilinear"
  opt@WgtFileName       = "obs_to_wrf"

  opt@SrcGridLat        = lat_pts
  opt@SrcGridLon        = lon_pts
  opt@SrcGridType       = "unstructured"
  opt@SrcRegional       = True

  opt@DstGridLat        = lat2d
  opt@DstGridLon        = lon2d
  opt@DstRegional       = True

  opt@ForceOverwrite    = True
  opt@PrintTimings      = True
  opt@Debug             = True

  var_regrid = ESMF_regrid(var,opt)     ; Do the regridding
  return(var_regrid)
end

;----------------------------------------------------------------------
; Main coee
;----------------------------------------------------------------------
begin
;---Open WRF output file and read variables
  fname = "wrfout_d01_2008-09-30_00:00:00"
  a = addfile(fname + ".nc", "r")

  nt    = 0
;  tk2   = a->T2(nt,:,:)
  tk2   = a->HGT(nt,:,:)
  lat2d = a->XLAT(nt,:,:)
  lon2d = a->XLONG(nt,:,:)
  tk2@lat2d = lat2d
  tk2@lon2d = lon2d
  minlat = min(lat2d)
  maxlat = max(lat2d)
  minlon = min(lon2d)
  maxlon = max(lon2d)

;---Generate some dummy lat/lon points
  npts = 300
  lat_pts = random_uniform(minlat,maxlat,npts)
  lon_pts = random_uniform(minlon,maxlon,npts)

;---Start the graphics
  wks = gsn_open_wks("x11","wrf_plot_t2_gsn")

;---Plotting options for T (filled contours)
  res                   = True
;  res@gsnMaximize           = True
  res@gsnDraw               = False
  res@gsnFrame              = False

  res@cnFillOn              = True  
  res@cnFillPalette         = "OceanLakeLandSnow"
  res@cnLinesOn             = False
  res@cnLineLabelsOn        = False
;  res@cnLevelSelectionMode  = "ExplicitLevels"
;  res@cnLevels              = ispan(256,302,2)
  res@cnLevelSpacingF       = 50
  res@pmTickMarkDisplayMode = "Always"
  res@pmTitleZone           = 4
  res@mpDataBaseVersion     = "MediumRes"

; res@lbOrientation         = "Vertical"
  res@lbLabelBarOn          = False     ; will turn on in panel

  res@mpMinLatF             = minlat-1
  res@mpMaxLatF             = maxlat+1
  res@mpMinLonF             = minlon-1
  res@mpMaxLonF             = maxlon+1
  res@gsnAddCyclic          = False

  res@tiMainString = "Original data on WRF grid"
  plot_wrf = gsn_csm_contour_map(wks,tk2,res)

  mkres = True
  mkres@gsMarkerIndex = 16
  mkres@gsMarkerSizeF = 1.2
  mkres@gsMarkerSizeF = 7.0
  mkres@gsMarkerColor = "black"

;  id1 = gsn_add_polymarker(wks,plot_wrf,lon_pts,lat_pts,mkres)
  draw(plot_wrf)
  frame(wks)

  tk2_obs = regrid_wrf_to_rdm(tk2,lat_pts,lon_pts)
  tk2_wrf = regrid_rdm_to_wrf(tk2_obs,lat_pts,lon_pts,lat2d,lon2d)
  printMinMax(tk2_obs,0)
  printMinMax(tk2_wrf,0)
  printVarSummary(tk2_obs)
  printVarSummary(tk2_wrf)

  res@tiMainString = "dummy observational values"
  res@cnFillMode   = "RasterFill"
  plot_obs = gsn_csm_contour_map(wks,tk2_obs,res)
  id2 = gsn_add_polymarker(wks,plot_obs,lon_pts,lat_pts,mkres)
  draw(plot_obs)
  frame(wks)

  res@tiMainString = "regridded back to WRF"
  delete(res@cnFillMode)
  plot_wrf2 = gsn_csm_contour_map(wks,tk2_wrf,res)
  draw(plot_wrf2)
  frame(wks)

  pres = True
  pres@gsnPanelLabelBar = True
  pres@gsnMaximize      = True
;  pres@gsnPanelRowSpec  = True
  gsn_panel(wks,(/plot_wrf,plot_obs,plot_wrf2/),(/1,3/),pres)
end
