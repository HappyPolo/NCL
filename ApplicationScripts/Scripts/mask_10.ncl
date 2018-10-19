;*************************************************
; mask_10.ncl
;
; Concepts illustrated:
;   - Masking missing values in a cell-fill plot
;   - Forcing missing value areas to be drawn with transparency
;   - Drawing cell-filled contours
;   - Drawing raster contours
;   - Overlaying cell-filled contours on raster contours
;   - Spanning part of a color map for contour fill
;   - Forcing the paper orientation to be "portrait"
;   - Using "setvalues" to change the main title of an existing plot
;   - Generating dummy data using "generate_2d_array"
;   - Reversing data in the X and Y axis
;   - Changing the orientation of the labelbar
;   - Maximizing plots after they've been created
;
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************************

begin
;---Generate some dummy data.
  x = generate_2d_array(10, 10, -15, 16, 0, (/100,100/))
  y = generate_2d_array(11, 11, -14, 13, 0, (/100,100/))

;
; Just for fun, reverse the two dimensions 
; and set some values to msg
;
  y = y(::-1,::-1)
  y@_FillValue = -999
  y = where(y.gt.-3.and.y.lt.3,y@_FillValue,y)

;---Open PNG file and change colormap.

  wks = gsn_open_wks("png","mask")
  cmap = read_colormap_file("BlGrYeOrReVi200")     ; read color data of 200 colors

;---Set up resources.
  res                      = True

;  res@gsnDraw              = False
;  res@gsnFrame             = False

  res@gsnMaximize          = True
  res@gsnPaperOrientation  = "Portrait"

  res@cnFillOn             = True
  res@cnFillMode           = "RasterFill"

  res@cnFillPalette        = cmap(:97,:)  ; Use subsetted color map

  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF	   = -15
  res@cnMaxLevelValF	   =  16
  res@cnLevelSpacingF	   =  1.0

  res@lbOrientation        = "Horizontal"

  res@cnLinesOn            = False
  res@cnLineLabelsOn       = False
  res@cnLineLabelsOn       = False

  res@tfDoNDCOverlay       = True          ; native projection

  res@tiMainString         = "Raster plot with no missing values"

;---Create raster filled plot.
  base = gsn_csm_contour(wks,x,res)

;---Change some resources for the second plot.
  res@cnFillPalette        := cmap(98:,:)     ; Use another subsetted color map

  res@cnFillMode            = "CellFill"     ; Can't use "RasterFill" with transparency
  res@cnMissingValFillColor = -1             ; can also use "transparent"
; res@cnMissingValPerimOn   = True

  res@lbOrientation        = "Vertical"

  res@tiMainString         = "Cell fill plot with missing values"

;---Create cell filled plot.
  top  = gsn_csm_contour(wks,y,res)

  overlay(base,top)

;---Change title of overlaid plots.
  setvalues base
    "tiMainString" : "Combined raster and cell fill plots"
  end setvalues

;---This will re-maximize the size of the new overlaid plots.
  pres = True
  maximize_output(wks,pres)
end
