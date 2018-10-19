;*************************************************
; conOncon_9.ncl
;
; Concepts illustrated:
;   - Overlaying three sets of contours on a map
;   - Creating a color map using RGB triplets
;   - Drawing three sets of contours each with different grid resolutions
;   - Overlaying contours on a map using two-dimensional lat,lon arrays
;   - Turning on map tickmarks for a Lambert Conformal map
;   - Zooming in on a particular area on a Lambert Conformal map
;   - Drawing boxes on a map using gsn_polyline_ndc
;   - Changing the thickness of polylines
;
; This plot was originally created in PyNGL by Ufuk Utku
; Turuncoglu of the  Istanbul Technical University in
; relation to a Turkey Climate Change Scenarios project.
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
; Open NetCDF files.
  m1 = addfile("./mm5_d1.nc", "r")
  m2 = addfile("./mm5_d2.nc", "r")
  m3 = addfile("./mm5_d3.nc", "r")

; Read first (and only) timestep of data to contour.
  m1t = m1->TERRAIN(0,:,:)     ; Coarse dataset
  m2t = m2->TERRAIN(0,:,:)     ; Finer resolution
  m3t = m3->TERRAIN(0,:,:)     ; Finest resolution

; Read lat/lon coordinates for each dataset.
  m1lat = m1->lat
  m1lon = m1->lon
  m2lat = m2->lat
  m2lon = m2->lon
  m3lat = m3->lat
  m3lon = m3->lon

  wks = gsn_open_wks("png", "conOncon")  ; send graphics to PNG file

; Define and set color map.
  cmap = (/(/181,255,181/),(/140,230,132/), \
           (/ 99,206, 99/),(/ 74,181, 66/),(/ 41,148, 41/),(/ 25,123, 16/), \
           (/  0, 99,  0/),(/ 66, 82,  0/),(/ 90, 99,  0/),(/107,107,  0/), \
           (/132,132,  0/),(/148,148,  0/),(/165,165,  0/),(/189,189,  0/), \
           (/214,214,  0/),(/230,230,  0/),(/255,255,  0/),(/255,255,123/), \
           (/239,230, 99/),(/222,206, 82/),(/197,173, 66/),(/181,148, 49/), \
           (/165,115, 33/),(/148, 90, 16/),(/132, 66,  8/),(/ 99, 58,  0/), \
           (/ 74, 41,  0/)/)/255.0

; Set some contouring resources.
  cnres                 = True
  cnres@gsnDraw         = False   ; Don't draw plot (will do later)
  cnres@gsnFrame        = False   ; Don't advance framce  (will do later)
  cnres@gsnMaximize     = True    ; Maximize plot in frame

  cnres@cnInfoLabelOn   = False   ; Turn off annotations
  cnres@cnFillPalette   = cmap    ; set color map
  cnres@gsnLeftString   = ""
  cnres@gsnCenterString = ""
  cnres@gsnRightString  = ""
  cnres@tiXAxisString   = ""
  cnres@tiYAxisString   = ""

; Set contour resources
  cnres@cnLinesOn       = False
  cnres@cnLineLabelsOn  = False
  cnres@cnInfoLabelOn   = False

  cnres@cnFillOn        = True
  cnres@cnFillMode      = "AreaFill"    ; This is the default.
;  cnres@cnFillMode     = "RasterFill"
  cnres@lbOrientation   = "Vertical"

; Set contour levels.
  cnres@cnLevelSelectionMode = "ExplicitLevels"
  cnres@cnLevels             = (/0, 10, 25, 50, 75, 125, 200, 350, 500, 750, \
                                1000, 1250, 1500, 1750, 2000, 2250, 3000/)

  res = cnres   ; Copy contour resources for 1st plot.

