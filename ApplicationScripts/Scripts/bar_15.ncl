;----------------------------------------------------------------------
; bar_15.ncl
;
; Concepts illustrated:
;   - Binning data
;   - Drawing a time series plot
;   - Drawing a bar chart
;   - Drawing filled bars in an XY plot
;   - Changing the fill colors in a bar plot
;   - Changing the aspect ratio of a bar plot
;   - Attaching a labelbar to a plot
;   - Labeling the X axis with nicely-formatted time labels
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"

;----------------------------------------------------------------------
; This function attaches a labelbar to the given plot.
;----------------------------------------------------------------------
undef("attach_labelbar")
function attach_labelbar(wks,plot,values[*]:numeric,colors[*])
local lbres, vph, vpw, nboxes
begin
;
; Retrieve width and height of plot. Labelbar width/height 
; will be based on these values.
;
  getvalues plot
    "vpHeightF" : vph
    "vpWidthF"  : vpw
  end getvalues

  nboxes  = dimsizes(colors)
  nvalues = dimsizes(values)
   
;---Resources for labelbar
  lbres                    = True          ; labelbar only resources

  lbres@lbAutoManage       = False         ; Necessary to control labelbar

  lbres@vpWidthF           = 0.9 * vpw     ; labelbar width
  lbres@vpHeightF          = 0.2 * vph     ; labelbar height

  lbres@lbLabelFontHeightF = 0.01          ; font height, default is small

  lbres@lbMonoFillPattern  = True          ; Solid fill pattern
  lbres@lbFillColors       = colors

  lbres@lbOrientation      = "horizontal"
  lbres@lbLabelAlignment   = "ExternalEdges"

  lbres@lbBoxSeparatorLinesOn = False      ; turn off interior box lines

;---Only label the left and right edges of the labelbar
  labels              = sprintf("%5.3f",values)
  labels(1:nvalues-2) = ""
  lbid = gsn_create_labelbar(wks,nboxes,labels,lbres)

;---Resources for attaching labelbar to plot
  amres                  = True
  amres@amJust           = "TopCenter"
  amres@amParallelPosF   =  0.0     ; Center
  amres@amOrthogonalPosF =  0.75    ; Go below X axis labels

  annoid = gsn_add_annotation(plot,lbid,amres)    ; Attaches labelbar to plot
;
; You must return the id of the attachment in order for
; the labelbar to "live" outside this function.
;
  return(annoid)
end

;----------------------------------------------------------------------
; This function attaches filled polygons to the given plot
;----------------------------------------------------------------------
undef("attach_polygons")
function attach_polygons(wks,plot,x,y,colors)
local ymin, xgon, ygon, gnres, ny, i
begin
  ny   = dimsizes(y)
  ymin = min(y)
 
;---Create box array to hold single polygons
  ystart = ymin
  xgon   = new(6,typeof(x))
  ygon   = new(6,typeof(y))

;---Resources for polygon
  gnres                 = True
  gnres@tfPolyDrawOrder = "predraw" ; make sure bars drawn first

;---Array to hold each polygon.
  gon_ids = new(ny,graphic)
;
; Loop through each y value and attach a filled polygon that
; goes from the X axis to the curve. The polygons at the edge
; are a special case, because they start or end at the X axis.
;
; The polygons in the middle are drawn starting halfway
; between  X points.
; 
  do i=0,ny-1
    if(i.gt.0.and.i.lt.(ny-1)) then
;---Middle polygons
      xstart    = avg(x(i-1:i))
      xend      = avg(x(i:i+1))
      xgon(0)   = xstart
      xgon(1:2) = xend
      xgon(3)   = x(i)
      xgon(4:5) = xstart
      ygon(0:1) = ymin
      ygon(2)   = avg(y(i:i+1))
      ygon(3)   = y(i)
      ygon(4)   = avg(y(i-1:i))
      ygon(5)   = ymin
    else if(i.eq.0) then
;---Leftmost polygon
      xstart    = tofloat(x(0))    ; start of X axis
      xend      = avg(x(0:1))
      xgon(0)   = xstart
      xgon(1:2) = xend
      xgon(3:4) = xstart
      xgon(5)   = xgon@_FillValue
      ygon(0:1) = ymin
      ygon(2)   = avg(y(i:i+1))
      ygon(3)   = y(0)
      ygon(4)   = ymin
      ygon(5)   = ygon@_FillValue
    else
;---Rightmost polygon
      xstart    = avg(x(ny-2:ny-1))
      xend      = x(ny-1)          ; end of X axis
      xgon(0)   = xstart
      xgon(1:2) = xend
      xgon(3:4) = xstart
      ygon(0:1) = ymin
      ygon(2)   = y(ny-1)
      ygon(3)   = y(i)
      ygon(4)   = avg(y(i-1:i))
      ygon(5)   = ymin
    end if
    end if

