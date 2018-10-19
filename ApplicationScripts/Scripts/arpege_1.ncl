;*************************************************
; arpege_1.ncl           
;
; Concepts illustrated:
;   - Contouring an ARPEGE grid
;   - Contouring one-dimensional X, Y, Z data
;   - Drawing filled contours over a Lambert Equal Area map
;   - Drawing raster contours
;   - Smoothing raster contours
;   - Drawing a map using the medium resolution map outlines
;   - Zooming in on a particular area on a Lambert Equal Area map
;======================================================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;
; This particular example shows how to contour an ARPEGE grid. This
; particular one cam from Christophe Cassou. An organization that
; seems to use these grids is Meteo-France.
; 
; This grid is similar to the ISCCP grid, but with somewhat finer
; resolution. See:
; 
; http://www.ncl.ucar.edu/Document/Graphics/contour_grids.shtml#ISCCP
;
; Also, the grid is rotated with respect to the globe so as
; to put its poles somewhere other than at the North and South Pole.

begin
  f = addfile("IBF_1m_000101_002012_SUTOPRSU.nc","r")
  g = addfile("arpege_grd.nc","r")

  wks = gsn_open_wks("png","arpege")                ; send graphics to PNG file

  cnres                       = True
  cnres@gsnMaximize           = True    ; Maximize plot in frame

;
; Data comes in as lat, lon, data triplets, so we need to set the
; sfXArray/sfYArray resources to the lon/lat values, and then we'll
; pass the data values directly into the plotting function below.
;
  cnres@sfXArray              = g->bt42_lon(0,:)
  cnres@sfYArray              = g->bt42_lat(0,:) 

  cnres@cnFillOn              = True
  cnres@cnFillMode            = "RasterFill"    ; Use smooth raster contours
  cnres@cnFillPalette         = "BlAqGrYeOrReVi200" ; set color map
  cnres@cnRasterSmoothingOn   = True

  cnres@cnLinesOn             = False

  cnres@cnLevelSelectionMode  = "ManualLevels"      ; Set the contour levels.
  cnres@cnMinLevelValF        =  0.0
  cnres@cnMaxLevelValF        = 30.0
  cnres@cnLevelSpacingF       =  0.15

  cnres@lbBoxLinesOn          = False    ; No labelbar box lines.

  mpres = cnres                          ; Make copy of the resource
                                         ; list up to this point.
;
; If you want the contour plot drawn here, then comment the 
; settings for gsnDraw and gsnFrame below
;
  cnres@gsnDraw               = False
  cnres@gsnFrame              = False

  contour = gsn_csm_contour(wks,f->SUTOPRSU(0,0,:),cnres)

;
; Retrieve the endpoint lat/lon values of the data,  and use these
; to define the corners of the map to view.
;
  getvalues contour@data
    "sfXCActualStartF" : xs
    "sfXCActualEndF"   : xe
    "sfYCActualStartF" : ys
    "sfYCActualEndF"   : ye
  end getvalues

  mpres@mpDataBaseVersion = "MediumRes"     ; Medium resolution for outlines.

  mpres@mpProjection      = "LambertEqualArea"
  mpres@mpCenterLatF      = 90
  mpres@mpCenterLonF      =  0

  mpres@mpLimitMode       = "LatLon"   ; Zoom in on smaller map area.
  mpres@mpMinLonF         = xs
  mpres@mpMaxLonF         = xe
  mpres@mpMinLatF         = ys
  mpres@mpMaxLatF         = ye

  mpres@mpPerimOn         = False

;
; If you want to generate a plot at each time step, then put
; this code inside a loop:
;
;  do i = 0, dimsizes(f->time_counter) -1
;    print("time counter = " + f->time_counter(i))
;    ...
;  end do
;
; Only do one time step here.
;
  i = 0

  mpres@gsnRightString = ""     ; Make sure the right and left
  mpres@gsnLeftString  = ""     ; sub strings are not drawn.

  mpres@tiMainString = f->SUTOPRSU@long_name + "at timestep " + \
                       f->time_counter(i)

  map = gsn_csm_contour_map(wks,f->SUTOPRSU(i,0,:),mpres)

end
