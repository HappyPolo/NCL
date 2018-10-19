;*************************************************
; gsn_xy_4.ncl
;*************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;*************************************************
begin
;---data.asc has 6 columns and 500 rows of data.
  data  = asciiread("./data.asc",(/500,6/),"float")
  x     = data(:,1)    ; Read the second column of data (indexing starts at 0)
  y1    = data(:,4)    ; Read the fifth column of data
  y2    = data(:,3)    ; Read the fourth column of data
;**************************************************
; smooth the data 
;**************************************************
  y1_smooth = runave(y1,25,0)
  y2_smooth = runave(y2,25,0)
  data_all = new((/3,dimsizes(y1)/),"float")
  data_all(0,:)=y2
  data_all(1,:)=y1_smooth
  data_all(2,:)=y1
;**************************************************
; create plot
;**************************************************
  wks = gsn_open_wks("png","gsn_xy")         ; send graphics to PNG file

  res               = True                   ; plot mods desired
  res@tiMainString  = "An xy plot Example"   ; title
  res@tiYAxisString = "Dust (ppm)"           ; y axis title
  res@tiXAxisString = "Time"                 ; x axis title

  res@xyLineColors      = (/"black","red","blue"/)  ; line colors
  res@xyLineThicknesses = (/1.0,2.0/)        ; line thicknesses
  res@xyDashPatterns    = (/0.0,0.0/)        ; line patterns

  res@xyMarkLineModes   = (/"Markers","Lines","MarkLines"/) ; markers?
  res@xyMarkerColors    = (/"red",    "black","black"/)     ; color
  res@xyMarkers         = (/2,         0,      1/)          ; style

  plot = gsn_xy(wks,x,data_all,res)          ; Draw an XY plot with 1 curve.
  
end
