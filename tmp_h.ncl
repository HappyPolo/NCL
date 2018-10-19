load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
    ft=addfile("/mnt/f/data/hour/adaptor.mars.2701.nc", "r")
    tmp=short2flt(ft->t(:,:,:,{90}))
    wks=gsn_open_wks("png", "tmph2")
    gsn_define_colormap(wks, "NCV_blue_red")
    printVarSummary(tmp)
    res                              =True
    res@cnLinesOn                    =True
    res@cnLineDashPattern            =2 ;线型为2虚线
    res@cnLineDashSegLenF            =0.25 ;虚线段长度
    ;res@cnLineColor                  ="black"
    res@cnLineThicknessF             =0.3 ;0.3倍粗细
    res@gsnContourNegLineDashPattern =16 ;正值等值线线型为16
    res@gsnContourPosLineDashPattern =0 ;负值等值线线型为0
    res@cnFillOn                     =False
    
    ;res@mpMinLonF                    =60
   ;res@mpMaxLonF                    =140
    ;res@mpMinLatF                    =0
    ;res@mpMaxLatF                    =90
    res@cnInfoLabelOn                =False
    res@cnHighLabelsOn               =False
    res@cnLineLabelsOn               =False
    res@cnLevelSelectionMode="ExplicitLevels"
    res@cnLevels=ispan(230,300,2)
    ;res@cnFillColors=(/2,12,22,32,2,52,62,72,82,91,102,118,150,160,170,180,190,200,210,220,230,240/)

    res@cnHighLabelBackgroundColor   =-1 ;背景透明
    res@cnHighLabelFontHeightF       =0.024 ;字体高度
    
    
    ;;;;;;;;;;;;;;;;;;;;;;添加低值标签

    ;plot=gsn_csm_contour_map(wks, tmp(i,:,:), res)
    plot=gsn_csm_pres_hgt(wks, tmp,{1000:500},{0:60}), res)
end
<-