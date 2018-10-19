;*************************************************
; icon_4.ncl
;
; Concepts illustrated:
;   - Plotting ICON model data
;   - Contouring one-dimensional X, Y, Z data
;   - Using triangular meshes to create contours
;   - Attaching filled polygons to a map
;   - Attaching a custom labelbar to a map
;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

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
  map@annoid = gsn_add_annotation(map,lbid,amres)

  return(map)
end

;*************************************************
; Main code
;************************************************* 
begin
  scale   = 1e6
  rad2deg = get_r2d(scale)     ; radians to degrees

  File = addfile("MRWB4N5_DOM01_R2B04L31_0001.nc", "r" )

  var = File->DIV(1,0,:)   ; dims: (time,lev,cell)
  var = var*scale

  x    = File->clon *rad2deg   ; cell center, lon
  y    = File->clat *rad2deg   ; cell center, lat
  vlat = File->clat_vertices * rad2deg
  vlon = File->clon_vertices * rad2deg
  vlon = where(vlon.lt.0, vlon + 360, vlon)

;
; Start the graphics.
;
  wks = gsn_open_wks("ps","icon")
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

; Set resources for a map plot.
  mpres                = True
  mpres@gsnMaximize    = True 
  mpres@mpFillOn       = False

  mpres@mpCenterLonF   = 180
  mpres@mpMinLonF      =   0.
  mpres@mpMaxLonF      = 360.
  mpres@mpMinLatF      = -90.
  mpres@mpMaxLatF      =  90.

; Set resources for a map plot.
  cnres                 = mpres    ; Inherit all the map resources
  cnres@gsnSpreadColors = True
  cnres@cnFillOn        = True
  cnres@cnLinesOn       = False
  cnres@sfXArray        = x   ; These are 1D arrays, so a triangular mesh
  cnres@sfYArray        = y   ; will be used to create the contours.

; Draw the contour/map plot.
  contour = gsn_csm_contour_map(wks,var,cnres)

;
; Retrieve the levels and colors so we can use them later for
; the filled triangles. We could also create levels and
; colors ourselves.
;
  getvalues contour@contour
    "cnLevels"     : levels
    "cnFillColors" : colors
  end getvalues
  nlevels = dimsizes(levels)

; Create the map, but don't draw it yet.

  mpres@gsnLeftString  = "divergence"
  mpres@gsnRightString = "1/s"

  mpres@gsnDraw        = False
  mpres@gsnFrame       = False

  map = gsn_csm_map(wks,mpres)

; Attach a labelbar. 
  map = attach_labelbar(wks,map,levels+"",colors)

; Set up a resource list for the polygons.
  pres             = True
; pres@gsEdgesOn   = True   ; Turn on edges
  pres@gsFillIndex = 0      ; Solid fill, the default

; First attach the triangles associated with the lowest level.
  vlow = ind(var .lt. levels(0))
  do i = 0, dimsizes(vlow)-1
    pres@gsFillColor = colors(0)
    varstring = unique_string("gon")
    map@$varstring$ = gsn_add_polygon(wks,map,vlon(vlow(i),:), \
                                              vlat(vlow(i),:),pres)
  end do

  print ("finished level 0 -- " + dimsizes(vlow) + " triangles considered")
  delete(vlow)

; Now attach the triangles associated with the middle levels.
  eps = 300.
  do i = 0, nlevels -2
    vind = ind(var .ge. levels(i) .and. var .lt. levels(i+1))
    do j = 0, dimsizes(vind)-1
      pres@gsFillColor = colors(i+1)

; This is a special test to make sure we don't get a triangle
; that wraps around.
      f = (/ (fabs(vlon(vind(j),0) - vlon(vind(j),1))), \
             (fabs(vlon(vind(j),2) - vlon(vind(j),1))), \
             (fabs(vlon(vind(j),0) - vlon(vind(j),2)))/)
      if (any(f.gt.eps)) then
; Fix vlon(vind(j),:) so it doesn't wrap around
        vlon(vind(j),:) = where(vlon(vind(j),:).gt.180, vlon(vind(j),:)-360, \
                                vlon(vind(j),:))
      end if
      varstring = unique_string("gon")
      map@$varstring$ = gsn_add_polygon(wks,map,vlon(vind(j),:), \
                                                vlat(vind(j),:),pres)
    end do
    print ("finished level " + (i+1) + "  -- " + dimsizes(vind) + \
           " triangles considered")
    delete(vind)
  end do

; Finally attach the triangles associated with the highest level.
  vhgh = ind(var .ge. levels(nlevels-1))
  do i = 0, dimsizes(vhgh)-1
    pres@gsFillColor = colors(nlevels)
    varstring = unique_string("gon")
    map@$varstring$ = gsn_add_polygon(wks,map,vlon(vhgh(i),:), \
                                              vlat(vhgh(i),:),pres)
  end do

  print ("finished level " + nlevels + " -- " + dimsizes(vhgh) + \
         " triangles considered")
  delete(vhgh)

  draw(map)    ; Draw everything.
  frame(wks)   ; Advance the frame
end

