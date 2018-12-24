;;******************************************************************************
;;           FUNCTION writeslhz for NCL Ver:1.0
;;  �������ȡ�����ĺ���ʸ���ֿ����ݣ�����NCL���йغ�������ɺ��ֵ�ʸ��
;;  �������ʾ������ 
;;  
;;  ����������Redhat Linux Server ver:6.5 ��NCAR Command Language Version 6.4.0
;;  �ϲ���ͨ��,�����İ汾û���������ԡ�
;;  ���ߣ� Lu Jianjun ³����  ����������� 
;;  �汾��Ver:1.0
;;  ������2018.02.24 
;;  ����޸ģ�2018.03.07
;; Copyright�0�82018 [Lujianjun]��³����  ��ַ������ʡ�����������  
;; ��Ȩ���У���������ҵ��;ʹ�ñ�������ֿ⣬���߱���ʹ�ñ�������ֿ⡣
;; ���ȷʵҵ����Ҫ����ҵ��;��Ҫ���ɻ��߱���ʹ�ô˳�����ֿ⣬����ϵ�ҡ�
;; email: hsljj@163.com  QQ:273603861
;;  ����˵����
;;       ������ΪNCL��д��ʾ���֣�֧�֡�֧�����ֵ�����,������ɫ����ת�������壬�����壬���뷽ʽ�Ȳ����趨��
;;  ��Ӣ�Ļ���ִ�ֻҪNCL����, ����Ϊ����ĳ���.֧����ʾһ���ֿ⺺��3755��, �����ֿ⺺��3008��,��ʱ��֧��ȫ���ַ���
;;  ֧��x-y���꺺�ֱ���ͱ�ǩ��ʾ��
;;       ����ʹ�÷�����test.ncl
;;  ��װ
;;  ��writeslhz1.0.tar.gz��ѹ��$NCARG_ROOTĿ¼�¡�
;;
;;  ����:ncl test.ncl �����н��, ^_^
;;  ����˵����
;;       ������֧����Դ�������趨  res
;;       res@fontSize = 0.03
;;       res@fontColor = "black"
;;       res@fontName = "STJ"
;;       res@fontXoffsetF = 0.
;;       res@fontYoffsetF = 0.
;;       res@fontAngleF = 0.
;;       res@fontJust = "BottomCenter"
;;       res@fontcnxsize = 1.0
;;       res@fontenxsize = 0.6
;;       fontSize: ����Ĵ�С[default=0.03]
;;       fontAngleF:��ת�ĽǶ�[default=0.],��ʱ����ת�� ����ȡ�����ʵ��. 0,360=ˮƽ 90=��ֱ 180=����
;;       fontJust:���뷽ʽ[default="BottomCenter"],
;;                        9�ֶ��뷽ʽ,"bottomleft","bottomright","bottomcenter",
;;                           "topleft","topright","topcenter",
;;                            "centerleft","centerright","centercenter"
;;       fontName:����[default="STJ"],��ѡ����FSJ,STJ,HTJ(�ֱ�Ϊ�����μ��壬������壬�������)
;;       fontColor:������ɫ[default="black"],��ȡNCL֧�ֵ�������ɫ
;;       fontXoffsetF:x�����ƫ��ֵ[default=0.0],��ȡ����ʵ��
;;       fontYoffsetF:y�����ƫ��ֵ[default=0.0],��ȡ����ʵ��
;;       fontcnxsize:���ĺ������[default=1.0], ����ȡ�������0��ʵ��
;;       fontenxsize:Ӣ�ĺ������[default=0.6], ����ȡ�������0��ʵ��
;;
;;       writeslhz(wks, str, x, y, ftres) 
;;          str:��д���ַ���;   x,y:��λ�����꣬  ftres:�����趨����Դ
;;
;;       writeTitle(wks, plot, hzres)
;;           wks:workstation;  plot:��ͼ�Ķ���  hzres:plot����Դ�趨������ʹ�ü�test.ncl
;;
;; Ver:1.0  2018.03.07
;;               
;;******************************************************************************
;;==============================================================================
;;--Global variables list
debug = False
;;==============================================================================



