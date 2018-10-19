;----------------------------------------------------------------------
; newcolor_11.ncl
;
; Concepts illustrated:
;   - Showing features of the new color display model
;   - Recreating a JPEG topographic image as an NCL map object
;   - Using more than 256 colors per frame
;   - Using "overlay" to overlay multiple contours
;   - Changing the size of a PNG image
;----------------------------------------------------------------------
; NOTE: This example will only work with NCL V6.1.0 and later.
;
; This example only works for "x11" or "png" output, and not with
; "ps" and "pdf" output.
;
; The original JPEG file was converted to a NetCDF file with color
; separated bands using the open source tool "gdal_translate":
;
;  gdal_translate -ot Int16 -of netCDF EarthMap_2500x1250.jpg \
;           EarthMap_2500x1250.nc
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

begin
  filename     = "EarthMap_2500x1250"
  jpg_filename = filename + ".jpg"
  nc_filename  = filename + ".nc"

;--You could use a system call to do the NetCDF conversion
;  system("gdal_translate -ot Int16 -of netCDF " + jpeg_filename + " " + nc_filename)

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

;
; Get the dimension sizes so we can properly size the
; viewport to match the image.
;

;
; NCL wants to draw to a square. So pick the largest of the
; two dimensions and make this the size of the square.
;
; Recreating jpeg images only works for X11 and PNG.
;
  wks_type          = "png"
  wks_type@wkWidth  = max((/nlat,nlon/))
  wks_type@wkHeight = max((/nlat,nlon/))
  wks = gsn_open_wks(wks_type, "newcolor")         ; Open a workstation.

  res                 = True
  res@vpWidthF        = 1.0          ; Force image to fill screen.
  res@vpHeightF       = 1.0

  res@gsnFrame        = False        ; Don't draw or advance
  res@gsnDraw         = False        ; frame yet.

  res@cnFillOn        = True         ; Turn on filled rasters
  res@cnFillMode      = "RasterFill"

  res@cnLevelSelectionMode  = "EqualSpacedLevels"
  res@cnMaxLevelCount       = 254  
  res@cnFillBackgroundColor = (/ 1., 1., 1., 1./)

  res@cnLinesOn       = False              ; Turn off contour lines      .
  res@cnLineLabelsOn  = False              ; Turn off contour labels
  res@cnInfoLabelOn   = False              ; Turn off info label
  res@gsnTickMarksOn  = False              ; Turn off tickmarks
  res@lbLabelBarOn    = False              ; Turn off labelbar
  res@gsnRightString  = ""                 ; Turn off subtitles
  res@gsnLeftString   = ""

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
  res@mpDataBaseVersion        = "MediumRes"
  res@mpOutlineBoundarySets    = "National"
  res@mpNationalLineThicknessF = 2.0
  res@mpFillOn                 = False  

  redMap = gsn_csm_contour_map(wks, Band1, res) 


;---Overlay everything and draw
  overlay(redMap, greenMap)
  overlay(redMap, blueMap)
  draw(redMap)
  frame(wks)

  delete(res)

;
; For the next frame, overlay some line contours. The "U" 
; data on the file contains lat/lon coordinate arrays, so
; the overlay should work correctly.
;

;---Read zonal winds
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
  u = a->U(1,:,:)              

;---Set new list of options. Just do line contours here.
  res                  = True
  res@gsnFrame         = False
  res@gsnDraw          = False  
  res@cnLineLabelsOn   = False
  res@cnLineColor      = "white"
  res@cnInfoLabelOn    = False
  res@cnLineThicknessF = 2.0
  res@gsnRightString   = ""
  res@gsnLeftString    = ""

  line_contours = gsn_csm_contour(wks, u, res) 

;---Change map to a satellite projection
  setvalues redMap
    "mpProjection" : "Satellite"
  end setvalues

;---Overlay on existing map and draw.
  overlay(redMap, line_contours)
  draw(redMap)
  frame(wks)

end