; Add map resources
  res@mpProjection          = "LambertConformal"  
  res@mpDataBaseVersion     = "MediumRes"          ; Default is LowRes
  res@mpOutlineDrawOrder    = "PostDraw"           ; Draw map outlines last
  res@mpGridAndLimbOn       = False                ; Turn off lat/lon lines
  res@pmTickMarkDisplayMode = "Always"             ; Turn on map tickmarks
  res@cnSpanFillPalette     = False                ; Use partial color map
 
  dims = dimsizes(m1t)
  r    = dimsizes(dims)
  r1   = dims(r-1)
  r2   = dims(r-2)

  res@mpLimitMode        = "Corners"            ; Portion of map to zoom
  res@mpLeftCornerLatF   = m1lat(0,r1-1)        ; in on.
  res@mpLeftCornerLonF   = m1lon(0,r1-1)
  res@mpRightCornerLatF  = m1lat(r2-1,0)
  res@mpRightCornerLonF  = m1lon(r2-1,0)

  res@mpLambertParallel1F = 30.
  res@mpLambertParallel2F = 60.
  res@mpLambertMeridianF  = 26.

  m1t@lat2d = m1lat    ; Special method for setting 2D lat/lon coords
  m1t@lon2d = m1lon

; Create 1st set of contours (coarsest resolution) over a map
  map = gsn_csm_contour_map(wks, m1t, res)
  
  res2              = cnres  ; Copy contour resources.
  res2@lbLabelBarOn = False  ; Labelbar already created in 1st plot  
  res2@gsnMaximize  = False  ; Use maximization from original plot

  m2t@lat2d = m2lat    ; Special method for setting 2D lat/lon coords
  m2t@lon2d = m2lon

; Create 2nd set of contours (medium resolution)
  plot2 = gsn_csm_contour(wks, m2t, res2)

  res3              = cnres  ; Copy contour resources.
  res3@gsnMaximize  = False  ; Use maximization from original plot
  res3@lbLabelBarOn = False  ; Labelbar already created in 1st plot  

  m3t@lat2d = m3lat    ; Special method for setting 2D lat/lon coords
  m3t@lon2d = m3lon

; Create 3rd set of contours (finest resolution)
  plot3 = gsn_csm_contour(wks, m3t, res3)

; Overlay 2nd and 3rd contour plots on original map/contour plot
  overlay(map, plot2)
  overlay(map, plot3)

; Draw map and the three contour plots.
  draw(map)

; 
; This section is to draw some polylines delineating the
; area on the map of the three datasets.
;

; Set some polyline resources.
  lnres                   = True
  lnres@gsLineThicknessF  = 1.5

; Add some boxes to the map, showing the two finer-resolution
; map areas.
  dims = dimsizes(m2t)
  r2   = dimsizes(dims)
  r21  = dims(r2-1)
  r22  = dims(r2-2)

  xbox = (/m2lon(0,0),m2lon(0,r21-1),m2lon(r22-1,r21-1), \
           m2lon(r22-1,0),m2lon(0,0)/)
  ybox = (/m2lat(0,0),m2lat(0,r21-1),m2lat(r22-1,r21-1), \
           m2lat(r22-1,0),m2lat(0,0)/)

  x_out = new(dimsizes(xbox),typeof(xbox))
  y_out = new(dimsizes(ybox),typeof(ybox))

; Can't use gsn_polyline here, because will get curved box lines.
  datatondc(map, xbox, ybox, x_out, y_out)
  gsn_polyline_ndc(wks, x_out, y_out, lnres)

  dims = dimsizes(m3t)
  r3   = dimsizes(dims)
  r31  = dims(r3-1)
  r32  = dims(r3-2)

  xbox = (/m3lon(0,0),m3lon(0,r31-1),m3lon(r32-1,r31-1), \
           m3lon(r32-1,0),m3lon(0,0)/)
  ybox = (/m3lat(0,0),m3lat(0,r31-1),m3lat(r32-1,r31-1), \
           m3lat(r32-1,0),m3lat(0,0)/)

  datatondc(map, xbox, ybox, x_out, y_out)
  gsn_polyline_ndc(wks, x_out, y_out, lnres)

; Now advance the frame.
  frame(wks)

end