;;---------------------------------------------------------------------------------
;; ͳ���ַ�����ASCII�ĸ���
;;---------------------------------------------------------------------------------
undef("CountStrAscii")
function CountStrAscii(str)
local str,num
begin
    len=strlen(str)
    num=0
    intChar = toint(tochar(str))
    do i=0,len-1
       if(intChar(i).lt.128) then
           num=num+1
       end if
    end do
    return num
end

;;==============================================================================
undef("writeslhz")
procedure writeslhz(wks, str, x, y, ftres)
local wks, str, x, y, ftres
begin
;;--Define Default Attribute
    res = True
    res@fontSize = 0.03
    res@fontColor = "black"
    res@fontName = "STJ"
    res@fontXoffsetF = 0.
    res@fontYoffsetF = 0.
    res@fontAngleF = 0.
    res@fontJust = "BottomCenter"
    res@fontcnxsize = 1.0
    res@fontenxsize = 0.6
    res = ftres
;-------------------------------------------------------------------------
;�����Ĵ���
;-------------------------------------------------------------------------
    cnsize = res@fontSize;//�����С
    enxsize = res@fontenxsize;Ӣ�ĵı���
    ensize = enxsize*cnsize;Ӣ�Ĵ�С

    ;enxsize = 0.6*cnsize;
    cnangle = res@fontAngleF;//0.0;��ת�Ƕ�
    cnxsize = res@fontcnxsize;����x����ı���
    
    hzsize=96;���ֱ�׼�Ĵ�С  
    xpos=x+res@fontXoffsetF;
    ypos=y+res@fontYoffsetF; 

    strlength=strlen(str)

;-------------------------------------------------------------------------
; ���뷽ʽ�Ĵ���
; ���¶���---Bottom,Top,Center
; ���Ҷ���--Left,Right,Center
; strlength:�ַ�������,numAscii:Ascii����,numHZ:���ֵĸ���
; writestrlength:д�ַ�����ʵ�ʳ���
;-------------------------------------------------------------------------
   
    numAscii=CountStrAscii(str)
    numHZ=toint((strlength-numAscii)/2.0)
    writestrlength=numHZ*cnsize*cnxsize+numAscii*ensize;

    fontJustChar=(/"bottomleft","bottomright","bottomcenter","topleft","topright","topcenter","centerleft","centerright","centercenter"/)
    fontJustNum=(/1,1,1,2,1,3,2,1,2,2,2,3,3,1,3,2,3,3/)
    fontJust = str_lower(res@fontJust);ȫ���ַ�תΪСд
    do i=0,8,1
        if(fontJustChar(i).eq.fontJust) then              
            break
        end if
    end do
    if i.eq.9 then
        print("error res@fontJust parameter!")
        exit
    end if
;print("i="+i+",Justnum="+fontJustNum(2*i+1))

;���¶��뷽ʽ bottom,top,right
    if(fontJustNum(2*i).eq.1) then ;bottom
        ;ypos=y+res@fontYoffsetF;
        y1=res@fontYoffsetF; 
    else 
       if(fontJustNum(2*i).eq.2) then ;top
          ;ypos=y+res@fontYoffsetF-cnsize*cnxsize; 
          y1=res@fontYoffsetF-cnsize*cnxsize; 
       else  ;center
          ;ypos=y+res@fontYoffsetF-cnsize*cnxsize/2.; 
          y1=res@fontYoffsetF-cnsize*cnxsize/2.; 
       end if
    end if

;���Ҷ��뷽ʽ left,right,center

    if(fontJustNum(2*i+1).eq.1) then ;left
       x1=res@fontXoffsetF;
    else 
       if(fontJustNum(2*i+1).eq.2) then ;right
          x1=res@fontXoffsetF-writestrlength
       else  ;center
          x1=res@fontXoffsetF-writestrlength/2.
       end if
    end if
    if(debug) then
       print("cnsize="+cnsize+",ensize="+ensize+",cnangle="+cnangle+",xpos="+xpos+",ypos="+ypos)
    end if
    

;-------------------------------------------------------------------------
; ���뷽ʽ�Ĵ���  end
;-------------------------------------------------------------------------

