;850hPa
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
    
    f_u                           =addfile("/mnt/f/data/NCEP/uwnd.mon.mean.nc", "r")
    f_v                           =addfile("/mnt/f/data/NCEP/vwnd.mon.mean.nc", "r")
    f_t                           =addfile("/mnt/f/data/NCEP/air.mon.mean.nc",  "r")
    f_ud                          =addfile("/mnt/f/data/NCEP/uwnd.DJF.mean.nc", "r")
    f_vd                          =addfile("/mnt/f/data/NCEP/vwnd.DJF.mean.nc", "r")
    f_td                          =addfile("/mnt/f/data/NCEP/air.DJF.mean.nc",  "r")
    f_h                           =addfile("/mnt/f/data/NCEP/hgt.sfc.nc", "r")
    


    u850                         =f_u->uwnd(ispan(372,731,1),{850},:,:)
    v850                         =f_v->vwnd(ispan(372,731,1),{850},:,:)
    t850                         =f_t->air(ispan(372,731,1),{850},:,:)
    u200                         =f_u->uwnd(ispan(372,731,1),{200},:,:)
    v200                         =f_v->vwnd(ispan(372,731,1),{200},:,:)
    t200                         =f_t->air(ispan(372,731,1),{200},:,:)
    hgt                          =short2flt(f_h->hgt(0,:,:))

    printVarSummary(t850)
    dims                        =dimsizes(u850)
    ;dims_v                        =dimsizes(v_850)
    ;dims_t                        =dimsizes(t_850)
    mlat                        =dims(1)
    mlat                        =dims(2)


    u850avg                       =dim_avg_n_Wrap(u850, 0)
    v850avg                       =dim_avg_n_Wrap(v850, 0)
    t850avg                       =dim_avg_n_Wrap(t850, 0)
    u200avg                       =dim_avg_n_Wrap(u200, 0)
    v200avg                       =dim_avg_n_Wrap(v200, 0)
    t200avg                       =dim_avg_n_Wrap(t200, 0)
    u850_MAM                      =month_to_season(u850, "MAM")
    u850_JJA                      =month_to_season(u850, "JJA")
    u850_SON                      =month_to_season(u850, "SON")
    u850_DJF                      =f_ud->uwnd(ispan(95, 184, 1),{850},:,:)
    u200_MAM                      =month_to_season(u200, "MAM")
    u200_JJA                      =month_to_season(u200, "JJA")
    u200_SON                      =month_to_season(u200, "SON")
    u200_DJF                      =f_ud->uwnd(ispan(95, 184, 1),{200},:,:)
    v850_MAM                      =month_to_season(v850, "MAM")
    v850_JJA                      =month_to_season(v850, "JJA")
    v850_SON                      =month_to_season(v850, "SON")
    v850_DJF                      =f_vd->vwnd(ispan(95, 184, 1),{850},:,:)
    v200_MAM                      =month_to_season(v200, "MAM")
    v200_JJA                      =month_to_season(v200, "JJA")
    v200_SON                      =month_to_season(v200, "SON")
    v200_DJF                      =f_vd->vwnd(ispan(95, 184, 1),{200},:,:)
    t850_MAM                      =month_to_season(t850, "MAM")
    t850_JJA                      =month_to_season(t850, "JJA")
    t850_SON                      =month_to_season(t850, "SON")
    t850_DJF                      =f_td->air(ispan(95, 184, 1),{850},:,:)
    t200_MAM                      =month_to_season(t200, "MAM")
    t200_JJA                      =month_to_season(t200, "JJA")
    t200_SON                      =month_to_season(t200, "SON")
    t200_DJF                      =f_td->air(ispan(95, 184, 1),{200},:,:)

    u850_MAM_avg                  =dim_avg_n_Wrap(u850_MAM, 0)
    u850_JJA_avg                  =dim_avg_n_Wrap(u850_JJA, 0)
    u850_SON_avg                  =dim_avg_n_Wrap(u850_SON, 0)
    u850_DJF_avg                  =dim_avg_n_Wrap(u850_DJF, 0)
    v850_MAM_avg                  =dim_avg_n_Wrap(v850_MAM, 0)
    v850_JJA_avg                  =dim_avg_n_Wrap(v850_JJA, 0)
    v850_SON_avg                  =dim_avg_n_Wrap(v850_SON, 0)
    v850_DJF_avg                  =dim_avg_n_Wrap(v850_DJF, 0)
    t850_MAM_avg                  =dim_avg_n_Wrap(t850_MAM, 0)
    t850_JJA_avg                  =dim_avg_n_Wrap(t850_JJA, 0)
    t850_SON_avg                  =dim_avg_n_Wrap(t850_SON, 0)
    t850_DJF_avg                  =dim_avg_n_Wrap(t850_DJF, 0)
    u200_MAM_avg                  =dim_avg_n_Wrap(u200_MAM, 0)
    u200_JJA_avg                  =dim_avg_n_Wrap(u200_JJA, 0)
    u200_SON_avg                  =dim_avg_n_Wrap(u200_SON, 0)
    u200_DJF_avg                  =dim_avg_n_Wrap(u200_DJF, 0)
    v200_MAM_avg                  =dim_avg_n_Wrap(v200_MAM, 0)
    v200_JJA_avg                  =dim_avg_n_Wrap(v200_JJA, 0)
    v200_SON_avg                  =dim_avg_n_Wrap(v200_SON, 0)
    v200_DJF_avg                  =dim_avg_n_Wrap(v200_DJF, 0)
    t200_MAM_avg                  =dim_avg_n_Wrap(t200_MAM, 0)
    t200_JJA_avg                  =dim_avg_n_Wrap(t200_JJA, 0)
    t200_SON_avg                  =dim_avg_n_Wrap(t200_SON, 0)
    t200_DJF_avg                  =dim_avg_n_Wrap(t200_DJF, 0)

    printVarSummary(u850avg)
    wks                           =gsn_open_wks("png", "/mnt/f/png/wind_temp3")
    gsn_define_colormap(wks, "NCV_blue_red")
