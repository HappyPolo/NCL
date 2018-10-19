;*************************************************
; bar_old_10.ncl
;
; Concepts illustrated:
;   - Drawing horizontal filled bars using gsn_add_polygon
;   - Creating a blank plot
;   - Changing the aspect ratio of a bar plot
;   - Setting the minimum/maximum value of the X and Y axis in a bar plot
;   - Explicitly setting tickmarks and labels on the left Y axis
;   - Turning off tickmarks, but not the labels
;   - Drawing grid lines on an XY plot
;*************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"

begin
  cities = (/"Dallas","Boston","Las Vegas","Austin","Seattle",\
             "Miami","Balitmore","Denver","Portland","Hartford","Detroit", \
             "Richmond","Nashville","Charlotte","Atlanta","Kansas City",\
             "Rochester","Minneapolis","Chicago","Washington DC", \
             "New York","Columbus","New Orleans","San Antonio","Phoenix", \
             "Memphis","Cincinatti","St. Louis","Pittsburgh","Salt Lake City"/)

  ncities = dimsizes(cities)

  data1 = random_uniform(5,75,ncities)
  data2 = data1 + random_uniform(5,30,ncities)

  wks = gsn_open_wks("png","bar_old")  ; send graphics to PNG file
;
; Set resources for blank plot. Be sure to set axes limits
; that represent data that will be added later via polygons.
;
  res                          = True

  res@gsnMaximize              = True    ; Maximize plot in frame
  res@gsnDraw                  = False   ; Don't draw
  res@gsnFrame                 = False   ; Don't advance frame

  res@vpWidthF                 = 0.3     ; Make long and
  res@vpHeightF                = 0.9     ; narrow

;---Set axes limits. Add extra space for X max.
  res@trXMinF                  = 0.0
  res@trXMaxF                  = max(data2) + max(data2)/10.  
  res@trYMinF                  = 0
  res@trYMaxF                  = ncities + 1

  res@gsnTickMarksPointOutward = True

;---Put city labels on Y axis
  res@tmYLMode                 = "Explicit"
  res@tmYLValues               = ispan(1,ncities,1)
  res@tmYLLabels               = cities

  res@tmYLLabelFontHeightF     = 0.01   ; make labels smaller

;--Turn off Y axis tickmarks
  res@tmYLMajorLengthF         = 0.
  res@tmYLMajorOutwardLengthF  = 0.  
  res@tmXBMajorLengthF         = 0.01
  res@tmXBMajorOutwardLengthF  = 0.01

  res@tmXTOn                   = False   ; Turn off top tickmarks

;---Create blank plot without X grid lines
  plot_without_xgrid = gsn_blank_plot(wks,res)

;---Create blank plot with X grid lines
  res@tmXMajorGrid                = True    ; Turn on grid lines
  res@tmXMajorGridLineDashPattern = 2       ; Dashed lines
  res@tmXMajorGridThicknessF      = 1.0     ; default is 2 (?)
  plot_with_xgrid = gsn_blank_plot(wks,res)

;---Arrays to hold the bar values and the bars themselves.
  xbar = new(5,float)
  ybar = new(5,float)
  dum1 = new(ncities,graphic)
  dum2 = new(ncities,graphic)

;---Set some resources for the bars.
  bres           = True
  bres@gsEdgesOn = True      ; Outline the polygons (bars)
;
; Loop through each city and attach bar to plot that
; doesn't have grid lines.
;
  do i=1,ncities

;---Do longer bar first.
    bres@gsFillColor = "red"
    xbar      = (/0,data2(i-1),data2(i-1),0,0/)
    ybar      = (/i-0.25,i-0.25,i+0.25,i+0.25,i-0.25/)
    dum2(i-1) = gsn_add_polygon(wks,plot_without_xgrid,xbar,ybar,bres)

;---Shorter bar
    bres@gsFillColor = "blue"
    xbar      = (/0,data1(i-1),data1(i-1),0,0/)
    dum1(i-1) = gsn_add_polygon(wks,plot_without_xgrid,xbar,ybar,bres)
  end do

;
; Drawing the plot will draw all the attached bars. Have to draw
; the plot twice: one with the X grid lines and one without, in
; order to make sure the X grid lines are behind the bars.
;
; Couldn't see how else to do this.
;
  draw(plot_with_xgrid)
  draw(plot_without_xgrid)
  frame(wks)
end
