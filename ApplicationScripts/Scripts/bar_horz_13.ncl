;----------------------------------------------------------------------
; bar_horz_13.ncl
;
; Concepts illustrated:
;   - Drawing three sets of "floating" filled bars
;   - Changing the aspect ratio of a bar plot
;   - Changing the height of the bars in a bar plot
;   - Setting the minimum/maximum value of the X and Y axis in a bar plot
;   - Explicitly setting tickmarks and labels on the left Y axis
;   - Adding additional tickmark labels to a plot using gsn_blank_plot
;   - Moving tickmark labels away from axis
;   - Drawing a custom legend using filled bars and text strings
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;----------------------------------------------------------------------
; This procedure draws a legend on the bottom of the page, using
; filled bars and text strings.
;----------------------------------------------------------------------
undef("draw_legend")
procedure draw_legend(wks)
local xbox, ybox, txres, gsres
begin
;---Add a legend at the bottom
  xbox = (/0.75,0.85,0.85,0.75,0.75/)
  ybox = (/0.05,0.05,0.075,0.075,0.05/)

  txres = True
  gsres = True
  txres@txFontHeightF = 0.01

;---Blue legend bar
  gsres@gsFillColor   = "blue"
  gsn_polygon_ndc(wks,xbox,ybox,gsres)

;---Right-justify this string at left of filled bars
  xpos         = min(xbox)
  ypos         = (max(ybox)+min(ybox))/2.
  txres@txJust = "CenterRight"
  gsn_text_ndc(wks,"Min ",xpos,ypos,txres)

;---Red legend bar
  xbox              = xbox + 0.1
  gsres@gsFillColor = "red"
  gsn_polygon_ndc(wks,xbox,ybox,gsres)

;---Left-justify this string at right of filled bars
  xpos         = max(xbox)
  txres@txJust = "CenterLeft"
  gsn_text_ndc(wks," Max",xpos,ypos,txres)

;---Center this string at bottom of filled bars
  xpos         = min(xbox)
  ypos         = min(ybox)
  txres@txJust = "TopCenter"
  gsn_text_ndc(wks,"Avg",xpos,ypos,txres)
end

;----------------------------------------------------------------------
; This function reshapes one array into another array. This will be
; a built-in function in Version 6.1.0.
;----------------------------------------------------------------------
;undef("reshape")
;function reshape(x,dims[*]:integer)
;begin
;  return(onedtond(ndtooned(x),dims))
;end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin

;----------------------------------------------------------------------
; Getting the data section
;----------------------------------------------------------------------

;---Read file as arrays of strings for parsing later
  lines  = asciiread("dummy_model_data.txt",-1,"string")
  nlines = dimsizes(lines)

;---Get title and year
  title = lines(0)
  year  = str_get_field(title,5," ")

;---Calculate number of models
  nmons    = 3                      ; Jan, Mar, May
  nmodels  = ((nlines-1)/nmons)-1   ; The -1 is for the min/max/avg header
  nmodmon  = nmodels*nmons

;---Debug prints
  print("Number of models = " + nmodels)
  print("Title            = '" + title + "'")
  print("Year             = '" + year + "'")

;---Special labels for tickmarks
  models = new(nmodels+1,string)    ; Add one for the blank space b/w models 

;---Get name of models
  do i=0,nmodels-1
    models(i) = str_get_field(lines(i+2),1," ")
  end do

;---Create array of repeating model names for X axis.
  models_repeat = ndtooned(conform_dims((/nmons,nmodels+1/),models,1))

;---Parse out min/max/avg values and put in big "data" array
  data = new((/nmons,nmodels+1,3/),float)    ; months x models x (min/max/avg)

  do i=0,nmons-1
    do j=0,nmodels-1
      istart = ((nmodels+1)*i)+j+2    ; the +1 is the title
      do k=0,2
        data(i,j,k) = tofloat(str_get_field(lines(istart),2+k," "))
      end do
    end do
  end do

