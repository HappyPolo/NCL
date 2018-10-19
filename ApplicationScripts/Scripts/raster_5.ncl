;***********************************************
; raster_5.ncl
;
; Concepts illustrated:
;   - Drawing raster contours
;   - Generating dummy data
;   - Forcing full-sized raster cells at the X,Y axis boundaries
;   - Creating a color map using RGB values.
;   - Removing the extra "0" from tickmark labels
;   - Turning off minor tickmarks
;***********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

begin
;---Create some dummy data.
  npts = 8
  data = generate_2d_array(10, 10, -8, 8, 0, (/npts,npts/))

;---Color map
  cmap = (/ (/ 91, 26, 32/), (/124, 29, 29/), (/158, 32, 25/), \
            (/177, 36, 22/), (/206, 35, 22/), (/203, 66, 22/), \
            (/235,143, 25/), (/252,211, 22/), (/137,204,219/), \
            (/ 41,175,197/), (/  0,155,215/), (/ 17,103,179/), \ 
            (/ 41, 81,162/), (/ 31, 54,147/), (/ 21, 29,132/), \
            (/ 31, 22,115/)/) / 255.

;---Open png for graphics.
  wks  = gsn_open_wks("png","raster")

  res                      = True
  res@gsnMaximize          = True          ; Maximize plot in frame.

  res@cnFillOn             = True          ; Turn on contour fill
  res@cnFillMode           = "RasterFill"  ; Turn on raster fill
  res@cnLinesOn            = False         ; Turn off contour lines
  res@cnFillPalette        = cmap

  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       = -7
  res@cnMaxLevelValF       =  7
  res@cnLevelSpacingF      =  1
  res@lbOrientation        = "vertical"

  res@tiMainString         = "Rasters are half-sized at boundary"

  res@tmXBMinorOn          = False
  res@tmXBFormat           = "f"
  res@tmYLFormat           = "f"

;---Create arrays for X/Y axes.
  res@sfXArray = fspan(-2.25,2.25,npts)
  res@sfYArray = fspan(-60,60,npts)

  contour = gsn_csm_contour(wks,data,res)
;
; By adding extra element to X,Y axes values, we can get
; full rasters at the boundary.  The ":=" is a reassignment
; operator.
;
  res@sfXArray := fspan(-2.25,2.25,npts+1)    ; One more element in both
  res@sfYArray := fspan(-60,60,npts+1)        ; X and Y
  
  res@tiMainString = "Rasters are full-sized at boundary"

  contour = gsn_csm_contour(wks,data,res)
end
