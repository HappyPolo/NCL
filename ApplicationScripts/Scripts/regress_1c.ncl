;*************************************************
; regress_1c.ncl
;
; Concepts illustrated:
;   - Specify x, y values
;   - Calculating the least squared regression for a one dimensional array
;   - Creating the reciprocal and performing regression calculation 
;   - Drawing a scatter plot with:
;     - markers
;     - regression line
;     - 95% mean response limits
;     - 95% prediction limits
;*************************************************
; http://www.ncl.ucar.edu/Document/Functions/Contributed/regline_stats.shtml
; Uses 6.4.0 updates
;*************************************************
; Source Data and R script:
;        http://people.stat.sc.edu/Tebbs/stat509/Rcode_CH11.htm
;*************************************************

;                      Wind Speed (mph)
    x  = (/ 5  ,6   , 3.4, 2.7,  10 , 9.7, 9.55,3.05, 8.15, 6.2, 2.9, 6.35 \ 
          , 4.6,5.8 , 7.4, 3.6, 7.85, 8.8, 7   ,5.45, 9.1 ,10.2, 4.1, 3.95, 2.45 /)

;                      DC Output                
    y  = (/ 1.582,1.822,1.057,0.5  ,2.236,2.386,2.294,0.558,2.166,1.866,0.653,1.93 \
          , 1.562,1.737,2.088,1.137,2.179,2.112,1.8  ,1.501,2.303,2.31 ,1.194,1.144,0.123 /)

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

    xx@long_name  = "Wind Speed (mph)"
    yy@long_name  = "DC Output" 

; reciprocal transformation 

    xxr = 1.0/xx           
    rcr =  regline_stats(xxr,yy) ; linear regression coef for reciprocal transformation
    print(rcr)

    xxr@long_name = "1/[Wind Speed (mph)]"
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
                               ,"Lines"  ,"Lines" \ 
                               ,"Lines"  ,"Lines" /)
    res@xyMarkers           = 16                     ; choose type of marker 
    res@xyMarkerSizeF       = 0.01                   ; Marker size (default 0.01)

    res@xyDashPatterns      = 0                      ; solid line 
   ;res@xyMonoDashPattern   = True
    res@xyLineThicknesses   = (/1,2,2,2,2,2/)        
    res@xyLineColors        = (/ "black", "black"\
                               , "blue" , "blue" \
                               , "red"  , "red"  /)
    res@tmYLFormat          = "f"                    ; not necessary but nicer labels 

    res@trXMinF                = min(xx)
    res@trXMaxF                = max(xx)

    res@tiMainString           = "regline_stats: Wind"
    plot                       = gsn_csm_xy (wks,xx,pltarry(0:1,:),res)

;---Make legend smaller and move into plot
    res@pmLegendDisplayMode    = "Always"            ; turn on legend
    res@pmLegendSide           = "Top"               ; Change location of 
    res@pmLegendParallelPosF   = .225                ; move units right
    res@pmLegendOrthogonalPosF = -0.45               ; move units down
    res@pmLegendWidthF         = 0.175               ; Change width and
    res@pmLegendHeightF        = 0.15                ; height of legend.
    res@lgPerimOn              = True                ; turn off/on box around
    res@lgLabelFontHeightF     = .015                ; label font height
    res@xyExplicitLegendLabels = (/"data","regline" \
                                  ,"5% response" , "95% response"\
                                  ,"5% prediction", "95% prediction" /)

    plot                       = gsn_csm_xy (wks,xx,pltarry,res) 

    pltarry(0,:) = yy                                ; use markers
    pltarry(1,:) = rcr@Yest                          ; reciprocal regression values

    pltarry(2,:) = rcr@YMR025                        ; MR: mean response
    pltarry(3,:) = rcr@YMR975

    pltarry(4,:) = rcr@YPI025                        ; PI: prediction interval
    pltarry(5,:) = rcr@YPI975

    res@pmLegendParallelPosF   = 0.625                ; move units right
    res@trXMinF                = min(xxr)
    res@trXMaxF                = max(xxr)

    res@tiMainString           = "regline_stats: (1/Wind)"
    plot                       = gsn_csm_xy (wks,xxr,pltarry,res)
