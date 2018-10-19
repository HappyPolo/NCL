;spring_mean_prc

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin 
    
    f                        =addfile("/mnt/e/data/precip.mon.mean.nc", "r")
    prc                      =f->precip(0:359,:,:)
    f_h                      =addfile("/mnt/e/data/hgt.sfc.nc", "r")
    hgt                      =short2flt(f_h->hgt(0,:,:))
    f_d                      =addfile("/mnt/e/data/precip.1212.mean.nc", "r")
    prc_D                    =f_d->precip(2:91,:,:)
    printVarSummary(hgt)
    
    dims                     =dimsizes(prc)
    mlat                     =dims(1)
    nlon                     =dims(2)
    prc_MAM                  =month_to_season(prc, "MAM")
    prc_JJA                  =month_to_season(prc, "JJA")
    prc_SON                  =month_to_season(prc, "SON")
    prc_DJF                  =month_to_season(prc, "DJF")
    

    prc_annaul_mean          =dim_avg_n_Wrap(prc, 0)
    prc_MAM_avg              =dim_avg_n_Wrap(prc_MAM, 0)
    prc_JJA_avg              =dim_avg_n_Wrap(prc_JJA, 0)
    prc_SON_avg              =dim_avg_n_Wrap(prc_SON, 0)
    prc_DJF_avg              =dim_avg_n_Wrap(prc_DJF, 0)
    prc_DJF1_avg             =dim_avg_n_Wrap(prc_D, 0)
    ;plot1                    =new(30, graphic)
    ;plot2                    =new(30, graphic)
    ;plot3                    =new(30, graphic)
    ;plot4                    =new(30, graphic)
printVarSummary(prc_MAM_avg)
    wks                      =gsn_open_wks("pdf", "/mnt/e/pdf/precip_hgt")
    gsn_define_colormap(wks, "wh-bl-gr-ye-re")

    res                      =True

    res@cnLinesOn            =False
    res@cnFillOn             =True

    res@gsnDraw              =False
    res@gsnFrame             =False
    ;res@gsnMaximize          =True


    res@mpMaxLatF            =60
    res@mpMinLatF            =10
    res@mpMaxLonF            =140
    res@mpMinLonF            =60


    ;等值线数值标签
  res@cnLineLabelsOn              =True
  res@cnLineLabelAngleF           =15.0
  res@cnLineLabelBackgroundColor  ="white"
  res@cnLineLabelDensityF         =0.5
  res@cnLineLabelPerimOn          =True
  res@cnLineLabelPerimColor       ="white"


  res@cnHighLabelsOn              =True
  res@cnHighLabelFontHeightF      =0.014  


  ;地图边界线
  res@mpGeophysicalLineColor      ="black"
  res@mpOutlineBoundarySets       ="National"
  res@mpGeophysicalLineDashPattern=16
  res@mpGeophysicalLineDashSegLenF=0.2
  res@mpGeophysicalLineThicknessF =0.5
  res@mpOutlineMaskingOn          =True
  res@mpOutlineOn                 =True
  
  ;绘制色标
  res@lbLabelBarOn                =True
  res@lbOrientation               ="Horizontal"

  res@lbBoxLinesOn                =False
  res@lbBoxLineColor              ="black"
  res@lbBoxLineThicknessF         =1.5
  res@lbBoxLineDashPattern        =16

  res@lbLabelOffsetF              =0.1
  res@lbLabelFontHeightF          =0.01
  res@lbLabelFontColor            ="black"
  res@lbLabelFontThicknessF       =1.5

  res@pmLabelBarParallelPosF      =0.5

  res@pmLabelBarWidthF            =0.45
  res@pmLabelBarHeightF           =0.15

  ;res@gsnLeftString               =""
  ;res@gsnRightString              =""
  ;res@gsnMaximize                 =True

  res@pmTickMarkDisplayMode       ="Always"


  
  res@mpFillOn                    =False
  res@mpGridAndLimbOn             =True
  res@mpGridLineThicknessF        =0.5
  res@mpGridLineDashPattern       =2
  res@mpGridSpacingF              =10
  


