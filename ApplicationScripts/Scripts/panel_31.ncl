;----------------------------------------------------------------------
; panel_31.ncl
;
; Concepts illustrated:
;   - Overlaying vectors on a topographic map
;   - Paneling 8 vector/map plots on a page
;   - Recreating a jpeg topographic image as an NCL map object
;   - Zooming in on a jpeg image
;   - Changing the length of the smallest vector as a fraction of the reference vector
;   - Turning on the vector reference annotation label for one plot
;   - Moving the vector reference annotation to the bottom outside-right of the plot
;   - Drawing curly vectors
;   - Increasing the thickness of vectors
;   - Increasing the size of the reference vector box
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    

;----------------------------------------------------------------------
; This function imports a JPEG image that's on the whole globe,
; and recreates it as an NCL map object that is zoomed in on the
; southern tip of Africa.
;----------------------------------------------------------------------
undef("recreate_jpeg_image")
function recreate_jpeg_image(wks,minlat,maxlat,minlon,maxlon)
begin
  orig_jpg_filename = "EarthMap_2500x1250.jpg"
  nc_filename       = "EarthMap_2500x1250.nc"

;--You could use a system call to do the NetCDF conversion
;  cmd = "gdal_translate -ot Int16 -of netCDF " + jpeg_filename + \
;         " " + nc_filename)
;  system(cmd)

;---Read the three bands of data
  f     = addfile(nc_filename,"r")
  Band1 = where(f->Band1.gt.255, 255, f->Band1)  ; red channel
  Band2 = where(f->Band2.gt.255, 255, f->Band2)  ; green channel
  Band3 = where(f->Band3.gt.255, 255, f->Band3)  ; blue channel

  band_dims = dimsizes(Band3)
  nlat      = band_dims(0)
  nlon      = band_dims(1)
  print("dimensions of image = " + nlat + " x " + nlon)

;
; Add lat/lon data so we can overlay on a map, and/or 
; overlay contours. We know the image is global,
; cylindrical equidistant, and centered about lon=0.
;
  lat       = fspan( -90, 90,nlat)
  lon       = fspan(-180,180,nlon)
  lat@units = "degrees_north"
  lon@units = "degrees_east"

  Band1!0   = "lat"
  Band1!1   = "lon"
  Band2!0   = "lat"
  Band2!1   = "lon"
  Band3!0   = "lat"
  Band3!1   = "lon"
  Band1&lat = lat
  Band1&lon = lon
  Band2&lat = lat
  Band2&lon = lon
  Band3&lat = lat
  Band3&lon = lon

  res                 = True

;  res@gsnMaximize     = True

  res@gsnFrame        = False        ; Don't draw or advance
  res@gsnDraw         = False        ; frame yet.

  res@cnFillOn        = True         
  res@cnFillMode      = "RasterFill" ; Raster fill can be faster

  res@cnLevelSelectionMode  = "EqualSpacedLevels"
  res@cnMaxLevelCount       = 254  
  res@cnFillBackgroundColor = (/ 1., 1., 1., 1./)

  res@cnLinesOn       = False              ; Turn off contour lines      .
  res@cnLineLabelsOn  = False              ; Turn off contour labels
  res@cnInfoLabelOn   = False              ; Turn off info label
  res@lbLabelBarOn    = False              ; Turn off labelbar
  res@gsnRightString  = ""                 ; Turn off subtitles
  res@gsnLeftString   = ""
  res@pmTickMarkDisplayMode = "Always"

;---Construct RGBA colormaps...
  ramp   = fspan(0., 1., 255)
  reds   = new((/255, 4/), float)
  greens = new((/255, 4/), float)
  blues  = new((/255, 4/), float)

  reds   = 0
  greens = 0
  blues  = 0

  reds(:,0)   = ramp
  greens(:,1) = ramp
  blues(:,2)  = ramp

  ; The red contour map is plotted fully opaque; the green and blue
  ; are plotted completely transparent. When overlain, the colors 
  ; combine (rather magically).
  reds(:,3)   = 1.
  greens(:,3) = 0 
  blues(:,3)  = 0

  res@cnFillColors = greens 
  greenMap = gsn_csm_contour(wks, Band2, res) 

  res@cnFillColors = blues
  blueMap = gsn_csm_contour(wks, Band3, res) 
 
;---This will be our base, so make it a map plot.
  res@cnFillColors             = reds 
  res@gsnAddCyclic             = False

  res@mpFillOn                 = False  
  res@mpDataBaseVersion        = "MediumRes"

