;;;;;;;;;;;;;;;;;;;;;;;;;折线类型
resxy@xyMarkLineMode      ="Lines" ;线条，Markers,Marklines
resxy@xyMarkLineModes     =(/"Markers","Marklines","Lines"/)

;;;;;;;;;;;;;;;;;;;;;;;;;折线采用相同颜色粗细
resxy@xyDashPattern       =0 ;视线
resxy@xyLineColor         ="blue"
resxy@xyLineThicknessF    =3

;;;;;;;;;;;;;;;;;;;;;;;;折线采用不同线型、颜色、粗细
resxy@xyDashPattern       =(/0,1,3,16/)
resxy@xyMonoDashPattern   =False
resxy@xyMonoLineColor     =False
resxy@xyMonoLineThickness =False
resxy@xyLineColors        =(/"blue","red"/)
resxy@xyLineThicknesses   =(/1.,1.,1.,3./)

;;;;;;;;;;;;;;;;;;;;;;;折线上标识采用相同的形状颜色大小
resxy@xyMarker            =3
resxy@xyMarkerColor       ="black"
resxy@xyMarkerSizes       =0.02

;;;;;;;;;;;;;;;;;;;;;;;折线上标识采用不同形状颜色粗细
resxy@xyMarkers           =(/3,5,16/)
resxy@xyMarkerColors      =(/"blue","yellow","red"/)
resxy@xyMarkers           =(/1.,2.,1./)
resxy@xyMonoMarkerColor   =False
resxy@xyMonoMarker        =False
resxy@xyMonoMarkerSize    =False