;绘制850hPa的温度场

    resc1                         =True

    resc1@gsnDraw                 =False
    resc1@gsnFrame                =False
    ;resc1@gsnMaximize             =True

    resc1@mpMaxLonF               =140
    resc1@mpMinLonF               =60
    resc1@mpMaxLatF               =60
    resc1@mpMinLatF               =10

    resc1@cnFillOn                =True
    resc1@cnLinesOn               =False

    resc1@gsnTickMarksOn          =False 
    ;resc1@cnLevelSelectionMode    ="ExplicitLevels"
    ;resc1@cnLevels                =(/-10,-5,0,5,10,15,20,25,30,35/)
    
    ;resc1@cnFillColors            =(/49,26,2,146,161,170,177,181,191,192,200/)

    resc1@cnLevelSelectionMode    ="ManualLevels"
    resc1@cnMinLevelValF           =-10
    resc1@cnMaxLevelValF           =30
    resc1@cnLevelSpacingF          =2

  
    ;resc1@gsnLeftString           =""
    resc1@gsnRightString          =""


    resc1@mpGeophysicalLineColor      ="black"
    resc1@mpOutlineBoundarySets       ="National"
    resc1@mpGeophysicalLineDashPattern=0
    resc1@mpGeophysicalLineDashSegLenF=0.2
    resc1@mpGeophysicalLineThicknessF =0.5
    resc1@mpOutlineMaskingOn          =True
    resc1@mpOutlineOn                 =True


    resc1@mpGridAndLimbOn             =True
    resc1@mpGridLonSpacingF           =10
    resc1@mpGridLatSpacingF           =10
    resc1@mpGridLineThicknessF        =0.02
    resc1@mpGridLineDashPattern       =2

    ;地图边界
    resc1@mpGeophysicalLineColor      ="black"
    resc1@mpOutlineBoundarySets       ="National"
    resc1@mpGeophysicalLineDashPattern=0
    resc1@mpGeophysicalLineDashSegLenF=0.2
    resc1@mpGeophysicalLineThicknessF =0.5
    resc1@mpOutlineMaskingOn          =True
    resc1@mpOutlineOn                 =True
    resc1@mpGridLineDashPattern       =2



  


