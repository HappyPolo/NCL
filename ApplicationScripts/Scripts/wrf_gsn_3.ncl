;----------------------------------------------------------------------
; wrf_gsn_3.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Using gsn_csm_contour_map to plot WRF-ARW data
;   - Drawing a WRF lat/lon grid using gsn_coordinates
;----------------------------------------------------------------------
; This example is similar to wrf_gsn_2.ncl, except it zooms in further
; on the map and draws the WRF grid as points, then as lines.
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
  res@gsnDraw       = False
  res@gsnFrame      = False

  res@tiMainString  = filename

  res@cnFillOn      = True  
  res@cnFillPalette = "OceanLakeLandSnow"
  res@cnLinesOn     = False

  res@mpProjection  = "CylindricalEquidistant"    ; The default

;---Zoom in on plot
  res@mpMinLatF     = 40
  res@mpMaxLatF     = 50
  res@mpMinLonF     = 120
  res@mpMaxLonF     = 130

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

  res@gsnAddCyclic         = False   ; don't add longitude cyclic point

  plot = gsn_csm_contour_map(wks,hgt,res)

  mkres                 = True
  mkres@gsMarkerSizeF  = 0.005
  mkres@gsMarkerColor  = "purple"
  gsn_coordinates(wks,plot,hgt,mkres)

  mkres@gsLineColor      = "Brown"
  mkres@gsLineThicknessF = 2.0

  mkres@gsnCoordsAsLines = True    ; draw grid as lines, not markers
  gsn_coordinates(wks,plot,hgt,mkres)
end
