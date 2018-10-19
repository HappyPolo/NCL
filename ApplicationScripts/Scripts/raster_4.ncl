;***********************************************
; raster_4.ncl
;
; Concepts illustrated:
;   - Drawing raster contours over a map
;   - Creating a topography plot using raster contours
;   - Moving the main title down
;   - Adding a title to a labelbar
;   - Explicitly setting contour levels
;   - Turning on nice map tickmarks
;   - Changing the size of a PNG image
;************************************
; This example generates a topo map over
; the area of Trinidad, Colorado.
;************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
 wtype          = "png"
 wtype@wkWidth  = 1500     ; Set the pixel size of PNG image.
 wtype@wkHeight = 1500  
 wks = gsn_open_wks(wtype,"raster")

 fname = "$NCARG_ROOT/lib/ncarg/data/cdf/trinidad.nc"
 f     = addfile(fname,"r")

 data         = f->data
 map_cornersW = f->map_cornersW
 map_cornersE = f->map_cornersE
 minmax_elevE = f->minmax_elevE
 minmax_elevW = f->minmax_elevW

 min_elev = sprintf("%.2f",min((/minmax_elevW(0),minmax_elevE(0)/))*3.28)
 max_elev = sprintf("%.2f",max((/minmax_elevW(1),minmax_elevE(1)/))*3.28)

;---Color map to use
  cmap = (/(/0.51, 0.13, 0.94/),(/0.00, 0.00, 0.59/), \
           (/0.00, 0.00, 0.80/),(/0.25, 0.41, 0.88/), \
           (/0.12, 0.56, 1.00/),(/0.00, 0.75, 1.00/), \
           (/0.63, 0.82, 1.00/),(/0.82, 0.96, 1.00/), \
           (/1.00, 1.00, 0.78/),(/1.00, 0.88, 0.20/), \
           (/1.00, 0.67, 0.00/),(/1.00, 0.43, 0.00/), \
           (/1.00, 0.00, 0.00/),(/0.78, 0.00, 0.00/), \
           (/0.63, 0.14, 0.14/),(/1.00, 0.41, 0.70/)/)

 res                       = True
 res@gsnMaximize           = True
 res@gsnAddCyclic          = False

; map plot resources
 res@mpFillOn              = False
 res@mpLimitMode           = "Corners"
 res@mpDataBaseVersion     = "MediumRes"
 res@mpOutlineBoundarySets = "AllBoundaries"
 res@mpLeftCornerLonF      = map_cornersW(0) 
 res@mpLeftCornerLatF      = map_cornersW(1)
 res@mpRightCornerLonF     = map_cornersE(2)
 res@mpRightCornerLatF     = map_cornersE(3)

; contour resources
 res@cnFillOn              = True
 res@cnLinesOn             = False
 res@cnFillMode            = "RasterFill"
 res@cnFillPalette         = cmap
 res@cnLevelSelectionMode  = "ExplicitLevels"
 res@cnLevels              = (/ 5000., 6000., 7000., 8000., 8500., 9000., \
                                9500.,10000.,10500.,11000.,11500.,12000., \
                               12500.,13000.,13500./)

; tickmark resources
 res@pmTickMarkDisplayMode  = "Always"
 res@tmXBLabelFontHeightF   = 0.010

; labelbar resources
 res@pmLabelBarWidthF         = 0.60
 res@txFontHeightF            = 0.012
 res@lbTitleString            = "elevation above mean sea level (feet)"
 res@lbTitleFontHeightF       = 0.012
 res@lbLabelFontHeightF       = 0.008
 res@lbTitleOffsetF           = -0.27
 res@lbBoxMinorExtentF        = 0.15     ; make the labelbar thinner

; title resources
 res@tiMainString      = "USGS DEM TRINIDAD (1 x 2 degrees)" 
 res@tiMainOffsetYF    = -0.02    ; Move title down towards graphic.
 res@tiMainFontHeightF = 0.015
 res@gsnLeftString     = "Min Elevation: "+min_elev
 res@gsnRightString    = "Max Elevation: "+max_elev
 res@gsnCenterString   = "Scale 1:250,000"

 plot = gsn_csm_contour_map(wks,data,res)

end

