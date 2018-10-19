;*************************************************
; scatter_4.ncl
;
; Concepts illustrated:
;   - Drawing a scatter plot with a regression line
;   - Drawing a time series plot
;   - Calculating the least squared regression for a one dimensional array
;   - Smoothing data so that seasonal cycle is less prominent
;   - Changing the markers in an XY plot
;   - Changing the marker color in an XY plot
;   - Changing the marker size in an XY plot
;
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;************************************************
; Create pointer to file and read in temperature.
;************************************************
   in  = addfile("b003_TS_200-299.nc","r") 
   ts  = in->TS(:,{60},{180})           ; extract time series at 60N,90W
;************************************************
; Smooth data so that seasonal cycle is less 
; prominent. This is for demo purposes only 
; so that the regression line is more sloped.
;************************************************
   ts  = runave(ts,40,0)
;************************************************
; Create x and calculate the regression coefficient.
; Note regline works on one dimensional arrays.   
;************************************************
   x     = ispan(0,dimsizes(ts)-1,1)*1.
   rc    = regline(x,ts)
;************************************************
; Create an array to hold both the original data
; and the calculated regression line.
;************************************************
 data      = new ( (/2,dimsizes(ts)/), typeof(ts))
 data(0,:) = ts
; y = mx+b 
; m is the slope:       rc      returned from regline
; b is the y intercept: rc@yave attribute of rc returned from regline
 data(1,:) = rc*(x-rc@xave) + rc@yave
;************************************************
; plotting parameters
;************************************************
 wks  = gsn_open_wks("png","scatter")             ; send graphics to PNG file
 
 res                     = True                   ; plot mods desired
 res@gsnMaximize         = True                   ; maximize plot in frame
 res@xyMarkLineModes     = (/"Markers","Lines"/)  ; choose which have markers
 res@xyMarkers           = 16                     ; choose type of marker 
 res@xyMarkerColor       = "red"                  ; Marker color
 res@xyMarkerSizeF       = 0.005                  ; Marker size (default 0.01)
 res@xyDashPatterns      = 1                      ; solid line 
 res@xyLineThicknesses   = (/1,2/)                ; set second line to 2

 res@tiMainString        = "Output from regline"  ; title

 plot  = gsn_csm_xy (wks,ts&time,data,res)        ; create plot
end
