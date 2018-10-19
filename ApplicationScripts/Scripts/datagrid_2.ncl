;--------------------------------------------------
; datagrid_2.ncl
;--------------------------------------------------
; Concepts illustrated:
;   - Drawing a WRF lat/lon grid using gsn_coordinates
;--------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
  a = addfile("wrfout_d01_2008-09-29_16:00:00","r")

  wks = gsn_open_wks("png","datagrid") ; send graphics to PNG file

  res              = True
  res@gsnMaximize  = True
  res@gsnDraw      = False
  res@gsnFrame     = False

;---Set some resources for correctly drawing WRF map.
  res = wrf_map_resources(a,res)

;---Create three map plots
  res@tiMainString = "XLAT / XLONG grid"
  plot_1 = gsn_csm_map(wks,res)
  res@tiMainString = "XLAT_U / XLONG_U grid"
  plot_2 = gsn_csm_map(wks,res)
  res@tiMainString = "XLAT_V / XLONG_V grid"
  plot_3 = gsn_csm_map(wks,res)
;
; Read three variables off the WRF output file and
; attach the necessary lat/lon information via
; lat2d and lon2d attributes.
;
; We are using hgt, u and v here, because they are
; all on different grids:
;
; hgt  [south_north | 197]      x [west_east | 206]
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
;
;
; Note: when you call gsn_coordinates, the lines are not attached to
; the plot by default. This means if you gsn_coordinates repeatedly, 
; you will not see the lines drawn from the previous call.
;
; To force the lines to be attached to the plot, you need to set 
; pres@gsnCoordsAttach to True. You will also need to draw the 
; plot and advance the frame yourself, since this resource turns
; off the drawing and frame advance by default.
;
  pres                   = True
  pres@gsnCoordsAsLines  = True        ; Default is points
  pres@gsLineColor = "NavyBlue"
  gsn_coordinates(wks,plot_1,hgt,pres)

  pres@gsLineColor = "ForestGreen"
  gsn_coordinates(wks,plot_2,u,pres)

  pres@gsLineColor = "Brown"
  gsn_coordinates(wks,plot_3,v,pres)
end
