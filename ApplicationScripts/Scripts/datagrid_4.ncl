;----------------------------------------------------------------------
; datagrid_4.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Drawing a WRF lat/lon grid using gsn_coordinates
;----------------------------------------------------------------------
; This is similar to datagrid_2.ncl, except now the lat/lon grids
; are drawn over a contour plot over a map.
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;---Read terrain height and lat/lon off file.
  filename = "wrfout_d01_2003-07-15_00:00:00.nc"
  a        = addfile(filename,"r")

  it  = 0     ; first time step
  hgt = wrf_user_getvar(a,"HGT",it)    ; Terrain elevation

  wks = gsn_open_wks("png","datagrid")

;---Set some basic plot options
  res                      = True

  res@gsnMaximize          = True   ; maximize plot in frame
  res@gsnDraw              = False
  res@gsnFrame             = False

  res@cnLinesOn            = False
  res@cnFillOn             = True  
  res@cnFillPalette        = "OceanLakeLandSnow"
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = (/2,100,200,400,600,800,1000,1200,1400,1600,1800,2000,2200/)

  res = wrf_map_resources(a,res)
  res@tfDoNDCOverlay       = True         ; use native WRF map projection
  res@gsnAddCyclic         = False        ; don't try to add longitude cyclic point

  res@tiMainString         = filename
  res@lbOrientation        = "Vertical"

  plot = gsn_csm_contour_map(wks,hgt,res)

;
; To draw the WRF lat/lon grid, it is necessary to read the 
; WRF XLAT/XLONG arrays off the file and attach them to "hgt".
;
; gsn_coordinates will look for the lat2d/lon2d attributes,
; if no coordinate arrays are attached to the variable.
;
  lnres                   = True
  lnres@gsLineColor       = "gray30"
  lnres@gsnCoordsAsLines  = True    ; draw grid as lines, not markers

  hgt@lat2d = wrf_user_getvar(a,"XLAT",it)   ; latitude/longitude
  hgt@lon2d = wrf_user_getvar(a,"XLONG",it)  ; required for plotting

  gsn_coordinates(wks,plot,hgt,lnres)
end
