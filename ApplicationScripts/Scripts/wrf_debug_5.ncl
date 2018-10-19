;--------------------------------------------------
; wrf_debug_5.ncl
; 
; THIS example is not done.  I was going to draw
; all three WRF grids, but this would make for a
; very busy plot. Instead, I probably need to zoom
; in on it.
;--------------------------------------------------
; Concepts illustrated:
;   - 
;--------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;---Open WRF output file and read off the lat/lon grid
  a     = addfile("wrfout_d01_2008-09-29_16:00:00","r")

  nt     = 0   ; 0 = first time step
  slp    = wrf_user_getvar(a,"slp",nt)
  lat2d  = wrf_user_getvar(a,"XLAT",nt)
  lon2d  = wrf_user_getvar(a,"XLONG",nt)
  ulat2d = wrf_user_getvar(a,"XLAT_U",nt)
  ulon2d = wrf_user_getvar(a,"XLONG_U",nt)
  vlat2d = wrf_user_getvar(a,"XLAT_V",nt)
  vlon2d = wrf_user_getvar(a,"XLONG_V",nt)

  wks = gsn_open_wks("x11","wrf_debug")

;---Set some resources for a WRF map
  res                         = True
  res@gsnMaximize             = True
  res@gsnDraw                 = False
  res@gsnFrame                = False
  res@cnFillOn                = True

  res = wrf_map_resources(a,res)
  res@tfDoNDCOverlay = True

;---Create a filled contour plot
  plot = gsn_csm_contour_map(wks,slp,res)

  pres = True
  pres@gsnCoordsLat = lat2d
  pres@gsnCoordsLon = lon2d
  pres@gsnCoordsAsLines = True
  gsn_coordinates(wks,plot,slp,pres) 

end
