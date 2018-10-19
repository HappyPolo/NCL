;利用GPCP数据作EOF分析
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

	f                           =addfile("/mnt/e/data/precip.mon.mean.nc", "r")
	precip                      =f->precip
	dims                        =dimsizes(precip)
	nlat                        =dims(1)
	mlon                        =dims(2)
	prc                         =new((/30,nlat,mlon/), float)
do i=0,29
	y=i*12+3
	prc(i,:,:)                  =precip(y,:,:)
end do
	

	year                        =ispan(1979,2009,1)
;计算权重
	w                           =sqrt(cos(0.01745328*prc&lat)) ;权重系数将prc中lat由度转换为弧度
	wp                          =prc*conform(prc, w, 1) ;将数组w扩展至与prc维数一致的新数组，1表示w与prc中第二维（纬度）大小一致
	copy_VarCoords(prc, wp)
;EOF分解 
    x                           =wp({lat|:},{lon|:},time|:)
    neof                        =3
    eof                         =eofunc_Wrap(x, neof, False)
printVarSummary(eof)
;north检验
    ntim                        =dims(0)
    sig_pcv                     =eofunc_north(eof@pcvar, ntim, False)
;计算并标准化时间序列
    eof_ts                      =eofunc_ts_Wrap(x, eof, False)
    eof_ts                      =dim_standardize_n(eof_ts, 1, 1)

;输出至netcdf文件
    ;path_out                    ="PRC_DJF"+".nc"
    ;system("rm -rf"+path_out)
    ;ncdf                        =addfile(path_out, "c")

    eof_ts!1                    ="year"
    eof_ts&year                 =ispan(1980,2009, 1)
    ;ncdf->EOF                   =eof_ts(0,:)


    wks                         =gsn_open_wks("x11", "/mnt/e/GPCP_EOF_J")
    gsn_define_colormap(wks, "wh-bl-gr-ye-re")

    res                         =True

    res@gsnDraw                 =False
    res@gsnFrame                =False

    res@mpMaxLatF                =60
    res@mpMinLatF                =10
    res@mpMaxLonF                =140
    res@mpMinLonF                =60

    res@mpGridAndLimbOn          =True
    
    res@pmTickMarkDisplayMode    ="Always" ;坐标标签添加符号度
    

    res@cnFillOn                 =True
    res@cnFillOpacityF           =0.9 ;透明度
    res@cnLinesOn                =False
    res@cnLevelSelectionMode     ="ManualLevels"
    res@cnMaxLevelValF           =0.06
    res@cnMinLevelValF           =-0.06
    res@cnLevelSpacingF          =0.01

    
    symMinMaxPlt(eof, 16, False, res)

    resp                         =True
    resp@gsnMaximize             =True
    resp@gsnPanelLabelBar        =True

    yrstrt                       =1980
    yrlast                       =2009

    plot                         =new(neof, graphic)
    do n=0,neof-1
        res@gsnLeftString        ="EOF"+(n+1)
        res@gsnRightString       =sprintf("%5.1f", eof@pcvar(n))+"%"
        plot(n)                  =gsn_csm_contour_map(wks, eof(n,:,:), res)
    end do
    gsn_panel(wks, plot, (/neof,1/), resp)

print("alldown")





end