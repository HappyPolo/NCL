;;******************************************************************************
;;           FUNCTION writeslhz for NCL Ver:1.0
;;  本程序读取真正的汉字矢量字库数据，利用NCL的有关函数，完成汉字的矢量
;;  字体的显示处理。 
;;  
;;  本程序是在Redhat Linux Server ver:6.5 的NCAR Command Language Version 6.4.0
;;  上测试通过,其他的版本没有做过测试。
;;  作者： Lu Jianjun 鲁建军  鄂州市气象局 
;;  版本：Ver:1.0
;;  创建：2018.02.24 
;;  最后修改：2018.03.07
;; Copyright©2018 [Lujianjun]，鲁建军  地址：湖北省鄂州市气象局  
;; 版权所有，请勿在商业用途使用本程序和字库，或者变相使用本程序和字库。
;; 如果确实业务需要或商业用途需要集成或者变相使用此程序或字库，请联系我。
;; email: hsljj@163.com  QQ:273603861
;;  功能说明：
;;       本程序为NCL书写显示汉字，支持。支持文字的字体,字体颜色，旋转，长字体，扁字体，对齐方式等参数设定，
;;  中英文混合字串只要NCL允许, 可以为任意的长度.支持显示一级字库汉字3755个, 二级字库汉字3008个,暂时不支持全角字符。
;;  支持x-y坐标汉字标题和标签显示。
;;       具体使用方法见test.ncl
;;  安装
;;  将writeslhz1.0.tar.gz解压在$NCARG_ROOT目录下。
;;
;;  测试:ncl test.ncl 看运行结果, ^_^
;;  参数说明：
;;       本程序支持资源参数的设定  res
;;       res@fontSize = 0.03
;;       res@fontColor = "black"
;;       res@fontName = "STJ"
;;       res@fontXoffsetF = 0.
;;       res@fontYoffsetF = 0.
;;       res@fontAngleF = 0.
;;       res@fontJust = "BottomCenter"
;;       res@fontcnxsize = 1.0
;;       res@fontenxsize = 0.6
;;       fontSize: 字体的大小[default=0.03]
;;       fontAngleF:旋转的角度[default=0.],逆时针旋转， 可以取任意的实数. 0,360=水平 90=垂直 180=倒立
;;       fontJust:对齐方式[default="BottomCenter"],
;;                        9种对齐方式,"bottomleft","bottomright","bottomcenter",
;;                           "topleft","topright","topcenter",
;;                            "centerleft","centerright","centercenter"
;;       fontName:字体[default="STJ"],可选参数FSJ,STJ,HTJ(分别为：仿宋简体，宋体简体，黑体简体)
;;       fontColor:字体颜色[default="black"],可取NCL支持的所有颜色
;;       fontXoffsetF:x方向的偏移值[default=0.0],可取所有实数
;;       fontYoffsetF:y方向的偏移值[default=0.0],可取所有实数
;;       fontcnxsize:中文横向比率[default=1.0], 可以取任意大于0的实数
;;       fontenxsize:英文横向比率[default=0.6], 可以取任意大于0的实数
;;
;;       writeslhz(wks, str, x, y, ftres) 
;;          str:书写的字符串;   x,y:定位的坐标，  ftres:字体设定的资源
;;
;;       writeTitle(wks, plot, hzres)
;;           wks:workstation;  plot:画图的对象；  hzres:plot的资源设定，具体使用见test.ncl
;;
;; Ver:1.0  2018.03.07
;;               
;;******************************************************************************
;;==============================================================================
;;--Global variables list
debug = False
;;==============================================================================



;;---------------------------------------------------------------------------------
;; 统计字符串中ASCII的个数
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
;参数的处理
;-------------------------------------------------------------------------
    cnsize = res@fontSize;//字体大小
    enxsize = res@fontenxsize;英文的比率
    ensize = enxsize*cnsize;英文大小

    ;enxsize = 0.6*cnsize;
    cnangle = res@fontAngleF;//0.0;旋转角度
    cnxsize = res@fontcnxsize;汉字x方向的比率
    
    hzsize=96;汉字标准的大小  
    xpos=x+res@fontXoffsetF;
    ypos=y+res@fontYoffsetF; 

    strlength=strlen(str)

;-------------------------------------------------------------------------
; 对齐方式的处理
; 上下对齐---Bottom,Top,Center
; 左右对齐--Left,Right,Center
; strlength:字符串长度,numAscii:Ascii个数,numHZ:汉字的个数
; writestrlength:写字符串的实际长度
;-------------------------------------------------------------------------
   
    numAscii=CountStrAscii(str)
    numHZ=toint((strlength-numAscii)/2.0)
    writestrlength=numHZ*cnsize*cnxsize+numAscii*ensize;

    fontJustChar=(/"bottomleft","bottomright","bottomcenter","topleft","topright","topcenter","centerleft","centerright","centercenter"/)
    fontJustNum=(/1,1,1,2,1,3,2,1,2,2,2,3,3,1,3,2,3,3/)
    fontJust = str_lower(res@fontJust);全部字符转为小写
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

