;*************************************************
; NCL Graphics: polar_6.ncl
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
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
  wks = gsn_open_wks("png" ,"polar")             ; send graphics to PNG file   
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
;************************************************
; Convert lat/lon points to NDC coordinates.
;************************************************
  xout = new(2,float)
  yout = new(2,float)
  datatondc(plot,(/lon_min,lon_max/),(/lat,lat/),xout,yout)
;************************************************
; Create a straight line between the NDC points.
;************************************************
  xout_new = new(lnpts,float)
  yout_new = new(lnpts,float)
  xout_new = fspan(xout(0),xout(1),lnpts)
  yout_new = fspan(yout(0),yout(1),lnpts)
;************************************************
; Convert the NDC coordinates in straight line
; back to lat/lon coordinates.
;************************************************
  lon_new = new(lnpts,float)
  lat_new = new(lnpts,float)
  ndctodata(plot,xout_new,yout_new,lon_new,lat_new)
;************************************************
; Any lon points that are less than 0,
; add 360 to them.
;************************************************
  lon_new = where(lon_new < 0,lon_new+360,lon_new)
;************************************************
; Create an array of lat/lon points that will
; include the straight line and the semi-circle.
;************************************************
  xpt = new(lnpts+cnpts,float)
  ypt = new(lnpts+cnpts,float)
  xpt(cnpts-1:0) = fspan(lon_min,lon_max,cnpts)  ; semi-circle
  ypt(0:cnpts-1) = lat
  xpt(cnpts:)    = lon_new                       ; straight line
  ypt(cnpts:)    = lat_new

;************************************************
; Add this polygon to plot.
;************************************************
  gsres             = True
  gsres@gsFillColor = "white"                     ; white polygon

  gon = gsn_add_polygon(wks,plot,xpt,ypt,gsres)
;************************************************
; Draw plot and advance frame.
;************************************************
  draw(plot)
  frame(wks)
end

