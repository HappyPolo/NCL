;----------------------------------------------------------------------
; wrf_nogsn_1.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Using wrf_xxxx scripts to plot WRF-ARW data
;----------------------------------------------------------------------
; This script is meant to show the difference between plotting WRF
; data using wrf_xxx scripts, and using gsn_csm_xxx scripts.
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

  wks = gsn_open_wks("png","wrf_nogsn")

;---Set some basic plot options
  res                   = True
  res@gsnMaximize       = True   ; maximize plot in frame
  res@tiMainString      = filename
  res@cnFillOn          = True  
  res@cnLinesOn         = False
  res@cnFillPalette     = "OceanLakeLandSnow"
  res@cnSpanFillPalette = True   ; in NCL V6.4.0 you won't need to set this.

;---Generate contour plot then overlay on map
  contour = wrf_contour(a,wks,hgt,res)
  map = wrf_map_overlays(a,wks,contour,True,True)
end
