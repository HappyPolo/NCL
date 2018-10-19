;----------------------------------------------------------------------
; wrf_gsn_2.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Using gsn_csm_contour_map to plot WRF-ARW data
;----------------------------------------------------------------------
; This example is similar to wrf_gsn_1.ncl, except more plot resources
; are set to:
;   - explicitly set the contour levels
;   - change the look of the map outlines
;   - change the color map
;   - make the labelbar vertical
;----------------------------------------------------------------------; 
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;---Open WRF output file.
  dir      = "./"
  filename = "wrfout_d01_2008-09-30_00:00:00"
  a = addfile(dir + filename + ".nc","r")

;---Read terrain height and lat/lon off file.
  it        = 0     ; first time step
  hgt       = wrf_user_getvar(a,"HGT",it)    ; Terrain elevation
  hgt@lat2d = wrf_user_getvar(a,"XLAT",it)   ; latitude/longitude
  hgt@lon2d = wrf_user_getvar(a,"XLONG",it)  ; required for plotting

  wks = gsn_open_wks("png","wrf_gsn")

;---Set some basic plot options
  res               = True

  res@gsnMaximize   = True   ; maximize plot in frame

  res@tiMainString  = filename

  res@cnFillOn      = True  
  res@cnFillPalette = "OceanLakeLandSnow"
  res@cnLinesOn     = False

  res@mpProjection  = "CylindricalEquidistant"    ; The default

  res@gsnAddCyclic  = False


;---Zoom in on plot
  res@mpMinLatF     = min(hgt@lat2d)
  res@mpMaxLatF     = max(hgt@lat2d)
  res@mpMinLonF     = min(hgt@lon2d)
  res@mpMaxLonF     = max(hgt@lon2d)

;---Additional resources desired
  res@pmTickMarkDisplayMode = "Always"   ; nicer tickmarks

  res@mpDataBaseVersion     = "MediumRes"       ; better and more map outlines
  res@mpDataSetName         = "Earth..4"
  res@mpOutlineBoundarySets = "AllBoundaries"
  res@mpOutlineOn           = True

  res@lbOrientation         = "Vertical"
  res@tiMainOffsetYF        = -0.03           ; Move the title down

;---Change contour levels to better match the color map being used
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels = (/2,100,200,400,600,800,1000,1200,1400,1600,1800,2000,2200/)

  contour = gsn_csm_contour_map(wks,hgt,res)

;
; This is for debugging purposes only. It shows what map resources the
; wrf_map_overlays routine would have use, if you had called that routine
; to do the plotting. This can be useful if you are trying to reproduce
; an original WRF-ARW plot.
;
  dbgres = True
  dbgres = wrf_map_resources(a,dbgres)
  print(dbgres)
end
