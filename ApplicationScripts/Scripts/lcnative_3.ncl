;*******************************************************
; lcnative_3.ncl
;*******************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
begin
;************************************************
; open file and read in data
;************************************************
  fili  = "ruc2.bgrb.20020418.i12.f00.grb"
  f     = addfile (fili, "r")

  vpt       = f->VPTMP_252_HYBL     
  lat2d     = f->gridlat_252  
  lon2d     = f->gridlon_252  
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","lcnative")      ; send graphics to PNG file

  res                   = True              ; plot mods desired
  res@tiMainString      = "Native Lambert Conformal"
;************************************************
; lambert conformal projections are limited using
; the corners method rather than the latlon method
; seen for cylindrical equidistant projections
;************************************************
  res@mpLimitMode       = "Corners"         ; choose range of map
  res@mpLeftCornerLatF  = lat2d@corners(0)
  res@mpLeftCornerLonF  = lon2d@corners(0)
  res@mpRightCornerLatF = lat2d@corners(2)
  res@mpRightCornerLonF = lon2d@corners(2)
;************************************************
; there are many instances when you may not know the
; appropriate parallels. Here is a method to find out...
; 1) as a first guess, start with the parellels in the 
;    center of the grid.
; 2) look at the lines plotted on the map (see below). 
;    you know the projection is correct when the red
;    and blue lines form a right angle between themselves
;    and the boundary. 
; 3) iterate as necessary to get the closest solution.
;************************************************
  res@mpProjection          = "LambertConformal"
  
  res@mpLambertParallel1F = (max(lat2d)+min(lat2d))*0.5
  res@mpLambertParallel2F = (max(lat2d)+min(lat2d))*0.5
  res@mpLambertMeridianF  = (max(lon2d)+min(lon2d))*0.5
;************************************************
  res@pmTickMarkDisplayMode = "Always"
  res@mpFillOn              =  False           ; turn off map fill
  res@mpOutlineDrawOrder    = "PostDraw"       ; draw continental outline last
  res@mpOutlineBoundarySets = "GeophysicalAndUSStates" ; state boundaries
;****************************************************************************
; usually, when data is placed onto a map, it is TRANSFORMED to the specified
; projection. Since this model is already on a native lambert conformal grid,
; we want to turn OFF the tranformation.
;****************************************************************************
  res@tfDoNDCOverlay = True
;****************************************************************************
  res@cnFillOn              = True            ; color plot desired
  res@cnLinesOn             = False           ; turn off contour lines
  res@cnFillPalette         = "gui_default"   ; set color map
  res@gsnAddCyclic          = False           ; regional data 
  res@gsnFrame              = False           ; don't advance frame yet

  plot = gsn_csm_contour_map(wks,vpt(9,:,:),res) ; draw plot
;****************************************************************************
; add lines that help determine correct projection
;****************************************************************************
  dims  = dimsizes(vpt)                       ; get dimension of grid
  nlat  = dims(1)
  nlon  = dims(2)
  
  gres                  = True                ; polyline mods desired
  gres@gsLineThicknessF = 3.0                 ; line thickness
  gres@gsLineColor      = "Red"               ; line color 
  gsn_polyline (wks, plot, lon2d(nlat/2,:), lat2d(nlat/2,:), gres)
  
  gres@gsLineColor      = "Blue" 
  gsn_polyline (wks, plot, lon2d(:,nlon/2), lat2d(:,nlon/2), gres)
  
  gres@gsLineColor      = "Black" 
  gsn_polyline (wks, plot, lon2d(:,0)     , lat2d(:,0), gres)
  gsn_polyline (wks, plot, lon2d(:,nlon-1), lat2d(:,nlon-1), gres)
  gsn_polyline (wks, plot, lon2d(0,:)     , lat2d(0,:), gres)
  gsn_polyline (wks, plot, lon2d(nlat-1,:), lat2d(nlat-1,:), gres)

  frame(wks)

end
