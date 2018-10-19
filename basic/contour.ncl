;;;contour
;;;;;;;;;;;;;;;;;;;;数值
;;;;1
res@cnLevelSelectionMode         ="Aumaticlevels" ;ExplicitLevels,ManualLevels
;;;;2
res@cnLevelSelectionMode         ="ManualLevels"
res@cnMaxLevelValF               =
res@cnMinLevelValF               =
res@cnLevelSpacingF              =
;;;;3
res@cnLevelSelectionMode         ="ExplicitLevels"
res@cnLevels                     =(/ /)


;;;;;;;;;;;;;;;;;线型
res@cnLinesOn                    =True
res@cnLineDashPattern            =2 ;线型为2虚线
res@cnLineDashSegLenF            =0.25 ;虚线段长度
res@cnLineColor                  ="black"
res@cnLineThicknessF             =0.3 ;0.3倍粗细
res@gsnContourNegLineDashPattern =16 ;正值等值线线型为16
res@gsnContourPosLineDashPattern =0 ;负值等值线线型为0
res@gsnContourZeroLineThicknessF =0 ;不画0等值线


;;;;;;;;;;;;;;;;;;等值线颜色
res@cnFillOn                     =True
res@cnFillColors                 =(//) ;
res@cnFillColor                  ="black" ;只设定一种颜色

;;;;填充
;;;1
res@cnFillMode                   ="RasterFill"
;;;2
res@cnFillMode                   ="AreaFill"
;;;3
res@cnFillMode                   ="CellFill"

res@cnFillOpacityF               =0.5 ;透明度
res@cnFillPalette                ="GMT_gray" ;指定等值线色板
res@cnFillPattern                =5 ;形状填充
res@cnFillScaleF                 =0.5 ;形状填充密度

;;;;;;;;;;;;;;;;;;;;;;;;;数值标签

res@cnLineLabelsOn               =True
res@cnLineLabelAngleF            =0.0 ;标签角度
res@cnLineLabelBackgroundColor   ="white" ;边框内部颜色
res@cnLineLabelDensityF          =0.5 ;标签密度
res@cnLineLabelPerimOn           =True ;添加边框
res@cnLineLabelPerimColor        ="white" ;边框颜色
res@cnLineLabelPlacementMode     ="Computed" ;可通过cnlinelinelabeldenstiyF修改密度


;;;;;;;;;;;;;;;;;;;;;;;;;数值信息标签
res@cnInfoLabelOn                =True ;打开等值线标签
res@cnInfoLabelOrthogonalPosF    =0.05 ;垂直移动标签
res@cnInfoLabelParallelPosF      =0.05 ;水平移动标签


;;;;;;;;;;;;;;;;;;;;;;;绘制顺序
res@cnLineDrawOrder              ="PostDraw"; 最后绘制。Draw,PreDraw
res@cnLabelDrawOrder             ="PostDraw"

;;;;;;;;;;;;;;;;;;;;;;;添加高值标签
res@cnHighLabelsOn               =True
res@cnHighLabelBackgroundColor   =-1 ;背景透明
res@cnHighLabelFontHeightF       =0.024 ;字体高度


;;;;;;;;;;;;;;;;;;;;;;添加低值标签
res@cnLowLabelsOn                =True 
res@cnLowLabelBackgroundColor    =-1
res@cnLowLabelFontHeightF        =0.024


res@gsnAddCyclic                 =True ;在数据为局部区域时需要
