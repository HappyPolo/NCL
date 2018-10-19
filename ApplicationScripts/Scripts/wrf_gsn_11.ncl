; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
  a = addfile("wrfout_d01_2008-09-29_00:00:00","r")
  hgt = wrf_user_getvar(a,"HGT",0)    ; Read height off WRF file

  wks = gsn_open_wks("png","wrf_gsn_10")

  res                   = True
  res@gsnMaximize       = True

  res@cnFillOn          = True         ; Turn on contour fill
  res@cnLinesOn         = False        ; Turn off contour lines
  res@cnFillPalette     = "OceanLakeLandSnow"
  res@lbOrientation     = "Vertical"   ; Default is horizontal
  res = wrf_map_resources(a,res)
  res@tfDoNDCOverlay    = True         ; If using WRF projection
  res@gsnAddCyclic      = False        ; IMPORTANT for WRF data         
  res@mpFillOn          = False
  res@mpOutlineOn       = False
  res@mpDataBaseVersion = "MediumRes"
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels = (/5,10,25,50,100,200,400,600,800,1000,1250,1500,1750,2000,2250/)
  plot = gsn_csm_contour_map(wks,hgt,res)
end
