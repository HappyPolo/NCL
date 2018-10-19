;*****************************************************
; xy_20.ncl
;
; Concepts illustrated:
;   - Drawing an XY plot with two different Y axes
;   - Drawing vertical grid lines on an XY plot
;   - Explicitly setting tickmarks and labels on the top X axis
;   - Manually creating a legend
;   - Drawing a legend inside an XY plot
;
;*****************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;*****************************************************

begin
    m1 = "ccsm3_bgc4_I_11b"
    m2 = "b30.061cb"
    fin1 = addfile(m1+"_ANN_globalClimo.nc","r")
    fin2 = addfile(m2+"_ANN_globalClimo.nc","r")
    v1   = fin1->MR
    v2   = fin2->MR

    nyrs1 = dimsizes(v1)
    nyrs2 = dimsizes(v2)
    nyrs  = max( (/nyrs1,nyrs2/) )

    y  = new((/2, nyrs/),"double")     ; Create new arrays to hold
    t  = new((/2, nyrs/),"double")     ; both curves.
;
; Fill in time values. Offset is the first year of the
; model run (e.g., 0, 1850, 1900).
;
    t1_offset = 1850
    t2_offset = 0
    t1     = ispan(0,nyrs-1,1)
    t(0,:) = t1 + t1_offset
    t(1,:) = t1 + t2_offset
;
; Fill in y values.  Shorter data vector will contain missing values.
;
    y(0,0:nyrs1-1) = v1
    y(1,0:nyrs2-1) = v2

    ymin = min((/y(0,:),y(1,:)/))        ; Get min and max values
    ymax = max((/y(0,:),y(1,:)/))        ; of Y values.

;
; Set line colors and dash patterns for both curves.
;
    line_col1 = "red"
    line_col2 = "blue"
    line_pat1 = 0          ; Solid
    line_pat2 = 2          ; Dashed

    wks = gsn_open_wks("png","xy")    ; send graphics to PNG file

    res1               = True
    res1@gsnFrame      = False
    res1@gsnMaximize   = True         ; Maximize plot in frame.

    res1@xyLineColor   = line_col1
    res1@xyDashPattern = line_pat1

    res1@trXMinF       = t(0,:)          ; Control limits of X
    res1@trXMaxF       = t(0,nyrs-1)     ; and Y axes.
    res1@trYMinF       = ymin       
    res1@trYMaxF       = ymax

    res1@tiXAxisString   = "time [model yrs]"
    res1@tiYAxisString   = "mm/d"
    res1@gsnCenterString = "D_TOTRUNOFF"

    res1@tmXMajorGrid                 = True   ; Turn on vertical lines
    res1@tmXMajorGridThicknessF       = 0.5
    res1@tmXMajorGridLineDashPattern  = 2

    res1@tmYROn             = False        ; Don't draw labels for
    res1@tmYRLabelsOn       = False        ; right Y axes, b/c left
    res1@tmXBLabelFontColor = line_col1    ; and right axes are same.

    res2           = True
    res2@gsnFrame  = False

    res2@xyLineColor   = line_col2
    res2@xyDashPattern = line_pat2

    res2@trXMinF       = t(1,0)          ; Control limits of X
    res2@trXMaxF       = t(1,nyrs-1)     ; and Y axes.
    res2@trYMinF       = ymin
    res2@trYMaxF       = ymax

    res2@tiXAxisString = m1 + " vs " + m2

    res2@tmYROn             = False       ; Don't draw labels for
    res2@tmYRLabelsOn       = False       ; right Y axes, b/c left
    res2@tmXTLabelFontColor = line_col2   ; and right axes are same.

;
; Here's the call to draw two curves, each with their own set of
; axes.  This example is a little unusual, because we went through
; the trouble of making both Y axes the same.
;
    plot = gsn_csm_x2y2(wks,t(0,:),t(1,:),y(0,:),y(1,:),res1,res2)

;
; Draw some text and lines to create a legend.
;
    res_text               = True
    res_text@txFontHeightF = 0.015
    res_text@txJust        = "CenterLeft"

    res_lines                   = True        ; polyline mods desired
    res_lines@gsLineColor       = line_col1   ; line color
    res_lines@gsLineThicknessF  = 3           ; line thicker
    res_lines@gsLineDashPattern = line_pat1   ; dash pattern

    xx = (/1860,1890/)
    yy = (/53.,53./)
    gsn_polyline(wks,plot,xx,yy,res_lines)
    gsn_text(wks,plot,m1,1900,53.,res_text)

    yy = (/52.5,52.5/)
    res_lines@gsLineColor       = line_col2   ; line color
    res_lines@gsLineDashPattern = line_pat2   ; dash pattern
    gsn_polyline(wks,plot,xx,yy,res_lines)
    gsn_text(wks,plot,m2,1900,52.5,res_text)
 
    frame(wks)    ; Advance the frame.
end

