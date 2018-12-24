load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/writeslhz/writeslhz.ncl" ; 
begin
;;--Plot a blank figure
; if you want look the dotting process, use X11 (very slowly)
; Generally a postscripts is a good choice
    type = "PS" 
    wks = gsn_open_wks(type, "test")
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
    res@tiMainString = "������"
    res@tiMainFontName ="HTJ"
    res@tiMainFontSize =0.03
    res@tiMainFontColor ="black"

    res@gsnLeftString = "���ַ���" 
    res@gsnLeftFontName = "STJ"
    res@gsnLeftFontSize = 0.03 
    res@gsnLeftFontColor = "blue"

    res@gsnRightString = "���ַ���" 
    res@gsnRightFontName = "STJ"  
    res@gsnRightFontSize = 0.03
    res@gsnRightFontColor = "yellow"

    res@tiXAxisString = "���������"
    res@gtiXAxisFontName = "STJ"
    res@gtiXAxisFontSize =0.03
    res@gtiXAxisFontColor ="RoyalBlue"

    res@tiYAxisString = "���������"
    res@gtiYAxisFontName = "STJ"
    res@gtiYAxisFontSize = 0.03
    res@gtiYAxisFontColor = "IndianRed"

    res@tmXBLabels = (/"һ��", "����", "����", "����", "����", "����"/)
    res@tmXBLabelsFontName = "FSJ"
    res@tmXBLabelsFontSize = 0.03
    res@tmXBLabelsFontColor = "PaleGreen"

    res@tmYLLabels = (/"һ", "��", "��", "��", "��", "��", "��", "��", "��", "ʮ"/)
    res@tmYLLabelsFontName = "FSJ"
    res@tmYLLabelsFontSize =0.03
    res@tmYLLabelsFontColor = "Khaki"

    writeTitle(wks, plot, res)
    
     

    ftres = True
    ftres@fontSize = 0.02 ;����Ĵ�С
    ftres@fontAngleF = 0. ;��ת�ĽǶ�
    ftres@fontJust = "CenterCenter"  ;���뷽ʽ
    ftres@fontName = "FSJ"   ; ���壺FSJ,STJ,HTJ
    ftres@fontColor = "blue" ;������ɫ
    ftres@fontXoffsetF = 0  ;x�����ƫ��ֵ
    ftres@fontYoffsetF = 0  ;y�����ƫ��ֵ
    ftres@fontcnxsize = 1.5  ;���ĺ������
    ftres@fontenxsize = 0.8  ;Ӣ�ĺ������

    writeslhz(wks, "NCL��ͼ����ʸ��������д֧��",0.5,0.4,ftres);

    ftres@fontName="STJ"
    ftres@fontSize = 0.03
    ftres@fontColor = "black" ;������ɫ
    ftres@fontcnxsize = 1.0  ;���ĺ������
    ftres@fontenxsize = 1.0  ;���ĺ������

    writeslhz(wks, "NCL��ͼ����ʸ��������д֧��",0.5,0.5,ftres);
    ftres@fontName="HTJ"
    ftres@fontSize = 0.05
    writeslhz(wks, "NCL��ͼ����ʸ��������д֧��",0.5,0.6,ftres);
    draw(plot)    
    frame(wks)

end 