;上下对齐方式 bottom,top,right
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

;左右对齐方式 left,right,center

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
; 对齐方式的处理  end
;-------------------------------------------------------------------------

;-------------------------------------------------------------------------
; 旋转的角度的处理  
;-------------------------------------------------------------------------
    cnrotation=cnangle*3.14159265359/180.
;**计算sin和cos的值
    sinrotation=sin(cnrotation)
    cosrotation=cos(cnrotation)
;print("sin="+sinrotation+",cos="+cosrotation);
;-------------------------------------------------------------------------
; xpos,ypos的处理  
;-------------------------------------------------------------------------
    xpos=x+x1*cosrotation-y1*sinrotation
    ypos=y+y1*cosrotation+x1*sinrotation 
;-------------------------------------------------------------------------
; 字体文件的处理  
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
; 以下汉字的处理  
;-------------------------------------------------------------------------
;**汉字计数
    hzcount = 0
;**字母计数
    encount = 0

    dat = cbinread(fontfilename, -1, "float")

    intChar = toint(tochar(str))

    strcount=0
    flag = 0
;最外层的循环
do while ( 1 .gt. 0 )  
       if(strcount.eq.strlength) then
         break;
       end if
;**  画汉字串的起点    
    cxx=hzcount*cnsize*cnxsize+encount*ensize;
;**判断是否为汉字 flag=1,汉字，flag=0,英文
    if( intChar(strcount) .lt. 128) then
       encount = encount+1
       flag = 0
     else   
       hzcount = hzcount+1 
       flag = 1
     end if


  if(flag.eq.1) then
;**单个汉字参数 
    cx=0
    cy=0

;**变量初始化
      if(flag.eq.1)
           qu=intChar(strcount)-160
           strcount=strcount+1
           wei=intChar(strcount)-160
           strcount=strcount+1
      ;print("qu="+qu+",wei="+wei)
      end if  
      i=((qu-1)*94+(wei-1))*3+50    
;得到区位码
      qwm=dat(i)       
;得到数据区的起始位置  len
       x1=dat(i+1)
       y1=dat(i+2)
       len=toint(y1+x1*65536)
       i = len +1

;开始循环,
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
          
          x1=floor(temp/100.);获取坐标 x1,y1
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
; 循环结束

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
; 最外层循环结束 

end



;;--------------------------------------------------------------------------
;; 检查参数str是否有中文
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
;; writeTitle 写标题等
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
      
    res=hzres;传递参数，没有赋值的就是缺省值。

    hasMainString = isatt(res,"tiMainString").and.strHZCheck(res@tiMainString)
    hasLeftString = isatt(res,"tiXAxisString").and.strHZCheck(res@gsnLeftString)
    hasRightString = isatt(res,"tiYAxisString").and.strHZCheck(res@gsnRightString)
    hasXAxisString = isatt(res,"tiXAxisString").and.strHZCheck(res@tiXAxisString)
    hasYAxisString = isatt(res,"tiYAxisString").and.strHZCheck(res@tiYAxisString)
    hasXBLabels = isatt(res,"tmXBLabels").and.strHZCheck(res@tmXBLabels)
    hasYLLabels = isatt(res,"tmYLLabels").and.strHZCheck(res@tmYLLabels)

;;--获得标签的坐标参数
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
;;~~~~~~~~~~~~~~~~~~~~ 主标题~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if(hasMainString)then
        ftres = True
        ftres@fontJust = "BottomCenter"
        ftres@fontSize = res@tiMainFontSize
        ftres@fontName = res@tiMainFontName
        ftres@fontColor = res@tiMainFontColor
        writeslhz(wks, res@tiMainString, vpx+vpw/2., vpy+4*tXTMOL, ftres)
    end if
;;~~~~~~~~~~~~~~~~~~~~左副标题~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if(hasLeftString)then
        ftres = True
        ftres@fontJust = "BottomLeft"
        ftres@fontSize = res@gsnLeftFontSize
        ftres@fontName = res@gsnLeftFontName
        ftres@fontColor = res@gsnLeftFontColor
        writeslhz(wks, res@gsnLeftString, vpx, vpy+tXTMOL, ftres)
    end if
;;~~~~~~~~~~~~~~~~~~~~右副标题~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if(hasRightString)then
        ftres = True
        ftres@fontJust = "BottomRight"
        ftres@fontSize = res@gsnRightFontSize
        ftres@fontName = res@gsnRightFontName 
        ftres@fontColor = res@gsnRightFontColor 
        writeslhz(wks, res@gsnRightString, vpx+vpw, vpy+tXTMOL, ftres)
    end if
;;~~~~~~~~~~~~~~~X 轴 说明 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

;;~~~~~~~~~~~~~~~Y 轴 说明 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
;;~~~~~~~~~~~~~~~X 轴 标签 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
;;~~~~~~~~~~~~~~~y 轴 标签 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

