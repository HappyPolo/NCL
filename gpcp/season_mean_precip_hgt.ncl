
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

    wks                      =gsn_open_wks("pdf", "/mnt/e/pdf/precip_hgt")
    gsn_define_colormap(wks, "wh-bl-gr-ye-re")


    res                      =True

    res@cnLinesOn            =True
    res@cnFillOn             =False
    res@cnLevelSelectionMode ="ExplicitLevels"
    res@cnLevels             =(/2000/)

    res@gsnDraw              =False
    res@gsnFrame             =False
    ;res@gsnMaximize          =True






  ;绘制色标
  res@lbLabelBarOn                =False


  res@gsnLeftString               =""
  res@gsnRightString              =""
  ;res@gsnMaximize                 =True

  res@pmTickMarkDisplayMode       ="Always"


  
  res@mpFillOn                    =False
  res@mpGridAndLimbOn             =True
  res@mpGridLineThicknessF        =0.5
  res@mpGridLineDashPattern       =2
  res@mpGridSpacingF              =10

  
  res2                            =True
  res2@cnLinesOn            =False
  res2@cnFillOn             =True
  res2@gsnDraw              =False
  res2@gsnFrame             =False
    res2@mpMaxLatF            =60
    res2@mpMinLatF            =10
    res2@mpMaxLonF            =140
    res2@mpMinLonF            =60

base=gsn_csm_contour_map(wks, prc_MAM_avg(:,:), res2)

  plot1=gsn_csm_contour(wks, hgt(:,:), res)
  
  plot2=gsn_csm_contour(wks, prc_JJA_avg, res2)
  plot3=gsn_csm_contour(wks, prc_SON_avg, res2)
  plot4=gsn_csm_contour(wks, prc_DJF_avg, res2)
  plot5=gsn_csm_contour(wks, prc_annaul_mean, res2)
  plot6=gsn_csm_contour(wks, prc_DJF1_avg, res2)

    overlay(base, plot1)
    draw(base)
    frame(wks)

print("alldown")
;print(p_spring)
end