;---Assign color and attach polygon
    gnres@gsFillColor = colors(i)
    gon_ids(i) = gsn_add_polygon(wks,plot,xgon,ygon,gnres)
  end do
;
; You must return the id of each polygon in order
; for them to "live" outside this function.
;
  return(gon_ids)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
;---Open data file
  dir      = "$NCARG_ROOT/lib/ncarg/data/cdf/"
  filename = "fice.nc"
  f        = addfile (dir + filename,"r")

;---Read data and fix the time units
  fice_avg   = dim_avg_n_Wrap(f->fice,(/1,2/))     ; (fice is 120 x 49 x 100)
  time       = f->time                             ; (120)
  time@units = time@units + " since " + time@time_origin

  nt       = dimsizes(fice_avg)                  ; # time steps
  fmin     = min(fice_avg)
  fmax     = max(fice_avg)
  tmin     = min(time)
  tmax     = max(time)

;---Start the graphics
  wks = gsn_open_wks("png","bar")  ; send graphics to PNG file
  gsn_define_colormap(wks,"WhiteBlue")

;---Retrieve color map length for binning range
  getvalues wks
    "wkColorMapLen" : clen
  end getvalues

;
; Set some values for "binning" the data. We want to
; span the full color map except for the first two
; colors, so we will need clen-1 bin values (one
; more than the number of colors).
; 
  bin_values = fspan(0.27,0.32,clen-1)    ; Span full color map
  nbins      = dimsizes(bin_values)

;---Create color array to hold a bar color for each Y value.
  colors = new(nt,integer)
  colors = -1                  ; Default to transparent
  do i=0,nt-1
    if(.not.ismissing(fice_avg(i))) then
      colors(i) = ind(fice_avg(i).ge.bin_values(0:nbins-2).and.\
                      fice_avg(i).lt.bin_values(1:nbins-1))+2
    end if
  end do

;---Set resources common to both plots.
  res                       = True

  res@gsnDraw               = False     ; So we can attach stuff later
  res@gsnFrame              = False

  res@gsnMaximize           = True
  res@vpWidthF              = 0.7        ; Stretch X axis a bit
  res@vpHeightF             = 0.3

  res@trYMinF               = fmin
  res@trYMaxF               = fmax+(fmax-fmin)/10.     ; add margin to top of plot
  res@trXMinF               = tmin
  res@trXMaxF               = tmax

  res@tiMainString          = filename + " (" + f@TITLE + ")"
  res@tiXAxisString         = time@long_name
  res@tiYAxisString         = "averaged " + fice_avg@long_name

  res@tiMainFontHeightF     = 0.015     ; Default fonts are too large
  res@tiXAxisFontHeightF    = 0.015
  res@tmXBLabelFontHeightF  = 0.010

  res@tmXBMinorOn           = False     ; For a cleaner look
  res@tmYLMinorOn           = False

;
; The time_axis_label function adds additional resources
; to "res" to give us nicely-formatted time labels on X axis.
; This function only works if you have a time "units" 
; recognized by the cd_calendar function.
;
  restick             = True
  restick@ttmFormat   = "%c %y"    ; MMM YY
  restick@ttmNumTicks = 8          ; 8 tick marks on X axis
  time_axis_labels(time,res,restick)

;----------------------------------------------------------------------
; First plot
;
; Draw filled bars based on ice concentration values. The top of
; these bars are flat.
;----------------------------------------------------------------------
  bres                      = res
  bres@gsnXYBarChart        = True            ; Turn on bar chart
  bres@gsnXYBarChartColors2 = colors          ; Color by bin values

  bar_plot = gsn_csm_xy (wks,time,fice_avg,bres)

;---Attach the XY curve, if desired
;  lnres                  = True
;  lnres@gsLineThicknessF = 5.0
;  curve_id = gsn_add_polyline(wks,bar_plot,time,fice_avg,lnres)

;---Attach a labelbar
  lbid1 = attach_labelbar(wks,bar_plot,bin_values,ispan(2,clen-1,1))

  draw(bar_plot)   ; This will draw the filled bars & labelbar
  frame(wks)

;----------------------------------------------------------------------
; Second plot
;
; Draw filled bars based on ice concentration values. The top of
; these bars are based on the XY curve.  The XY curve is drawn
; on top as a thick black line.
;----------------------------------------------------------------------

;---Create an XY plot with a single curve
  res@xyLineThicknessF = 4
  xyplot = gsn_csm_xy(wks,time,fice_avg,res)

;---Attach filled bars
  gonids = attach_polygons(wks,xyplot,time,fice_avg,colors)

;---Attach a labelbar
  lbid2 = attach_labelbar(wks,xyplot,bin_values,ispan(2,clen-1,1))

  draw(xyplot)   ; This will draw the filled bars, curve, & labelbar
  frame(wks)  
end
