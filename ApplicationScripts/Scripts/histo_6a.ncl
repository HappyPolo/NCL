;*************************************************
; histo_6a.ncl
;
; Concepts illustrated:
;   - Comparing two sets of histograms
;   - Generating dummy data using "rand"
;   - Specifying the bar fill colors in a histogram
;   - Increasing the density of histogram fill patterns
;   - Increasing the thickness of various histogram elements 
;   - Increasing the thickness of the axis borders and tickmarks
;************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
;************************************************
begin
;************************************************
; Generate some random data.
;************************************************
  x = new(1000,integer)
  y = new(1000,integer)
  do i=0,dimsizes(x)-1
    x(i) = rand()
    y(i) = rand()
  end do
  x = x/320
  y = y/320

;************************************************
; Set up a variable to hold both x and y.
;************************************************
  z = new((/2,dimsizes(x)/),integer)
  z(0,:) = x
  z(1,:) = y

;************************************************
; create several plots
;************************************************
  wtype          = "png"
  wres           = 2500
  wtype@wkWidth  = wres
  wtype@wkHeight = wres
  wks = gsn_open_wks(wtype,"histo")
  gsn_define_colormap(wks,"temp1")               ; choose colormap

  res                     = True          ; plot mods desired
  res@gsnMaximize         = True

;---Draw histogram with default settings.
  res@gsnHistogramCompare = True
  res@tiMainString        = "Histogram drawn with default settings"
  res@tiMainFontHeightF   = 0.02
  plot = gsn_histogram(wks,z,res)

;---Make the fill pattern more dense.
  res@gsFillScaleF   = 0.5
  res@tiMainString   = "Increase density of fill patterns"
  plot = gsn_histogram(wks,z,res)

;---Go back to default density, but make the fill lines thicker and perimeter thicker
  delete(res@gsFillScaleF)

  res@gsEdgeThicknessF      = 3.0
  res@gsFillLineThicknessF  = 5.0
  res@tiMainString          = "Increase thickness of patterns & bar outlines"
  plot = gsn_histogram(wks,z,res)

;---Increase thickness of tickmarks and border.
  res@tmBorderThicknessF  = 5.0
  res@tmXBMajorThicknessF = 5.0
  res@tmYLMajorThicknessF = 5.0
  res@tmXBMinorThicknessF = 5.0
  res@tmYLMinorThicknessF = 5.0
  res@tiMainString          = "Increase thickness of tickmarks and border"
  plot = gsn_histogram(wks,z,res)

end