;---Turn into 2D array for plotting later
  nmodmon1 = (nmodels+1)*nmons              ; The "+1" gives us an extra value 
  data2d   = reshape(data,(/nmodmon1,3/))   ; between models.
  x        = ispan(0,nmodmon1-1,1)

;----------------------------------------------------------------------
; The graphics section
;----------------------------------------------------------------------
  wks = gsn_open_wks("png","bar_horz")  ; send graphics to PNG file

;---Values for the X and Y axes
  xmin = min(data2d(:,0))-2   ; add small margins at
  xmax = max(data2d(:,1))+2   ; top and bottom
  ymin = min(x)-1
  ymax = max(x)

;---resources for each bar chart
  res                       = True

  res@gsnMaximize           = True     ; maximize plots in frame
  res@gsnFrame              = False
  res@gsnDraw               = False

  res@vpWidthF              = 0.3
  res@vpHeightF             = 0.8

  res@trYMinF               = ymin
  res@trYMaxF               = ymax
  res@trXMinF               = xmin
  res@trXMaxF               = xmax

  res@tmYLLabelFontHeightF    = 0.006

;---Make sure major X tickmarks don't disappear
  res@tmXBLabelFontHeightF    = 0.006
  res@tmXBMajorLengthF        = 0.011
  res@tmXBMajorOutwardLengthF = 0.011
  res@tmXBMinorLengthF        = 0.008
  res@tmXBMinorOutwardLengthF = 0.008

;--Turn off top and right axis tickmarks
  res@tmYROn                = False
  res@tmXTOn                = False

;---Copy resources up to this point for later.
  bres = res

;---Put model names on Y axis
  ii = ind(.not.ismissing(models_repeat))
  res@tmYLMode                = "Explicit"
  res@tmYLValues              = x(ii)
  res@tmYLLabels              = models_repeat(ii)
  res@tmYLLabelAngleF         = 90
  res@tmYLLabelJust           = "CenterCenter"

  res@tiMainString          = "Some model variable"
  res@tiMainFontHeightF     = 0.02

;---Turn on bar chart
  res@gsnXYBarChart         = True
  res@gsnXYBarChartBarWidth = 0.7      ; Default is 1.0
  res@gsnXRefLineColor      = "transparent"
  res@gsnRightXRefLineColor = "red"
  res@gsnLeftXRefLineColor  = "blue"

;
; Loop across each month, creating a red bar above the
; mean value and a blue bar below the mean value.
;
  min_plot = new(nmodmon1,graphic)
  max_plot = new(nmodmon1,graphic)

  do i=0,nmodmon1-1
    if(.not.ismissing(data2d(i,2))) then

;---This resource indicates where the red/blue bars begin and end
      res@gsnXRefLine = data2d(i,2)       ; avg value
     
;---First time in loop, create base plot
      if(i.eq.0) then
        base_plot   = gsn_csm_xy(wks,data2d(i,0),x(i),res)   ; min value
        max_plot(i) = gsn_csm_xy(wks,data2d(i,1),x(i),res)   ; max value
        overlay(base_plot,max_plot(i))
      else
        min_plot(i) = gsn_csm_xy(wks,data2d(i,0),x(i),res)   ; min value
        max_plot(i) = gsn_csm_xy(wks,data2d(i,1),x(i),res)   ; max value
        overlay(base_plot,min_plot(i))
        overlay(base_plot,max_plot(i))
      end if
    end if
  end do

;---Create a blank plot in order to get additional X tickmark labels
  bres@tmYLMode             = "Explicit"
  bres@tmYLValues           = x(nmodels/2::nmodels+1)
  bres@tmYLLabels           = (/"JAN","MAR","MAY"/) + " " + year
  bres@tmYLLabelDeltaF      = 1.5
  bres@tmYLLabelFontHeightF = 0.008

  blank_plot = gsn_csm_blank_plot(wks,bres)
  overlay(base_plot,blank_plot)

;---Drawing the base plot draws everything.
  draw(base_plot)

;---"draw_legend" is defined above.
  draw_legend(wks)
  frame(wks)

end 
