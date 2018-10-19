;绘制30年各季节平均降水
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

    f                        =addfile("/mnt/e/data/precip.mon.mean.nc", "r")
    prc                      =f->precip(0:359,:,:)
    prc_MAM                  =month_to_season(prc, "MAM")
    plot                     =new(30, graphic)

wks                      =gsn_open_wks("png", "/mnt/e/ncl/MAM/1")
    gsn_define_colormap(wks, "wh-bl-gr-ye-re")

    res                      =True

    res@cnLinesOn            =False
    res@cnFillOn             =True

    ;res@gsnDraw              =False
    ;res@gsnFrame             =False


    res@mpMaxLatF            =60
    res@mpMinLatF            =10
    res@mpMaxLonF            =140
    res@mpMinLonF            =60


    resp                      =True

  do i=0,29

    year                      =1979+i
    res@gsnLeftString         =(year)+"annual_mean_precip"
    plot(i)=gsn_csm_contour_map_ce(wks, prc_MAM(i,:,:), res)
  end do

print("Alldown")
end