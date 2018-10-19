;----------------------------------------------------------------------
; time_labels_4.ncl
;
; Concepts illustrated:
;   - Labeling the X axis with nicely-formatted time labels
;   - Converting YYYYMM time to "days since" time using cd_inv_calendar
;----------------------------------------------------------------------
; This example shows what happens if you try to create a plot with
; a "time" axis represented by values like 201011, 201012, 201101,
; 201102, etc.
;
; You will get the following warning because the time axis is too 
; irregularly spaced:
;
;   _NhlCreateSplineCoordApprox: Attempt to create spline approximation 
;       for X axis failed: consider adjusting trXTensionF value
;
; To fix this, you must convert YYYYMM to a numeric time with reasonable
; spacing. 
;----------------------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"

;----------------------------------------------------------------------
; Converts YYYYMM time to "days since" time.
;----------------------------------------------------------------------
function yyyymm_to_time(time)
local ntime, stime, year, month, day, hour, minute, second, units
begin
  ntime  = dimsizes(time)
  stime  = tostring(time)
  year   = toint(str_get_cols(stime,0,3))
  month  = toint(str_get_cols(stime,4,5))
  day    = new(ntime,integer)
  hour   = new(ntime,integer)
  minute = new(ntime,integer)
  second = new(ntime,double)
 
;----------------------------------------------------------------------
; Note: you may need to change the day, hour, minute values depending
; on your definition of "YYYYMM".  Is this the first day and the 
; first hour of the month? Is it the middle of the month?
;----------------------------------------------------------------------
  day    = 1
  hour   = 0
  minute = 0
  second = 0.d
  units  = "days since " + min(year) + "-01-01 00:00"

  newtime = cd_inv_calendar(year,month,day,hour,minute,second,units,0)

  return(newtime)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
;---Create dummy lat and time coordinate arrays to be used for 2D data.
  lat  = fspan(9.5,55.5,47)
  time = (/201001,201002,201003,201004,201005,201006,201007,201008,\
           201009,201010,201011,201012,201101,201102,201103,201104,\
           201105,201106,201107,201108,201109,201110,201111,201112,\
           201201,201202,201203,201204,201205,201206,201207,201208,\
           201209,201210,201211,201212/)

  lat!0      = "lat"
  lat@units  = "degrees_north"
  time!0     = "time"
  time@units = "YYYYMM"

;---Create dummy array dimensioned lat x time, with time = YYYYMM.
  nlat   = dimsizes(lat)
  ntim   = dimsizes(time)
  x      = generate_2d_array(10, 10, -19.69, 15.82, 0, (/nlat,ntim/))
  x!0    = "lat"
  x!1    = "time"
  x&lat  = lat
  x&time = time
  printVarSummary(x)

;---Start the graphics
  wks = gsn_open_wks("png","time_labels")

  res              = True
  res@gsnMaximize  = True
  res@cnFillOn     = True
  res@tiMainString = "Spline error for X (time) axis"

  plot = gsn_csm_contour(wks,x,res)    

;---Convert the time values and reassign as x's time coordinate array
  newtime = yyyymm_to_time(time)
  x&time  := newtime
  printVarSummary(x)

;---Set resources necessary to nicely format X axis
  restick           = True
  restick@ttmFormat = "%c %Y"              ; Jan 2010, Feb 2010, etc.
  time_axis_labels(newtime,res,restick)

  res@tiMainString = "Nice time axis"
  plot = gsn_csm_contour(wks,x,res)    
end
