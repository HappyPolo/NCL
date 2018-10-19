;----------------------------------------------------------------------
; newcolor_9.ncl
;
; Concepts illustrated:
;   - Showing features of the new color display model
;   - Importing a jpeg image into an NCL graphic
;   - Using more than 256 colors per frame
;   - Using "overlay" to overlay multiple contours
;----------------------------------------------------------------------
; NOTE: This example will only work with NCL V6.1.0 and later.
;
; This example only works for "x11" or "png" output, and not with
; "ps" and "pdf" output.
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

;----------------------------------------------------------------------
; This function takes a NetCDF file that was created by running
; something like:
;
;   gdal_translate -ot Int16 -of netCDF jpeg_file netcdf_file
; 
; on a jpeg image, and reconstructs it using NCL graphics.
;
; The plot is drawn unless opt@Draw = False.
;----------------------------------------------------------------------
function draw_image(wks,ncfile,opt)
local f, Band1, Band2, Band3, res, nlat, nlon, reds, greens, blues, \
      ramp, redMap, blueMap, greenMap
begin
  DRAW = .not.opt.or..not.isatt(opt,"Draw").or. \
         (isatt(opt,"Draw").and.opt@Draw)

;---Read the three bands of data
  f     = addfile(ncfile,"r")
  Band1 = where(f->Band1.gt.255, 255, f->Band1)  ; red channel
  Band2 = where(f->Band2.gt.255, 255, f->Band2)  ; green channel
  Band3 = where(f->Band3.gt.255, 255, f->Band3)  ; blue channel

  band_dims = dimsizes(Band3)
  nlat      = band_dims(0)
  nlon      = band_dims(1)
  print("draw_image: dimensions of image = " + nlat + " x " + nlon)

;---Start the graphics
  res                 = True
  res@gsnMaximize     = True
  res@vpHeightF       = tofloat(nlat)/max((/nlat,nlon/))
  res@vpWidthF        = tofloat(nlon)/max((/nlat,nlon/))

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

  redMap = gsn_csm_contour(wks, Band1, res) 

;---Overlay everything
  overlay(redMap, greenMap)
  overlay(redMap, blueMap)

  if(DRAW) then
    draw(redMap)
    frame(wks)
  else
    print("draw_image: no image drawn, opt@Draw was set to False.")
  end if

  return(redMap)
end 

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
  wks_type = "png"                       ; only works with x11 and png
  wks = gsn_open_wks(wks_type, "newcolor")

  opt = False    ; no options desired
  plot = draw_image(wks,"fuji.nc",opt)
end
