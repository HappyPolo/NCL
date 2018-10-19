; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
  a = addfile("wrfout_d01_2008-09-29_00:00:00","r")
  hgt = wrf_user_getvar(a,"HGT",0)    ; Read height off WRF file

  wks = gsn_open_wks("png","wrf_gsn_10_shapefiles")

  res                   = True
  res@gsnMaximize       = True

  res@cnFillOn          = True         ; Turn on contour fill
  res@cnLinesOn         = False        ; Turn off contour lines
  res@cnFillPalette     = "OceanLakeLandSnow"
  res@lbOrientation     = "Vertical"   ; Default is horizontal
  res = wrf_map_resources(a,res)
  res@tfDoNDCOverlay    = True         ; If using WRF projection
  res@gsnAddCyclic      = False        ; IMPORTANT for WRF data         
  res@mpOutlineOn       = False
  res@mpFillOn          = False
  res@gsnDraw = False
  res@gsnFrame = False
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels = (/5,10,25,50,100,200,400,600,800,1000,1250,1500,1750,2000,2250/)
  plot = gsn_csm_contour_map(wks,hgt,res)

  lnres = True
  lnres@gsLineThicknessF = 2.0
  Japan = gsn_add_shapefile_polylines(wks,plot,"JPN_adm/JPN_adm2.shp",lnres)
  China = gsn_add_shapefile_polylines(wks,plot,"CHN_adm/CHN_adm2.shp",lnres)
  Korea = gsn_add_shapefile_polylines(wks,plot,"KOR_adm/KOR_adm2.shp",lnres)
  Russia = gsn_add_shapefile_polylines(wks,plot,"RUS_adm/RUS_adm2.shp",lnres)
  draw(plot)
  frame(wks)
end
