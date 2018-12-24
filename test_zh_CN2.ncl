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
    res@tiMainString = "¿¿"
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
    res@tiMainString = ""
    res@tiMainFontName ="HTJ"
    res@tiMainFontSize =0.03
    res@tiMainFontColor ="black"

    res@gsnLeftString = "×ó×Ö·û´®" 
    res@gsnLeftFontName = "STJ"
    res@gsnLeftFontSize = 0.03 
    res@gsnLeftFontColor = "blue"

    res@gsnRightString = "ÓÒ×Ö·û´®" 
    res@gsnRightFontName = "STJ"  
    res@gsnRightFontSize = 0.03
    res@gsnRightFontColor = "yellow"

    res@tiXAxisString = "横轴"
    res@gtiXAxisFontName = "STJ"
    res@gtiXAxisFontSize =0.03
    res@gtiXAxisFontColor ="RoyalBlue"

    res@tiYAxisString = "×Ý×ø±ê±êÌâ"
    res@gtiYAxisFontName = "STJ"
    res@gtiYAxisFontSize = 0.03
    res@gtiYAxisFontColor = "IndianRed"

    res@tmXBLabels = (/"Ò»ÔÂ", "¶þÔÂ", "ÈýÔÂ", "ËÄÔÂ", "ÎåÔÂ", "ÁùÔÂ"/)
    res@tmXBLabelsFontName = "FSJ"
    res@tmXBLabelsFontSize = 0.03
    res@tmXBLabelsFontColor = "PaleGreen"

    res@tmYLLabels = (/"Ò»", "¶þ", "Èý", "ËÄ", "Îå", "Áù", "Æß", "°Ë", "¾Å", "Ê®"/)
    res@tmYLLabelsFontName = "FSJ"
    res@tmYLLabelsFontSize =0.03
    res@tmYLLabelsFontColor = "Khaki"

    writeTitle(wks, plot, res)
    
     

    ftres = True
    ftres@fontSize = 0.02 ;×ÖÌåµÄ´óÐ¡
    ftres@fontAngleF = 0. ;Ðý×ªµÄ½Ç¶È
    ftres@fontJust = "CenterCenter"  ;¶ÔÆë·½Ê½
    ftres@fontName = "FSJ"   ; ×ÖÌå£ºFSJ,STJ,HTJ
    ftres@fontColor = "blue" ;×ÖÌåÑÕÉ«
    ftres@fontXoffsetF = 0  ;x·½ÏòµÄÆ«ÒÆÖµ
    ftres@fontYoffsetF = 0  ;y·½ÏòµÄÆ«ÒÆÖµ
    ftres@fontcnxsize = 1.5  ;ÖÐÎÄºáÏò±ÈÂÊ
    ftres@fontenxsize = 0.8  ;Ó¢ÎÄºáÏò±ÈÂÊ

    writeslhz(wks, "NCL»æÍ¼Èí¼þÊ¸Á¿ºº×ÖÊéÐ´Ö§³Ö",0.5,0.4,ftres);

    ftres@fontName="STJ"
    ftres@fontSize = 0.03
    ftres@fontColor = "black" ;×ÖÌåÑÕÉ«
    ftres@fontcnxsize = 1.0  ;ÖÐÎÄºáÏò±ÈÂÊ
    ftres@fontenxsize = 1.0  ;ÖÐÎÄºáÏò±ÈÂÊ

    writeslhz(wks, "NCL»æÍ¼Èí¼þÊ¸Á¿ºº×ÖÊéÐ´Ö§³Ö",0.5,0.5,ftres);
    ftres@fontName="HTJ"
    ftres@fontSize = 0.05
    writeslhz(wks, "NCL»æÍ¼Èí¼þÊ¸Á¿ºº×ÖÊéÐ´Ö§³Ö",0.5,0.6,ftres);
    draw(plot)    
    frame(wks)

end 
