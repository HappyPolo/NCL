;;;;;;;;;;;;;;水平参考线
res@gsnXRefLine                              =0. ;X轴参考线
res@gsnXRefLineColor                         ="black"
res@gsnXRefLineDashPattern                   =15
res@gsnXRefLineThicknessF                    =2.

;;;;;;;;;;;;;垂直参考线
res@gsnYRefLine                              =0. 
res@gsnYRefLineColor                         ="black"
res@gsnYRefLineDashPattern                   =16
res@gsnYRefLineThicknessF                    = 2.

;;;;;;;;;;;;;;;;;;;;;;;;;经纬线间隔
res@gsnMajorLatSpacing                       =10
res@gsnMinorLatSpacing                       =5
res@gsnMajorLonSpacing                       =10
res@gsnMinorLonSpacing                       =5

;;;;;;;;;;;;;;;;bar图
res@gsnXYBarChart                            = True
res@gsnXYBarChartBarWidth                    =0.5
res@gsnXYBarChartFillOpacityF                =0.5

;;;;;;;;;;;;;;;;折线或bar图
res@gsnAboveYRefLineBarColors                ="red" ;大于Y参考值时颜色
res@gsnAboveYRefLineBarPatterns              =16
res@gsnAboveYRefLineColor                    ="black" ;折线
res@gsnBelowYRefLineColor                    ="blue"

;;;;;;;;;;;;;;;;;;;;;;;;绘制纬向平均，用于gsn_csm_contour_map_ce，gsn_csm_contour_map
res@gsnZonalMean                             =True ;图形右侧绘制纬向平均
res@gsnZonalMeanXMaxF                        =30 ;X轴最大值
res@gsnZonalMeanXMaxF                        =-30 
res@gsnZonalMeanYRefLine                     =0 ;纬向平均参考值

;;;;;;;;;;;;;;;;;;;;;;Lambert Mask
res@gsnMaskLambertConformal                  =True ;labert投影mask
res@gsnMaskLambertConformalOutlineOn         =True ;绘制边界线

;;;;;;;;;;;;;;;;;;;;;;;;;panel
res@gsnPanelCenter                           =True ;居中对齐
res@gsnPanelDebug                            =False ;不显示坐标信息
res@gsnPanelFigureStrings                    =(/"(a)","(b)","(c)","(d)"/)
res@gsnPanelFigureStringsBackgroundFillColor ="white" ;标号签背景色
res@gsnPanelFigureStringsFontHeightF         =0.02
res@gsnPanelFigureStringsPerimOn             =False ;序号标签周围加框
res@gsnPanelLabelBar                         =False ;多图共用一色标
res@gsnPanelBottom                           =0.0 ;最下边图形绘制结束位置
res@gsnPanelLeft                             =0.0 ;最左绘制位置
res@gsnPanelRight                            =1.0 ;最右位置
res@gsnPanelRowSpec                          =False ;手动指定每行绘制图形数
res@gsnPanelTop                              =1.0
res@gsnPanelXWhiteSpacePercent               =1. ;每两个相邻字图之间沿x轴之间空白大小
res@gsnPanelYWhiteSpacePercent               =1.


;;;;;;;;;;;;;;;;;;;;;;;;;;图形上方字符
res@gsnCenterString                          ="title"
res@gsnCenterStringFontColor                 ="black"
res@gsnCenterStringFontHeightF               =0.02
res@gsnCenterStringFuncCode                  =":" ;字符函数码
res@gsnCenterStringOrthogonalPosF            =0.02 ;调整垂直位置
res@gsnCenterStringParallelPosF              =0.02 ;调整水平位置


;;;;;;;;;;;;;;;;;;;;;;;;;;;图形左上方字符
res@gsnLeftString                            ="title"
res@gsnLeftStringFontColor                   ="black"
res@gsnLeftStringFontHeightF                 =0.02
res@gsnLeftStringFuncCode                    =":"
res@gsnLeftStringOrthogonalPosF              =0.02
res@gsnLeftStringParallelPosF                =0.02


;;;;;;;;;;;;;;;;;;;;;;;;;;;图形右上方字符
res@gsnRightString                           ="title"
res@gsnRightStringFontColor                  ="black"
res@gsnRightStringFontHeightF                =0.02
res@gsnRightStringFuncCode                   =":"
res@gsnRightStringOrthogonalPosF             =0.02
res@gsnRightStringParallelPosF               =0.02


;;;;;;;;;;;;;;;;;;;;;;;;;;;;色板颜色选用
res@gsnSpreadColorStart                      =2 ;指定色板第二个颜色用于绘制第一个等值线
res@gsnSpreadColorEnd                        =-1 ;指定色板最后一个颜色绘制最后一等值线


;;;;;;;;;;;;;;;;;;;;;;;;;;;;gsn_histogram(wks, data, res)
res@gsnHistogramHorizontal                   =False ;水平绘制
res@gsnHistogramBarWidthPercent              =66 ;histogarm宽度
res@gsnHistogramBinWidth                     =10
res@gsnHistogramBinIntervals                 =(/1,2,5,7/) ;设定bin的不等间距间隔
res@gsnHistogramCompare                      =True ;绘制两类数据的频率统计结果。输入数据最左边维大小为2
res@gsnHistogramComputePercentages           =True ;在右侧Y轴显示百分比
res@gsnHistogramMinMaxBinsOn                 =True ;设定gsnhistogrambinintervals将添加两个bins
res@gsnHistogramPercentSign                  =True ;设定gsnhistogramcomputepercentages为ture后将在右侧Y轴标签添加符号%


;;;;;;;;;;;;;;;;;;;;;;;;;;;;绘图及图形设置
res@gsnDraw                                  =False 
res@gsnFrame                                 =False
res@gsnMaximize                              =False

res@gsnPolar                                 ="NH" ;北半球极射赤面投影
res@gsnPolarLabelFontHeightF                 =0.02
res@gsnScalarContour                         =True ;
res@gsnShape                                 =False