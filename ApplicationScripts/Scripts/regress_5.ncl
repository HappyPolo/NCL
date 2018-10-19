;*************************************************
; regress_5.ncl
;
; Concepts illustrated:
;   - Read tabular values from an ascii file
;   - Assign to independent and predictor variables
;   - Perform multiple linear interpolation
;   - Drawing a scatter plot with a regression line
;   - Merging two sets of values into a single array
;   - Changing the markers in an XY plot
;   - Changing the marker color in an XY plot
;   - Changing the marker size in an XY plot
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;==========================================================
; Read ascii table:   Y   X1   X2   X3   X4   X5   X6
;==========================================================

       diri    = "./"
       fili    = "KENTUCKY.TXT"
       
       ncol    = numAsciiCol(diri+fili)
       data    = readAsciiTable( diri+fili, ncol, "float" , 1)  ; one header 
       printVarSummary(data)

;==========================================================
; Assign to dependent (y) & independent (x) variables 
;==========================================================
       y       = data(:,0)
       x       = data(:,1:)

;==========================================================
; Set options and invoke function                      
;==========================================================
       opt = True
       opt@print_anova = True
       opt@print_data  = True

       preg    =  reg_multlin_stats(y,x,opt) 
       print(preg)

;************************************************
; plotting parameters
;************************************************
       N    = preg@N                                    

       YY   = new ( (/2,N/), typeof(data))
       YY(0,:) = data(:,0)                              ; y
       YY(1,:) = preg@Yest                              ; model estimates

       wks  = gsn_open_wks("png","regress")             ; send graphics to PNG file
       res                     = True                   ; plot mods desired
       res@gsnMaximize         = True                   ; maximize plot in frame
       res@xyMarkLineModes     = (/"Markers","Lines"/)  ; choose which have markers
       res@xyMarkers           = 16                     ; choose type of marker 
       res@xyMarkerColor       = "red"                  ; Marker color
       res@xyMarkerSizeF       = 0.0075                 ; Marker size (default 0.01)
       res@xyDashPatterns      = 1                      ; solid line 
       res@xyLineThicknesses   = (/1,2/)                ; set second line to 2
       res@tiYAxisString       = "Y"
       res@tiXAxisString       = "Obs. Number"
      
       res@tiMainString        = "Output: reg_multLin_stats"  ; title
     
       plot  = gsn_csm_y (wks,YY,res)        ; create plot