;-------------------------------------------------------------------------
; ��ת�ĽǶȵĴ���  
;-------------------------------------------------------------------------
    cnrotation=cnangle*3.14159265359/180.
;**����sin��cos��ֵ
    sinrotation=sin(cnrotation)
    cosrotation=cos(cnrotation)
;print("sin="+sinrotation+",cos="+cosrotation);
;-------------------------------------------------------------------------
; xpos,ypos�Ĵ���  
;-------------------------------------------------------------------------
    xpos=x+x1*cosrotation-y1*sinrotation
    ypos=y+y1*cosrotation+x1*sinrotation 
;-------------------------------------------------------------------------
; �����ļ��Ĵ���  
;-------------------------------------------------------------------------
    fontnames=(/"FSJ","STJ","HTJ"/)
    fontfiles=(/"SLHZKFSJ.DAT","SLHZKSTJ.DAT","SLHZKHTJ.DAT"/)
    fontnum=3
    do i=0,fontnum-1
        if(fontnames(i).eq.res@fontName) then              
            break
        end if         
    end do
    if i.eq.fontnum then
        print("error res@fontName parameter!")
        exit
    end if
    fontfilename="$NCARG_ROOT/writeslhz/"+fontfiles(i)
;-------------------------------------------------------------------------
; ���º��ֵĴ���  
;-------------------------------------------------------------------------
;**���ּ���
    hzcount = 0
;**��ĸ����
    encount = 0

    dat = cbinread(fontfilename, -1, "float")

    intChar = toint(tochar(str))

    strcount=0
    flag = 0
;������ѭ��
do while ( 1 .gt. 0 )  
       if(strcount.eq.strlength) then
         break;
       end if
;**  �����ִ������    
    cxx=hzcount*cnsize*cnxsize+encount*ensize;
;**�ж��Ƿ�Ϊ���� flag=1,���֣�flag=0,Ӣ��
    if( intChar(strcount) .lt. 128) then
       encount = encount+1
       flag = 0
     else   
       hzcount = hzcount+1 
       flag = 1
     end if


  if(flag.eq.1) then
;**�������ֲ��� 
    cx=0
    cy=0

;**������ʼ��
      if(flag.eq.1)
           qu=intChar(strcount)-160
           strcount=strcount+1
           wei=intChar(strcount)-160
           strcount=strcount+1
      ;print("qu="+qu+",wei="+wei)
      end if  
      i=((qu-1)*94+(wei-1))*3+50    
;�õ���λ��
      qwm=dat(i)       
;�õ�����������ʼλ��  len
       x1=dat(i+1)
       y1=dat(i+2)
       len=toint(y1+x1*65536)
       i = len +1

;��ʼѭ��,
    do while ( 1.gt. 0 )  
       temp=dat(i)
 
       if toint(temp).eq.0 then 
          break;  
       end if

       p_num=toint(temp) 
       i=i+1  
       xx=fspan(0,p_num,p_num+1)    
       yy=fspan(0,p_num,p_num+1)
   

       do n=0,p_num-1,1   
          temp=dat(i)
          
          x1=floor(temp/100.);��ȡ���� x1,y1
          y1=temp-x1*100              
          y1=hzsize-y1

          x1=x1/hzsize*cnxsize*cnsize+cxx
          y1=y1/hzsize*cnsize


          xx1=xpos+x1*cosrotation-y1*sinrotation
          yy1=ypos+y1*cosrotation+x1*sinrotation 

        
          xx(n)=xx1;
          yy(n)=yy1;
          i = i+1;         
       end do
       xx(p_num)=xx(0)
       yy(p_num)=yy(0)

       gres                 = True
       gres@gsFillColor     = res@fontColor;
       ;dum0 = gsn_add_polygon(wks,plot,xx,yy,res)
        gsn_polygon_ndc(wks,xx,yy,gres) ; 
  
       delete(xx);
       delete(yy);
       
    end do
