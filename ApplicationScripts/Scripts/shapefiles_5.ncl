;*************************************************
; shapefiles_5.ncl
;
; Concepts illustrated:
;   - Reading shapefiles
;   - Masking a data array based on a geographical area obtained from a shapefile
;   - Using geometry and data from a shapefile to draw and label provinces and cities in Pakistan
)5
;   - Using gsn_table to create a custom legend
;
;*************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"

; ---------------------------------------------------------
; A utility function to compute the area and centroid of 
; a polygon. Returns a 1D array of length 3, as:
;   a(0) --> area
;   a(1) --> centroid X coordinate
;   a(2) --> centroid Y coordinate
; ---------------------------------------------------------
undef("calcPolygonAreaAndCentroid")
function calcPolygonAreaAndCentroid(x, y, firstVert, lastVert)
  local cY, cY, a, tmp
begin
  cX = 0.d
  cY = 0.d
  area = 0.d
  do i=firstVert,lastVert
    if (i .eq. lastVert) then
      j = firstVert
    else
      j = i + 1
    end if
    tmp = x(i)*y(j) - x(j)*y(i)
    area = area + tmp
    cX = cX + (x(i) + x(j))*tmp
    cY = cY + (y(i) + y(j))*tmp
  end do

  area = area / 2.0
  cX = cX / (6.0 * area)
  cY = cY / (6.0 * area)

  ; recall that the area calculation may yield a negative result, 
  ; depending upon CW vs. CCW ordering of the vertices.
  return (/ abs(area), cX, cY /)
end

begin
  ; -----------------------------------------------
  ; open file and read in data
  ; -----------------------------------------------
  f = addfile ("wrfout_d01_pakistan.nc", "r")

  ; -----------------------------------------------
  ; Read character variable Times; Convert to string for plots
  ; Read vertical coordinate for plot labels
  ; -----------------------------------------------
  Times = chartostring(f->Times)   ; built-in function

  ; -----------------------------------------------
  ; Read 10 meter winds
  ; -----------------------------------------------
  u       = f->U10                 ; (Time, south_north, west_east)
  v       = f->V10      
  s       = sqrt(u^2 + v^2)
  s@long_name = "Wind Speed: 10m"

  s@lat2d = f->XLAT(0,:,:)         ; direct assignment
  s@lon2d = f->XLONG(0,:,:)

  sCritical    = 6.0
  s@_FillValue = 1e20

  ; ----------------------------------------------
  ; Get the national boundary from a shapefile. 
  ; We'll use this as a mask for the data.
  ; ----------------------------------------------
  natBdry = addfile("PAK_adm0.shp", "r")
  
  maskedS = new(dimsizes(s),typeof(s),s@_FillValue)
  maskedS@lat2d = s@lat2d
  maskedS@lon2d = s@lon2d

  ; Get the size of the lat/lon grid of variable "s"
  sDims = dimsizes(s)
  iNumLat = sDims(1)
  iNumLon = sDims(2)

  ; Put data in the areas that we don't want masked.
  do j=0,iNumLat-1
    print("masking row " + j)
    do i=0,iNumLon-1
      if(gc_inout(f->XLAT(0,j,i), f->XLONG(0,j,i), natBdry->y, natBdry->x)) then 
        maskedS(:,j,i) = s(:,j,i)
      end if
    end do
  end do
  
  ; -----------------------------------------------
  ; create plots  
  ; -----------------------------------------------
  wks = gsn_open_wks("png" ,"shapefiles")                ; send graphics to PNG file

  ; We want a very specific colormap...
  cmap = (/ (/1., 1., 1./), (/ 0., 0., 0./),          \  ; background/foreground
            (/ 231./255.,  250./255.,  254./255. /),  \  ; color for ocean
            (/ 230./255.,  236./255.,  236./255. /),  \  ; color for land outside AOI
            (/ .3,         .3,         .3        /),  \  ; color for city labels
            (/ 1.,         1.,         1.        /),  \  ; colors for data mapping...
            (/ 221./255.,  184./255.,  129./255. /),  \
            (/ 254./255.,  157./255.,  014./255. /),  \
            (/ 253./255.,  075./255.,  251./255. /),  \
            (/ 116./255.,  042./255.,  253./255. /),  \
            (/ 255./255.,  001./255.,  001./255. /),  \
            (/ 034./255.,  062./255.,  255./255. /)   \
         /)
  gsn_define_colormap(wks, cmap) 

  res                       = True             ; plot mods desired
  res@gsnFrame              = False            
  res@gsnDraw               = False
  res@gsnMaximize           = True 
  res@cnFillColors          = cmap(5:,:)
  res@cnLevelSelectionMode  = "ExplicitLevels"
  res@cnLevels              = (/ 5.4, 6.2, 6.9, 7.4, 7.8, 8.6 /)
  res@cnMinLevelValF        =  5.0
  res@cnMaxLevelValF        =  10.0
  res@cnFillOn              = True             ; color plot desired
  res@cnLinesOn             = False            ; turn off contour lines
  res@cnLineLabelsOn        = False            ; turn off contour labels

  ; -----------------------------------------------
  ; Set map extent to zoom in on Pakistan
  ; -----------------------------------------------
  res@mpMinLonF = 60.
  res@mpMaxLonF = 78.
  res@mpMinLatF = 21
  res@mpMaxLatF = 39.
  res@mpGeophysicalLineColor = 1
  res@mpOceanFillColor       = 2                ; color for sea
  res@mpLandFillColor        = 3                ; color for land outside of borders
  res@mpOutlineBoundarySets  = "Geophysical"    ; draw coastlines for entire region
  res@mpGridAndLimbOn        = True
  res@mpGridLineColor        = (/ .25, .25, .25 /)
  res@mpGridLatSpacingF      = 4.0
  res@mpGridLonSpacingF      = 4.0

  ; ----------------------------------------------
  ; Turn on lat / lon labeling
  ; ----------------------------------------------
  res@pmTickMarkDisplayMode = "Always"         ; turn on tickmarks
  res@tmXTOn = False            ; turn off top   labels 
  res@tmYROn = False            ; turn off right labels
   
  ; -----------------------------------------------
  ; Loop over all times and levels ( uncomment )
  ; Demo: one arbitrarily closen time and level  
  ; -----------------------------------------------
  dims  = dimsizes(s)                          ; dimensions of x
  ntim  = dims(0)                              ; number of time steps
  klev  = dims(1)                              ; number of "bottom_top" levels

  nt    =  0
