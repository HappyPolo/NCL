load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

    fte=addfile("/home/ys-ug/data/era-interim/air.mon.mean.nc", "r")
    f6=addfile("/home/ys-ug/data/cfsv2/t500/tmp500.ensm.jun.cfsv2.data.nc", "r")
    f7=addfile("/home/ys-ug/data/cfsv2/t500/tmp500.ensm.jul.cfsv2.data.nc", "r")
    f8=addfile("/home/ys-ug/data/cfsv2/t500/tmp500.ensm.aug.cfsv2.data.nc", "r")

    te=short2flt(fte->t(48:383,{500},:,:))
    t6=short2flt(f6->TMP_P8_L100_GLL0_avg1m(:,0,:,:))
    t7=short2flt(f6->TMP_P8_L100_GLL0_avg1m(:,0,:,:))
    t8=short2flt(f6->TMP_P8_L100_GLL0_avg1m(:,0,:,:))

    te_jja=month_to_season(te, "JJA")
    te_JJA=dim_avg_n_Wrap(te_jja, 0)
    tc_JJA=(dim_avg_n(t6, 0)+dim_avg_n(t7, 0)+dim_avg_n(t8, 0))/3
    copy_VarCoords(te_JJA, tc_JJA)
    printVarSummary(tc_JJA)

    diff=tc_JJA-te_JJA
    copy_VarCoords(te_JJA, diff)

wks1=gsn_open_wks("png", "/home/ys-ug/kt/plots/CFSv2_tmp500")
wks2=gsn_open_wks("png", "/home/ys-ug/kt/plots/ERA-Int_tmp500")
wks3=gsn_open_wks("png", "/home/ys-ug/kt/plots/CFSv2-ERA_tmp500")   
gsn_define_colormap(wks1, "cmp_b2r") 
gsn_define_colormap(wks2, "cmp_b2r") 
gsn_define_colormap(wks3, "cmp_b2r") 

;=========================plot===================================
    tres                      =True
    tres@gsnDraw              =False
    tres@gsnFrame             =False
    
    tres@cnFillOn             =True
    tres@cnLinesOn            =True
    tres@cnLevelSelectionMode ="ExplicitLevels"
    ;tres@cnLevels
    ;tres@cnFillColors
    tres@cnInfoLabelOn        =False
    tres@cnLineLabelsOn       =False
    tres@cnLineLabelPerimOn   =False
    tres@gsnLeftString="JJA"
    tres@gsnRightString="units : K"
    tres@cnLineThicknessF=0.2
    
    tres@mpMaxLonF            =130
    tres@mpMinLonF            =50
    tres@mpMaxLatF            =70
    tres@mpMinLatF            =10
    
    tres3=tres
    tres@cnLevels=(/261,262,264,265,266,267,267.5,268,268.5,269,269.5,270,270.5,271,272,273,274/)
    tres@cnFillColors=(/12,14,16,18,20,23,29,34,37,40,43,46,49,52,55,58,59,60/)
    tres2=tres
    tres3@cnLevels=(/-4,-3.5,-3,-2.5,-2,-1.5,-1,-.5,0,0.5,1,1.5,2/)
    tres3@cnFillColors=(/2,5,8,11,14,17,20,23,26,35,37,41,44,47,50/)
    tres@tiMainString="(a) CFSv2 tmp 500"
    tres2@tiMainString="(b) ERA-Interim tmp 500"
    tres3@tiMainString="(c) CFSv2-ERA tmp 500"

    lnres=True
    lnres@gsLineThicknessF=3.
    lnres@gsLineDashPattern=1

    base1=gsn_csm_contour_map(wks1, tc_JJA, tres)
    base2=gsn_csm_contour_map(wks2, te_JJA, tres2)
    base3=gsn_csm_contour_map(wks3, diff, tres3)
    plot1=gsn_add_shapefile_polylines(wks1, base1, "/home/ys-ug/kt/tibetan/tibetan.shp", lnres)
    plot2=gsn_add_shapefile_polylines(wks2, base2, "/home/ys-ug/kt/tibetan/tibetan.shp", lnres)
    plot3=gsn_add_shapefile_polylines(wks3, base3, "/home/ys-ug/kt/tibetan/tibetan.shp", lnres)
maximize_output(wks1, False)
maximize_output(wks2, False)
maximize_output(wks3, False)

end