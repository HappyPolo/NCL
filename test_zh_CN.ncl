load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/writeslhz/writeslhz.ncl" ; 
begin
;;--Plot a blank figure
; if you want look the dotting process, use X11 (very slowly)
; Generally a postscripts is a good choice
    type = "PS" 
    wks = gsn_open_wks("x11", "test")
   ; plot = new(4, graphic)
    res = True
    res@gsnDraw = False
    res@gsnFrame = False
    res@tiMainString = ""
    res@gsnLeftString = ""         
    res@gsnRightString = ""        
    res@tiXAxisString = ""
    res@tiYAxisString = ""
    res@tmXBMode = "Explicit"
    res@tmXBValues = fspan(0, 1, 6)
    ;res@tmXBLabels = (/"", "", "", "", "", ""/)

    res@tmYLMode = "Explicit"
    res@tmYLValues = fspan(0, 1, 10)
    ;res@tmYLLabels = (/"", "", "", "", "", "", "", "", "", ""/)

    plot = gsn_csm_blank_plot(wks, res)



    drawNDCGrid(wks)

    res = True
    res@tiMainString = "主标题"
    res@tiMainFontName ="HTJ"
    res@tiMainFontSize =0.03
    res@tiMainFontColor ="black"

    res@gsnLeftString = "左字符串" 
    res@gsnLeftFontName = "STJ"
    res@gsnLeftFontSize = 0.03 
    res@gsnLeftFontColor = "blue"

    res@gsnRightString = "右字符串" 
    res@gsnRightFontName = "STJ"  
    res@gsnRightFontSize = 0.03
    res@gsnRightFontColor = "yellow"

    res@tiXAxisString = "横坐标标题"
    res@gtiXAxisFontName = "STJ"
    res@gtiXAxisFontSize =0.03
    res@gtiXAxisFontColor ="RoyalBlue"

    res@tiYAxisString = "纵坐标标题"
    res@gtiYAxisFontName = "STJ"
    res@gtiYAxisFontSize = 0.03
    res@gtiYAxisFontColor = "IndianRed"

    res@tmXBLabels = (/"一月", "二月", "三月", "四月", "五月", "六月"/)
    res@tmXBLabelsFontName = "FSJ"
    res@tmXBLabelsFontSize = 0.03
    res@tmXBLabelsFontColor = "PaleGreen"

    res@tmYLLabels = (/"一", "二", "三", "四", "五", "六", "七", "八", "九", "十"/)
    res@tmYLLabelsFontName = "FSJ"
    res@tmYLLabelsFontSize =0.03
    res@tmYLLabelsFontColor = "Khaki"

    writeTitle(wks, plot, res)
    
     

    ftres = True
    ftres@fontSize = 0.02 ;字体的大小
    ftres@fontAngleF = 0. ;旋转的角度
    ftres@fontJust = "CenterCenter"  ;对齐方式
    ftres@fontName = "FSJ"   ; 字体：FSJ,STJ,HTJ
    ftres@fontColor = "blue" ;字体颜色
    ftres@fontXoffsetF = 0  ;x方向的偏移值
    ftres@fontYoffsetF = 0  ;y方向的偏移值
    ftres@fontcnxsize = 1.5  ;中文横向比率
    ftres@fontenxsize = 0.8  ;英文横向比率

    writeslhz(wks, "NCL绘图软件矢量汉字书写支持",0.5,0.4,ftres);

    ftres@fontName="STJ"
    ftres@fontSize = 0.03
    ftres@fontColor = "black" ;字体颜色
    ftres@fontcnxsize = 1.0  ;中文横向比率
    ftres@fontenxsize = 1.0  ;中文横向比率

    writeslhz(wks, "NCL绘图软件矢量汉字书写支持",0.5,0.5,ftres);
    ftres@fontName="HTJ"
    ftres@fontSize = 0.05
    writeslhz(wks, "NCL绘图软件矢量汉字书写支持",0.5,0.6,ftres);
    draw(plot)    
    frame(wks)

end 
