;*************************************************
; NCL Graphics: polar_6.ncl
;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
;************************************************
begin
;************************************************
; read in netCDF file and access data
;************************************************
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
  u = a->U(1,:,:)                                ; read July zonal winds
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("x11" ,"polar")              ; open a ps file    
  res            = True                          ; plot mods desired
  res@gsnPolar   = "NH"                          ; specify the hemisphere
  res@mpMinLatF  = 40                            ; minimum lat
  res@mpGridAndLimbDrawOrder = "PreDraw"         ; draw lat/lon lines first
  res@gsnDraw    = False                         ; don't draw
  res@gsnFrame   = False                         ; don't advance frame
  plot = gsn_csm_contour_map_polar(wks,u,res)    ; create the plot


;************************************************
; create polygon
;************************************************
  lon_min = 120.     ; Min lon value for masked semi-circle
  lon_max = 240.     ; Max lon value for masked semi-circle
  lat     = 40.      ; Lat value for masked semi-circle
  lnpts = 10         ; Number of points in straight line.
  cnpts = 25         ; Number of points in semi-circle.

  dist = gc_latlon(lat,lon_min,lat,lon_max,100,2)
  print(dist@gclat + "/" + dist@gclon)

  gsres             = True
  gsres@gsFillColor = "white"                     ; white polygon

  gon = gsn_add_polyline(wks,plot,dist@gclon,dist@gclat,gsres)
;************************************************
; Draw plot and advance frame.
;************************************************
  draw(plot)
  frame(wks)
end
