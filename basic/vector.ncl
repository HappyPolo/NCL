resv@vcMapDirection            =False ;绘制垂直剖面图时设为False
resv@vcMaxMagnitudeF           =160. ;大于该值不绘制
resv@vcMinDistanceF            =0.03 ;箭头之间最小距离
resv@vcMinMagnitudeF           =1.0 ;小于该值不绘制
resv@vcGlyphOpacityF           =0.5

;;;;;;;;;;;;;;;;;;FillArrow
resv@vcGlyphStyle              ="FillArrow"
resv@vcVectorDrawOrder         ="PostDraw"
resv@vcFillArrowEdgeThicknessF =2
resv@vcFillArrowEdgeColor      ="White"
resv@vcFillArrowFillColor      ="black"
resv@vcFillArrowHeadInteriorXF =0.25
resv@vcFillArrowHeadXF         =0.6
resv@vcFillArrowHeadYF         =0.2
resv@vcFillArrowWidthF         =0.1


;;;;;;;;;;;;;;;;;;;;;linearrow
resv@vcMonoLineArrowColor      =True
resv@vcLineArrowColor          ="black"


;;;;;;;;;;;;;;;;;;;;;;;参考箭头
resv@vcRefAnnoOn               =True
resv@vcRefAnnoBackgroundColor  ="White"
resv@vcRefAnnoFontHeightF      =0.015
resv@vcRefAnnoOrthogonalPosF   =-0.12
resv@vcRefAnnoParallelPosF     =0.95
resv@vcRefAnnoPerimOn          =False
resv@vcRefAnnoSide             ="Top"
resv@vcRefAnnoString1On        =False ;参考箭头上方字符
resv@vcRefAnnoString2On        =True ;参考箭头下方字符
resv@vcRefAnnoString2          ="30 m/s"
resv@vcRefMagnitudeF           =30 ;单位长度箭头表示实际物理量大小
resv@vcRefLengthF              =0.045 ;单位长度箭头在图中长度
