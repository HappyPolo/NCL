;--------------------------------------------------
; wrf_debug_2.ncl
;--------------------------------------------------
; Concepts illustrated:
;   - Drawing various elements of WRF lat/lon grids using lines, markers, text
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

;---Resources for a zoomed-in WRF map
  res              = True
  res@gsnMaximize  = True
  res@gsnDraw      = False
  res@gsnFrame     = False
  res@tiMainString = "XLAT/XLONG, XLATU/XLONU, XLATV/XLONGV points"

;
; Code to zoom in on WRF map. This will make the various drawing
; elements (markers, lines, text) go faster.
;
; If you draw the full WRF output grid, it can be slow!
;
; Here we are interested in a map area with the SW corner at
; roughly (46N,56W) and the NE corner at (49N,53W). We use 
; wrf_user_ll_to_ij to calculate the estimated index locations 
; of these points.
;
  lats = (/  46.4,  49.0 /)
  lons = (/ -56.0, -53.0 /)
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

;---Create plot, but don't draw it yet.
  plot = gsn_csm_map(wks,res)

;---Set index for grid location of interest.
  ic = 130              ; associated with lat dimension
  jc =  59              ; associated with lon dimension

;---Set various colors to use
  rcolor    = "Black"       ; for grid lines and markers
  ucolor    = "SteelBlue1"
  vcolor    = "Orange"    

;---Indexes for four corners surrounding cell of interest
  icm1 = ic-1
  icp1 = ic+1
  jcm1 = jc-1
  jcp1 = jc+1

;---Get the lat/lon of the regular, and U/V staggered grids
  latc   = lat2d(ic,jc)      ; regular grid
  lonc   = lon2d(ic,jc)
  latu   = lat2du(ic,jc)     ; u stagger
  lonu   = lon2du(ic,jc)
  latv   = lat2dv(ic,jc)     ; v stagger
  lonv   = lon2dv(ic,jc)

;---Get the four grid corners around the "regular" cell of interest
  latLL   = lat2d(icm1,jcm1)   ; Bottom left grid corner
  lonLL   = lon2d(icm1,jcm1)
  latLR   = lat2d(icm1,jcp1)   ; Bottom right grid corner
  lonLR   = lon2d(icm1,jcp1)
  latUR   = lat2d(icp1,jcp1)   ; Upper right grid corner
  lonUR   = lon2d(icp1,jcp1)
  latUL   = lat2d(icp1,jcm1)   ; Upper left grid corner
  lonUL   = lon2d(icp1,jcm1)

;---Get the four grid corners around the "U" cell of interest
  latuLL  = lat2du(icm1,jcm1)   ; Bottom left grid corner
  lonuLL  = lon2du(icm1,jcm1)
  latuLR  = lat2du(icm1,jcp1)   ; Bottom right grid corner
  lonuLR  = lon2du(icm1,jcp1)
  latuUR  = lat2du(icp1,jcp1)   ; Upper right grid corner
  lonuUR  = lon2du(icp1,jcp1)
  latuUL  = lat2du(icp1,jcm1)   ; Upper left grid corner
  lonuUL  = lon2du(icp1,jcm1)

;---Get the four grid corners around the "V" cell of interest
  latvLL  = lat2dv(icm1,jcm1)   ; Bottom left grid corner
  lonvLL  = lon2dv(icm1,jcm1)
  latvLR  = lat2dv(icm1,jcp1)   ; Bottom right grid corner
  lonvLR  = lon2dv(icm1,jcp1)
  latvUR  = lat2dv(icp1,jcp1)   ; Upper right grid corner
  lonvUR  = lon2dv(icp1,jcp1)
  latvUL  = lat2dv(icp1,jcm1)   ; Upper left grid corner
  lonvUL  = lon2dv(icp1,jcm1)

;---Add the "u" lat/lon lines
  add_latlon_lines(wks,plot,lon2du,lat2du,ucolor,5,0)
  add_latlon_lines(wks,plot,lon2dv,lat2dv,vcolor,5,0)
  add_latlon_lines(wks,plot,lon2d,lat2d,  rcolor,1.5,2)

;---Draw plot before you draw anything else
  draw(plot)