base1=gsn_csm_contour_map(wks, t850avg(:,:), resc1)
base1_MAM=gsn_csm_contour_map(wks, t850_MAM_avg(:,:), resc1)
base1_JJA=gsn_csm_contour_map(wks, t850_JJA_avg(:,:), resc1)
base1_SON=gsn_csm_contour_map(wks, t850_SON_avg(:,:), resc1)
base1_DJF=gsn_csm_contour_map(wks, t850_DJF_avg(:,:), resc1)


         res2                           =True
    res2@gsnDraw                   =False
    res2@gsnFrame                  =False
    res2@gsnLeftString             =""
    res2@gsnRightString            =""
    res2@cnFillOn                  =False
    res2@cnLinesOn                 =True
    res2@cnLevelSelectionMode      ="ExplicitLevels"
    res2@cnLevels                  =(/2000/)
    res2@cnLineThicknesses         =0.9
    res2@cnLineColor               ="red"
    res2@cnInfoLabelOn             =False


        resc2                         =True

    resc2@gsnDraw                 =False
    resc2@gsnFrame                =False

    resc2@mpMaxLonF               =140
    resc2@mpMinLonF               =60
    resc2@mpMaxLatF               =60
    resc2@mpMinLatF               =10

    resc2@cnFillOn                =True
    resc2@cnLinesOn               =False
    ;resc2@cnLevelSelectionMode    ="ExplicitLevels"
    ;resc2@cnLevels                =(/-10,-5,0,5,10,15,20,25,30,35/)
    
    ;resc2@cnFillColors            =(/49,26,2,146,161,170,177,181,191,192,200/)

    resc2@cnLevelSelectionMode    ="AutomaticLevels"
    ;resc2@cnMinLevelValF           =-10
    ;resc2@cnMaxLevelValF           =30
    ;resc2@cnLevelSpacingF          =2

  
    resc2@gsnLeftString           =""
    resc2@gsnRightString          =""
    ;resc2@gsnMaximize             =True


      resc2@mpGeophysicalLineColor      ="black"
  resc2@mpOutlineBoundarySets       ="National"
  resc2@mpGeophysicalLineDashPattern=0
  resc2@mpGeophysicalLineDashSegLenF=0.2
  resc2@mpGeophysicalLineThicknessF =0.5
  resc2@mpOutlineMaskingOn          =True
  resc2@mpOutlineOn                 =True

    resc2@mpGeophysicalLineColor      ="black"
    resc2@mpOutlineBoundarySets       ="National"
    resc2@mpGeophysicalLineDashPattern=0
    resc2@mpGeophysicalLineDashSegLenF=0.2
    resc2@mpGeophysicalLineThicknessF =0.5
    resc2@mpOutlineMaskingOn          =True
    resc2@mpOutlineOn                 =True


    resc2@mpGridAndLimbOn             =True
    resc2@mpGridLonSpacingF           =10
    resc2@mpGridLatSpacingF           =10
    resc2@mpGridLineThicknessF        =0.02
    resc2@mpGridLineDashPattern       =2

    
  


base2=gsn_csm_contour_map(wks, t200avg(:,:), resc2)
base2_MAM=gsn_csm_contour_map(wks, t200_MAM_avg(:,:), resc2)
base2_JJA=gsn_csm_contour_map(wks, t200_JJA_avg(:,:), resc2)
base2_SON=gsn_csm_contour_map(wks, t200_SON_avg(:,:), resc2)
base2_DJF=gsn_csm_contour_map(wks, t200_DJF_avg(:,:), resc2)

        res3                                 =True
    res3@stArrowLengthF                  =0.02
    res3@stArrowStride                   =3
    res3@stMinArrowSpacingF              =0.04
    res3@gsnDraw                         =False
    res3@gsnFrame                        =False
    ;ress@stLevelSpacingF                 =1.
    ;ress@stLineThicknessF                =0.5
    res3@stLineColor                     ="black"
    ;ress@stMinDistanceF                  =0.3
    ;ress@stMinLineSpacingF               =0.007



    plot1=gsn_csm_contour(wks, hgt, res2)
    plot2=gsn_csm_contour(wks, hgt, res2)
    plot3=gsn_csm_contour(wks, hgt, res2)
    plot4=gsn_csm_contour(wks, hgt, res2)
    plot5=gsn_csm_contour(wks, hgt, res2)

plot2_MAM_SR=gsn_csm_streamline(wks, u200_MAM_avg, v200_MAM_avg, res3)
plot2_JJA_SR=gsn_csm_streamline(wks, u200_JJA_avg, v200_JJA_avg, res3)
plot2_SON_SR=gsn_csm_streamline(wks, u200_SON_avg, v200_SON_avg, res3)
plot2_DJF_SR=gsn_csm_streamline(wks, u200_DJF_avg, v200_DJF_avg, res3)
    overlay(base2_MAM, plot2_MAM_SR)
    draw(base2_MAM)
    frame(wks)
    overlay(base2_JJA, plot2_JJA_SR)
    draw(base2_JJA)
    frame(wks)
    overlay(base2_SON, plot2_SON_SR)
    draw(base2_SON)
    frame(wks)
    overlay(base2_DJF, plot2_DJF_SR)
    draw(base2_DJF)
    frame(wks)
print("All Down")
end



     