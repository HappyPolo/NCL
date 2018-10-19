;======================================================================
; datagrid_8.ncl
;
; Concepts illustrated:
;   - Drawing a lat/lon curvilinear grid using gsn_coordinates
;   - Using a lat/lon grid to help determine correct lambert conformal parameters
;======================================================================
; This example is based on example lcnative_1.ncl, where the two
; lambert parallels were unknown. Somebody had guessed at the values,
; but the res@mpLambertParallel1F value of 30 was not quite right.
; We used gsn_coordinates to loop through small changes in this value
; to see when the grid "straightened" out. This means we likely have our
; parallels correct.
;======================================================================
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
;======================================================================

begin
;--------------------------------------------------
; Open file and read in data. The arrays
; are dimensioned (time x xcoord x ycoord)
; (time x lon x lon), so we must reorder
; to (time x ycoord x xcoord).
;--------------------------------------------------
  f     = addfile ("pre.8912.mon.nc", "r")
  p     = f->pre(time|:,ycoord|:,xcoord|:)
  lat2d = f->lat(ycoord|:,xcoord|:)
  lon2d = f->lon(ycoord|:,xcoord|:)

;--------------------------------------------------
; get some parameters
;--------------------------------------------------
  nlat = dimsizes(lat2d(:,0))
  nlon = dimsizes(lat2d(0,:))
;--------------------------------------------------
; create plot
;--------------------------------------------------
  wks  = gsn_open_wks ("png", "datagrid")         ; open workstation
  cmap = read_colormap_file("gui_default")        ; so we can subset later

  res                        = True               ; plot mods desired
  res@gsnMaximize            = True
  res@gsnDraw                = False              ; want to add lat/lon
  res@gsnFrame               = False              ; grid later

  res@cnFillOn               = True               ; color fill  
  res@cnFillPalette          = cmap(2:,:)         ; subset the color map
  res@cnFillOpacityF         = 0.25               ; make filled contours mostly opaque
  res@cnLinesOn              = False              ; no contour lines
  res@cnLineLabelsOn         = False              ; no contour labels
  res@cnInfoLabelOn          = False              ; no contour info label

  res@lbOrientation          = "vertical"
  res@lbLabelFontHeightF     = 0.01  
  
  res@mpDataBaseVersion      = "MediumRes"        ; better map outlines
  res@pmTickMarkDisplayMode  = "Always"           ; turn on tickmarks
  res@tmXBLabelFontHeightF   = 0.01
  res@tmYLLabelFontHeightF   = 0.01  

  res@tiMainFont             = "helvetica"        ; default is helvetica-bold
  
  res@gsnAddCyclic           = False              ; regional data
  res@gsnRightString         = ""                 ; don't care about these for now b/c
  res@gsnLeftString          = ""                 ; just trying to get projection right  
;
; Tell NCL to not project the data onto the map, because we going to 
; supply the map projection parameters ourselves.
;  
  res@tfDoNDCOverlay         = True

  res@mpLimitMode            = "Corners"          ; choose region of map
  res@mpLeftCornerLatF       = lat2d(0,0)
  res@mpLeftCornerLonF       = lon2d(0,0)
  res@mpRightCornerLatF      = lat2d(nlat-1,nlon-1)
  res@mpRightCornerLonF      = lon2d(nlat-1,nlon-1)

;
; Since the meridian and parallel information is not available
; on the script, the three values were guessed at here.  Originally,
; a value of 30 was being used for mpLambertParallel1F, but this
; didn't look quite right when you draw the lat/lon grid with
; gsn_coordinates. So, we wrote a do loop to try slightly different
; values for this resource, and it looks like a value of 35 is the best one.
;
  res@mpProjection           = "LambertConformal"
  res@mpLambertParallel2F    = 55.
  res@mpLambertMeridianF     = 45.

;---Set up resources for drawing the lat/lon grid.
  lnres = True
  lnres@gsnCoordsAsLines = True
  lnres@gsnCoordsLat     = lat2d
  lnres@gsnCoordsLon     = lon2d

  lnres@gsLineColor      = "DarkViolet"   ; Setting these two resources helps you 
  lnres@gsLineThicknessF = 5.             ; see if lat/lon lines are straight.
;
; Loop through possible values for mpLambertParallel1F. Note the
; purple grid lines and whether they are slightly off at the plot's 
; boundaries. The value of 36 seems to be the best fit.
;
  lp = ispan(34,38,1)
  do np=0,dimsizes(lp)-1
    res@mpLambertParallel1F = lp(np)
    res@tiMainString        = "res@mpLambertParallel1F = " + lp(np)
    plot = gsn_csm_contour_map(wks,p(0,:,:),res)     ; Create contours over a map.
    gsn_coordinates(wks,plot,p(0,:,:),lnres)         ; Add lat/lon lines and draw.
  end do
end
