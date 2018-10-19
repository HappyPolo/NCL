;850-200
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
    
    f_u                           =addfile("/mnt/e/data/uwnd.mon.mean.nc", "r")
    f_v                           =addfile("/mnt/e/data/vwnd.mon.mean.nc", "r")
    f_t                           =addfile("/mnt/e/data/air.mon.mean.nc", "r")


    u_850                         =f_u->uwnd(ispan(372,731,1),{850},:,:)
    v_850                         =f_v->vwnd(ispan(372,731,1),{850},:,:)
    t_850                         =f_t->air(ispan(372,731,1),{850},:,:)
    u_200                         =f_u->uwnd(ispan(372,731,1),{200},:,:)
    v_200                         =f_v->vwnd(ispan(372,731,1),{200},:,:)
    t_200                         =f_t->air(ispan(372,731,1),{200},:,:)
    printVarSummary(u_850)

    u850avg                       =dim_avg_n_Wrap(u_850, 0)
    v850avg                       =dim_avg_n_Wrap(v_850, 0)
    t850avg                       =dim_avg_n_Wrap(t_850, 0)
    u200avg                       =dim_avg_n_Wrap(u_200, 0)
    v200avg                       =dim_avg_n_Wrap(v_200, 0)
    t200avg                       =dim_avg_n_Wrap(t_200, 0)                     
printVarSummary(u850avg)

    wks                           =gsn_open_wks("png", "/mnt/e/wind_temp")
gsn_define_colormap(wks, "wh-bl-gr-ye-re")
    
    resc1                         =True

    resc1@gsnDraw                 =False
    resc1@gsnFrame                =False

    resc1@mpMaxLonF               =140
    resc1@mpMinLonF               =60
    resc1@mpMaxLatF               =60
    resc1@mpMinLatF               =10

    resc1@cnFillOn                =True
    resc1@cnLinesOn               =False
    resc1@cnLevelSelectionMode    ="AutomaticLevels"

    resc1@gsnLeftString           =""
    resc1@gsnRightString          =""
base1=gsn_csm_contour_map(wks, t850avg(:,:), resc1)
    
    resv1                         =True

    resv1@gsnDraw                 =False
    resv1@gsnFrame                =False
    resv1@vcGlyphStyle                  ="FillArrow"
    resv1@vcFillArrowEdgeColor          ="white"
    resv1@vcFillArrowFillColor          ="black"
    resv1@vcMinMagnitudeF                =1.0
    resv1@vcMinDistanceF                 =0.03
 
    resv1@vcFillArrowEdgeThicknessF      =0.02
  
    resv1@vcFillArrowHeadInteriorXF      =0.25
    resv1@vcFillArrowHeadXF              =0.6
    resv1@vcFillArrowHeadYF              =0.2
    resv1@vcFillArrowWidthF              =0.1
    resv1@vcRefLengthF                   =0.05       ;单位长度箭头在图中的长度
    resv1@vcRefMagnitudeF                =10 

    resv1@vcRefAnnoPerimOn              =False  ;关闭边框
    resv1@vcMinAnnoOn                   =True 
plot1=gsn_csm_vector(wks, u850avg(:,:), v850avg(:,:), resv1)
    

    overlay(base1,plot1)
    draw(base1)
    frame(wks)


    resc2                         =True

    resc2@gsnDraw                 =False
    resc2@gsnFrame                =False

    resc2@mpMaxLonF               =140
    resc2@mpMinLonF               =60
    resc2@mpMaxLatF               =60
    resc2@mpMinLatF               =10

    resc2@cnFillOn                =True
    resc2@cnLinesOn               =False
    resc2@cnLevelSelectionMode    ="AutomaticLevels"

    resc2@gsnLeftString           =""
    resc2@gsnRightString          =""
base2=gsn_csm_contour_map(wks, t200avg(:,:), resc2)


    resv2                         =True

    resv2@gsnDraw                 =False
    resv2@gsnFrame                =False
    resv2@vcGlyphStyle                  ="FillArrow"
    resv2@vcFillArrowEdgeColor          ="white"
    resv2@vcFillArrowFillColor          ="black"
    resv2@vcMinMagnitudeF                =1.0
    resv2@vcMinDistanceF                 =0.03
 
    resv2@vcFillArrowEdgeThicknessF      =0.02
  
    resv2@vcFillArrowHeadInteriorXF      =0.25
    resv2@vcFillArrowHeadXF              =0.6
    resv2@vcFillArrowHeadYF              =0.2
    resv2@vcFillArrowWidthF              =0.1
    resv2@vcRefLengthF                   =0.02       ;单位长度箭头在图中的长度
    resv2@vcRefMagnitudeF                =10 

    resv2@vcRefAnnoPerimOn              =False  ;关闭边框
    resv2@vcMinAnnoOn                   =True 
 
plot2=gsn_csm_vector(wks, u200avg(:,:), v200avg(:,:), resv2)

overlay(base2, plot2)
draw(base2)
frame(wks)    




end