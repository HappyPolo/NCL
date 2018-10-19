load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
    
    f2   =addfile("/mnt/f/data/For_Fortran/nc/1961_1970_temp_ano.nc", "r")
    f3   =addfile("/mnt/f/data/For_Fortran/nc/1971_1980_temp_ano.nc", "r")
    f4   =addfile("/mnt/f/data/For_Fortran/nc/1981_1990_temp_ano.nc", "r")
    f5   =addfile("/mnt/f/data/For_Fortran/nc/1991_2000_temp_ano.nc", "r")
    f6   =addfile("/mnt/f/data/For_Fortran/nc/2001_2010_temp_ano.nc", "r")

    temp2 =f2->T2
    temp3 =f3->T2
    temp4 =f4->T2
    temp5 =f5->T2
    temp6 =f6->T2

    wks=gsn_open_wks("pdf", "/mnt/f/data/For_Fortran/temp_mean")
gsn_define_colormap(wks, "MPL_jet") 
plot=new(5, graphic)
    
    res=True
    res@mpMinLonF=72
    res@mpMaxLonF=136
    res@mpMinLatF=18
    res@mpMaxLatF=54
    res@gsnAddCyclic=False
    res@cnLinesOn=False
    res@cnFillOn=True
    res@cnLevelSelectionMode="ExplicitLevels"
    ;res@cnLevels =(/-40,-30,-20,-16,-12,-10,-8,-4,-3,-2,-1,0,1,2,3,4,8/)
    res@mpGeophysicalLineColor      ="black"
    res@mpOutlineBoundarySets       ="National"
    res@mpGeophysicalLineDashPattern=0
    res@mpGeophysicalLineDashSegLenF=0.2
    res@mpGeophysicalLineThicknessF =0.5
    res@mpOutlineMaskingOn          =True
    res@mpOutlineOn                 =True


    res@mpAreaMaskingOn             =True
    res@mpMaskAreaSpecifiers        =(/"China","Taiwan"/)

    res1                            =True
    res1@mpMinLonF=72
    res1@mpMaxLonF=136
    res1@mpMinLatF=18
    res1@mpMaxLatF=54
    res1@gsnAddCyclic=False
    res1@cnLinesOn=False
    res1@cnFillOn=True
    res1@cnLevelSelectionMode="AutomaticLevels"
    ;res1@cnLevels =(/-40,-30,-20,-16,-12,-10,-8,-4,-3,-2,-1,0,1,2,3,4,8/)
    res1@mpGeophysicalLineColor      ="black"
    res1@mpOutlineBoundarySets       ="National"
    res1@mpGeophysicalLineDashPattern=0
    res1@mpGeophysicalLineDashSegLenF=0.2
    res1@mpGeophysicalLineThicknessF =0.5
    res1@mpOutlineMaskingOn          =True
    res1@mpOutlineOn                 =True


    res1@mpAreaMaskingOn             =True
    res1@mpMaskAreaSpecifiers        =(/"China","Taiwan"/)

    res2=res
    res3=res
    res4=res
    res5=res
    res6=res

    res1@gsnLeftString ="1961-2010 temp mean"
    res2@gsnLeftString ="1961-1970 temp ano"
    res3@gsnLeftString ="1971-1980 temp ano"
    res4@gsnLeftString ="1981-1990 temp ano"
    res5@gsnLeftString ="1991-2000 temp ano"
    res6@gsnLeftString ="2001-2010 temp ano"
    res1@gsnRightString="C"
    res2@gsnRightString="C"
    res3@gsnRightString="C"
    res4@gsnRightString="C"
    res5@gsnRightString="C"
    res6@gsnRightString="C"


    ;printVarSummary(temp)
    ;plot1=gsn_csm_contour_map(wks,temp1, res1)
    plot(0)=gsn_csm_contour_map(wks,temp2, res2)
    plot(1)=gsn_csm_contour_map(wks,temp3, res3)
    plot(2)=gsn_csm_contour_map(wks,temp4, res4)
    plot(3)=gsn_csm_contour_map(wks,temp5, res5)
    plot(4)=gsn_csm_contour_map(wks,temp6, res6)

    
    resp                          =True
    resp@gsnPanelCenter           =True ;排列时居中对齐每行图
    resp@gsnPanelDebug            =True ;在图形中显示图形的坐标等信息
    resp@gsnPanelFigureStrings    =(/"(a)","(b)","(c)","(d)","(e)"/) ;为每幅图添加标号
    resp@gsnPanelFigureStringsBackgroundFillColor="white"
    resp@gsnPanelFigureStringsFontHeightF =0.01
    resp@amJust                   ="TopLeft"
    resp@gsnPanelFigureStringsPerimOn     =True ;序号加边框
    resp@gsnPanelLabelBar         =True ;多图公用一个色标
    resp@gsnLeftString            =""
    resp@gsnRightString           =""
    ;resp@gsnCenterString          ="GPCP_season"
    ;resp@gsnMaximize              =True
    resp@txString                 ="Temp"
    resp@gsnPanelLabelBar         =False
    resp@gsnPanelFigureStringsPerimOn=False
    gsn_panel(wks, plot, (/2,3/), resp)
print("All Down")


end