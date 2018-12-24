load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

    fo = addfile("/mnt/e/data/ty/omega.nc", "r")
    fv = addfile("/mnt/e/data/ty/vwnd.nc", "r")
    fu = addfile("/mnt/e/data/ty/uwnd.nc", "r")
    ft = addfile("/mnt/e/data/ty/air.nc", "r")
    T = short2flt(ft->t)
    u = short2flt(fu->u(:,:,:,:))
    T0 = T
    T0 = 273.15
    t = T-T0
    copy_VarCoords(T, t)

    pt = pot_temp(t&level, t, 1, False)
printVarSummary(t)
    v = short2flt(fv->v)
    omega = short2flt(fo->w)
    p = u&level 
    p0 = u
    p0 = 100
    P = conform(u, p, 1)
    P := P*p0
    P@units = "Pa"

    w = omega_to_w(omega, P, T)


 wAve   = avg(w(0,:,:,{113}))           ; used for scaling
 vAve   = avg(v(0,:,:,{113}))
 scale  = fabs(vAve/wAve)
 wscale = w*scale                       ; now scale

 copy_VarCoords(w, wscale)              ; copy coordinate variables 

;---Create plot
   wks = gsn_open_wks("eps","uvw")    ; send graphics to PNG file

 res                 = True                     ; plot mods desired
 ; res@tiMainString    = "Pressure/Height Vector" ; title
 res@gsnDraw = False
 res@gsnFrame = False
res@cnLinesOn = False
 res@cnLineLabelsOn  = False                ; turn off line labels
 res@cnFillOn        = True                 ; turn on color fill
 res@cnFillPalette   = "WhiteBlueGreenYellowRed"  ; choose color map

res@cnLevelSelectionMode = "ExplicitLevels"
res@cnLevels = ispan(30, 65, 2)
; res@cnMaxLevelValF = 30
; res@cnMinLevelValF = -30
; res@cnLevelSpacingF = 2
 res@lbLabelStride   = 2                    ; every other color


    res@vcGlyphStyle = "CurlyVector"
    res@vcLineArrowColor          ="black"
    res@vcLineArrowThicknessF     = 1.5
    ; ; res@vcRefAnnoPerimOn 
    res@vcRefAnnoOn               =True
    res@vcRefAnnoBackgroundColor  ="white"
    res@vcRefAnnoFontHeightF      =0.01
    res@vcRefAnnoOrthogonalPosF   =-0.13
    res@vcRefAnnoParallelPosF     =1.
    res@vcRefAnnoPerimOn          =True
    res@vcRefAnnoArrowUseVecColor = False
    ; res@vcRefAnnoArrowLineColor   ="CadetBlue3"
    res@vcRefAnnoSide             ="Bottom"
    res@vcRefAnnoString1On        =False ;参考箭头上方字符
    res@vcRefAnnoString2On        =True ;参考箭头下方字符

    res@vcRefMagnitudeF = 60
    res@vcRefLengthF = 0.03
    res@vcMinDistanceF = 0.025

    ; res@vcMinDistanceF = 0.03

    res@vcRefAnnoString2          ="60 m/s"   

        res@pmTickMarkDisplayMode="Always"
    
    res@pmLabelBarWidthF         =0.6 
    res@pmLabelBarHeightF        =0.06 
    
    res@lbLabelOffsetF           =0.1 
    res@lbLabelFontHeightF       =0.026
    res@lbLabelFontColor         ="black"
    res@lbLabelFontThicknessF    =2
    res@lbLabelStride            =1 
    ; res@pmLabelBarOrthogonalPosF =0.25
    res@lbBoxEndCapStyle         = "TriangleBothEnds"

    ; res@cnFillOpacityF = 0.9
    res@gsnLeftString = ""
    res@gsnRightString = ""

    rest = True
    rest@gsnDraw = False
    rest@gsnFrame = False
    rest@cnLinesOn = True
    rest@cnFillOn = False

    rest@cnInfoLabelOn = False
    rest@cnLineLabelsOn = True
    rest@cnLineLabelBackgroundColor = -1
    rest@cnLevelSelectionMode = "ManualLevels"



    rest@cnMaxLevelValF = 30
    rest@cnMinLevelValF = -90
    rest@cnLevelSpacingF = 10

    rest@gsnContourNegLineDashPattern =16 ;负值等值线线型为0
    rest@cnLineLabelDensityF = 1
    rest@cnLineLabelFontHeightF = 0.01

    rest@cnLineThicknessF = 3.5

    rest@cnLineColor = "Blue"
res@tmXBLabelFontThicknessF = 0.024
res@tmYLLabelFontThicknessF = 0.024
res@tmXTLabelFontThicknessF = 0.024


res@lbLabelBarOn             =False
res@cnInfoLabelOn = False
; res@vcLineArrowColor = "green"

;---Draw plot from pole to pole at 170E
time:=cd_calendar(v&time, -5)
id = (/6,8,10/)
plot = new(3, graphic)
plot2=plot
do hh = 0,2
    i = id(hh)
           res@tiMainString=sprinti("%4i", time(i,0))+"-"+sprinti("%02i", time(i,1))+"-"\
    +sprinti("%02i", time(i,2))+" "+sprinti("%02i", time(i,3))+":00 (GMT)"
 plot(hh)  = gsn_csm_pres_hgt_vector(wks,u(i,{1000:100},{0:90},{116}),v(i,{1000:100},{0:90},{116}),\
                                wscale(i,{1000:100},{0:90},{116}),res ) 
 plot2(hh) = gsn_csm_pres_hgt(wks, pt(i,{1000:100},{0:90},{116}), rest)
 overlay(plot(hh), plot2(hh))
 ; draw(plot)
 ; frame(wks)
end do 
    resp                          =True
    resp@gsnPanelCenter           =True ;排列时居中对齐每行图
    resp@gsnPanelDebug            =True ;在图形中显示图形的坐标等信息
    resp@gsnPanelFigureStrings    =(/"(a)","(b)","(c)"/) ;为每幅图添加标号
    resp@gsnPanelFigureStringsBackgroundFillColor="white"
    resp@gsnPanelFigureStringsFontHeightF =0.012
    ; resp@gsnPanelTick
    resp@amJust                   ="BottomLeft"
    resp@gsnPanelFigureStringsPerimOn     =False ;序号加边框
    resp@gsnPanelLabelBar         =True ;多图公用一个色标
    resp@gsnLeftString            =""
    resp@gsnRightString           =""
    resp@gsnMaximize              =False
    resp@txString                 =""
    resp@txFontHeightF            = 0.05
    resp@txPosYF                  = 0.85
    resp@gsnPanelLabelBar         =True
    resp@gsnPanelFigureStringsPerimOn=True
    ; resp@lbLabelOffsetF           =0.1 
    resp@lbLabelFontHeightF       =0.024
    resp@lbLabelFontColor         ="black"
    resp@lbLabelFontThicknessF    =2
    resp@lbLabelStride            =1 
    resp@pmLabelBarOrthogonalPosF =-0.05
    resp@lbBoxEndCapStyle         = "TriangleBothEnds"
    resp@pmLabelBarWidthF         =0.6 ;宽度
resp@pmLabelBarHeightF        =0.05 ;高度
    resp@gsnRightString = "units:"+"~S~o~N~"+"C"
    resp@gsnLeftString = "air_temperature"
    ; resp@gsnpanel
    
        gsn_panel(wks, plot, (/1,3/), resp)
end