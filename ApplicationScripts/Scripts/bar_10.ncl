;*************************************************
; bar_10.ncl
;
; Concepts illustrated:
;   - Drawing horizontal filled bars using gsnXYBarChart
;   - Changing the aspect ratio of a bar plot
;   - Setting the minimum/maximum value of the X and Y axis in a bar plot
;   - Explicitly setting tickmarks and labels on the left Y axis
;   - Turning off tickmarks, but not the labels
;   - Overlaying XY plots on each other
;   - Drawing grid lines on an XY plot
;*************************************************
; This script requires NCL V6.4.0 or later to 
; run. See bar_old_10.ncl for an older way of
; creating this plot.
;*************************************************
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
  y     = ispan(1,ncities,1)

  wks = gsn_open_wks("png","bar")  ; send graphics to PNG file
;
; Set resources for blank plot. Be sure to set axes limits
; that represent data that will be added later via polygons.
;
  res                          = True

  res@gsnMaximize              = True    ; Maximize plot in frame
  res@gsnDraw                  = False   ; Don't draw plot
  res@gsnFrame                 = False   ; Don't advance frame

  res@vpWidthF                 = 0.3     ; Make long and
  res@vpHeightF                = 0.9     ; narrow

;---Set axes limits. Add extra space for X max.
  res@trXMinF                  = 0.0
  res@trXMaxF                  = max(data2) + max(data2)/10.  
  res@trYMinF                  = 0
  res@trYMaxF                  = ncities + 1

;---Put city labels on Y axis
  res@tmYLMode                 = "Explicit"
  res@tmYLValues               = y
  res@tmYLLabels               = cities

  res@tmYLLabelFontHeightF     = 0.01   ; make labels smaller

;--Turn off Y axis tickmarks
  res@tmYLMajorLengthF         = 0.
  res@tmYLMajorOutwardLengthF  = 0.  
  res@tmXBMajorLengthF         = 0.01
  res@tmXBMajorOutwardLengthF  = 0.01

  res@tmXTOn                   = False   ; Turn off top tickmarks

  res@gsnXYBarChart               = True
  res@gsnXRefLine                 = 0
  res@gsnXYBarChartBarWidth       = 0.60

  res@tmXMajorGrid                = True    ; Turn on grid lines
  res@tmXMajorGridLineDashPattern = 2       ; Dashed lines
  res@tmXMajorGridThicknessF      = 1.0

;---Create base plot with just outlined bars
  base_plot = gsn_csm_xy(wks,data2,y,res)
  delete([/res@tmXMajorGridLineDashPattern,res@tmXMajorGridThicknessF/])

;---Create plot of shorter bars
  res@gsnXYBarChartColors = "blue"
  plot1 = gsn_csm_xy(wks,data1,y,res)

;---Create plot of longer bars
  res@gsnXYBarChartColors = "red"
  plot2 = gsn_csm_xy(wks,data2,y,res)

;---Overlay everything and draw.
  overlay(base_plot,plot2)    ; long bars on outlined bars
  overlay(base_plot,plot1)    ; short bars on long bars and outlined bars

  draw(base_plot)             ; this draws all three XY plots.
  frame(wks)
end
