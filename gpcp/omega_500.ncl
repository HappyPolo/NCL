load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin 
    f_o                      =addfile("/mnt/f/data/NCEP/omega.mon.mean.nc", "r")
    f_od                     =addfile("/mnt/f/data/NCEP/omega.DJF.mean.nc", "r")
    f_h                      =addfile("/mnt/f/data/NCEP/hgt.sfc.nc", "r")
    hgt                      =short2flt(f_h->hgt(0,:,:))
    o500                     =f_o->omega(ispan(372,731,1),{500},:,:)
    o500_MAM                      =month_to_season(o500, "MAM")
    o500_JJA                      =month_to_season(o500, "JJA")
    o500_SON                      =month_to_season(o500, "SON")
    o500_DJF                      =f_od->omega(ispan(95, 184, 1),{500},:,:)
    o500_MAM_avg                  =dim_avg_n_Wrap(o500_MAM, 0)
    o500_JJA_avg                  =dim_avg_n_Wrap(o500_JJA, 0)
    o500_SON_avg                  =dim_avg_n_Wrap(o500_SON, 0)
    o500_DJF_avg                  =dim_avg_n_Wrap(o500_DJF, 0)
    o500_mean                     =dim_avg_n_Wrap(o500, 0)

       wks                      =gsn_open_wks("x11", "/mnt/f/png/omega_500")
    gsn_define_colormap(wks, "wh-bl-gr-ye-re")

    res                      =True
    res@cnFillOn             =True
    res@cnLinesOn            =False
    res@cnLevelSelectionMode ="AutomaticLevels"

    ;res@gsnDraw              =False
    ;res@gsnFrame             =False
    res@mpMaxLonF            =140
    res@mpMinLonF            =60
    res@mpMaxLatF            =60
    res@mpMinLatF            =10
    res@pmTickMarkDisplayMode       ="Always"




  
    res@mpFillOn                    =False
    res@mpGridAndLimbOn             =True
    res@mpGridLineThicknessF        =0.5
    res@mpGridLineDashPattern       =2
    res@mpGridSpacingF              =10

    
    res@gsnRightString              =""

    res2                           =True
    res2@gsnDraw                   =False
    res2@gsnFrame                  =False
    res2@gsnLeftString             =""
    res2@gsnRightString            =""
    res2@cnFillOn                  =False
    res2@cnLinesOn                 =True
    res2@mpMaxLonF            =140
    res2@mpMinLonF            =60
    res2@mpMaxLatF            =60
    res2@mpMinLatF            =10
    res2@cnLevelSelectionMode      ="ExplicitLevels"
    res2@cnLevels                  =(/2000/)
    res2@cnLineThicknessF          =2.5
    res2@cnLineColor               ="black"
    res2@cnInfoLabelOn             =False

    plot1=gsn_csm_contour_map(wks, hgt, res2)
    plot2=gsn_csm_contour_map(wks, hgt, res2)
    plot3=gsn_csm_contour_map(wks, hgt, res2)
    plot4=gsn_csm_contour_map(wks, hgt, res2)
    plot5=gsn_csm_contour_map(wks, hgt, res2)

    plot_MAM=gsn_csm_contour(wks, o500_MAM_avg(:,:), res)
    plot_JJA=gsn_csm_contour(wks, o500_JJA_avg(:,:), res)
    plot_SON=gsn_csm_contour(wks, o500_SON_avg(:,:), res)
    plot_DJF=gsn_csm_contour(wks, o500_DJF_avg(:,:), res)
    plot_mean=gsn_csm_contour(wks, o500_mean(:,:), res)

    overlay(plot_MAM, plot1)
    draw(plot1)
    frame(wks)
end