; ѭ������

  else

     txres               = True                 
     txres@txFontHeightF = cnsize*1.0        
     txres@txJust        = "bottomLeft"
     txres@txAngleF      = cnangle
     txres@txFontAspectF      = 1.0/(enxsize-0.2)
     txres@txConstantSpacingF = 0.0
     txres@txFontColor = res@fontColor
     cnx=xpos+cxx*cosrotation
     cny=ypos+cxx*sinrotation 

     gsn_text_ndc(wks,tochar(intChar(strcount)),cnx,cny,txres)
     strcount=strcount+1
  end if

end do  
; �����ѭ������ 

end



;;--------------------------------------------------------------------------
;; ������str�Ƿ�������
;;--------------------------------------------------------------------------
undef("strHZCheck")
function strHZCheck(str)
begin
    intChar = toint(tochar(str))
    if(max(intChar).lt.128)then
        return False
    else
        return True
    end if
end


;;--------------------------------------------------------------------------
;; writeXYBLabels 
;;--------------------------------------------------------------------------
undef("writeXYLabels")
procedure writeXYLabels(wks, str, x, y, ftres)
begin
    do i = 0, dimsizes(str)-1
        if (dimsizes(y).eq.1) then
            writeslhz(wks,  str(i), x(i), y, ftres)
        else if (dimsizes(x).eq.1) then
            writeslhz(wks, str(i), x, y(i), ftres)
        else
            writeslhz(wks, str(i), x(i), y(i), ftres)
        end if
        end if
    end do
end

;;----------------------------------------------------------------------------
;; writeTitle д�����
;;----------------------------------------------------------------------------
undef("writeTitle")
procedure writeTitle(wks, plot, hzres)
begin
res = True
    res@tiMainString = ""
    res@tiMainFontName = "HTJ"
    res@tiMainFontSize = 0.03
    res@tiMainFontColor = "black"

    res@gsnLeftString = "" 
    res@gsnLeftFontName = "STJ"
    res@gsnLeftFontSize = 0.03
    res@gsnLeftFontColor = "black" 

    res@gsnRightString = "" 
    res@gsnRightFontName = "STJ"  
    res@gsnRightFontSize = 0.03 
    res@gsnRightFontColor = "black"
 
    res@tiXAxisString = ""
    res@gtiXAxisFontName = "STJ"
    res@gtiXAxisFontSize = 0.03
    res@gtiXAxisFontColor = "black"

    res@tiYAxisString = ""
    res@gtiYAxisFontName = "STJ"
    res@gtiYAxisFontSize = 0.03
    res@gtiYAxisFontColor = "black"

    res@tmXBLabelsFontName = "FSJ"
    res@tmXBLabelsFontSize = 0.03
    res@tmXBLabelsFontColor = "black"

    res@tmYLLabelsFontName = "FSJ"
    res@tmYLLabelsFontSize = 0.03
    res@tmYLLabelsFontColor = "black"
      
    res=hzres;���ݲ�����û�и�ֵ�ľ���ȱʡֵ��

    hasMainString = isatt(res,"tiMainString").and.strHZCheck(res@tiMainString)
    hasLeftString = isatt(res,"tiXAxisString").and.strHZCheck(res@gsnLeftString)
    hasRightString = isatt(res,"tiYAxisString").and.strHZCheck(res@gsnRightString)
    hasXAxisString = isatt(res,"tiXAxisString").and.strHZCheck(res@tiXAxisString)
    hasYAxisString = isatt(res,"tiYAxisString").and.strHZCheck(res@tiYAxisString)
    hasXBLabels = isatt(res,"tmXBLabels").and.strHZCheck(res@tmXBLabels)
    hasYLLabels = isatt(res,"tmYLLabels").and.strHZCheck(res@tmYLLabels)

;;--��ñ�ǩ���������
    getvalues plot
        "vpXF"          : vpx
        "vpYF"          : vpy
        "vpWidthF"      : vpw
        "vpHeightF"     : vph
        "tmXBValues"    : XBV
        "tmYLValues"    : YLV
        "tmXBMajorLengthF": tXBML
        "tmYLMajorLengthF": tYLML
        "tmXTMajorOutwardLengthF" : tXTMOL
    end getvalues
