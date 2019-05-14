; @Author: wqshen
; @Date: 2016-07-18 13:00
; @Last Modified by: wqshen

begin
    homeAttrs              = True
    homeAttrs@gsnMaximize  = True
    homeAttrs@gsnDraw      = False
    homeAttrs@gsnFrame     = False
    homeAttrs@trXMinF      = -30
    homeAttrs@trYMinF      = -30
    homeAttrs@trXMaxF      = 30
    homeAttrs@trYMaxF      = 30
    homeAttrs@tmXBOn       = False
    homeAttrs@tmYLOn       = False
    homeAttrs@tmYROn       = False
    homeAttrs@tmXTOn       = False
    homeAttrs@tmXBBorderOn = False
    homeAttrs@tmXTBorderOn = False
    homeAttrs@tmYLBorderOn = False
    homeAttrs@tmYRBorderOn      = False
    
    girlAttrs                   = True
    girlAttrs@gsFillColor       = "green"
    girlAttrs@gsEdgesOn         = False
    girlAttrs@gsFillOpacityF    = 0.8
    boyAttrs                    = girlAttrs
    boyAttrs@gsFillOpacityF     = 0.6
    wkstype                     = "X11"
    wkstype@wkHeight            = 1000
    wkstype@wkWidth             = 1000
    wks                         = gsn_open_wks(wkstype, "RedHeartAndCupidArrow")
    ;; 绘制爱之载体，家
    home                        = gsn_blank_plot(wks, homeAttrs)
    ;;-------数据准备------------
    PI                          = 3.1415926
    t                           = fspan(0, 2*PI, 1000)
    x                           = 16*sin(t)^3
    y                           = 13*cos(t) - 5*cos(2*t) - 2*cos(3*t) - cos(4*t)
    heartDistX                  = -8.
    heartDistY                  = 4.
    k                           = heartDistY/heartDistX
    ;;-------爱神之箭与情侣之心------------    
    arrowAttrs                  = True
    arrowAttrs@gsLineColor      = "Orange"
    arrowAttrs@gsLineThicknessF = 8
    ;; 绘制爱神之箭，底部图层之箭体部分
    arrow0 = gsn_add_polyline(wks, home, fspan(-25, 0, 2), k*fspan(-25, 0, 2), arrowAttrs)
    ;; 绘制男友之真红心
    boyHeart = gsn_add_polygon(wks, home, x+heartDistX, y+heartDistY, boyAttrs)
    ;; 绘制女友之真红心
    girlHeart = gsn_add_polygon(wks, home, x, y, girlAttrs)
    
    ;; 绘制爱神之箭，顶部图层之箭体部分
    arrow1 = gsn_add_polyline(wks, home, fspan(0, 15, 2), k*fspan(0, 15, 2), arrowAttrs)
    arrowAttrs@gsMarkerIndex = NhlNewMarker(wks, ">", 1, 0, 0, 1, 4, atan(k)*45.0/atan(1.0))
    arrowAttrs@gsMarkerThicknessF = 10
    arrowAttrs@gsMarkerColor = "Orange"
    ;; 绘制爱神之箭，箭头部分
    arrow2 = gsn_add_polymarker(wks, home, 15-0.5, k*(15-0.5), arrowAttrs)
    ;; 绘制爱神之箭，箭尾部分
    arrow3 = gsn_add_polymarker(wks, home, -25-1.2, k*(-25-1.2), arrowAttrs)
    arrow4 = gsn_add_polymarker(wks, home, -25-2.4, k*(-25-2.4), arrowAttrs)

    ;;-------------文本部分----------------
    titleAttrs = True
    titleAttrs@txFont = "simplex_script"
    plainAttrs = titleAttrs
    titleAttrs@txFontHeightF = 26
    plainAttrs@txFontHeightF = 16
    ;; 标题
    title = gsn_add_text(wks, home, "Happy everyday", 0+heartDistX/2., 20, titleAttrs)
    ;; 绘制格式文本
    from = gsn_add_text(wks, home, "From ~F14~:", 11, 14, plainAttrs)
    ;; 绘制格式文本
    to = gsn_add_text(wks, home, "To ~F14~:", -25, -15, plainAttrs)
    ;; 绘制爱之宣言
    oathText = "The play is over but the audience may not just say goodbye, ~C~~C~" + \
               "    and people with love are destined to reunite."
    oath = gsn_add_text(wks, home, oathText, 0+heartDistX/2., -20, plainAttrs)

    subjectAttrs = True
    subjectAttrs@txFont = "triplex_italic"
    subjectAttrs@txFontHeightF = 15
    predicateAttrs = subjectAttrs
    ;; 绘制落款人
    subject = gsn_add_text(wks, home, "落款", 12, -24, subjectAttrs)
    ;; 绘制收信人
    predicate = gsn_add_text(wks, home, "lovers", -20, -15, predicateAttrs)
    draw(home)
    frame(wks)
    sleep(10)
end
