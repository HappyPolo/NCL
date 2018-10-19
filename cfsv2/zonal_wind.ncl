load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

;input data
ft=addfile("/home/ys-ug/data/era-interim/air.mon.mean.nc", "r")
fh=addfile("/home/ys-ug/data/hgt.sfc.nc", "r")
fu=addfile("/home/ys-ug/data/era-interim/uwnd.mon.mean.nc", "r")
fv=addfile("/home/ys-ug/data/era-interim/vwnd.mon.mean.nc", "r")

temp=short2flt(ft->t(0:383,30,:,:))
hgt=short2flt(fh->hgt(0,:,:))
uwnd=short2flt(fu->u(0:383,30,:,:))
vwnd=short2flt(fv->v(0:383,30,:,:))

wks1=gsn_open_wks("png", "/home/ys-ug/fei_cy/zonal_wind_summer")
wks2=gsn_open_wks("png", "/home/ys-ug/fei_cy/zonal_wind_winter")

;pt calculatitudeion
pt=new((/384,181,360/),float)
copy_VarCoords(temp, pt)
pt=temp
pt=pt*(1000/850)^0.286

dim      = dimsizes(pt)
t_clm   = onedtond(ndtooned(pt),(/dim(0)/12,12,dim(1),dim(2)/))
t_clm!0 = "year"
t_clm!1 = "month"
t_clm!2 = "latitude"
t_clm!3 = "longitude"
t_clm&year  = ispan(1979, 2010, 1)
copy_VarCoords_1(pt(latitude|:,longitude|:,time|:), t_clm(latitude|:,longitude|:,year|:,month|:))
t_ann=dim_avg_n_Wrap(t_clm, 0)
delete(dim)

;wind calculatitudeion
dim      = dimsizes(uwnd)
u_clm   = onedtond(ndtooned(uwnd),(/dim(0)/12,12,dim(1),dim(2)/))
u_clm!0 = "year"
u_clm!1 = "month"
u_clm!2 = "latitude"
u_clm!3 = "longitude"
u_clm&year  = ispan(1979, 2010, 1)
copy_VarCoords_1(uwnd(latitude|:,longitude|:,time|:), u_clm(latitude|:,longitude|:,year|:,month|:))
u_ann=dim_avg_n_Wrap(u_clm, 0)
delete(dim)

dim    = dimsizes(vwnd)
v_clm  = onedtond(ndtooned(vwnd), (/dim(0)/12, 12, dim(1), dim(2)/))
v_clm!0 = "year"
v_clm!1 = "month"
v_clm!2 = "latitude"
v_clm!3 = "longitude"
v_clm&year = ispan(1979, 2010, 1)
copy_VarCoords_1(vwnd(latitude|:,longitude|:,time|:), v_clm(latitude|:,longitude|:,year|:,month|:))
v_ann=dim_avg_n_Wrap(v_clm, 0)
delete(dim)

xo=fspan(0, 359, 360)
yo=fspan(-90, 90, 181)
lat=fspan(-90, 90, 73)
h=linint2_Wrap(hgt&lon, lat, hgt, True, xo, yo, 0)

do i=0,11,1
    t_ann(i,:,:)=where(h.lt.3000, t_ann(i,:,:), t_ann@_FillValue)
    u_ann(i,:,:)=where(h.lt.3000, u_ann(i,:,:), u_ann@_FillValue)
    v_ann(i,:,:)=where(h.lt.3000, v_ann(i,:,:), v_ann@_FillValue)
end do

t_jja=(t_ann(5,:,:)+t_ann(6,:,:)+t_ann(7,:,:))/3
t_djf=(t_ann(0,:,:)+t_ann(1,:,:)+t_ann(11,:,:))/3

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

;streamline
sres=True
sres@gsnDraw=False
sres@gsnFrame=False

sres@stLevelSpacingF               =1.0
sres@stMonoLineColor               =True
sres@stMinDistanceF                =0.1
sres@stMinLineSpacingF             =0.007
sres@stArrowLengthF                =0.01
sres@stArrowStride                 =5.25
sres@stMinArrowSpacingF            =0.01
sres@stLineThicknessF              =2.5
sres@stLineOpacityF                =0.7

sres@cnLinesOn=False
sres@cnFillOn=False
sres@cnInfoLabelOn=False
sres@gsnAddCyclic=False

sres@tiMainString="Summer"
sres@cnLevelSelectionMode="ExplicitLevels"
sres@cnLevels=(/3000/)
sres@cnLineLabelsOn=False
sres@cnLineColor="red"
sres@cnLineThicknessF=3
sres@cnLineDashPattern=12

sres@mpMaxLonF=130
sres@mpMinLonF=50
sres@mpMaxLatF=70
sres@mpMinLatF=10

res=sres
res@tiMainString="Winter"

;potential temperature
tres=True 
tres@gsnDraw=False
tres@gsnFrame=False 
tres@cnLineLabelsOn=True 
tres@gsnAddCyclic=False

tres@cnLinesOn=True 
tres@cnFillOn=False 
tres@cnLineDashPattern=2
tres@cnLevelSpacingF=4
tres@stMinDistanceF=0.1
;===============================================================
lnres=True
;========================================================================
;plot command
copy_VarCoords(uwnd(0,:,:), t_jja)
copy_VarCoords(uwnd(0,:,:), t_djf)
copy_VarCoords(uwnd(0,:,:), u_dif_jja)
copy_VarCoords(uwnd(0,:,:), v_dif_jja)
copy_VarCoords(uwnd(0,:,:), u_dif_djf)
copy_VarCoords(uwnd(0,:,:), v_dif_djf)
copy_VarCoords(uwnd(0,:,:), h)

plot=new(2, graphic)
base=new(2, graphic)

base(0)=gsn_csm_streamline_contour_map(wks1, u_dif_jja, v_dif_jja, h, sres)
base(1)=gsn_csm_streamline_contour_map(wks2, u_dif_djf, v_dif_djf, h, res)
plot(0)=gsn_csm_contour(wks1, t_jja, tres)
plot(1)=gsn_csm_contour(wks2, t_djf, tres)

overlay(base(0), plot(0))
;draw(base(0))
;frame(wks)
overlay(base(1), plot(1))
;draw(base(1))
;frame(wks)
;===================================================================================
plot1=gsn_add_shapefile_polygons(wks1, base(0), "/home/ys-ug/kt/tibetan/tibetan.shp", lnres)
plot2=gsn_add_shapefile_polygons(wks2, base(1), "/home/ys-ug/kt/tibetan/tibetan.shp", lnres)
maximize_output(wks1, False)
maximize_output(wks2, False)
;==================================================================================
end 