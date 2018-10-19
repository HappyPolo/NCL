;----------------------------------------------------------------------
; icon_faster_5.ncl
;
; Concepts illustrated:
;   - Plotting ICON model data
;   - Using special "gsSegments" resource for faster primitive draws
;   - Contouring one-dimensional X, Y, Z data
;   - Using triangular meshes to create contours
;   - Drawing filled polygons on a map
;   - Turning on edges for polygons
;   - Using "getvalues" to retrieve resource values
;   - Attaching a custom labelbar to a map
;----------------------------------------------------------------------
; This script is identical to icon_5.ncl, except it uses some resources
; (gsSegments and gsColors) that are only available in NCL V6.2.0.
; 
; Use of these resources can significantly speed up code for plotting 
; filled polygons.  This particular example took 38.3 seconds for the 
; slow method, and 0.55 seconds for the fast method.
;----------------------------------------------------------------------
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"


;*************************************************
; Function to attach a custom label bar
;************************************************* 
undef("attach_labelbar")
function attach_labelbar(wks,map,labels,colors)
local lbres, nlevels, amres
begin

  nlevels = dimsizes(labels)

  lbres = True
  lbres@lbPerimOn            = False               ; no label bar box
  lbres@lbOrientation        = "Horizontal"        ; orientation
  lbres@vpWidthF             = 0.7                 ; width of labelbar
  lbres@vpHeightF            = 0.10                ; height of labelbar
  lbres@lbLabelFontHeightF   = 0.015               ; label font height
  lbres@lbLabelAlignment     = "InteriorEdges"     ; where to label
  lbres@lbMonoFillPattern    = True                ; fill sold
  lbres@lbFillColors         = colors
  
  lbid = gsn_create_labelbar (wks,nlevels+1,labels,lbres)

  amres                  = True
  amres@amJust           = "TopCenter"
  amres@amOrthogonalPosF = 0.6

;  amres@gsnMaximize      = True   ; Be sure to remaxmize output

  map@annoid             = gsn_add_annotation(map,lbid,amres)

  return(map)
end

;*************************************************
; Main code
;************************************************* 
begin
  start_code_time = get_cpu_time()

  DataFileName = "DIV850_hex_day9.nc"  ; input
  VarName      = "DIV"             ; variable name in the input file       

  colormap  = "testcmap"
  scale     = 1e6

  varMin = -15.  ; minimum contour level
  varMax =  15.  ; maximum contour level
  varInt =   3.  ; interval between contours

  rad2deg = get_r2d("float")    ; radians to degrees

;---------------------------------------------------------------
; read in the meteorological field and grid information
;---------------------------------------------------------------

  File = addfile( DataFileName, "r" )

  var = File->$VarName$(0,0,:)   ; dims: (time,lev,cell)
  var = var*scale

  x    = File->vlon *rad2deg   ; cell center, lon
  y    = File->vlat *rad2deg   ; cell center, lat
  vlon = File->vlon_vertices * rad2deg
  vlon = where(vlon.lt.0, vlon + 360, vlon)
  vlat = File->vlat_vertices * rad2deg
  nv   = dimsizes(vlon(0,:))   ; # of points in polygon

;---------------------------------------------------------------
; make plot
;---------------------------------------------------------------

  wks = gsn_open_wks("ps","icon_faster")

; Set up resources for contour/map plot.
  mpres                      = True

  mpres@gsnMaximize          = True
  mpres@gsnPaperOrientation  = "Portrait"

  mpres@mpLimitMode          = "LatLon"
  mpres@mpMinLatF            =   0
  mpres@mpMaxLatF            =  90
  mpres@mpMinLonF            = 120
  mpres@mpMaxLonF            = 240
  mpres@mpCenterLonF         = 180

  mpres@mpFillOn             = False

  cnres                      = mpres  ; Inherit the map resources

  cnres@sfXArray             = x  ; These are 1D arrays, so a triangular
  cnres@sfYArray             = y  ; mesh will be created internally.

  cnres@cnLinesOn            = False
  cnres@cnInfoLabelOn        = False

  cnres@cnFillOn             = True
  cnres@cnFillMode           = "rasterfill"
  cnres@cnRasterSmoothingOn  = True
  cnres@cnFillPalette        = colormap

  cnres@cnLevelSelectionMode = "ManualLevels"
  cnres@cnLevelSpacingF      = varInt
  cnres@cnMinLevelValF       = varMin
  cnres@cnMaxLevelValF       = varMax

  cnres@tiMainString         = "Filled contours"
  plot = gsn_csm_contour_map(wks,var,cnres)

;
; Retrieve the contour levels and colors used. This information
; will be used to draw the filled polygons.
;
  getvalues plot@contour
   "cnLevels"     : levels
   "cnFillColors" : colors
  end getvalues

  mpres@gsnDraw              = False   ; Just create the plot, 
  mpres@gsnFrame             = False   ; don't draw it.

  mpres@tiMainString         = "Filled hexagons with outlines"

  mpres@gsnLeftString  = var@long_name
  mpres@gsnRightString = var@units

  map = gsn_csm_map(wks,mpres)

; Attach a labelbar.
  map = attach_labelbar(wks,map,levels+"",colors)

;---Create color array for triangles
  nhex     = dimsizes(y)                  ;-- Number of hexagons
  gscolors = new(nhex,integer)
  gscolors = -1                           ;-- Initialize to transparent

; Set up a resource list for the polygons.
  pres             = True
  pres@gsEdgesOn   = True   ; Turn on edges
  pres@gsFillIndex = 0      ; Solid fill, the default

; First attach the polygons associated with the lowest level.
  vind = ind(var .lt. levels(0))
  if(.not.all(ismissing(vind))) then
    gscolors(vind) = colors(0)
    nhex_tot = dimsizes(vind)
    print ("finished level 0 -- " + dimsizes(vind) + " polygons considered")
  end if

;---All hexagons inbetween levels
  nlevels = dimsizes(levels)
  do i = 1, nlevels-1
    vind := ind(var .ge. levels(i-1) .and. var .lt. levels(i))
    if(.not.all(ismissing(vind))) then
      gscolors(vind) = colors(i)
      nhex_tot = nhex_tot + dimsizes(vind)
      print ("finished level " + i + "  -- " + dimsizes(vind) + \
           " polygons considered")
    end if
  end do

;---All hexagons higher than highest level
  vind := ind(var .ge. levels(nlevels-1))
  if(.not.all(ismissing(vind))) then
    gscolors(vind) = colors(dimsizes(levels)-1)
    nhex_tot = nhex_tot + dimsizes(vind)
    print ("finished level " + nlevels + " -- " + dimsizes(vind) + \
           " polygons considered")
  end if

  pres@gsColors   = gscolors
  pres@gsSegments = ispan(0,dimsizes(var) * 6,6)  ; hexagon --> 6 sides

  gsid = gsn_add_polygon(wks,map,ndtooned(vlon),ndtooned(vlat),pres)

;---Drawing the map will draw map, attached polygons, and attached labelbar
  draw(map)
  frame(wks)

  end_code_time = get_cpu_time()
  print("--> Elapsed time in CPU seconds: " + (end_code_time-start_code_time))
end

