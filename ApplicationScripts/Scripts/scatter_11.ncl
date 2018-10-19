;*************************************************
; scatter_11.ncl  (adapted from scatter_5.ncl)
;
; Concepts illustrated:
;   - Illustrates the use of new XYPlot opacity resources.
;     (new with NCL 6.4.0).
;   - Illustrated difference between uniform opacity setting
;     versus per data-channel settings.
;
;*************************************************

begin
;---Generate random data with an average of 10 and a stddev of 3.
  npts   = 2000
  data1d = random_normal(10.,3.,npts)

;---Create roughly ten equally spaced levels through the data.
  nlevels = 10

;---Create new 2D array to hold groupings of values
  data2d = new((/nlevels,npts/),typeof(data1d))

;---Group the values and put in 2D array.
  do i=0,npts-1
    data2d(i%nlevels,i) = data1d(i)
  end do

;----------------------------------------------------------------------
; Graphics section
;----------------------------------------------------------------------

  wks  = gsn_open_wks("png","scatter")            ; send graphics to PNG file

;---Create a scatter plot
  res                    = True                   ; plot mods desired
  res@gsnMaximize        = True
  res@tiMainString       = "Scatter plot with grouped markers (uniform opacity)"

;---Set some legend resurces
  res@pmLegendDisplayMode    = "Always"         ; Turn on the legend
  res@lgOrientation          = "horizontal"     ; Default is vertical
  res@pmLegendWidthF         = 0.75             ; Make it wider
  res@pmLegendOrthogonalPosF = -0.1             ; Move it up slightly
  res@lgPerimOn              = False            ; Turn off the perimeter box

;---Set some marker resources
  res@xyMarkLineMode     = "Markers"
  res@xyMarkerThicknessF = 2.5
  res@xyMarkerColors     = (/"darkgoldenrod","darkgreen","coral4", \ 
                             "cyan3","firebrick1","darkslateblue","limegreen",     \
                             "lightgoldenrod","darkseagreen1","lightsteelblue1"/)
  res@xyMarkerOpacityF   = .25
;
; Set the marker indexes. There are 17 predefined ones at:
;
;   http://www.ncl.ucar.edu/Document/Graphics/Images/markers.png
;
; or you can define your own with NhNewMarker:
;   http://www.ncl.ucar.edu/Document/Functions/Built-in/NhlNewMarker.shtml
;
  res@xyMarkers          = ispan(2,16,1)  ; Again, you can list more than you need.


  plot1  = gsn_csm_y (wks,data2d,res)

  ;
  ; apply per-group opacities (NOTE that this resource overrides xyMarkerOpacityF)
 
  res@xyMarkerOpacities = fspan(.2, 1., nlevels)
  res@tiMainString      = "Scatter plot with grouped markers (per-group opacities)"
  plot2 = gsn_csm_y (wks, data2d, res)

end