;---Zoom in on area of interest
  res@mpMinLatF                = minlat
  res@mpMaxLatF                = maxlat
  res@mpMinLonF                = minlon
  res@mpMaxLonF                = maxlon

 redMap = gsn_csm_contour_map(wks, Band1, res) 

;---Overlay everything to create the topo map
  overlay(redMap, greenMap)
  overlay(redMap, blueMap)

  return(redMap)
end

;----------------------------------------------------------------------
; This function creates a basic NCL map object. This is faster
; than creating a topographic map, so it can be used for
; debugging purposes, until you are ready to draw the vectors
; over a topo map.
;----------------------------------------------------------------------
undef("create_regular_map")
function create_regular_map(wks,minlat,maxlat,minlon,maxlon)
begin
  res                 = True

  res@gsnFrame        = False        ; Don't draw or advance
  res@gsnDraw         = False        ; frame yet.

  res@mpDataBaseVersion        = "MediumRes"
  res@pmTickMarkDisplayMode    = "Always"

;---Zoom in on area of interest
  res@mpMinLatF                = minlat
  res@mpMaxLatF                = maxlat
  res@mpMinLonF                = minlon
  res@mpMaxLonF                = maxlon

  map = gsn_csm_map(wks, res) 
  return(map)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------

begin
  TOPO_MAP = True     ; Whether to overlay vectors on topo map. Set to
                      ; False while you are debugging this script,
                      ; since it's faster.
;---open netCDF file
  a = addfile("uvt.nc","r")

;---Read in U and V at various mb levels
  minlon            =  65.               ; select a subregion
  maxlon            =  95.
  minlat            =   5. 
  maxlat            =  25.
  u        = a->U(0,:,{minlat-2:maxlat+2},{minlon-2:maxlon+2})
  v        = a->V(0,:,{minlat-2:maxlat+2},{minlon-2:maxlon+2})
  lat_uv   = a->lat
  lon_uv   = a->lon

;---Recreating jpeg images only works for X11 and PNG. 
  wtype          = "png"
;  wtype@wkWidth  = 2500
;  wtype@wkHeight = 2500
  wks = gsn_open_wks(wtype,"panel")

;---Resources for vector plot
  res                           = True            ; plot mods desired
  res@gsnDraw                   = False
  res@gsnFrame                  = False
  res@vcRefMagnitudeF           = 4.0             ; define vector ref mag
  res@vcRefLengthF              = 0.045           ; define length of vec ref
  res@vcRefAnnoOrthogonalPosF   = -0.33           ; move ref vector
  res@vcRefAnnoParallelPosF     = 1.4             ; move ref vector over
  res@vcRefAnnoFontHeightF      = 0.02

  res@vcGlyphStyle            = "CurlyVector"     ; turn on curly vectors
  if(TOPO_MAP) then
    res@vcLineArrowColor          = "white"       ; change vector color
    res@vcRefAnnoArrowUseVecColor = False         ; don't use vec color for ref
  end if
  res@vcLineArrowThicknessF   = 3.0               ; change vector thickness
  res@vcVectorDrawOrder       = "PostDraw"        ; draw vectors last
  res@gsnAddCyclic            = False

  res@gsnRightString            = ""                 ; Turn off subtitles
  res@gsnLeftString             = ""

;---Number of levels to plot
  nlevels = 8
  map     = new(nlevels,graphic)
  vectors = new(nlevels,graphic)

;---Loop through all the requested levels and create vectors over maps
  do i=0,nlevels-1
    print("Plotting level = " + u&lev(i) + "...")
    res@gsnCenterString = "level = " + u&lev(i) + " " + u&lev@units

;---Only turn on vector reference box for the lower rightmost plot.
    if(i.eq.7) then
      res@vcRefAnnoOn = True
    else
      res@vcRefAnnoOn = False
    end if

;---Create the topographic or regular map
    if(TOPO_MAP) then
      map(i)= recreate_jpeg_image(wks,minlat,maxlat,minlon,maxlon)
    else
      map(i)= create_regular_map(wks,minlat,maxlat,minlon,maxlon)
    end if

;---Create vector plot and overlay on map
    vectors(i) = gsn_csm_vector(wks,u(i,:,:),v(i,:,:),res)
    overlay(map(i),vectors(i))
  end do

;---Panel all nlevels plots
  pres             = True
  pres@gsnPanelMainString = "Zonal wind (m/2)"
  pres@gsnMaximize = True
  gsn_panel(wks,map,(/4,2/),pres)
end
