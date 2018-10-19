load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  albedo_filename      = "albedo_a.nc"
  albedo_grid_filename = "albedo_a_curvelinear.nc"

  f1 = addfile(albedo_filename,"r")
  f2 = addfile(albedo_grid_filename,"r")
  
;---Variable to plot
  sbt = f1->var242     

;---Needed for getting the projection parameters in plot.
  lat2d          = f2->lat
  lon2d          = f2->lon
  north_pole_lat = f1->rotated_pole@grid_north_pole_latitude   ; 6.55
  north_pole_lon = f1->rotated_pole@grid_north_pole_longitude  ; 0.0

  nlat  = dimsizes(lat2d(:,0))
  nlon  = dimsizes(lon2d(0,:))

;---Start the graphics section
  wks  = gsn_open_wks("png", "albedo_native")

  res                        = True             ; plot mods desired

  res@gsnMaximize            = True             ; maxmize plot in frame

  res@cnFillOn               = True             ; turn on color 
  res@cnLinesOn              = False            ; no contour lines
  res@cnLineLabelsOn         = False            ; no contour labels
  res@cnFillPalette          = "BlGrYeOrReVi200"
  res@lbOrientation          = "Vertical"       ; vertical labelbar
  res@pmLabelBarOrthogonalPosF = 0.18        ; move lbar away from plot

  res@mpDataBaseVersion      = "MediumRes"      ; use finer database
  res@pmTickMarkDisplayMode  = "always"

  res@gsnAddCyclic           = False

;
; Setting tfDoNDCOverlay to True means you have specified the
; exact projection that your data is on, and thus no data
; transformation takes place when the contours are overlaid
; on the map.
; 
  res@tfDoNDCOverlay         = True

  res@mpLimitMode            = "Corners"
  res@mpLeftCornerLatF       = lat2d(0,nlon-1)      
  res@mpLeftCornerLonF       = lon2d(0,nlon-1)
  res@mpRightCornerLatF      = lat2d(nlat-1,0) 
  res@mpRightCornerLonF      = lon2d(nlat-1,0) 

  res@tiMainString           = albedo_filename + " (var242)"

  res@mpCenterLatF           = 90 - north_pole_lat  ; north_pole_lat=6.55
  res@mpCenterLonF           = 180 + north_pole_lon ; north_pole_lon=0
  
  plot = gsn_csm_contour_map (wks,sbt(0,0,:,:),res)    ; Draw plot

end 
