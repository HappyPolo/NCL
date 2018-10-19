;*************************************************
; polyg_6.ncl
;
; Concepts illustrated:
;   - Filling the area between two curves in an XY plot
;   - Attaching polylines to a map plot
;   - Drawing a lat/lon grid
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  in   = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
  lat  = in ->lat
  lon  = in ->lon
  nlat = dimsizes(lat)
  nlon = dimsizes(lon)

;************************************************
; create default plot
;************************************************
  wks = gsn_open_wks("png","polyg")               ; send graphics to PNG file

  res               = True                        ; plot mods desired
  res@gsnDraw       = False                       ; don't draw yet
  res@gsnFrame      = False                       ; don't advance frame
  res@tiMainString  = "Grid of two dimensional data"
  plot = gsn_csm_map_ce(wks,res)                 ; draw global map
;************************************************
; draw longitude lines
;************************************************
  dum = new(dimsizes(lon),graphic)
  do i = 0 ,nlon-1,3
    dum(i) = gsn_add_polyline(wks,plot,(/lon(i),lon(i)/),(/lat(0),lat(nlat-1)/),False)
  end do
;************************************************
; Draw longitude lines
; 
; Note that you can't simply draw a line from 
; longitude -180 to 180. In order to avoid 
; ambiguity concerning cyclic longitude values,
; map polylines and polygons always use the
; shortest path around the globe between any
; two points.
;
;************************************************
  nlon2 = toint(nlon*1./3.)  ; this gives us two extra longitude
  nlon3 = toint(nlon*2./3.)  ; points to plot for each latitude line.
  dum1  = new(dimsizes(lat),graphic)
  lon_vals = (/lon(0),lon(nlon2),lon(nlon3),lon(nlon-1)/)
  do i = 0 ,nlat-1,3
    lat_vals = (/lat(i),lat(i),lat(i),lat(i)/)
    dum1(i) = gsn_add_polyline(wks,plot,lon_vals,lat_vals,False)
  end do

  draw(plot)
  frame(wks)
end




