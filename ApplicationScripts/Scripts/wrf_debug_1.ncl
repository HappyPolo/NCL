;--------------------------------------------------
; wrf_debug_1.ncl
;--------------------------------------------------
; Concepts illustrated:
;   - Drawing various WRF lat/lon grids using gsn_add_polyline
;   - Zooming in on a WRF map
;   - Setting the correct WRF map projection using wrf_map_resources
;--------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

;----------------------------------------------------------------------
; This procedure attaches the given lat/lon lines to the existing
; map plot.
;----------------------------------------------------------------------
procedure add_latlon_lines(wks,plot,lon,lat,color,thickness,style)
local lnres, nlat, nlon,slat, slon
begin
  nlat = dimsizes(lat(:,0))
  nlon = dimsizes(lon(0,:))

;---Add the "u" lat/lon lines
  lnres                   = True
  lnres@gsLineThicknessF  = thickness
  lnres@gsLineColor       = color
  lnres@gsLineDashPattern = style
 
  slat = unique_string("lat") + ispan(0,nlat-1,1)
  slon = unique_string("lon") + ispan(0,nlon-1,1)
  do i=0,nlat-1
    plot@$slat(i)$ = gsn_add_polyline(wks,plot,lon(i,:),lat(i,:),lnres)
  end do
  do i=0,nlon-1
    plot@$slon(i)$ = gsn_add_polyline(wks,plot,lon(:,i),lat(:,i),lnres)
  end do
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
;---Set various colors to use for lat/lon grid lines
  rcolor    = "Black"       ; grid line colors
  ucolor    = "Green"
  vcolor    = "Orange"    

  a = addfile("wrfout.nc","r")

;---Read the lat/lon arrays
  lat2d  = wrf_user_getvar(a,"XLAT",0)       ; "regular" grid
  lon2d  = wrf_user_getvar(a,"XLONG",0)
  lat2du = wrf_user_getvar(a,"XLAT_U",0)     ; "u" grid
  lon2du = wrf_user_getvar(a,"XLONG_U",0)
  lat2dv = wrf_user_getvar(a,"XLAT_V",0)     ; "v" grid
  lon2dv = wrf_user_getvar(a,"XLONG_V",0)

;---Start the graphics
  wks = gsn_open_wks("png","wrf_debug")

;---Set some resources for a WRF map
  res                         = True
  res@gsnMaximize             = True
  res@gsnDraw                 = False
  res@gsnFrame                = False

  res@tiMainString             = "Map with all three lat/lon grids on WRF file"
  res@tiMainFontHeightF        = 0.02
  res@gsnStringFontHeightF     = 0.01

  res@gsnLeftString            = ucolor + ": XLATU/XLONGU"
  res@gsnLeftStringFontColor   = ucolor

  res@gsnCenterString          = rcolor + " (dashed): XLAT/XLONG"
  res@gsnCenterStringFontColor = rcolor

  res@gsnRightString           = vcolor + ": XLATV/XLONGV"
  res@gsnRightStringFontColor  = vcolor

;
; Code to zoom in on WRF map. This will make the various drawing
; elements (markers, lines, text) go faster.
;
; If you draw the full WRF output grid, it can be slow!
;
; Here we are interested in a map area with the SW corner at
; roughly (46N,56W) and the NE corner at (52N,52W). We use 
; wrf_user_ll_to_ij to calculate the estimated index locations 
; of these points.
;
  lats = (/  46.0,  52.0 /)
  lons = (/ -56.0, -52.0 /)
  loc  = wrf_user_ll_to_ij(a, lons, lats, True)
; 
; loc(0,:) is west-east (x)
; loc(1,:) is south-north (y)
;
; Use "loc" values to set special resources for zooming in on map.
;
  loc        = loc-1       ; Subtract one since we want to use it 
                           ; as an index in NCL.
  res@ZoomIn = True        ; Tell wrf_map_resources we want to zoom in.
  res@Xstart = loc(0,0)    ; Set the zoom in coordinates
  res@Xend   = loc(0,1)
  res@Ystart = loc(1,0)
  res@Yend   = loc(1,1)
;
; Set some resources for drawing a WRF map. This will produce
; some warnings which you can safely ignore.
;
  res = wrf_map_resources(a,res)

  plot = gsn_csm_map(wks,res)   ; Create plot, but don't draw it yet.

;---Add the lat/lon lines for all three lat/lon grids
  add_latlon_lines(wks,plot,lon2du,lat2du,ucolor,5,0)
  add_latlon_lines(wks,plot,lon2dv,lat2dv,vcolor,5,0)
  add_latlon_lines(wks,plot,lon2d,lat2d,  rcolor,1.5,2)

  draw(plot)     ; Drawing the plot draws all the attached lat/lon lines
  frame(wks)     ; Advance the frame
end
