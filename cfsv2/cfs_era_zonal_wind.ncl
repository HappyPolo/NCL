load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

;input data
fh=addfile("/home/ys-ug/data/hgt.sfc.nc", "r")
fu=addfile("/home/ys-ug/data/cfsv2/u850.em24.out.nc", "r")
fv=addfile("/home/ys-ug/data/cfsv2/v850.em24.out.nc", "r")
fue=addfile("/home/ys-ug/data/era-interim/uwnd.mon.mean.nc", "r")
fve=addfile("/home/ys-ug/data/era-interim/vwnd.mon.mean.nc", "r")

uwnde=short2flt(fue->u(48:383,30,::-1,:))
vwnde=short2flt(fve->v(48:383,30,::-1,:))

hgt=short2flt(fh->hgt(0,:,:))
uwnd=fu->ugrd(:,0,:,:)
vwnd=fv->vgrd(:,0,:,:)
wks1=gsn_open_wks("png", "/home/ys-ug/fei_cy/CFSv2-ERA_summer")
wks2=gsn_open_wks("png", "/home/ys-ug/fei_cy/CFSv2_summer")
wks3=gsn_open_wks("png", "/home/ys-ug/fei_cy/ERA-Interim_summer")

;========================era-interim==========================
;============================================================

ue_JJA=month_to_season(uwnde, "JJA")
ve_JJA=month_to_season(vwnde, "JJA")
ue_JJA_avg=dim_avg_n_Wrap(ue_JJA, 0)
ve_JJA_avg=dim_avg_n_Wrap(ve_JJA, 0)
;printVarSummary(ue_JJA)
ue_zm=dim_avg_n_Wrap(ue_JJA_avg, 1)
ve_zm=dim_avg_n_Wrap(ve_JJA_avg, 1)
ue_dif_JJA=new((/181,360/), float)
ve_dif_JJA=new((/181,360/), float)
do i=0,180
    do j=0,359
        ue_dif_JJA(i,j)=ue_JJA_avg(i,j)-ue_zm(i)
        ve_dif_JJA(i,j)=ve_JJA_avg(i,j)-ve_zm(i)
    end do
end do 
copy_VarCoords(ue_JJA_avg, ue_dif_JJA)
copy_VarCoords(ve_JJA_avg, ve_dif_JJA)
;==========================================================

;==========================cfsv2===========================
;wind calculation
dim      = dimsizes(uwnd)
u_clm   = onedtond(ndtooned(uwnd),(/dim(0)/12,12,dim(1),dim(2)/))
u_clm!0 = "year"
u_clm!1 = "month"
u_clm!2 = "lat"
u_clm!3 = "lon"
u_clm&year  = ispan(1983, 2010, 1)
copy_VarCoords_1(uwnd(lat|:,lon|:,time|:), u_clm(lat|:,lon|:,year|:,month|:))
u_ann=dim_avg_n_Wrap(u_clm, 0)
delete(dim)

dim    = dimsizes(vwnd)
v_clm  = onedtond(ndtooned(vwnd), (/dim(0)/12, 12, dim(1), dim(2)/))
v_clm!0 = "year"
v_clm!1 = "month"
v_clm!2 = "lat"
v_clm!3 = "lon"
v_clm&year = ispan(1983, 2010, 1)
copy_VarCoords_1(vwnd(lat|:,lon|:,time|:), v_clm(lat|:,lon|:,year|:,month|:))
v_ann=dim_avg_n_Wrap(v_clm, 0)
delete(dim)

xo=fspan(0, 359, 360)
yo=fspan(-90, 90, 181)
lat=fspan(-90, 90, 73)
h=linint2_Wrap(hgt&lon, lat, hgt, True, xo, yo, 0)
h=h(::-1,:)
do i=0,11,1
    u_ann(i,:,:)=where(h.lt.3000, u_ann(i,:,:), u_ann@_FillValue)
    v_ann(i,:,:)=where(h.lt.3000, v_ann(i,:,:), v_ann@_FillValue)
end do