;do i=0,29
;    y=1979+i
;    res@gsnLeftString        =(y)+"MAM"
;    plot1(i)=gsn_csm_contour_map(wks, prc_MAM(i,:,:), res)
;    plot2(i)=gsn_csm_contour_map(wks, prc_JJA(i,:,:), res)
;    plot3(i)=gsn_csm_contour_map(wks, prc_SON(i,:,:), res)
;    plot4(i)=gsn_csm_contour_map(wks, prc_DJF(i,:,:), res)
;end do

    resp                      =True
    ;gsn_panel(wks, plot1, (/5,6/), resp)
    ;gsn_panel(wks, plot2, (/5,6/), resp)
    ;gsn_panel(wks, plot3, (/5,6/), resp)

    res2                      =True
    res2@cnLinesOn            =False
    res2@cnFillOn             =True
    res2@mpMaxLatF            =60
    res2@mpMinLatF            =10
    res2@mpMaxLonF            =140
    res2@mpMinLonF            =60

    res2@gsnDraw              =False
    res2@gsnFrame             =False





  ;地图边界线
  res2@mpGeophysicalLineColor      ="black"
  res2@mpOutlineBoundarySets       ="National"
  res2@mpGeophysicalLineDashPattern=0
  res2@mpGeophysicalLineDashSegLenF=0.2
  res2@mpGeophysicalLineThicknessF =0.5
  res2@mpOutlineMaskingOn          =True
  res2@mpOutlineOn                 =True
  
  ;绘制色标
  res2@lbLabelBarOn                =True
  res2@lbOrientation               ="Horizontal"

  res2@lbBoxLinesOn                =False
  res2@lbBoxLineColor              ="black"
  res2@lbBoxLineThicknessF         =1.5
  res2@lbBoxLineDashPattern        =16

  res2@lbLabelOffsetF              =0.1
  res2@lbLabelFontHeightF          =0.01
  res2@lbLabelFontColor            ="black"
  res2@lbLabelFontThicknessF       =1.5

  res2@pmLabelBarParallelPosF      =0.5

  res2@pmLabelBarWidthF            =0.45
  res2@pmLabelBarHeightF           =0.15

  ;res2@gsnLeftString               =""
  ;res2@gsnRightString              =""
  ;res2@gsnMaximize                 =True

  res2@pmTickMarkDisplayMode       ="Always"


  
  res2@mpFillOn                    =False
  res2@mpGridAndLimbOn             =True
  res2@mpGridLineThicknessF        =0.5
  res2@mpGridLineDashPattern       =2
  res2@mpGridSpacingF              =10


    resh                           =True
    resh@gsnDraw                   =False
    resh@gsnFrame                  =False
    resh@mpMaxLatF                 =60
    resh@mpMinLatF                 =10
    resh@mpMinLonF                 =60
    resh@mpMaxLonF                 =140
    resh@cnLinesOn                 =True
    resh@cnFillOn                  =False
    resh@cnLevelSelectionMode      ="ExplicitLevels"
    resh@cnLevels                  =(/2000/)
   

    base1=gsn_csm_contour_map(wks, hgt(:,:), resh)

    ;plot1=gsn_csm_contour_map(wks, prc_MAM_avg, res2)
    plot2=gsn_csm_contour_map(wks, prc_JJA_avg, res2)
    plot3=gsn_csm_contour_map(wks, prc_SON_avg, res2)
    plot4=gsn_csm_contour_map(wks, prc_DJF_avg, res2)
    plot5=gsn_csm_contour_map(wks, prc_annaul_mean, res2)
    plot6=gsn_csm_contour_map(wks, prc_DJF1_avg, res2)

    plot1=gsn_csm_contour(wks, prc_MAM_avg(:,:), res2)
    ;plot2=gsn_csm_contour(wks, prc_JJA_avg, res2)
    ;plot3=gsn_csm_contour(wks, prc_SON_avg, res2)
    ;plot4=gsn_csm_contour(wks, prc_DJF_avg, res2)
    ;plot5=gsn_csm_contour(wks, prc_annaul_mean, res2)
    ;plot6=gsn_csm_contour(wks, prc_DJF1_avg, res2)
    overlay(base1, plot1)
    draw(base1)
    frame(wks)
    ;overlay(base, plot2)
    ;draw(base)
    ;frame(wks)
    ;overlay(base, plot3)
    ;draw(base)
    ;frame(wks)
    ;overlay(base, plot4)
    ;draw(base)
    ;frame(wks)
    ;overlay(base, plot5)
    ;draw(base)
    ;frame(wks)
    ;overlay(base, plot6)
    ;draw(base)
    ;frame(wks)

print("alldown")
;print(p_spring)
end