;;do nt=0,ntim-1                               ; uncomment for loop
;;  do ll=0,klev-1
       res@tiMainString  = Times(nt)
       res@lbLabelBarOn  = False
       plot    = gsn_csm_contour_map(wks,maskedS(nt,:,:),res)
;;  end do
;;end do


  ; -------------------------------------------------------------
  ; Read a second shapefile to draw the administrative boundaries
  ; -------------------------------------------------------------
  admShapes = addfile("PAK_adm1.shp", "r")
  segsDims = dimsizes(admShapes->segments)
  geomDims = dimsizes(admShapes->geometry)

  ; Read global attributes  
  geom_segIndex = admShapes@geom_segIndex
  geom_numSegs  = admShapes@geom_numSegs
  segs_xyzIndex = admShapes@segs_xyzIndex
  segs_numPnts  = admShapes@segs_numPnts

  lines       = new(segsDims(0), graphic)   ; Array to hold polygon edges
  numFeatures = geomDims(0)
  labels      = new(numFeatures, graphic)   ; Array for region labels
  segNum = 0
 
  gres = True
  gres@gsLineColor = "black"

  ; Text resources...
  tRes = True
  tRes@gsTextJustification = 4    ; CenterCenter
  tRes@txFontColor         = 1
  tRes@txFontHeightF       = 0.01

  ; Loop over the features in this shapefile and draw the administrative boundaries and
  ; label them with the name provided in the shapefile database.
  ;
  ; NOTE on labeling strategy: Posting the label at the centroid of the admin. region 
  ; is a simple approach that usually works in most cases. In this specific shapefile 
  ; the admin. regions consist of one or more polygons, and in particular, the coastal 
  ; regions have many small polygons that comprise the islands. With that in mind, we
  ; will place the label at the centroid of the polygon that has the largest area for
  ; that region.
  do feature=0, numFeatures-1  
     startSegment = admShapes->geometry(feature, geom_segIndex)
     numSegments  = admShapes->geometry(feature, geom_numSegs)
     centroidX = 0.d
     centroidY = 0.d
     area = -1.0d

     do seg=startSegment, startSegment+numSegments-1
        startPT = admShapes->segments(seg, segs_xyzIndex)
        endPT = startPT + admShapes->segments(seg, segs_numPnts) - 1
        lines(segNum) = gsn_add_polyline(wks, plot, admShapes->x(startPT:endPT),  \
                          admShapes->y(startPT:endPT), gres)
        segNum = segNum + 1

        ; find center-of-mass and area of this polygon.
        areaCenter = calcPolygonAreaAndCentroid(admShapes->x, admShapes->y, startPT, endPT)
        if (areaCenter(0) .gt. area) then
           area = areaCenter(0)
           centroidX = areaCenter(1)
           centroidY = areaCenter(2) 
        end if
     end do

     ; plot the label
     labels(feature) = gsn_add_text(wks, plot, admShapes->NAME_1(feature), centroidX, centroidY, tRes)
  end do

  ; -----------------------------------------------------------------------------------------------
  ; Use a third shapefile to plot several of the major cities. Here we hardcode the list of cities 
  ; to display, and use this list to perform a lookup into the shapefile to get the geometry.
  ; -----------------------------------------------------------------------------------------------
  citiesShapes = addfile("PAK_adm3.shp", "r")
  segsDims = dimsizes(citiesShapes->segments)
  geomDims = dimsizes(citiesShapes->geometry)
  geom_segIndex = citiesShapes@geom_segIndex
  geom_numSegs  = citiesShapes@geom_numSegs
  segs_xyzIndex = citiesShapes@segs_xyzIndex
  segs_numPnts  = citiesShapes@segs_numPnts

  ; The major cities to be plotted; the first element in each subarray is the database lookup string, 
  ; the second is the string to be used as the label on the plot.
  majorCities = (/ (/ "Karachi Central", "Karachi"     /), \
                   (/ "Lahore",          "Lahore"      /), \
                   (/ "Faisalabad",      "Faisalabad"  /), \
                   (/ "Quetta",          "Quetta"      /), \
                   (/ "Hyderabad",       "Hyderabad"   /), \
                   (/ "Islamabad",       "Islamabad"   /), \
                   (/ "Peshawar",        "Peshawar"    /)  \
                /)

  ; This array parallels "majorCities", and represents whether we want the corresponding
  ; label to be vertically offset up or down, relative to the city's marker (these values
  ; are essentially the sign of the offset; they were determined through trial-and-error).
  citiesOffset = (/ 1., 1., 1., -1., -1., -1., -1. /)

  ; get the indices of the shapefile-features corresponding to our "majorCities"
  citiesGeom = get1Dindex(citiesShapes->NAME_3, majorCities(:,0))

  numCities = dimsizes(citiesGeom)
  citiesLabels = new(numCities, graphic)
  citiesPoints = new(numCities, graphic)

  gres@gsMarkerColor = 4
  gres@gsMarkerIndex = 16
  gres@gsMarkerSizeF = 0.005

  tRes@txFontHeightF = 0.0075
  tRes@txFontColor = 4

  ; some variables used in calculating label placement...
  lblX = new(1, float)
  lblY = new(1, float)
  lblXNDC = new(1, float)
  lblYNDC = new(1, float)

  do city=0, numCities-1
     feature = citiesGeom(city)
     startSegment = citiesShapes->geometry(feature, geom_segIndex)
     numSegments  = citiesShapes->geometry(feature, geom_numSegs)

     ; Find the centroid of the feature...
     centroidX = 0.d
     centroidY = 0.d
     area = -1.0d
     do seg=startSegment, startSegment+numSegments-1
        startPT = citiesShapes->segments(seg, segs_xyzIndex)
        endPT = startPT + citiesShapes->segments(seg, segs_numPnts) - 1

        areaCenter = calcPolygonAreaAndCentroid(citiesShapes->x, citiesShapes->y, \
                     startPT, endPT)
        if (areaCenter(0) .gt. area) then
           area = areaCenter(0)
           centroidX = areaCenter(1)
           centroidY = areaCenter(2) 
        end if
     end do

     ; plot a marker at the centroid for the city, and plot a label offset either vertically 
     ; up or down from the marker (offset calculation is done in NDC space).
     citiesPoints(city) = gsn_add_polymarker(wks, plot, centroidX, centroidY, gres)
     datatondc(plot, doubletofloat(centroidX), doubletofloat(centroidY), lblXNDC, lblYNDC)
     ndctodata(plot, lblXNDC, lblYNDC+(citiesOffset(city)*0.01), lblX, lblY)
     citiesLabels(city) = gsn_add_text(wks, plot, majorCities(city, 1), lblX, lblY, tRes)
  end do

  ; finally, cause our plot to be written...    
  draw(plot)
  
  ; --------------------------------------------------------------------
  ; Draw the legend
  ; --------------------------------------------------------------------
  ulX = .618  ; anchor the positioning relative to these two variables, so that we can 
  ulY = .3    ; move the table easily.
  tblRes = True
  tblRes@gsLineColor = "black"
  tblRes@txFontHeightF = 0.01
  tblRes@gsFillColor = (/ "white" /)
  tblRes@gsLineThicknessF = 2.

  ; draw an outer table to frame it all...
  gsn_table(wks, (/ 1, 1 /), (/ ulX-.005, ulX+.255 /), (/ ulY-.21, ulY /), (/ " " /), tblRes)

  ; the title...
  tblRes@gsLineColor = "Transparent"  ; no interior grid lines
  hdr = (/ 1, 1 /)
  hdrX = (/ ulX, ulX+0.25 /)
  hdrY = (/ ulY-.025, ulY /)
  hdrText = "Wind Power Classification"
  gsn_table(wks, hdr, hdrX, hdrY, hdrText, tblRes)

  ; column headers...
  tblRes@txFontHeightF = 0.0075
  tblRes@txJust = (/ "TopCenter", "TopCenter", "TopCenter", "TopCenter" /)
  subHdr = (/ 1, 4 /)
  hdrY = (/ ulY-.065, ulY-.025 /)
  subHdrText = (/ "Wind~C~Power~C~Class", "Resource~C~Potential", \
                "Power~C~Density at~C~10m W/m~S~2~N~2", "Wind Speed~C~at 10m~C~m/s" /)
  gsn_table(wks, subHdr, hdrX, hdrY, subHdrText, tblRes)

  ; the legend body...
  tblBdy = (/ 7, 4 /)
  tblX = hdrX
  tblY = (/ ulY-.205, ulY-.065 /)
  tblText = (/ (/ "1", "  Poor",        "  0-200", "0.0-5.4" /),  \
               (/ "2", "  Marginal",    "200-300", "5.4-6.2" /),  \
               (/ "3", "  Fair",        "300-400", "6.2-6.9" /),  \
               (/ "4", "  Good",        "400-500", "6.9-7.4" /),  \
               (/ "5", "  Excellent",   "500-600", "7.4-7.8" /),  \
               (/ "6", "  Outstanding", "600-800", "7.8-8.6" /),  \
               (/ "7", "  Superb",      ">800",    ">8.6" /)      \
            /)

  delete(tblRes@txJust)
  tblRes@txJust = (/ (/ "CenterCenter", "CenterLeft", "CenterCenter", "CenterCenter" /),  \
                     (/ "CenterCenter", "CenterLeft", "CenterCenter", "CenterCenter" /),  \
                     (/ "CenterCenter", "CenterLeft", "CenterCenter", "CenterCenter" /),  \
                     (/ "CenterCenter", "CenterLeft", "CenterCenter", "CenterCenter" /),  \
                     (/ "CenterCenter", "CenterLeft", "CenterCenter", "CenterCenter" /),  \
                     (/ "CenterCenter", "CenterLeft", "CenterCenter", "CenterCenter" /),  \
                     (/ "CenterCenter", "CenterLeft", "CenterCenter", "CenterCenter" /)   \
                  /)

  delete(tblRes@gsFillColor)
  tblRes@gsFillColor = (/ (/ 0, 0, 0, 0 /), \
                          (/ 6, 0, 0, 0 /), \
                          (/ 7, 0, 0, 0 /), \
                          (/ 8, 0, 0, 0 /), \
                          (/ 9, 0, 0, 0 /), \
                          (/10, 0, 0, 0 /), \
                          (/11, 0, 0, 0 /)  \
                       /)
  gsn_table(wks, tblBdy, tblX, tblY, tblText, tblRes)

  frame(wks)
end
