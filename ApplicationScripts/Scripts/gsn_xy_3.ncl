;*************************************************
; gsn_xy_3.ncl
;*************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;*************************************************
begin
;---data.asc has 6 columns and 500 rows of data.
  data  = asciiread("./data.asc",(/500,6/),"float")
  x     = data(:,1)    ; Read the second column of data (indexing starts at 0)
  y     = data(:,4)    ; Read the fifth column of data
;**************************************************
; smooth the data 
;**************************************************
  y_smooth = runave(y,25,0)

  data_all = new((/2,dimsizes(y)/),"float")
  data_all(0,:)=y
  data_all(1,:)=y_smooth
;**************************************************
; create plot
;**************************************************
  wks = gsn_open_wks("png","gsn_xy")         ; send graphics to PNG file
 
  res               = True                   ; plot mods desired
  res@tiMainString  = "An xy plot Example"   ; title
  res@tiYAxisString = "Dust (ppm)"           ; y axis title
  res@tiXAxisString = "Time"                 ; x axis title

  res@xyLineColors      = (/"black","red"/)  ; line colors
  res@xyLineThicknesses = (/1.0,2.0/)        ; line thicknesses
  res@xyDashPatterns    = (/0.0,0.0/)        ; line patterns

  plot = gsn_xy(wks,x,data_all,res)          ; Draw an XY plot with 1 curve.
  
end