;---Draw a marker at the "regular" cell of interest and its four corners
  mkres               = True
  mkres@gsMarkerIndex = 16           ; Filled dot
  mkres@gsMarkerSizeF = 0.02
  mkres@gsMarkerColor = rcolor

  gsn_polymarker(wks,plot,lonc,latc,mkres)
  gsn_polymarker(wks,plot,lonLL,latLL,mkres)
  gsn_polymarker(wks,plot,lonLR,latLR,mkres)
  gsn_polymarker(wks,plot,lonUR,latUR,mkres)
  gsn_polymarker(wks,plot,lonUL,latUL,mkres)

;---Draw text strings on top of the markers
  txres               = True
  txres@txFontHeightF = 0.01
  txres@txFontColor   = "white"
  gsn_text(wks,plot,"C",lonc,latc,txres)
  gsn_text(wks,plot,"LL",lonLL,latLL,txres)
  gsn_text(wks,plot,"LR",lonLR,latLR,txres)
  gsn_text(wks,plot,"UR",lonUR,latUR,txres)
  gsn_text(wks,plot,"UL",lonUL,latUL,txres)

;---Draw markers/text strings at the "U" cell of interest & its four corners
  txres@txFontColor   = "black"
  mkres@gsMarkerColor = ucolor
  gsn_polymarker(wks,plot,lonu,latu,mkres)
  gsn_polymarker(wks,plot,lonuLL,latuLL,mkres)
  gsn_polymarker(wks,plot,lonuLR,latuLR,mkres)
  gsn_polymarker(wks,plot,lonuUR,latuUR,mkres)
  gsn_polymarker(wks,plot,lonuUL,latuUL,mkres)
  gsn_text(wks,plot,"UC",lonu,latu,txres)
  gsn_text(wks,plot,"LL",lonuLL,latuLL,txres)
  gsn_text(wks,plot,"LR",lonuLR,latuLR,txres)
  gsn_text(wks,plot,"UR",lonuUR,latuUR,txres)
  gsn_text(wks,plot,"UL",lonuUL,latuUL,txres)

;---Draw markers/text strings at the "V" cell of interest & its four corners
  mkres@gsMarkerColor = vcolor
  gsn_polymarker(wks,plot,lonv,latv,mkres)
  gsn_polymarker(wks,plot,lonvLL,latvLL,mkres)
  gsn_polymarker(wks,plot,lonvLR,latvLR,mkres)
  gsn_polymarker(wks,plot,lonvUR,latvUR,mkres)
  gsn_polymarker(wks,plot,lonvUL,latvUL,mkres)
  gsn_text(wks,plot,"VC",lonv,latv,txres)
  gsn_text(wks,plot,"LL",lonvLL,latvLL,txres)
  gsn_text(wks,plot,"LR",lonvLR,latvLR,txres)
  gsn_text(wks,plot,"UR",lonvUR,latvUR,txres)
  gsn_text(wks,plot,"UL",lonvUL,latvUL,txres)

;---Explanatory text
  txres                       = True
  txres@txFontHeightF         = 0.012
  txres@txJust                = "CenterLeft"
  txres@txBackgroundFillColor = "white"
  xpos = 0.60
  ypos = 0.55

  gsn_text_ndc(wks,"The 'C' marker is the grid~C~" + \
        "location of the XLAT/XLONG array~C~at indexes " + \
        "("+ic+","+jc+").~C~~C~" + \
        "The UC/VC markers are the grid~C~" + \
        "locations of the XLAT{U,V}/XLONG{U,V}~C~" + \
        "arrays at indexes ("+ic+","+jc+").~C~~C~" + \
        rcolor  + " markers/lines show~C~XLAT/XLONG locations.~C~~C~" + \
        ucolor + " markers/lines show~C~XLATU/XLONGU locations.~C~~C~"+ \
        vcolor + " markers/lines show~C~XLATV/XLONGV locations.~C~~C~" + \
        "'UL'='Upper left', 'UR'='Upper right'~C~" + \
        "'LL'='Lower left', 'LR'='Lower right'", xpos,ypos,txres)

;---We're done
  frame(wks)
end
