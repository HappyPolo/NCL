;***********************************************
; raster_3.ncl
;
; Concepts illustrated:
;   - Drawing raster contours over a lambert conformal map
;   - Creating a vegetation plot using raster contours
;   - Drawing map outlines in red
;   - Moving the subtitles up
;   - Changing the map grid lines to dashed lines
;   - Overlaying contours on a map using two-dimensional lat,lon arrays
;   - Zooming in on a particular area on a Lambert Conformal map
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

begin
  ff = addfile("fh.0000_tl.press_gr.egrdsf.partial.nc","r")

  veg       = ff->VGTYP_96_SFC
  veg@lat2d = ff->gridlat_96
  veg@lon2d = ff->gridlon_96

  wks = gsn_open_wks("png","raster")         ; Open a workstation.

  res                 = True                ; Plot mods desired.

  res@gsnMaximize     = True                ; Maximize plot in frame.

  res@gsnStringFontHeightF         = 0.013
  res@gsnRightStringOrthogonalPosF = 0.02
  res@gsnLeftStringOrthogonalPosF  = 0.02

  res@cnFillOn        = True               ; Color plot desired.
  res@cnLinesOn       = False              ; Turn off contour lines      .
  res@cnLineLabelsOn  = False              ; Turn off contour labels.

  res@mpProjection           = "LambertConformal"
  res@mpLambertParallel1F    = 33.0                ; two parallels
  res@mpLambertParallel2F    = 45.0
  res@mpLambertMeridianF     = -95.0               ; central meridian
  res@mpLimitMode            = "LatLon"

  res@mpMinLatF              = 24.0                ; map area
  res@mpMaxLatF              = 50.0                ; latitudes
  res@mpMinLonF              = -125.0              ; and
  res@mpMaxLonF              = -65.0               ; longitudes

  res@cnInfoLabelOn       = False           ; Turn off info label.

  res@mpGeophysicalLineColor = "red"     ; color of continental outlines
  res@mpUSStateLineColor     = "red" 
  res@mpGridLineDashPattern  = 2         ; lat/lon lines as dashed
  res@mpOutlineBoundarySets  = "GeophysicalAndUSStates" 

  res@pmTickMarkDisplayMode = "Always"       ; Turn on map tickmarks.

  cmap = read_colormap_file("BlAqGrYeOrRe")   ; 100 colors
  res@cnFillPalette        = cmap(16:,:)
  res@cnFillMode           = "RasterFill"
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       = 0.0              ; min contour level
  res@cnMaxLevelValF       = 14.0             ; max contour level
  res@cnLevelSpacingF      = 1.0              ; contour spacing

  res@pmLabelBarWidthF     = 0.6
  res@lbLabelFontHeightF   = 0.013
  res@lbLabelStride        = 2
  res@lbBoxLinesOn         = False

  map = gsn_csm_contour_map(wks,veg,res) 

end
