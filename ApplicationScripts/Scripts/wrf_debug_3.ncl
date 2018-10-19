;--------------------------------------------------
; wrf_debug_3.ncl
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
; Draw lat/lon lines, given the start/end indexes of the area of 
; interest, and the desired color and thickness of the lines.
;
; Note that this procedure uses gsn_polyline instead of gsn_add_polyline.
; This is mainly to save time and memory. If you need to zoom in on
; the image after adding the lines, text, and markers, then you will
; need to use gsn_add_polyline here.
;----------------------------------------------------------------------
procedure draw_latlon_lines(wks,plot,lat,lon,xloc,yloc,color,thickness)
local i, lnres
begin
  lnres                  = True
  lnres@gsLineThicknessF = thickness
  lnres@gsLineColor      = color
  do i=yloc(0),yloc(1)
    gsn_polyline(wks,plot,lon(i,:),lat(i,:),lnres)
  end do
  do i=xloc(0),xloc(1)
    gsn_polyline(wks,plot,lon(:,i),lat(:,i),lnres)
  end do
end

;----------------------------------------------------------------------
; Draw markers, given the start/end indexes of the area of 
; interest, and the desired color of the markers.
;
; Note that this procedure uses gsn_polymarker instead of 
; gsn_add_polymarker. This is mainly to save time and memory. If you 
; need to zoom in on the image after adding the lines, text, and 
; markers, then you will need to use gsn_add_polymarker here.
;----------------------------------------------------------------------
procedure draw_markers(wks,plot,lat,lon,xloc,yloc,color)
local mkres, i, j
begin
  mkres               = True
  mkres@gsMarkerIndex = 16           ; Filled dot
  mkres@gsMarkerSizeF = 0.04
  mkres@gsMarkerColor = color

  do i=yloc(0),yloc(1)
    do j=xloc(0),xloc(1)
      gsn_polymarker(wks,plot,lon(i,j),lat(i,j),mkres)
    end do
  end do
end

;----------------------------------------------------------------------
; Draw text srings, given the start/end indexes of the area of 
; interest, and the desired color of the text.
;
; Note that this procedure uses gsn_text instead of gsn_add_text.
; This is mainly to save time and memory. If you need to zoom in on
; the image after adding the lines, text, and markers, then you will
; need to use gsn_add_text here.
;----------------------------------------------------------------------
procedure draw_text(wks,plot,str,lat,lon,xloc,yloc,color)
local txres, i, j
begin
  txres               = True
  txres@txFontHeightF = 0.008
  txres@txFontColor   = color
;
; Add strings like:
;
;   U(149,
;      28)
; 
; to each given lat/lon location.
;
  do i=yloc(0),yloc(1)
    do j=xloc(0),xloc(1)
      gsn_text(wks,plot,str+"("+i+",~C~   "+j+")",lon(i,j),lat(i,j),txres)
    end do
  end do
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
  a = addfile("wrfout.nc","r")           ; Open WRF output file

  wks = gsn_open_wks("png","wrf_debug")   ; Open workstation

  res              = True                ; Set map resources 

  res@gsnMaximize  = True
  res@gsnDraw      = False
  res@gsnFrame     = False
  res@tiMainString = "Location of WRF grid centers"
;
; Code to zoom in on WRF map. This will make the various drawing
; elements (markers, lines, text) go faster.
;
; If you draw the full WRF output grid, it can be slow!
;
; Here we are interested in a map area with the SW corner at
; roughly (47N,56W) and the NE corner at (49N,54W). We use 
; wrf_user_ll_to_ij to calculate the estimated index locations 
; of these points.
;
  lats = (/  47.2,  49.0 /)
  lons = (/ -56.0, -54.0 /)
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

;---Set some more resources for correctly drawing WRF map.
  res = wrf_map_resources(a,res)    ; This will produce some warnings
                                    ; which you can ignore

;---Create plot, but don't draw it yet.
  plot = gsn_csm_map(wks,res)

;---Read the various lat/lon arrays
  lat2d  = wrf_user_getvar(a,"XLAT",0)       ; "regular" grid
  lon2d  = wrf_user_getvar(a,"XLONG",0)
  lat2du = wrf_user_getvar(a,"XLAT_U",0)     ; "u" grid
  lon2du = wrf_user_getvar(a,"XLONG_U",0)
  lat2dv = wrf_user_getvar(a,"XLAT_V",0)     ; "v" grid
  lon2dv = wrf_user_getvar(a,"XLONG_V",0)

;---Draw plot before you draw anything else
  draw(plot)

;---Colors for markers and grid lines
  rcolor = "yellow"
  ucolor = "lightblue"
  vcolor = "orange"    

;---Draw lat/lon lines
  draw_latlon_lines(wks,plot,lat2du,lon2du,loc(0,:),loc(1,:),ucolor,5.0)
  draw_latlon_lines(wks,plot,lat2dv,lon2dv,loc(0,:),loc(1,:),vcolor,5.0)
  draw_latlon_lines(wks,plot,lat2d ,lon2d ,loc(0,:),loc(1,:),rcolor,5.0)

;---Draw markers at grid locations
  draw_markers(wks,plot,lat2d ,lon2d ,loc(0,:),loc(1,:),rcolor)
  draw_markers(wks,plot,lat2du,lon2du,loc(0,:),loc(1,:),ucolor)
  draw_markers(wks,plot,lat2dv,lon2dv,loc(0,:),loc(1,:),vcolor)

;---Draw text strings at grid locations
  draw_text(wks,plot,"r",lat2d ,lon2d ,loc(0,:),loc(1,:),"black")
  draw_text(wks,plot,"u",lat2du,lon2du,loc(0,:),loc(1,:),"black")
  draw_text(wks,plot,"v",lat2dv,lon2dv,loc(0,:),loc(1,:),"black")

;---We're done
  frame(wks)
end
