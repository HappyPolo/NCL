;**************************************
; conOncon_7.ncl
;
; Concepts illustrated:
;   - Drawing a spaghetti contour plot
;   - Drawing contours over a Lambert Conformal map
;   - Overlaying contours on a map using two-dimensional lat,lon arrays
;   - Drawing contours over a map using a native lat,lon grid
;   - Zooming in on a particular area on a Lambert Conformal map
;   - Turning on map tickmarks for a Lambert Conformal map
;   - Changing the color of a contour line
;   - Decreasing the thickness of contour lines
;   - Explicitly setting contour levels
;**************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

  files = (/"mm5_2003041012f024_01n.nc","mm5_2003041012f024_10n.nc",\
  "mm5_2003041012f048_01n.nc","mm5_2003041012f048_10n.nc"/)
;**************************************
; open one data file to get lat/lon info
;**************************************
  in         = addfile(files(0),"r")
  LAT2D      = in->latitcrs
  LON2D      = in->longicrs
  dims       = dimsizes(LAT2D)
  nlat       = dims(0)
  nlon       = dims(1)
;**************************************
; plot parameters
;**************************************
  plot = new(4,graphic)
  wks  = gsn_open_wks("png","conOncon")  ; send graphics to PNG file
;**************************************
; create map plot w/o contours
; this is a native grid projection
;**************************************

  colors = (/ "red", "green", "blue", "yellow", "cyan", "hotpink", \
  "red4", "skyblue", "navyblue", "lightyellow", "mediumorchid4", "orange", \
  "slateblue3", "palegreen", "magenta", "springgreen", "pink", \
  "forestgreen", "violet" /)
  mres                     = True
  mres@mpLimitMode         = "Corners"             ; corner method of zoom
  mres@mpLeftCornerLatF    = LAT2D(0,0)            ; left corner
  mres@mpLeftCornerLonF    = LON2D(0,0)            ; left corner
  mres@mpRightCornerLatF   = LAT2D(nlat-1,nlon-1)  ; right corner
  mres@mpRightCornerLonF   = LON2D(nlat-1,nlon-1)  ; right corner
  mres@mpProjection        = "LambertConformal"    ; choose projection
  mres@mpLambertParallel1F = in->stdlat_1          ; first parallel
  mres@mpLambertParallel2F = in->stdlat_2          ; second parallel
  mres@mpLambertMeridianF  = in->stdlon            ; meridian
  mres@tfDoNDCOverlay      = True                  ; native grid, no transform
  mres@gsnDraw             = False                 ; don't draw yet
  mres@gsnFrame            = False                 ; don't advance frame yet
  mres@pmTickMarkDisplayMode = "Always"            ; turn on tickmarks

  plot_base = gsn_csm_map(wks,mres)
;**************************************
; contour plot resources
;**************************************
  cnres                       = True
  cnres@cnLevelSelectionMode  = "ExplicitLevels"  ; explicit contour levels
  cnres@cnLevels              = 0.005             ; level to plot
  cnres@cnInfoLabelOn         = False             ; no info label
  cnres@cnLineLabelsOn        = False             ; no line labels
  cnres@cnLineThicknessF      = 0.5               ; line thickness
  cnres@tiMainString          = "Spaghetti Plot from data w/ 2D coords"
  cnres@gsnDraw               = False             ; don't draw yet
  cnres@gsnFrame              = False             ; don't advance frame yet

; if you are going to use "overlay" with data that has 2D coordinates,
; it is best to use gsn_contour rather than gsn_csm_contour. This is b/c
; as of version  4.2.0.a028, there is an issue with the tickmarks on
; contour plots of this type of data.  

; the following two resources are required if using gsn_contour. WARNING!
; do not put these two resources in the loop. You will get an error 
; message.
  cnres@sfXArray  = LON2D
  cnres@sfYArray  = LAT2D
;**************************************
; create spaghetti plot
;**************************************
  do i=1,3
    in               = addfile(files(i),"r")
    var                = in->q
    cnres@cnLineColor  = colors(i-1)
    plot(i)            = gsn_contour(wks,var(0,18,:,:),cnres)
    overlay(plot_base,plot(i))
  end do
  draw(plot_base)
  frame(wks)
end