;;~~~~~~~~~~~~~~~~~~~~ ������~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if(hasMainString)then
        ftres = True
        ftres@fontJust = "BottomCenter"
        ftres@fontSize = res@tiMainFontSize
        ftres@fontName = res@tiMainFontName
        ftres@fontColor = res@tiMainFontColor
        writeslhz(wks, res@tiMainString, vpx+vpw/2., vpy+4*tXTMOL, ftres)
    end if
;;~~~~~~~~~~~~~~~~~~~~�󸱱���~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if(hasLeftString)then
        ftres = True
        ftres@fontJust = "BottomLeft"
        ftres@fontSize = res@gsnLeftFontSize
        ftres@fontName = res@gsnLeftFontName
        ftres@fontColor = res@gsnLeftFontColor
        writeslhz(wks, res@gsnLeftString, vpx, vpy+tXTMOL, ftres)
    end if
;;~~~~~~~~~~~~~~~~~~~~�Ҹ�����~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if(hasRightString)then
        ftres = True
        ftres@fontJust = "BottomRight"
        ftres@fontSize = res@gsnRightFontSize
        ftres@fontName = res@gsnRightFontName 
        ftres@fontColor = res@gsnRightFontColor 
        writeslhz(wks, res@gsnRightString, vpx+vpw, vpy+tXTMOL, ftres)
    end if
;;~~~~~~~~~~~~~~~X �� ˵�� ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if(hasXAxisString)then
        ftres = True
        ftres@fontJust = "CenterCenter"
        ftres@fontSize = res@gtiXAxisFontSize
        ftres@fontName = res@gtiXAxisFontName
        ftres@fontColor = res@gtiXAxisFontColor
        XBV_NDC := XBV
        YLV_NDC := XBV
        datatondc(plot, XBV, onedtond(YLV(0), dimsizes(XBV)), XBV_NDC, YLV_NDC)
        writeslhz(wks, res@tiXAxisString, vpx+vpw/2., YLV_NDC(0)-6*tXBML, ftres)
    end if 

;;~~~~~~~~~~~~~~~Y �� ˵�� ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if(hasYAxisString)then
        ftres = True
        ftres@fontJust = "CenterCenter"
        ftres@fontSize = res@gtiYAxisFontSize
        ftres@fontName = res@gtiYAxisFontName
        ftres@fontColor = res@gtiYAxisFontColor
        ftres@fontAngleF = 90
        XBV_NDC := YLV
        YLV_NDC := YLV
        datatondc(plot, onedtond(XBV(0), dimsizes(YLV)), YLV, XBV_NDC, YLV_NDC)
        writeslhz(wks, res@tiYAxisString, XBV_NDC(0)-6*tYLML, vpy-vph/2., ftres)
    end if
;;~~~~~~~~~~~~~~~X �� ��ǩ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if(hasXBLabels)then
        ;print("Font XBLabels")
        ftres = True
        ftres@fontJust = "TopCenter"
        ftres@fontSize = res@tmXBLabelsFontSize
        ftres@fontName = res@tmXBLabelsFontName
        ftres@fontColor = res@tmXBLabelsFontColor
        ftres@fontAngleF = 0
        XBV_NDC := XBV
        YLV_NDC := XBV
        datatondc(plot, XBV, onedtond(YLV(0), dimsizes(XBV)), XBV_NDC, YLV_NDC)
        writeXYLabels(wks, res@tmXBLabels, XBV_NDC, YLV_NDC(0)-2*tXBML, ftres)
    end if
;;~~~~~~~~~~~~~~~y �� ��ǩ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if(hasYLLabels)then
        ;print("Font YLLabels")
        ftres = True
        ftres@fontJust = "CenterRight"
        ftres@fontSize = res@tmYLLabelsFontSize
        ftres@fontName = res@tmYLLabelsFontName
        ftres@fontColor = res@tmYLLabelsFontColor
        ftres@fontAngleF = 0
        XBV_NDC := YLV
        YLV_NDC := YLV
        datatondc(plot, onedtond(XBV(0), dimsizes(YLV)), YLV, XBV_NDC, YLV_NDC)
        writeXYLabels(wks, res@tmYLLabels, XBV_NDC(0)-2*tYLML, YLV_NDC, ftres)
    end if 

end
