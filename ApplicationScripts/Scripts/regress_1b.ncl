;*************************************************
; regress_1b.ncl
;
; Concepts illustrated:
;   - Specify x, y values
;   - Calculating the least squared regression for a one dimensional array
;   - Uses 6.4.0 information to calculate:
;     (a) 95% line drawn with 5 and 95% slope and y-intercept limits
;     (b) 95% mean response
;     (c) 95% confidence interval
;   - Drawing a scatter plot with:
;     - markers
;     - regression line
;     - 95% mean response limits   (2.5% to 97.5%)
;     - 95% prediction limits
;*************************************************
; http://www.ncl.ucar.edu/Document/Functions/Contributed/regline_stats.shtml
; Uses 6.4.0 updates
;*************************************************
; Data Source: http://www.stat.ucla.edu/~hqxu/stat105/pdf/ch11.pdf
;*************************************************

;                      Hydrocarbon level (%)    
    x  = (/ 0.99, 1.02, 1.15, 1.29, 1.46, 1.36, 0.87, 1.23, 1.55, 1.40  \
          , 1.19, 1.15, 0.98, 1.01, 1.11, 1.20, 1.26, 1.32, 1.43, 0.95 /)
;                             Purity     (%)    
    y  = (/ 90.01, 89.05, 91.43, 93.74, 96.73, 94.45, 87.59, 91.77, 99.42, 93.65  \
          , 93.54, 92.52, 90.56, 89.54, 89.85, 90.39, 93.25, 93.41, 94.98, 87.33  /)

; Perform regression 
; Ccomputations are independent of order. However, for subsequent graphics, 
; it is best to reorder  the ; independent variable so it is monotonically 
; {in/de}creasing. Move dependent variable (y) with associated x

    mono = 1                  ; ascending=1 , descending=-1
    ii =  dim_pqsort_n(x,mono,0)
    xx = x(ii)                ; temporary 'work' arrays
    yy = y(ii)

    rc =  regline_stats(xx,yy) ; linear regression coef
    print(rc)

    xx@long_name = "Hydrocarbon (%)" 
    yy@long_name = "Purity (%)" 
;************************************************
; create an array to hold both the original data
; and the calculated mean regression line   
;
; Use xx and yy results
;************************************************
    nx   = dimsizes(x)
    pltarry      = new ( (/6,nx/), typeof(x))
    pltarry(0,:) = yy                                ; use markers
    pltarry(1,:) = rc@Yest                           ; regression values

    pltarry(2,:) = rc@YMR025                         ; MR: mean response
    pltarry(3,:) = rc@YMR975

    pltarry(4,:) = rc@YPI025                         ; PI: prediction interval
    pltarry(5,:) = rc@YPI975

;************************************************
; Plotting parameters
; This illustrates one approach. Overlays could also be used.
;************************************************
    wks  = gsn_open_wks("png","regress")             ; send graphics to PNG file
    
    res                     = True                   ; plot mods desired
    res@xyMarkLineModes     = (/"Markers","Lines" \  ; choose which have markers
                               ,"Lines"  ,"Lines" \ 
                               ,"Lines"  ,"Lines" /)
    res@xyMarkers           = 16                     ; choose type of marker 
    res@xyMarkerSizeF       = 0.0075                 ; Marker size (default 0.01)

    res@xyDashPatterns      = 0                      ; solid line 
   ;res@xyMonoDashPattern   = True
    res@xyLineThicknesses   = (/1,3,2,2,2,2/)        
    res@xyLineColors        = (/ "black", "black"\
                               , "blue" , "blue" \
                               , "red"  , "red"  /)
    res@tmYLFormat          = "f"                    ; not necessary but nicer labels 

  ;;res@trXMinF                =   min(xx)
  ;;res@trXMaxF                =   max(xx)

    res@tiMainString           = "regline_stats: Purity"
    plot                       = gsn_csm_xy (wks,xx,pltarry(0:1,:),res) 

;---Make legend smaller and move into plot
    res@pmLegendDisplayMode    = "Always"            ; turn on legend
    res@pmLegendSide           = "Top"               ; Change location of 
    res@pmLegendParallelPosF   = .225                ; move units right
    res@pmLegendOrthogonalPosF = -0.45               ; move units down
    res@pmLegendWidthF         = 0.15                ; Change width and
    res@pmLegendHeightF        = 0.175               ; height of legend.
    res@lgPerimOn              = True                ; turn off/on box around
    res@lgLabelFontHeightF     = .015                ; label font height
    res@xyExplicitLegendLabels = (/"data"         , "regline"       \
                                  ,"5% response"  , "95% response"  \   
                                  ,"5% prediction", "95% prediction"/)  

    res@tiMainString           = "regline_stats: Purity"
    plot                       = gsn_csm_xy (wks,xx,pltarry,res)           ; create plot
