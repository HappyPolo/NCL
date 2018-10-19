load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
    ft=addfile("/mnt/e/software/adaptor.mars.air.nc", "r")
    tmp=short2flt(ft->t(:,{850},:,:))
    wks=gsn_open_wks("pdf", "tmp_850")
    gsn_define_colormap(wks, "NCV_blue_red")
    printVarSummary(tmp)
    ti=tmp&time
    time=cd_calendar(ti,-3 )
    do i=0,215
    res                              =True
    res@gsnDraw                      =False
    res@gsnFrame                     =False
    res@cnLinesOn                    =True
    res@cnLineLabelsOn               =False
    res@cnLineDashPattern            =2 ;线型为2虚线
    res@cnLineDashSegLenF            =0.25 ;虚线段长度
    res@cnLineColor                  ="black"
    res@cnLineThicknessF             =0.3 ;0.3倍粗细
    res@gsnContourNegLineDashPattern =16 ;正值等值线线型为16
    res@gsnContourPosLineDashPattern =0 ;负值等值线线型为0
    res@cnFillOn                     =True
    res@gsnLeftString                =time(i)+"_No."+i
    res@mpMinLonF                    =60
    res@mpMaxLonF                    =140
    res@mpMinLatF                    =0
    res@mpMaxLatF                    =60
    res@cnInfoLabelOn                =False
    res@cnHighLabelsOn               =False
    res@cnLevelSelectionMode="ExplicitLevels"
    res@cnLevels=ispan(250,300,1)
    res@mpFillColor            ="grey"
    res@mpInlandWaterFillColor ="white"
    ;res@mpLandFillColor        ="white"
    ;res@mpOceanFillColor       ="white"
    ;res@mpGeophysicalLineColor ="black"
    ;res@cnFillColors=(/2,12,22,32,2,52,62,72,82,91,102,118,150,160,170,180,190,200,210,220,230,240/)

    res@cnHighLabelBackgroundColor   =-1 ;背景透明
    res@cnHighLabelFontHeightF       =0.024 ;字体高度
    lnres             =True
    lnres@gsFillColor ="black"
    lnres@gsLineThicknessF=3.
    lnres@gsLineDashPattern=0
    
    ;;;;;;;;;;;;;;;;;;;;;;添加低值标签

    base=gsn_csm_contour_map(wks, tmp(i,:,:), res)
plot=gsn_add_shapefile_polygons(wks, base, "/mnt/f/scripts/ncl/shapefile/tibetan/tibetan.shp", lnres)
;maximize_output(wks, False)
draw(base)
frame(wks)
end do 
end
