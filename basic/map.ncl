;;;;;;;;;;;;;;;投影方式
res@mpProjection="LambertConformal" ; 默认为CylindricalEquidistant
;Orthographic,Stereographic,Gnomonic,AzimuthalEquidistant,ROtateMercator,Aitoff,Hammer,Mollweide,WinkelTripel


;;;;;;;;;;;;;;长宽比
res@mpShapeMode="FreeAspect" ;默认为固定比


;;;;;;;;;;;;;;;范围
res@mpCenterLonF=180
res@mpMaxLonF=180
res@mpMinLonF=0
res@mpMaxLatF=90
res@mpMinLatF=10


;;;;;;;;;;;;;;;;;;经纬线及标签
res@mpGridAndLimbOn=True ;绘制经纬线
res@mpGridLatSpacingF=15 ;纬线间隔
res@mpGridLineDashPattern=2 ;线型
res@mpGridLineThicknessF=0.5
res@mpGridLonSpacingF=15 ;经线间隔
res@mpGridPolarLonSpacingF=15 ;极射赤面经线间隔
res@pmTickMarkDisplayMode="Always" ;坐标标签添加符号度


;;;;;;;;;;;;;;;;;;;;;;;;;地图数据
res@mpDataBaseVersion="MediumRes" ;中等分辨率，默认为低等
res@mpDataSetName="Earth..4" ;


;;;;;;;;;;;;;;;;;;;;;;;;地图边线
res@mpGeophysicalLineColor="black" 
res@mpGeophysicalLineDashPattern=16
res@mpGeophysicalLineDashSegLenF=0.2 ;虚线段长度
res@mpGeophysicalLineThicknessF=0.5 
res@mpMaskOutlineSpecifiers=(/"China:Jiangsu","Japan"/) ;不绘制的边界名称
res@mpOutlineBoundarySets="NoBoundaries" ;无边界,默认Geophysical,National
res@mpOutlineMaskingOn=True ;打开边界线mask
res@mpOutlineOn=True ;绘制边界线
res@mpOutlineSpecifiers=(/"China:Jiangsu"/) ;指定绘图边界


;;;;;;;;;;;;;;;;;;;;;;;;地图填色
res@mpFillOn=True
res@mpFillColor="gray"
res@mpInlandWaterFillColor=0 ;内陆湖泊白色
res@mpLandFillColor=0 ;陆地白色
res@mpMonoFillColor=True 
res@mpOceanFillColor=0

;;;;;;;;;;;;;;;;;;;;;;;;指定区域绘图
res@mpAreaMaskingOn=True ;mask某区域
res@mpMaskAreaSpecifiers=(/"China","Taiwan","Arunachal Pradesh"."Disputed area between India and China"/)
res@mpFillDrawOrder="PostDraw" ;最后填色
res@mpFillAreaSpecifiers=(/"China"/) ;指定绘图区域
