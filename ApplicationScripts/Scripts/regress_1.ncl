;*************************************************
; regress_1.ncl
;
; Concepts illustrated:
;   - Read tabular values from an ascii file
;   - Calculating the least squared regression for a one dimensional array
;   - Drawing a scatter plot with a regression line
;   - Merging two sets of values into a single array
;   - Changing the markers in an XY plot
;   - Changing the marker color in an XY plot
;   - Changing the marker size in an XY plot
;
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

 begin
;************************************************
; Read data from file [time, value]. 
; Missing values (_FillValue) indicated by -9999.0
;************************************************
   ncol  = 2
   ntim  = numAsciiRow("regress_1.txt")
   data  = asciiread("regress_1.txt", (/ntim,ncol/), "float")
   data@_FillValue = -9999.0 

   x     = data(:,0)              ; model time: units are days              
   y     = data(:,1)              ; model value: units degK

;************************************************
; calculate the regression coefficient (slope)    
;************************************************
   rc    = regline(x, y)          ; slope           
   rc@units = "degK/day"         
   print(rc)

;************************************************
; create an array to hold both the original data
; and the calculated regression line   
;     ---------
;     y = mx+b 
;     m is the slope:       rc      returned from regline
;     b is the y intercept: rc@yave attribute of rc returned from regline
;************************************************
   pltarry   = new ( (/2,ntim/), typeof(data), data@_FillValue)

   pltarry(0,:) = y                                 ; use markers
   pltarry(1,:) = rc*x + rc@yintercept              ; use solid line

;************************************************
; plotting parameters
; This illustrates one approach. Overlays could also be used.
;************************************************
   wks  = gsn_open_wks("png","regress")             ; send graphics to PNG file
   
   res                     = True                   ; plot mods desired
   res@xyMarkLineModes     = (/"Markers","Lines"/)  ; choose which have markers
   res@xyMarkers           = 16                     ; choose type of marker 
   res@xyMarkerColor       = "red"                  ; Marker color
   res@xyMarkerSizeF       = 0.005                  ; Marker size (default 0.01)
   res@xyDashPatterns      = 1                      ; solid line 
   res@xyLineThicknesses   = (/1,2/)                ; set second line to 2
   res@tmYLFormat          = "f"                    ; not necessary but nicer labels 

   res@tiMainString        = "Output from regline"  ; title

   plot  = gsn_csm_xy (wks,x,pltarry,res)           ; create plot
end

