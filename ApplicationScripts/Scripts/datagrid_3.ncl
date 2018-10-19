;--------------------------------------------------
; datagrid_3.ncl
;--------------------------------------------------
; Concepts illustrated:
;   - Drawing three different WRF lat/lon grid using gsn_coordinates
;   - Zooming in on a WRF map
;--------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
  a = addfile("wrfout_d01_2008-09-29_16:00:00","r")

;
; Read three variables off the WRF output file and
; attached the necessary lat/lon information via
; lat2d and lon2d attributes.
;
;   u  [south_north | 197]      x [west_east_stag | 207]
;   v  [south_north_stag | 198] x [west_east | 206]
;
  hgt       = a->HGT(0,:,:)
  u         = a->U(0,0,:,:)
  v         = a->V(0,0,:,:)
  hgt@lat2d = a->XLAT(0,:,:)
  hgt@lon2d = a->XLONG(0,:,:)
  u@lat2d   = a->XLAT_U(0,:,:)
  u@lon2d   = a->XLONG_U(0,:,:)
  v@lat2d   = a->XLAT_V(0,:,:)
  v@lon2d   = a->XLONG_V(0,:,:)
 
  u_color = "NavyBlue"
  v_color = "ForestGreen"
  h_color = "orange"

;--- Start the graphics
  wks = gsn_open_wks("png","datagrid")

;
; Note: we are NOT using the map projection defined on the
; WRF output file. Instead, we are going to do a simple
; lat/lon map and zoom in on a small piece of it so we
; can see the grid lines better.
;
  res              = True
  res@gsnMaximize  = True
  res@gsnDraw      = False
  res@gsnFrame     = False
  res@pmTickMarkDisplayMode = "Always"   ; nicer map tickmarks
  res@mpDataBaseVersion = "mediumres"

;---These settings hard-code an area of the map we want to "zoom" in on
  res@mpMinLatF    = 50
  res@mpMaxLatF    = 55 
  res@mpMinLonF    = 155
  res@mpMaxLonF    = 160

;--- Various titles
  res@tiMainString                  = "Three WRF grids"
  res@gsnLeftString                 = "U grid: " + u_color
  res@gsnRightString                = "V grid: " + v_color
  res@gsnCenterString               = "HGT grid: " + h_color
  res@gsnStringFontHeightF          = 0.012
  res@gsnLeftStringOrthogonalPosF   = -0.01
  res@gsnLeftStringFontColor        = u_color
  res@gsnCenterStringFontColor      = h_color
  res@gsnRightStringFontColor       = v_color
  res@gsnCenterStringOrthogonalPosF = -0.01
  res@gsnRightStringOrthogonalPosF  = -0.01

;--- Create plot, but don't draw it yet.
  plot = gsn_csm_map(wks,res)

;--- Call gsn_coordinates 3x to attach lat/lon lines or points
  pres                   = True
  pres@gsnCoordsAttach   = True
  pres@gsLineThicknessF  = 5.0
  pres@gsnCoordsAsLines  = True        ; Default is points

  pres@gsLineColor       = u_color
  gsn_coordinates(wks,plot,v,pres)

  pres@gsLineColor       = v_color
  gsn_coordinates(wks,plot,u,pres)

  pres@gsnCoordsAsLines  = False       ; Go back to points
  pres@gsMarkerColor     = h_color
  gsn_coordinates(wks,plot,hgt,pres)

  draw(plot)
  frame(wks)
end