u_jja=(u_ann(5,:,:)+u_ann(6,:,:)+u_ann(7,:,:))/3
v_jja=(v_ann(5,:,:)+v_ann(6,:,:)+v_ann(7,:,:))/3
u_djf=(u_ann(0,:,:)+u_ann(1,:,:)+u_ann(11,:,:))/3
v_djf=(v_ann(0,:,:)+v_ann(1,:,:)+v_ann(11,:,:))/3

u_zm1=dim_avg_n_Wrap(u_jja, 1)
v_zm1=dim_avg_n_Wrap(v_jja, 1)
u_zm2=dim_avg_n_Wrap(u_djf, 1)
v_zm2=dim_avg_n_Wrap(v_djf, 1)

u_dif_jja=new((/181,360/), float)
u_dif_djf=new((/181,360/), float)
v_dif_jja=new((/181,360/), float)
v_dif_djf=new((/181,360/), float)

do i=0,180,1
    do j=0,359,1
        u_dif_jja(i,j)=u_jja(i,j)-u_zm1(i)
        v_dif_jja(i,j)=v_jja(i,j)-v_zm1(i)
        u_dif_djf(i,j)=u_djf(i,j)-u_zm2(i)
        v_dif_djf(i,j)=v_djf(i,j)-v_zm2(i)
    end do 
end do 
copy_VarCoords(uwnd(0,:,:), u_dif_jja)
copy_VarCoords(uwnd(0,:,:), v_dif_jja)

diffu=new((/181,360/), float)
diffv=new((/181,360/), float)
diffu!0 = "lat"
diffv!1 = "lon"
copy_VarCoords(u_dif_jja, diffu)
copy_VarCoords(v_dif_jja, diffv)
diffu=(u_dif_jja-ue_dif_JJA)
diffv=(v_dif_jja-ve_dif_JJA)

;================plot==============================

;streamline
sres                        =True
sres@stLevelSpacingF        =1.0
sres@stMonoLineColor        =True
sres@stMinDistanceF         =0.07
sres@stMinLineSpacingF      =0.007
sres@stArrowLengthF         =0.01
sres@stArrowStride          =5.25
sres@stMinArrowSpacingF     =0.01
sres@stLineThicknessF       =2.5
sres@stLineOpacityF         =0.7
sres@mpFillOn               =True
sres@mpOutlineOn            =True
sres@mpFillColor            ="grey"
sres@mpInlandWaterFillColor ="white"
sres@mpLandFillColor        ="white"
sres@mpOceanFillColor       ="white"
sres@mpGeophysicalLineColor ="black"

sres@gsnAddCyclic =False

sres@tiMainString ="(c) CFSv2-ERA"

sres@mpMaxLonF    =130
sres@mpMinLonF    =50
sres@mpMaxLatF    =70
sres@mpMinLatF    =10
sres@gsnDraw      =False
sres@gsnFrame     =False
res               =sres
res2=sres
res2@tiMainString="(b) ERA-Interim"
res@tiMainString  ="(a) CFSv2"

lnres             =True
lnres@gsFillColor ="grey"
;plot command


base                      =new(2, graphic)
base(0)                   =gsn_csm_streamline_map(wks1, diffu, diffv, sres)
base1=gsn_csm_streamline_map(wks2, u_dif_jja, v_dif_jja, res)
base2=gsn_csm_streamline_map(wks3, ue_dif_JJA, ve_dif_JJA, res2)

plot                      =new(2, graphic)
plot(0)                   =gsn_add_shapefile_polygons(wks1, base(0), "/home/ys-ug/kt/tibetan/tibetan.shp", lnres)
plot1                     =gsn_add_shapefile_polygons(wks2, base1, "/home/ys-ug/kt/tibetan/tibetan.shp", lnres)
plot2                     =gsn_add_shapefile_polygons(wks3, base2, "/home/ys-ug/kt/tibetan/tibetan.shp", lnres)
maximize_output(wks1, False)
maximize_output(wks2, False)
maximize_output(wks3, False)

end 
