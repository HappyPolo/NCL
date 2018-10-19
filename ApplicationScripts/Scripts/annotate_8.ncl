;----------------------------------------------------------------------
; annotate_8.ncl
;
; Concepts illustrated:
;   - Drawing bar charts around a map plot
;   - Using viewport resources to specify the locations of plots
;   - Drawing lines between plots
;   - Drawing an XY plot on top of filled bars
;   - Changing the width of the bars in a bar plot
;   - Filling the bars in a bar plot with different colors
;   - Setting the mininum/maximum value of the X and Y axis in a bar plot
;   - Rotating the Y axis string 45 degrees
;   - Using "getvalues" to retrieve the size of a plot
;   - Using "setvalues" to set the size of a plot
;   - Drawing a Y reference line in an XY plot
;   - Changing the color and thickness of a Y reference line
;   - Resizing a plot
;   - Zooming in on Australia on a cylindrical equidistant map
;   - Drawing polylines in NDC space
;   - Drawing polymarkers in lat/lon space
;   - Converting lat/lon values to NDC values
;----------------------------------------------------------------------
; Note: dummy data was used for nearly every aspect of this plot,
; including the values for the bar chart and the xy plot, and
; the locations of the lat/lon markers.
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;---Create some dummy data
  nmos = 12
  nobs = 11

;---Dummy X axis values
  x      = ispan(1,nmos,1)
  xrange = max(x) - min(x)
  deltax = xrange/10.

;---Dummy bar chart values (units="mm")
  y1 = random_uniform(0,100,(/nobs,nmos/)) 

;---Dummy XY plot values (units="deg C")
  av    = 30.
  sd    = 10.
  y2 = random_normal(av,sd,(/nobs,nmos/))      

;---Start the graphics
  wks = gsn_open_wks("png","annotate")                  ; send graphics to PNG file

;---Resources for map plot
  mpres             = True
  mpres@gsnFrame    = False

;---Position the map plot and make it smaller
  mpres@vpXF              = 0.03
  mpres@vpYF              = 0.80
  mpres@vpWidthF          = 0.60
  mpres@vpHeightF         = 0.30

;---Use high-res map database. Set to "MediumRes" if you don't have high-res db.
  mpres@mpDataBaseVersion = "HighRes"

;---Turn off tickmarks and labels
  mpres@tmXBOn            = False
  mpres@tmXTOn            = False
  mpres@tmYROn            = False
  mpres@tmYLOn            = False

;---Zoom in on map
  mpres@mpMinLatF         = 35
  mpres@mpMaxLatF         = 50
  mpres@mpMinLonF         = 45
  mpres@mpMaxLonF         = 80

  mpres@mpFillOn          = True       ; Turn on map fill
  mpres@mpOutlineOn       = True       ; Turn on map outlines
  mpres@mpFillColors      = (/"background","LightGray","transparent","LightGray"/) 
                                  ; default,     ocean,        land,     inland water

;---Create "big" map plot
  base_map = gsn_csm_map_ce(wks,mpres)

;---Set X and Y positions of the bar/XY plots and lat/lon line
  xpos = (/0.04, 0.30, 0.57, 0.69, 0.68, 0.67, 0.64, 0.38, 0.34, 0.07, 0.04/)
  ypos = (/0.90, 0.95, 0.92, 0.78, 0.65, 0.52, 0.38, 0.48, 0.33, 0.35, 0.48/)

;---Markers on map
  lat  = (/41, 48, 47, 46, 45,   43, 40, 38, 41, 42, 38 /)*1.   ; make sure it's float
  lon  = (/70, 68, 78, 79, 78.5, 72, 77, 72, 67, 60, 56 /)*1.   ; datatondc expects floats

;---Markers on bar charts
  xndc_beg = (/0.22, 0.40, 0.62, 0.66, 0.65, 0.64, 0.66, 0.42, 0.37, 0.26, 0.06/)
  yndc_beg = (/0.79, 0.84, 0.81, 0.76, 0.63, 0.50, 0.39, 0.49, 0.34, 0.36, 0.49/)

;---Set resources common to both bar and XY plot
  res                       = True

  res@gsnFrame              = False     ; Turn off individual draw
;  res@gsnDraw               = False     ; and frame for all plots

  res@vpWidthF              = 0.20      ; Make plots small,
  res@vpHeightF             = 0.10      ; and non-square.

;---Turn off bottom tickmarks, and all minor tickmarks
  res@tmXBOn                = False
  res@tmXTOn                = False
  res@tmYLMinorOn           = False
  res@tmXTMinorOn           = False

;---Set X axis limits, and y minimum to same for all plots
  res@trXMinF               = min(x) - deltax
  res@trXMaxF               = max(x) + deltax
  res@trYMinF               = 0.0    ; set to same for both plots
                                     ; we'll let ncl set the max Y
;---XY curve resources
  xyres                     = res
  xyres@xyLineThicknessF    = 2.0               ; default is 1.0
  xyres@xyLineColor         = "NavyBlue"

  xyres@gsnYRefLine           = 20                ; Draw horiz line at y=20
  xyres@gsnYRefLineColor      = "NavyBlue"
  xyres@gsnYRefLineThicknessF = 2.

  xyres@tiYAxisSide         = "Right"      ; Move Y axis label to right
  xyres@tiYAxisAngleF       = 270          ; Rotate 270 degrees
  xyres@tiYAxisString       = "~S~o~N~C"

;---Turn off top, left, and bottom tickmarks and labels
  xyres@tmXTOn              = False
  xyres@tmYLOn              = False
  xyres@tmYROn              = True
  xyres@tmYRLabelsOn        = True

;---Bar chart resources
  bres                      = res  

  bres@gsnXYBarChart         = True                 ; turn on bar chart
  bres@gsnXYBarChartBarWidth = 0.75                 ; change bar widths
  bres@gsnXYBarChartColors   = "orange"

;---Turn off right tickmarks
  bres@tmYROn                = False

  bres@tiYAxisString         = "mm"
  
;---Create arrays to hold plot ids
  xy_plot  = new(nobs,graphic)
  bar_plot = new(nobs,graphic)
  anno_id  = new(nobs,graphic)

;---Resource for markers
  mkres               = True
  mkres@gsMarkerIndex = 16    ; Filled dot

;---Resources for connecting lines
  lnres                   = True
  lnres@gsLineThicknessF  = 1.5
  lnres@gsLineDashPattern = 5     ; dashed line

;---Convert lon/lat to X/Y NDC coordinates
  xndc_end = new(nobs,float)
  yndc_end = new(nobs,float)
  datatondc(base_map, lon, lat, xndc_end, yndc_end)

;---Loop through each "observation" and create a plot
  do i=0,nobs-1
    bres@vpXF         = xpos(i)
    bres@vpYF         = ypos(i)
    xyres@vpXF        = xpos(i)
    xyres@vpYF        = ypos(i)

    bres@tiMainString = "dummy obs #" + i

;---Create bar plot
    bar_plot(i) = gsn_csm_xy (wks,x,y1(i,:),bres)

;---Create XY plot
    xy_plot(i) = gsn_csm_xy (wks,x,y2(i,:),xyres)

;---Draw connecting line
    gsn_polyline_ndc(wks,(/xndc_beg(i),xndc_end(i)/),(/yndc_beg(i),yndc_end(i)/),lnres)
  end do

;---Add markers to map
  gsn_polymarker(wks,base_map,lon,lat,mkres)

  frame(wks)
end
